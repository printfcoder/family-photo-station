import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_mobile/core/constants/app_constants.dart';
import 'package:family_photo_mobile/core/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      Get.snackbar(
        '提示',
        '请同意服务条款和隐私政策',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authController = Get.find<AuthController>();
    final success = await authController.register(
      username,
      email,
      password,
    );

    if (success && mounted) {
      Get.snackbar(
        '成功',
        '注册成功！欢迎加入家庭照片站',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // 注册成功后自动跳转到首页
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final isLoading = authController.status == AuthStatus.loading;

        // 监听错误状态
        if (authController.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              '错误',
              authController.error!,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            authController.clearError();
          });
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo和标题
                          _buildHeader(),
                          const SizedBox(height: 48),
                          
                          // 注册表单
                          _buildRegisterForm(),
                          const SizedBox(height: 24),
                          
                          // 服务条款
                          _buildTermsAgreement(),
                          const SizedBox(height: 32),
                          
                          // 注册按钮
                          _buildRegisterButton(isLoading),
                          const SizedBox(height: 32),
                          
                          // 分割线
                          _buildDivider(),
                          const SizedBox(height: 32),
                          
                          // 登录链接
                          _buildLoginLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.photo_library_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        // 标题
        Text(
          '创建账户',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // 副标题
        Text(
          '加入家庭照片站，开始您的美好回忆之旅',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // 用户名输入框
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: '用户名',
            prefixIcon: Icon(Icons.person_outline),
            hintText: '请输入用户名',
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入用户名';
            }
            if (value.trim().length < 3) {
              return '用户名长度至少3位';
            }
            if (!RegExp(AppConstants.usernameRegex).hasMatch(value.trim())) {
              return '用户名只能包含字母、数字和下划线';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 邮箱输入框
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: '邮箱地址',
            prefixIcon: Icon(Icons.email_outlined),
            hintText: '请输入邮箱地址',
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入邮箱地址';
            }
            if (!RegExp(AppConstants.emailRegex).hasMatch(value.trim())) {
              return '请输入有效的邮箱地址';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 密码输入框
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: '密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            hintText: '请输入密码（至少8位）',
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入密码';
            }
            if (value.length < 8) {
              return '密码长度至少8位';
            }
            if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
              return '密码必须包含字母和数字';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 确认密码输入框
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: '确认密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            hintText: '请再次输入密码',
          ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请确认密码';
            }
            if (value != _passwordController.text) {
              return '两次输入的密码不一致';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: '我已阅读并同意 '),
                  TextSpan(
                    text: '服务条款',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' 和 '),
                  TextSpan(
                    text: '隐私政策',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '创建账户',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
             color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
           ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            '立即登录',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}