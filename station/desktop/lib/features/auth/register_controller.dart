import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/controllers/network_controller.dart';
import '../../core/utils/validators.dart';
import '../../core/models/api_models.dart';

class RegisterController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  final ApiService _apiService = Get.find<ApiService>();
  final NetworkController _networkController = Get.find<NetworkController>();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void clearError() {
    errorMessage.value = '';
  }

  Future<void> handleRegister(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = '密码不匹配';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _apiService.register(RegisterRequest(
        username: usernameController.text.trim(),
        email: '', // 使用空字符串
        password: passwordController.text,
        displayName: usernameController.text.trim(), // 使用用户名作为显示名称
        deviceName: 'Desktop App',
        deviceType: 'desktop',
      ));

      // 注册成功，跳转到登录页面
      if (context.mounted) {
        context.go('/login');
        Get.snackbar(
          '注册成功',
          '管理员账户创建成功，请登录',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _networkController.handleNetworkError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateUsername(String? value) {
    return Validators.validateUsername(value);
  }

  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != passwordController.text) {
      return '密码不匹配';
    }
    return null;
  }
}