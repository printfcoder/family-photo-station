import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  
  final authController = Get.find<AuthController>();
  final networkController = Get.find<NetworkController>();

  @override
  void onInit() {
    super.onInit();
    _setupAnimations();
    _listenToAuthChanges();
  }

  void _setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    animationController.forward();
  }

  void _listenToAuthChanges() {
    // Listen for auth state changes
    ever(authController.status.obs, (status) {
      if (status != AuthStatus.loading && status != AuthStatus.initial) {
        // Delay a bit to let animation complete
        Future.delayed(const Duration(milliseconds: 500), () {
          // Router will handle navigation logic automatically
        });
      }
    });
  }

  String getLoadingText(AuthStatus status) {
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

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}