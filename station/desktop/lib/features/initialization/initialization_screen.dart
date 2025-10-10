import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'initialization_controller.dart';
import '../../core/widgets/error_bottom_bar.dart';

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InitializationController());
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App icon和标题
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      '家庭照片站',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      '初始化设置',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 连接状态显示
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Obx(() => Row(
                        children: [
                          if (controller.isConnecting.value)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              controller.networkController.isConnected 
                                  ? Icons.check_circle 
                                  : Icons.error_outline,
                              color: controller.networkController.isConnected 
                                  ? Colors.green 
                                  : Colors.orange,
                              size: 20,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.connectionStatus.value.isEmpty 
                                  ? '等待连接检测...' 
                                  : controller.connectionStatus.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      )),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons区域
                    Obx(() {
                      if (!controller.networkController.isConnected && !controller.isConnecting.value) {
                        return Column(
                          children: [
                            // 一键启动本地服务
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: controller.startLocalBackend,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('一键启动本地后端服务'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // 手动输入地址
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: controller.toggleManualInput,
                                icon: const Icon(Icons.settings),
                                label: const Text('连接远程后端服务'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            
                            // 手动输入框
                            if (controller.showManualInput.value) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.backendUrlController,
                                decoration: const InputDecoration(
                                  labelText: '后端服务地址',
                                  hintText: 'http://192.168.1.100:8080',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.link),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.connectToRemoteBackend,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('连接'),
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // 分割线
                            const Divider(),
                            
                            const SizedBox(height: 16),
                            
                            // 预览模式
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: controller.enterPreviewMode,
                                icon: const Icon(Icons.visibility),
                                label: const Text('进入预览模式（无需后端）'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
                    // 重新检测按钮
                    Obx(() {
                      if (!controller.isConnecting.value) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: controller.checkBackendConnection,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重新检测'),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ),
          
          // 错误底部栏
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ErrorBottomBar(),
          ),
        ],
      ),
    );
  }
}
