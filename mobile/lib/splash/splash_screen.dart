import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_photo_mobile/routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showIntro = false;

  @override
  void initState() {
    super.initState();
    _checkLoginAndRoute();
  }

  Future<void> _checkLoginAndRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final firstRunDone = prefs.getBool('first_run_completed') ?? false;
    final host = prefs.getString('station.host');
    final port = prefs.getInt('station.port');
    if (firstRunDone && host != null && port != null) {
      Get.offAllNamed(Routes.home);
    } else {
      setState(() {
        _showIntro = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showIntro) {
      // 轻量占位，避免空白闪烁
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF3F7), Color(0xFFE5F1EE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // 轨道头像区域
                const _OrbitAvatars(),
                const SizedBox(height: 32),
                // 标题文案（部分渐变）
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _GradientText(
                        'Connect',
                        gradient: LinearGradient(colors: [Color(0xFF66E88C), Color(0xFF3EC2F7)]),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'With Family Photo Station',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Share memories with the ones who matter most',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Get Started 按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Get.toNamed(Routes.discovery),
                    child: const Text('Get Started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 文本渐变
class _GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;
  const _GradientText(this.text, {required this.gradient, required this.style});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

/// 轨道上的网络头像
class _OrbitAvatars extends StatelessWidget {
  const _OrbitAvatars();

  // 使用在线占位图（自然/风景类）以避免人物隐私问题
  List<String> get _images => const [
        'https://picsum.photos/seed/family1/120',
        'https://picsum.photos/seed/family2/120',
        'https://picsum.photos/seed/family3/120',
        'https://picsum.photos/seed/family4/120',
        'https://picsum.photos/seed/family5/120',
        'https://picsum.photos/seed/family6/120',
        'https://picsum.photos/seed/family7/120',
      ];

  @override
  Widget build(BuildContext context) {
    const double size = 280;
    const double centerSize = 90;
    const double orbitRadius = 110;
    const double avatarSize = 42;
    final angles = List<double>.generate(_images.length, (i) => i * (360.0 / _images.length));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外部淡淡的圆环
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 30, spreadRadius: 2),
              ],
            ),
          ),
          // 中心头像占位
          Container(
            width: centerSize,
            height: centerSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(centerSize / 2),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/family-center/240'),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 20, spreadRadius: 1),
              ],
            ),
          ),
          // 轨道上的小头像
          for (int i = 0; i < _images.length; i++)
            Positioned(
              left: (size / 2) + orbitRadius * math.cos(_deg2rad(angles[i])) - avatarSize / 2,
              top: (size / 2) + orbitRadius * math.sin(_deg2rad(angles[i])) - avatarSize / 2,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  image: DecorationImage(image: NetworkImage(_images[i]), fit: BoxFit.cover),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 10),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _deg2rad(double deg) => deg * math.pi / 180.0;
}