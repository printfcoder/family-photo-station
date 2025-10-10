import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/controllers/network_controller.dart';
import '../../core/constants/app_constants.dart';

class InitializationController extends GetxController {
  final _authController = Get.find<AuthController>();
  final networkController = Get.find<NetworkController>();
  final backendUrlController = TextEditingController();
  
  final isConnecting = false.obs;
  final showManualInput = false.obs;
  final connectionStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkBackendConnection();
  }

  @override
  void onClose() {
    backendUrlController.dispose();
    super.onClose();
  }

  Future<void> checkBackendConnection() async {
    isConnecting.value = true;
    connectionStatus.value = '正在检测后端服务...';

    try {
      // 检测本地8080端口
      await networkController.checkConnection();
      
      if (networkController.isConnected) {
        connectionStatus.value = '后端服务连接成功';
        checkUserStatus();
      } else {
        connectionStatus.value = '未检测到后端服务';
      }
    } catch (e) {
      connectionStatus.value = '连接检测失败: ${e.toString()}';
    } finally {
      isConnecting.value = false;
    }
  }

  void checkUserStatus() {
    if (_authController.isAuthenticated) {
      // 用户已登录，跳转到主界面
      Get.context?.go(AppRoutes.dashboard);
    } else {
      // 检查是否有用户存在
      checkIfUsersExist();
    }
  }

  Future<void> checkIfUsersExist() async {
    connectionStatus.value = '正在检查用户状态...';

    try {
      // TODO: 调用API检查是否有用户存在
      // 这里暂时模拟检查结果
      await Future.delayed(const Duration(seconds: 1));
      
      // 假设没有用户存在，需要创建管理员
      showUserSetupDialog(hasUsers: false);
    } catch (e) {
      connectionStatus.value = '检查用户状态失败: ${e.toString()}';
    }
  }

  void showUserSetupDialog({required bool hasUsers}) {
    Get.dialog(
      AlertDialog(
        title: Text(hasUsers ? '用户登录' : '初始化管理员'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hasUsers 
              ? '检测到已有用户，请选择登录方式：' 
              : '未检测到用户，需要创建管理员账户：'),
            const SizedBox(height: 16),
            if (hasUsers) ...[
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.context?.go(AppRoutes.login);
                },
                child: const Text('登录'),
              ),
              const SizedBox(height: 8),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.context?.go(AppRoutes.register);
                },
                child: const Text('创建管理员账户'),
              ),
              const SizedBox(height: 8),
            ],
            TextButton(
              onPressed: () {
                Get.back();
                enterPreviewMode();
              },
              child: const Text('进入预览模式'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> startLocalBackend() async {
    isConnecting.value = true;
    connectionStatus.value = '正在启动本地后端服务...';

    try {
      // 使用 Process.run 启动 Go 后端服务
      final result = await Process.run(
        'go',
        ['run', '.'],
        workingDirectory: 'E:\\Projects\\family-photo-station\\station\\backend',
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        connectionStatus.value = '后端服务启动成功，正在检测连接...';
        
        // 等待服务启动
        await Future.delayed(const Duration(seconds: 3));
        
        // 重新检测连接
        await checkBackendConnection();
      } else {
        connectionStatus.value = '启动后端服务失败: ${result.stderr}';
        isConnecting.value = false;
      }
    } catch (e) {
      connectionStatus.value = '启动后端服务失败: ${e.toString()}';
      isConnecting.value = false;
    }
  }

  Future<void> connectToRemoteBackend() async {
    final controller = TextEditingController();
    
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('连接远程后端'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入远程后端服务器地址：'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.100:8080',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text),
            child: const Text('连接'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      isConnecting.value = true;
      connectionStatus.value = '正在连接到 $result...';

      try {
        // 更新网络控制器的后端地址
        networkController.updateBaseUrl(result);
        
        // 检测连接
        await checkBackendConnection();
      } catch (e) {
        connectionStatus.value = '连接失败: ${e.toString()}';
        isConnecting.value = false;
      }
    }
  }

  void toggleManualInput() {
    showManualInput.value = !showManualInput.value;
  }

  void enterPreviewMode() {
    // 设置为离线模式
    _authController.setOfflineMode();
    
    connectionStatus.value = '已进入预览模式，使用本地演示数据';
    
    // 延迟跳转到仪表板
    Future.delayed(const Duration(seconds: 1), () {
      Get.context?.go(AppRoutes.dashboard);
    });
  }
}