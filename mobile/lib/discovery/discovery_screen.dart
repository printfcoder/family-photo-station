import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_photo_mobile/routes/app_pages.dart';
import 'package:family_photo_mobile/qr/qr_scan_screen.dart';
import 'package:dio/dio.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryStation {
  final String host;
  final int port;
  final String? name;
  DateTime lastSeen;
  _DiscoveryStation({required this.host, required this.port, this.name, DateTime? lastSeen})
      : lastSeen = lastSeen ?? DateTime.now();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  static const int _discoveryPort = 45454; // align with desktop responder
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  bool _scanning = false;
  final List<_DiscoveryStation> _stations = [];
  final Set<String> _seenKeys = {};

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    _socket?.close();
    super.dispose();
  }

  Future<void> _startScan() async {
    _broadcastTimer?.cancel();
    _socket?.close();
    setState(() {
      _scanning = true;
      _stations.clear();
      _seenKeys.clear();
    });
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      _socket = socket;
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = socket.receive();
          if (dg == null) return;
          final data = dg.data;
          try {
            final payload = json.decode(utf8.decode(data));
            if (payload is Map && payload['service'] == 'family_photo_station') {
              final host = (payload['host'] as String?) ?? dg.address.address;
              final port = payload['port'] is int ? payload['port'] as int : int.tryParse('${payload['port']}') ?? 0;
              if (host.isNotEmpty && port > 0) {
                final key = '$host:$port';
                String? name;
                final rawName = payload['name'];
                if (rawName is String && rawName.isNotEmpty) name = rawName;
                if (!_seenKeys.contains(key)) {
                  _seenKeys.add(key);
                  setState(() {
                    _stations.add(_DiscoveryStation(host: host, port: port, name: name));
                  });
                } else {
                  final idx = _stations.indexWhere((e) => '${e.host}:${e.port}' == key);
                  if (idx >= 0) _stations[idx].lastSeen = DateTime.now();
                }
              }
            }
          } catch (_) {
            // ignore non-JSON responses
          }
        }
      });

      // send initial and periodic broadcast discovery probe
      void sendProbe() {
        final bytes = utf8.encode('FAMILY_PHOTO_DISCOVERY');
        socket.send(bytes, InternetAddress('255.255.255.255'), _discoveryPort);
      }
      sendProbe();
      _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) => sendProbe());

      // Stop scanning indicator after a short period, but keep listening
      Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => _scanning = false);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('自动发现初始化失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '8000');
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现家庭照片站'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('已连接家庭WiFi后，自动发现照片站或通过二维码快速连接'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('手动连接'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: hostCtrl,
                      decoration: const InputDecoration(labelText: '照片站 IP 地址'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: portCtrl,
                      decoration: const InputDecoration(labelText: '端口号'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final host = hostCtrl.text.trim();
                        final port = int.tryParse(portCtrl.text.trim());
                        if (host.isEmpty || port == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入有效的 IP 和端口')),
                          );
                          return;
                        }
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('station.host', host);
                        await prefs.setInt('station.port', port);
                        Get.toNamed(Routes.register);
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('连接照片站'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('二维码快速连接'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.to<String>(() => const QrScanScreen());
                        if (result == null || result.isEmpty) return;
                        final uri = Uri.tryParse(result);
                        if (uri == null || uri.scheme != 'familyphoto') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未识别的设备二维码')));
                          return;
                        }

                        final host = uri.queryParameters['host'];
                        final port = int.tryParse(uri.queryParameters['port'] ?? '');

                        if (host == null || port == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('二维码缺少必要信息')));
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('station.host', host);
                        await prefs.setInt('station.port', port);

                        if (uri.host == 'register') {
                          final token = uri.queryParameters['token'] ?? uri.queryParameters['register_token'];
                          if (token == null || token.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册二维码缺少token')));
                            return;
                          }
                          await prefs.setString('qr.token', token);
                          try {
                            final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3), receiveTimeout: const Duration(seconds: 3)));
                            await dio.post('http://$host:$port/qr/register/scan', data: {'token': token});
                          } catch (_) {}
                          Get.toNamed(Routes.register);
                          return;
                        }

                        if (uri.host == 'login') {
                          final token = uri.queryParameters['token'];
                          if (token == null || token.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录二维码缺少token')));
                            return;
                          }
                          try {
                            final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3), receiveTimeout: const Duration(seconds: 3)));
                            await dio.post('http://$host:$port/qr/login/scan', data: {'token': token});
                          } catch (_) {}
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已扫码登录，请到桌面端确认')));
                          return;
                        }

                        if (uri.host == 'station') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已连接到照片站，请在桌面端“用户管理→二维码添加用户”生成注册二维码后再扫描')));
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('未识别的设备二维码')));
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('扫描设备二维码'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新扫描局域网'),
                ),
                const SizedBox(width: 12),
                if (_scanning) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  const Text('正在扫描...')
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _stations.isEmpty
                  ? Center(
                      child: Text(_scanning ? '正在扫描局域网设备...' : '未发现设备，可尝试手动连接或二维码'),
                    )
                  : ListView.separated(
                      itemCount: _stations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = _stations[index];
                        return ListTile(
                          leading: const Icon(Icons.devices_other),
                          title: Text(s.name?.isNotEmpty == true ? s.name! : '家庭照片站'),
                          subtitle: Text('${s.host}:${s.port}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('station.host', s.host);
                            await prefs.setInt('station.port', s.port);
                            Get.toNamed(Routes.register);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}