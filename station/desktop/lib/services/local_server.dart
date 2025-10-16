import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import '../storage/user_data_manager.dart';
import '../controllers/auth_controller.dart';
import '../controllers/invite_controller.dart';
import '../database/users/user_repository.dart';
import '../database/users/user.dart';

class LocalServer extends GetxService {
  HttpServer? _server;
  late final int listenPort;
  late String hostAddress;
  // UDP discovery responder
  RawDatagramSocket? _discoverySocket;
  static const int _discoveryPort = 45454;
  // Presence (heartbeats) storage: username -> device -> lastSeen(ms)
  final Map<String, Map<String, int>> _presence = {};
  static const int _presenceTtlMs = 25000; // 25s TTL considered online
  Timer? _desktopBeatTimer;
  String? _desktopUsername;
  Worker? _authUserWatcher;

  LocalServer({int port = 8000}) {
    listenPort = port;
    hostAddress = '127.0.0.1';
  }

  Future<void> start() async {
    if (_server != null) return;
    hostAddress = await _detectLocalIPv4Async() ?? hostAddress;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, listenPort);
    _server!.listen(_handle);

    // Start UDP discovery responder
    await _startUdpDiscoveryResponder();

    // Bind desktop heartbeat to current authenticated user
    try {
      final auth = Get.find<AuthController>();
      // Watch currentUser changes
      _authUserWatcher?.dispose();
      _authUserWatcher = ever<User?>(auth.currentUser, (user) {
        _startDesktopHeartbeat(user);
      });
      // Initialize with current value if already authenticated
      _startDesktopHeartbeat(auth.currentUser.value);
    } catch (_) {
      // AuthController not available yet; ignore
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    try {
      _discoverySocket?.close();
    } catch (_) {}
    _discoverySocket = null;
  }

