import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_mobile/core/services/storage_service.dart';
import 'package:family_photo_mobile/core/controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  bool _autoBackup = false;
  bool _highQualityUpload = false;
  String _language = 'zh';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final storage = StorageService();
      final isDarkMode = await storage.getSetting<bool>('isDarkMode') ?? false;
      final enableNotifications = await storage.getSetting<bool>('enableNotifications') ?? true;
      final autoBackup = await storage.getSetting<bool>('autoBackup') ?? false;
      final highQualityUpload = await storage.getSetting<bool>('highQualityUpload') ?? false;
      final language = await storage.getSetting<String>('language') ?? 'zh';

      if (mounted) {
        setState(() {
          _isDarkMode = isDarkMode;
          _enableNotifications = enableNotifications;
          _autoBackup = autoBackup;
          _highQualityUpload = highQualityUpload;
          _language = language;
        });
      }
    } catch (e) {
      debugPrint('加载设置失败: $e');
    }
  }

  Future<void> _updateTheme(bool value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('isDarkMode', value);
      setState(() {
        _isDarkMode = value;
      });
      // TODO: 更新应用主题
    } catch (e) {
      debugPrint('更新主题失败: $e');
    }
  }

  Future<void> _updateNotifications(bool value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('enableNotifications', value);
      setState(() {
        _enableNotifications = value;
      });
    } catch (e) {
      debugPrint('更新通知设置失败: $e');
    }
  }

  Future<void> _updateLanguage(String value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('language', value);
      setState(() {
        _language = value;
      });
    } catch (e) {
      debugPrint('更新语言设置失败: $e');
    }
  }

  Future<void> _updateAutoBackup(bool value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('autoBackup', value);
      setState(() {
        _autoBackup = value;
      });
    } catch (e) {
      debugPrint('更新自动备份设置失败: $e');
    }
  }

  Future<void> _updateHighQualityUpload(bool value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('highQualityUpload', value);
      setState(() {
        _highQualityUpload = value;
      });
    } catch (e) {
      debugPrint('更新高质量上传设置失败: $e');
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这将删除本地存储的图片缓存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final storage = StorageService();
        await storage.clearCache();
        if (mounted) {
          Get.snackbar(
            '成功',
            '缓存已清除',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        if (mounted) {
          Get.snackbar(
            '错误',
            '清除缓存失败: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final storage = StorageService();
      await storage.exportData();
      // TODO: 实现数据导出功能，比如保存到文件或分享
      if (mounted) {
        Get.snackbar(
          '提示',
          '数据导出功能即将推出',
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          '错误',
          '导出失败: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('设置'),
          ),
          body: ListView(
            children: [
              // 用户信息
              _buildUserSection(user),
              const Divider(),

              // 外观设置
              _buildAppearanceSection(),
              const Divider(),

              // 通知设置
              _buildNotificationSection(),
              const Divider(),

              // 备份设置
              _buildBackupSection(),
              const Divider(),

              // 上传设置
              _buildUploadSection(),
              const Divider(),

              // 存储设置
              _buildStorageSection(),
              const Divider(),

              // 关于
              _buildAboutSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSection(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '账户',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: user?.avatar != null
                ? NetworkImage(user!.avatar!)
                : null,
            child: user?.avatar == null
                ? Text(
                    user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(user?.displayName ?? user?.username ?? '用户'),
          subtitle: Text(user?.email ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: 跳转到个人资料编辑页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('个人资料编辑功能即将推出')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '外观',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('深色模式'),
          subtitle: const Text('使用深色主题'),
          value: _isDarkMode,
          onChanged: _updateTheme,
          secondary: const Icon(Icons.dark_mode_outlined),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text('语言'),
          subtitle: Text(_language == 'zh' ? '中文' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
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
                      groupValue: _language,
                      onChanged: (value) {
                        if (value != null) {
                          _updateLanguage(value);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('English'),
                      value: 'en',
                      groupValue: _language,
                      onChanged: (value) {
                        if (value != null) {
                          _updateLanguage(value);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '通知',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('推送通知'),
          subtitle: const Text('接收新照片和活动通知'),
          value: _enableNotifications,
          onChanged: _updateNotifications,
          secondary: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildBackupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '备份',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('自动备份'),
          subtitle: const Text('自动备份新拍摄的照片'),
          value: _autoBackup,
          onChanged: _updateAutoBackup,
          secondary: const Icon(Icons.backup_outlined),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '上传',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('高质量上传'),
          subtitle: const Text('上传原始质量的照片（消耗更多流量）'),
          value: _highQualityUpload,
          onChanged: _updateHighQualityUpload,
          secondary: const Icon(Icons.high_quality_outlined),
        ),
      ],
    );
  }

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '存储',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services_outlined),
          title: const Text('清除缓存'),
          subtitle: const Text('清除本地缓存的图片和数据'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _clearCache,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('导出数据'),
          subtitle: const Text('导出您的照片和设置数据'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _exportData,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '关于',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('版本信息'),
          subtitle: const Text('1.0.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showAboutDialog(
              context: context,
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
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('隐私政策页面即将推出')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('服务条款'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('服务条款页面即将推出')),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}