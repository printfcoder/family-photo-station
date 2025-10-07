import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/features/splash/splash_screen.dart';
import 'package:family_photo_desktop/features/auth/login_screen.dart';
import 'package:family_photo_desktop/features/auth/register_screen.dart';
import 'package:family_photo_desktop/features/dashboard/dashboard_screen.dart';
import 'package:family_photo_desktop/features/photos/photos_screen.dart';
import 'package:family_photo_desktop/features/albums/albums_screen.dart';
import 'package:family_photo_desktop/features/users/users_screen.dart';
import 'package:family_photo_desktop/features/settings/settings_screen.dart';
import 'package:family_photo_desktop/features/error/error_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authController = Get.find<AuthController>();
      final isAuthenticated = authController.isAuthenticated;
      final isLoading = authController.status == AuthStatus.loading || 
                       authController.status == AuthStatus.initial;
      
      // 如果正在加载，显示启动页
      if (isLoading) {
        return AppRoutes.splash;
      }
      
      // 如果未认证且不在认证相关页面，跳转到登录页
      if (!isAuthenticated && 
          !state.matchedLocation.startsWith('/login') && 
          !state.matchedLocation.startsWith('/register') &&
          state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.login;
      }
      
      // 如果已认证且在认证相关页面，跳转到仪表板
      if (isAuthenticated && 
          (state.matchedLocation.startsWith('/login') || 
           state.matchedLocation.startsWith('/register') ||
           state.matchedLocation == AppRoutes.splash)) {
        return AppRoutes.dashboard;
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
      
      // 主要功能页面 - 桌面端使用仪表板作为主页
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // 照片管理页面
      GoRoute(
        path: AppRoutes.photos,
        name: 'photos',
        builder: (context, state) => const PhotosScreen(),
      ),
      
      // 相册管理页面
      GoRoute(
        path: AppRoutes.albums,
        name: 'albums',
        builder: (context, state) => const AlbumsScreen(),
      ),
      
      // 用户管理页面
      GoRoute(
        path: AppRoutes.users,
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      
      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('返回仪表板'),
            ),
          ],
        ),
      ),
    ),
  );
}