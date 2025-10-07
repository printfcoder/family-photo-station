import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/storage_service.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/models/user.dart';

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

  Future<void> _updateDarkMode(bool value) async {
    try {
      final storage = StorageService();
      await storage.saveSetting('isDarkMode', value);
      setState(() {
        _isDarkMode = value;
      });
    } catch (e) {
      debugPrint('更新深色模式设置失败: $e');
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

  Widget _buildUserSection(User? user) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户信息',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatar != null 
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null 
                      ? Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U')
                      : null,
                ),
                title: Text(user.username),
                subtitle: Text(user.email),
              ),
            ] else ...[
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('未登录'),
                subtitle: Text('请先登录以查看用户信息'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '外观设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('启用深色主题'),
              value: _isDarkMode,
              onChanged: _updateDarkMode,
            ),
            ListTile(
              title: const Text('语言'),
              subtitle: Text(_language == 'zh' ? '中文' : 'English'),
              trailing: DropdownButton<String>(
                value: _language,
                onChanged: (value) {
                  if (value != null) {
                    _updateLanguage(value);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'zh',
                    child: Text('中文'),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '通知设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('启用通知'),
              subtitle: const Text('接收应用通知'),
              value: _enableNotifications,
              onChanged: _updateNotifications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备份设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('自动备份'),
              subtitle: const Text('自动备份照片到云端'),
              value: _autoBackup,
              onChanged: _updateAutoBackup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '上传设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('高质量上传'),
              subtitle: const Text('上传原始质量的照片'),
              value: _highQualityUpload,
              onChanged: _updateHighQualityUpload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '存储设置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('清理缓存'),
              subtitle: const Text('清理应用缓存文件'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 实现清理缓存功能
                Get.snackbar(
                  '提示',
                  '清理缓存功能即将推出',
                );
              },
            ),
            ListTile(
              title: const Text('存储管理'),
              subtitle: const Text('管理本地存储空间'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 实现存储管理功能
                Get.snackbar(
                  '提示',
                  '存储管理功能即将推出',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关于',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('版本信息'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: '家庭照片站',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 家庭照片站',
                );
              },
            ),
            ListTile(
              title: const Text('帮助与反馈'),
              subtitle: const Text('获取帮助或提供反馈'),
              trailing: const Icon(Icons.help_outline),
              onTap: () {
                Get.snackbar(
                  '提示',
                  '帮助功能即将推出',
                );
              },
            ),
            ListTile(
              title: const Text('隐私政策'),
              subtitle: const Text('查看隐私政策'),
              trailing: const Icon(Icons.privacy_tip_outlined),
              onTap: () {
                Get.snackbar(
                  '提示',
                  '隐私政策功能即将推出',
                );
              },
            ),
          ],
        ),
      ),
    );
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
}