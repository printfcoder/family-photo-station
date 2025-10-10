import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'login_controller.dart';
import '../../core/widgets/error_bottom_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // 左侧装饰区域
              Expanded(
                flex: 3,
                child: Container(
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
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 120,
                          color: Colors.white,
                        ),
                        SizedBox(height: 24),
                        Text(
                          '家庭照片站',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '管理和分享您的珍贵回忆',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 右侧登录表单
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 标题
                              Text(
                                '欢迎回来',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 8),
                              Text(
                                '请登录您的账户',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 48),
                              
                              // 错误信息显示
                              Obx(() {
                                if (controller.errorMessage.value.isNotEmpty) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            controller.errorMessage.value,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: controller.clearError,
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(context).colorScheme.error,
                                            size: 18,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              
                              // 用户名输入框
                              TextFormField(
                                controller: controller.usernameController,
                                validator: controller.validateUsername,
                                decoration: const InputDecoration(
                                  labelText: '用户名',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 密码输入框
                              TextFormField(
                                controller: controller.passwordController,
                                validator: controller.validatePassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '密码',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => controller.handleLogin(context),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 记住我选项
                              Row(
                                children: [
                                  Obx(() => Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: controller.toggleRememberMe,
                                  )),
                                  const Text('记住我'),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // 登录按钮
                              Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value 
                                    ? null 
                                    : () => controller.handleLogin(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        '登录',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              )),
                              
                              const SizedBox(height: 24),
                              
                              // 注册链接
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '还没有账户？',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/register'),
                                    child: const Text('立即注册'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
