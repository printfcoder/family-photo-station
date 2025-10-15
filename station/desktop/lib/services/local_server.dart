import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/invite_controller.dart';
import '../database/users/user_repository.dart';
import '../database/users/user.dart';

class LocalServer extends GetxService {
  HttpServer? _server;
  late final int listenPort;
  late String hostAddress;

  LocalServer({int port = 8000}) {
    listenPort = port;
    hostAddress = '127.0.0.1';
  }

  Future<void> start() async {
    if (_server != null) return;
    hostAddress = await _detectLocalIPv4Async() ?? hostAddress;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, listenPort);
    _server!.listen(_handle);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
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
      if (path == '/health') {
        await _ok(req.response, {'status': 'ok'});
      } else if (path == '/qr/login/scan' && req.method == 'POST') {
        await _qrLoginScan(req);
      } else if (path == '/qr/login/confirm' && req.method == 'POST') {
        await _qrLoginConfirm(req);
      } else if (path == '/qr/register/scan' && req.method == 'POST') {
        await _qrRegisterScan(req);
      } else if (path == '/qr/register/confirm' && req.method == 'POST') {
        await _qrRegisterConfirm(req);
      } else {
        await _notFound(req.response);
      }
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