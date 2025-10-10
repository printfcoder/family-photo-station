import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'register_controller.dart';
import '../../core/widgets/error_bottom_bar.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    
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
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SVG插画
                        Container(
                          width: 300,
                          height: 225,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SvgPicture.asset(
                              'assets/images/family_illustration.svg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '加入我们的大家庭',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '开始您的美好照片管理之旅',
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
              
              // 右侧注册表单
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
                                '创建管理员账户',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 8),
                              Text(
                                '请填写以下信息',
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
                                  hintText: '3-20个字符，支持字母、数字和下划线',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // 密码输入框
                              Obx(() => TextFormField(
                                controller: controller.passwordController,
                                validator: controller.validatePassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '密码',
                                  hintText: '至少8位字符',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                textInputAction: TextInputAction.next,
                              )),
                              
                              const SizedBox(height: 24),
                              
                              // 确认密码输入框
                              Obx(() => TextFormField(
                                controller: controller.confirmPasswordController,
                                validator: controller.validateConfirmPassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '确认密码',
                                  hintText: '请再次输入密码',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => controller.handleRegister(context),
                              )),
                              
                              const SizedBox(height: 32),
                              
                              // 注册按钮
                              Obx(() => ElevatedButton(
                                onPressed: controller.isLoading.value 
                                    ? null 
                                    : () => controller.handleRegister(context),
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
                                        '创建管理员',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              )),
                              
                              const SizedBox(height: 24),
                              
                              // 登录链接
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '已有账户？',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text('立即登录'),
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
