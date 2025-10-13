import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_mobile/core/constants/app_constants.dart';
import 'package:family_photo_mobile/features/splash/splash_screen.dart';
import 'package:family_photo_mobile/features/auth/login_screen.dart';
import 'package:family_photo_mobile/features/auth/register_screen.dart';
import 'package:family_photo_mobile/features/home/home_screen.dart';
import 'package:family_photo_mobile/features/settings/settings_screen.dart';
import 'package:family_photo_mobile/features/upload/upload_screen.dart';
import 'package:family_photo_mobile/features/error/error_screen.dart';
import 'package:family_photo_mobile/features/device_discovery/device_discovery_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.deviceDiscovery,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // 简化重定向逻辑，直接返回设备发现页
      // 后续可以添加更复杂的路由逻辑
      if (state.matchedLocation != AppRoutes.deviceDiscovery &&
          state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.deviceDiscovery;
      }
      
      return null;
    },
    routes: [
      // 启动页
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 设备发现
      GoRoute(
        path: AppRoutes.deviceDiscovery,
        name: 'deviceDiscovery',
        builder: (context, state) => const DeviceDiscoveryScreen(),
      ),
      
      // 认证相关
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // 主要功能页面
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // 上传页面
      GoRoute(
        path: AppRoutes.upload,
        name: 'upload',
        builder: (context, state) => const UploadScreen(),
      ),
      
      // 错误页面
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final error = state.extra as String? ?? '未知错误';
          return ErrorScreen(error: error);
        },
      ),
    ],
    
    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '页面未找到',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '路径: ${state.matchedLocation}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}