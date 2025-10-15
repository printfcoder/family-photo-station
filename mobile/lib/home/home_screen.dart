import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? host;
  int? port;
  String? nickname;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      host = prefs.getString('station.host');
      port = prefs.getInt('station.port');
      nickname = prefs.getString('user.nickname');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家庭照片站')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('欢迎，${nickname ?? '用户'}'),
            const SizedBox(height: 12),
            Text('已连接：${host ?? '未知主机'}:${port ?? 0}'),
            const SizedBox(height: 24),
            const Text('这里是首页占位，后续进入上传/浏览等功能'),
          ],
        ),
      ),
    );
  }
}