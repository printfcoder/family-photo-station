import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  final _authController = Get.find<AuthController>();
  final _networkController = Get.find<NetworkController>();
  final _backendUrlController = TextEditingController();
  
  bool _isConnecting = false;
  bool _showManualInput = false;
  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _checkBackendConnection() async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = '正在检测后端服务...';
    });

    try {
      // 检测本地8080端口
      await _networkController.checkConnection();
      
      if (_networkController.isConnected) {
        setState(() {
          _connectionStatus = '后端服务连接成功';
        });
        _checkUserStatus();
      } else {
        setState(() {
          _connectionStatus = '未检测到后端服务';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '连接检测失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _checkUserStatus() {
    final authController = Get.find<AuthController>();
    
    if (authController.isAuthenticated) {
      // 用户已登录，跳转到主界面
      context.go(AppRoutes.dashboard);
    } else {
      // 检查是否有用户存在
      _checkIfUsersExist();
    }
  }

  Future<void> _checkIfUsersExist() async {
    setState(() {
      _connectionStatus = '正在检查用户状态...';
    });

    try {
      // TODO: 调用API检查是否有用户存在
      // 这里暂时模拟检查结果
      await Future.delayed(const Duration(seconds: 1));
      
      // 假设没有用户存在，需要创建管理员
      _showUserSetupDialog(hasUsers: false);
    } catch (e) {
      setState(() {
        _connectionStatus = '检查用户状态失败: ${e.toString()}';
      });
    }
  }

  void _showUserSetupDialog({required bool hasUsers}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
                  Navigator.of(context).pop();
                  context.go(AppRoutes.login);
                },
                child: const Text('登录'),
              ),
              const SizedBox(height: 8),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.register);
                },
                child: const Text('创建管理员账户'),
              ),
              const SizedBox(height: 8),
            ],
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enterPreviewMode();
              },
              child: const Text('进入预览模式'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startLocalBackend() async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = '正在启动本地后端服务...';
    });

    try {
      // 使用 Process.run 启动 Go 后端服务
      final result = await Process.run(
        'go',
        ['run', '.'],
        workingDirectory: 'E:\\Projects\\family-photo-station\\station\\backend',
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        setState(() {
          _connectionStatus = '后端服务启动成功，正在检测连接...';
        });
        
        // 等待服务启动
        await Future.delayed(const Duration(seconds: 3));
        
        // 重新检测连接
        await _checkBackendConnection();
      } else {
        setState(() {
          _connectionStatus = '启动后端服务失败: ${result.stderr}';
          _isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '启动后端服务失败: ${e.toString()}';
        _isConnecting = false;
      });
    }
  }

  Future<void> _connectToRemoteBackend() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('连接'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _isConnecting = true;
        _connectionStatus = '正在连接到 $result...';
      });

      try {
        // 更新网络控制器的后端地址
        final networkController = Get.find<NetworkController>();
        networkController.updateBaseUrl(result);
        
        // 检测连接
        await _checkBackendConnection();
      } catch (e) {
        setState(() {
          _connectionStatus = '连接失败: ${e.toString()}';
          _isConnecting = false;
        });
      }
    }
  }

  void _enterPreviewMode() {
    final authController = Get.find<AuthController>();
    
    // 设置为离线模式
    authController.setOfflineMode();
    
    setState(() {
      _connectionStatus = '已进入预览模式，使用本地演示数据';
    });
    
    // 延迟跳转到仪表板
    Future.delayed(const Duration(seconds: 1), () {
      context.go(AppRoutes.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                // 应用图标和标题
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
                  child: Row(
                    children: [
                      if (_isConnecting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _networkController.isConnected 
                              ? Icons.check_circle 
                              : Icons.error_outline,
                          color: _networkController.isConnected 
                              ? Colors.green 
                              : Colors.orange,
                          size: 20,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _connectionStatus.isEmpty 
                              ? '等待连接检测...' 
                              : _connectionStatus,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 操作按钮区域
                if (!_networkController.isConnected && !_isConnecting) ...[
                  // 一键启动本地服务
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startLocalBackend,
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
                      onPressed: () {
                        setState(() {
                          _showManualInput = !_showManualInput;
                        });
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('连接远程后端服务'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  // 手动输入框
                  if (_showManualInput) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _backendUrlController,
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
                        onPressed: () => _connectToRemoteBackend(),
                        child: const Text('连接'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
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
                      onPressed: _enterPreviewMode,
                      icon: const Icon(Icons.visibility),
                      label: const Text('进入预览模式（无需后端）'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
                
                // 重新检测按钮
                if (!_isConnecting) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _checkBackendConnection,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新检测'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}