  Future<String?> _detectLocalIPv4Async() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: false);
      for (final ni in interfaces) {
        for (final addr in ni.addresses) {
          final ip = addr.address;
          if (_isPrivateIPv4(ip)) return ip;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _startUdpDiscoveryResponder() async {
    try {
      _discoverySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort, reuseAddress: true);
      _discoverySocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = _discoverySocket!.receive();
          if (dg == null) return;
          final msg = utf8.decode(dg.data).trim();
          if (msg == 'FAMILY_PHOTO_DISCOVERY') {
            final payload = jsonEncode({
              'service': 'family_photo_station',
              'host': hostAddress,
              'port': listenPort,
            });
            // Reply to sender
            _discoverySocket!.send(utf8.encode(payload), dg.address, dg.port);
          }
        }
      });
    } catch (_) {
      // ignore discovery socket errors
    }
  }

  bool _isPrivateIPv4(String ip) {
    return ip.startsWith('10.') ||
        ip.startsWith('192.168.') ||
        _is172Private(ip);
  }

  bool _is172Private(String ip) {
    if (!ip.startsWith('172.')) return false;
    final parts = ip.split('.');
    if (parts.length < 2) return false;
    final second = int.tryParse(parts[1]) ?? -1;
    return second >= 16 && second <= 31;
  }

  void _addCors(HttpResponse res) {
    res.headers.add('Access-Control-Allow-Origin', '*');
    res.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
    res.headers.add('Access-Control-Allow-Headers', 'Content-Type');
  }

  Future<void> _handle(HttpRequest req) async {
    _addCors(req.response);
    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      return;
    }

    final path = req.uri.path;
    try {
      if (path == '/health' || path == '/api/v1/health') {
        await _ok(req.response, {'status': 'ok'});
      } else if (path == '/presence/heartbeat' && req.method == 'POST') {
        await _presenceHeartbeat(req);
      } else if (path == '/presence/status' && req.method == 'GET') {
        await _presenceStatus(req);
      } else if (path == '/qr/login/scan' && req.method == 'POST') {
        await _qrLoginScan(req);
      } else if (path == '/qr/login/confirm' && req.method == 'POST') {
        await _qrLoginConfirm(req);
      } else if (path == '/qr/register/scan' && req.method == 'POST') {
        await _qrRegisterScan(req);
      } else if (path == '/qr/register/confirm' && req.method == 'POST') {
        await _qrRegisterConfirm(req);
      } else if (path == '/sync/upload' && req.method == 'POST') {
        await _syncUpload(req);
      } else if (path == '/sync/upload/status' && req.method == 'GET') {
        await _syncUploadStatus(req);
      } else {
        await _notFound(req.response);
      }
    } catch (e) {
      await _error(req.response, '$e');
    }
  }

  String _photoRoot() {
    final base = UserDataManager.instance.appDataDirectory;
    return path.join(base, 'photos');
  }

  Future<Directory> _ensureUserPhotoDir(String username) async {
    final dir = Directory(path.join(_photoRoot(), username));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _syncUploadStatus(HttpRequest req) async {
    final username = req.uri.queryParameters['username'];
    final filename = req.uri.queryParameters['filename'];
    if (username == null || username.isEmpty || filename == null || filename.isEmpty) {
      await _badRequest(req.response, 'missing username or filename');
      return;
    }
    final dir = await _ensureUserPhotoDir(username);
    final finalFile = File(path.join(dir.path, filename));
    final partFile = File(path.join(dir.path, '$filename.part'));
    if (await finalFile.exists()) {
      final stat = await finalFile.stat();
      await _ok(req.response, {
        'completed': true,
        'size': stat.size,
      });
      return;
    }
    if (await partFile.exists()) {
      final stat = await partFile.stat();
      await _ok(req.response, {
        'completed': false,
        'receivedBytes': stat.size,
      });
      return;
    }
    await _ok(req.response, {
      'completed': false,
      'receivedBytes': 0,
    });
  }

  Future<void> _syncUpload(HttpRequest req) async {
    final username = req.uri.queryParameters['username'];
    final filename = req.uri.queryParameters['filename'];
    final offsetStr = req.uri.queryParameters['offset'];
    final totalStr = req.uri.queryParameters['totalSize'];
    final completeStr = req.uri.queryParameters['complete'];
    if (username == null || username.isEmpty || filename == null || filename.isEmpty) {
      await _badRequest(req.response, 'missing username or filename');
      return;
    }
    final offset = int.tryParse(offsetStr ?? '0') ?? 0;
    final totalSize = int.tryParse(totalStr ?? '-1') ?? -1;
    final markComplete = completeStr == '1' || completeStr == 'true';

    try {
      final dir = await _ensureUserPhotoDir(username);
      final partPath = path.join(dir.path, '$filename.part');
      final finalPath = path.join(dir.path, filename);

      // 读取请求体二进制
      final bytes = await req.fold<List<int>>(<int>[], (p, e) {
        p.addAll(e);
        return p;
      });

      // 断点写入
      final raf = await File(partPath).open(mode: FileMode.write);
      await raf.setPosition(offset);
      await raf.writeFrom(bytes);
      await raf.close();

      // 完成标记：重命名为最终文件
      if (markComplete) {
        // 若有已存在最终文件先删除以覆盖
        try {
          final existing = File(finalPath);
          if (await existing.exists()) {
            await existing.delete();
          }
        } catch (_) {}
        await File(partPath).rename(finalPath);
      }

      await _ok(req.response, {
        'status': 'ok',
        'received': offset + bytes.length,
        'completed': markComplete,
        'total': totalSize,
      });
    } catch (e) {
      await _error(req.response, '$e');
    }
  }

  void _recordHeartbeatFor(String username, String device) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final d = device.toLowerCase();
    final m = _presence.putIfAbsent(username, () => <String, int>{});
    m[d] = now;
  }

  void _startDesktopHeartbeat(User? user) {
    // Stop previous timer
    _desktopBeatTimer?.cancel();
    _desktopBeatTimer = null;
    _desktopUsername = null;
    if (user == null) return;
    _desktopUsername = user.username;
    // Immediately record one beat
    _recordHeartbeatFor(user.username, 'desktop');
    // Start periodic heartbeats
    _desktopBeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_desktopUsername != null) {
        _recordHeartbeatFor(_desktopUsername!, 'desktop');
      }
    });
  }

  Future<void> _presenceHeartbeat(HttpRequest req) async {
    final data = await _readJson(req);
    final username = data['username'] as String?;
    final device = (data['deviceType'] as String?) ?? (data['device'] as String?);
    if (username == null || username.isEmpty || device == null || device.isEmpty) {
      await _badRequest(req.response, 'missing username or device');
      return;
    }
    _recordHeartbeatFor(username, device);
    await _ok(req.response, {'status': 'ok'});
  }

  Future<void> _presenceStatus(HttpRequest req) async {
    // Build status for all known users in DB
    Map<String, dynamic> buildUserStatus(User u) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final m = _presence[u.username] ?? const {};
      final lastDesktop = m['desktop'];
      final lastMobile = m['mobile'];
      final desktopOnline = lastDesktop != null && (now - lastDesktop) <= _presenceTtlMs;
      final mobileOnline = lastMobile != null && (now - lastMobile) <= _presenceTtlMs;
      return {
        'username': u.username,
        'displayName': u.displayName,
        'isAdmin': u.isAdmin,
        'online': {
          'desktop': desktopOnline,
          'mobile': mobileOnline,
        },
        'lastSeen': {
          'desktop': lastDesktop,
          'mobile': lastMobile,
        }
      };
    }

    try {
      final auth = Get.find<AuthController>();
      final repo = auth.users;
      final users = await repo.listAll();
      final payload = users.map(buildUserStatus).toList();
      await _ok(req.response, {'users': payload});
    } catch (e) {
      await _error(req.response, '$e');
    }
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest req) async {
    final content = await utf8.decoder.bind(req).join();
    if (content.isEmpty) return {};
    final data = jsonDecode(content);
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<void> _ok(HttpResponse res, Object body) async {
    res.statusCode = HttpStatus.ok;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(body));
    await res.close();
  }

  Future<void> _badRequest(HttpResponse res, String message) async {
    res.statusCode = HttpStatus.badRequest;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode({'error': message}));
    await res.close();
  }

  Future<void> _notFound(HttpResponse res) async {
    res.statusCode = HttpStatus.notFound;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode({'error': 'not_found'}));
    await res.close();
  }

  Future<void> _error(HttpResponse res, String message) async {
    res.statusCode = HttpStatus.internalServerError;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode({'error': message}));
    await res.close();
  }

  Future<void> _qrLoginScan(HttpRequest req) async {
    final data = await _readJson(req);
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      await _badRequest(req.response, 'missing token');
      return;
    }
    final auth = Get.find<AuthController>();
    if (auth.qrToken.value != token) {
      await _badRequest(req.response, 'invalid token');
      return;
    }
    auth.markQrScanned();
    await _ok(req.response, {'status': 'scanned'});
  }

  Future<void> _qrLoginConfirm(HttpRequest req) async {
    final data = await _readJson(req);
    final token = data['token'] as String?;
    final username = data['username'] as String?;
    if (token == null || token.isEmpty || username == null || username.isEmpty) {
      await _badRequest(req.response, 'missing token or username');
      return;
    }
    final auth = Get.find<AuthController>();
    if (auth.qrToken.value != token) {
      await _badRequest(req.response, 'invalid token');
      return;
    }
    final ok = await auth.confirmQrLoginAs(username);
    if (!ok) {
      await _badRequest(req.response, 'user not found');
      return;
    }
    await _ok(req.response, {'status': 'logged_in', 'username': username});
  }

  Future<void> _qrRegisterScan(HttpRequest req) async {
    final data = await _readJson(req);
    final token = data['token'] as String?;
    final invite = Get.find<InviteController>();
    if (token == null || token.isEmpty || invite.regToken.value != token) {
      await _badRequest(req.response, 'invalid token');
      return;
    }
    invite.markRegScanned();
    await _ok(req.response, {'status': 'scanned'});
  }

  Future<void> _qrRegisterConfirm(HttpRequest req) async {
    final data = await _readJson(req);
    final token = data['token'] as String?;
    final username = data['username'] as String?;
    final displayName = data['displayName'] as String?;
    final password = data['password'] as String?;
    if (token == null || token.isEmpty || username == null || username.isEmpty) {
      await _badRequest(req.response, 'missing token or username');
      return;
    }
    final invite = Get.find<InviteController>();
    if (invite.regToken.value != token) {
      await _badRequest(req.response, 'invalid token');
      return;
    }
    if (password == null || password.isEmpty) {
      await _badRequest(req.response, 'missing password');
      return;
    }

    final auth = Get.find<AuthController>();
    final repo = auth.users;
    final exists = await repo.findByUsername(username);
    if (exists != null) {
      await _badRequest(req.response, 'username exists');
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final pwdHash = sha256.convert(utf8.encode(password)).toString();
    final user = User(
      username: username,
      displayName: displayName,
      isAdmin: false,
      passwordHash: pwdHash,
      createdAt: now,
    );
    final inserted = await repo.insert(user);
    invite.completeRegister();
    await _ok(req.response, {
      'status': 'registered',
      'user': {
        'id': inserted.id,
        'username': inserted.username,
        'displayName': inserted.displayName,
        'isAdmin': inserted.isAdmin,
        'createdAt': inserted.createdAt,
      }
    });
  }
}