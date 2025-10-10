import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/storage_service.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final StorageService _storage = StorageService();

  // Observable settings
  final RxBool _isDarkMode = false.obs;
  final RxBool _enableNotifications = true.obs;
  final RxBool _autoBackup = false.obs;
  final RxBool _highQualityUpload = false.obs;
  final RxString _language = 'zh'.obs;

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  bool get enableNotifications => _enableNotifications.value;
  bool get autoBackup => _autoBackup.value;
  bool get highQualityUpload => _highQualityUpload.value;
  String get language => _language.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final isDarkMode = await _storage.getSetting<bool>('isDarkMode') ?? false;
      final enableNotifications = await _storage.getSetting<bool>('enableNotifications') ?? true;
      final autoBackup = await _storage.getSetting<bool>('autoBackup') ?? false;
      final highQualityUpload = await _storage.getSetting<bool>('highQualityUpload') ?? false;
      final language = await _storage.getSetting<String>('language') ?? 'zh';

      _isDarkMode.value = isDarkMode;
      _enableNotifications.value = enableNotifications;
      _autoBackup.value = autoBackup;
      _highQualityUpload.value = highQualityUpload;
      _language.value = language;
    } catch (e) {
      debugPrint('加载设置失败: $e');
    }
  }

  Future<void> updateDarkMode(bool value) async {
    try {
      await _storage.saveSetting('isDarkMode', value);
      _isDarkMode.value = value;
    } catch (e) {
      debugPrint('更新深色模式设置失败: $e');
    }
  }

  Future<void> updateNotifications(bool value) async {
    try {
      await _storage.saveSetting('enableNotifications', value);
      _enableNotifications.value = value;
    } catch (e) {
      debugPrint('更新通知设置失败: $e');
    }
  }

  Future<void> updateLanguage(String value) async {
    try {
      await _storage.saveSetting('language', value);
      _language.value = value;
    } catch (e) {
      debugPrint('更新语言设置失败: $e');
    }
  }

  Future<void> updateAutoBackup(bool value) async {
    try {
      await _storage.saveSetting('autoBackup', value);
      _autoBackup.value = value;
    } catch (e) {
      debugPrint('更新自动备份设置失败: $e');
    }
  }

  Future<void> updateHighQualityUpload(bool value) async {
    try {
      await _storage.saveSetting('highQualityUpload', value);
      _highQualityUpload.value = value;
    } catch (e) {
      debugPrint('更新高质量上传设置失败: $e');
    }
  }

  void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('中文'),
              value: 'zh',
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: language,
              onChanged: (value) {
                if (value != null) {
                  updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: '家庭照片站',
        applicationVersion: '1.0.0',
        applicationLegalese: '© 2024 家庭照片站\n\n一个专为家庭设计的照片管理应用',
        children: [
          const SizedBox(height: 16),
          const Text('功能特性：'),
          const Text('• 智能照片管理'),
          const Text('• 人脸识别'),
          const Text('• 自动标签'),
          const Text('• 多设备同步'),
          const Text('• 隐私保护'),
        ],
      ),
    );
  }

  void showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私政策页面即将推出')),
    );
  }

  void showTermsOfService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务条款页面即将推出')),
    );
  }

  void logout() {
    authController.logout();
  }
}