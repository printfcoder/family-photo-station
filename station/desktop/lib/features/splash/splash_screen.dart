import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
    
    // 监听认证状态变化
    ever(Get.find<AuthController>().status.obs, (status) {
      if (status != AuthStatus.loading && status != AuthStatus.initial) {
        // 延迟一点时间让动画完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // 路由会自动处理跳转逻辑
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 应用图标
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 60,
                        color: Color(0xFF6364FF),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 应用名称
                    const Text(
                      '家庭照片站',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 副标题
                    const Text(
                      'Family Photo Station',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // 加载指示器
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 加载文本（根据认证状态显示更详细的初始化信息）
                    GetBuilder<AuthController>(
                      builder: (authController) {
                        return Text(
                          _getLoadingText(authController.status),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // 网络状态提示（如果有错误则显示）
                    GetBuilder<NetworkController>(
                      builder: (networkController) {
                        if (networkController.isConnected ||
                            networkController.errorMessage.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          networkController.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  String _getLoadingText(AuthStatus status) {
    switch (status) {
      case AuthStatus.initial:
        return '正在初始化应用...';
      case AuthStatus.loading:
        return '正在验证身份并加载用户信息...';
      case AuthStatus.authenticated:
        return '登录成功，正在进入首页...';
      case AuthStatus.unauthenticated:
        return '未登录，请先完成登录';
      case AuthStatus.error:
        return '初始化失败，请稍后重试';
      case AuthStatus.offline:
        return '无法连接服务器，进入离线模式';
    }
  }
}