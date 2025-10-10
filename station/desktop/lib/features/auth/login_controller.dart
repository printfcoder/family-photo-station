import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_service.dart';
import '../../core/controllers/network_controller.dart';
import '../../core/utils/validators.dart';
import '../../core/models/api_models.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxString errorMessage = ''.obs;
  
  final ApiService _apiService = Get.find<ApiService>();
  final NetworkController _networkController = Get.find<NetworkController>();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearError() {
    errorMessage.value = '';
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _apiService.login(LoginRequest(
        username: usernameController.text.trim(),
        password: passwordController.text,
        deviceName: 'Desktop App',
        deviceType: 'desktop',
      ));

      // 登录成功，跳转到仪表板
      if (context.mounted) {
        context.go('/dashboard');
        Get.snackbar(
          '登录成功',
          '欢迎回来！',
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
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    return null;
  }
}