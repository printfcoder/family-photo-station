import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_photo_mobile/routes/app_pages.dart';
import 'package:family_photo_mobile/qr/qr_scan_screen.dart';
import 'package:dio/dio.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

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
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('正在扫描局域网设备...（示例占位）'),
                    SizedBox(height: 12),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}