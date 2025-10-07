import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:family_photo_mobile/core/models/user.dart';
import 'package:family_photo_mobile/core/services/api_service.dart';
import 'package:family_photo_mobile/core/services/storage_service.dart';

// 认证状态
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  final StorageService _storageService = StorageService.instance;

  // 响应式状态
  final Rx<AuthStatus> _status = AuthStatus.initial.obs;
  final Rxn<User> _user = Rxn<User>();
  final RxnString _error = RxnString();

  // Getters
  AuthStatus get status => _status.value;
  User? get user => _user.value;
  String? get error => _error.value;
  
  // 便捷的getter
  bool get isAuthenticated => _status.value == AuthStatus.authenticated;
  bool get isLoading => _status.value == AuthStatus.loading;
  bool get isAdmin => _user.value?.role == UserRole.admin;
  bool get canUpload => _user.value != null && _user.value!.isActive;
  double get storageUsage => _user.value?.stats?.storageUsagePercentage ?? 0.0;
  UserStats? get userStats => _user.value?.stats;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      _status.value = AuthStatus.loading;
      
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _storageService.getUser();
        if (user != null) {
          _status.value = AuthStatus.authenticated;
          _user.value = user;
          _error.value = null;
          return;
        }
      }
      
      _status.value = AuthStatus.unauthenticated;
      _user.value = null;
      _error.value = null;
    } catch (e) {
      _status.value = AuthStatus.error;
      _error.value = e.toString();
    }
  }

  // 登录
  Future<bool> login(String username, String password) async {
    try {
      _status.value = AuthStatus.loading;
      _error.value = null;
      
      final response = await _apiClient.login(username, password);
      
      // 保存认证信息
      await _storageService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await _storageService.saveUser(response.user);
      
      _status.value = AuthStatus.authenticated;
      _user.value = response.user;
      _error.value = null;
      
      return true;
    } catch (e) {
      _status.value = AuthStatus.error;
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 注册
  Future<bool> register(String username, String email, String password, {String? displayName}) async {
    try {
      _status.value = AuthStatus.loading;
      _error.value = null;
      
      final response = await _apiClient.register(username, email, password, displayName: displayName);
      
      // 保存认证信息
      await _storageService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await _storageService.saveUser(response.user);
      
      _status.value = AuthStatus.authenticated;
      _user.value = response.user;
      _error.value = null;
      
      return true;
    } catch (e) {
      _status.value = AuthStatus.error;
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      // 调用API登出
      await _apiClient.api.logout();
    } catch (e) {
      // 即使API调用失败，也要清除本地数据
      debugPrint('Logout API call failed: $e');
    } finally {
      // 清除本地数据
      await _storageService.clearAll();
      
      _status.value = AuthStatus.unauthenticated;
      _user.value = null;
      _error.value = null;
    }
  }

  // 更新用户信息
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    try {
      final updatedUser = await _apiClient.api.updateProfile(request);
      
      // 更新本地存储
      await _storageService.saveUser(updatedUser);
      
      _user.value = updatedUser;
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 修改密码
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      await _apiClient.api.changePassword(request);
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 刷新用户信息
  Future<void> refreshUserProfile() async {
    try {
      final user = await _apiClient.api.getUserProfile();
      await _storageService.saveUser(user);
      _user.value = user;
    } catch (e) {
      debugPrint('Failed to refresh user profile: $e');
    }
  }

  // 清除错误
  void clearError() {
    _error.value = null;
  }

  // 获取错误消息
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}