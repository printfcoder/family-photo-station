import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/storage_service.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/features/settings/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildUserSection(BuildContext context, User? user, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '用户信息',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (user != null) ...[
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: user.avatar.isNotEmpty 
                          ? NetworkImage(user.avatar)
                          : null,
                      backgroundColor: const Color(0xFFFFCC80),
                      child: user.avatar.isEmpty 
                          ? Text(
                              user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Color(0xFF5D4037),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ),
              ] else ...[
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFFFCC80),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                  title: const Text(
                    '未登录',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    '请先登录以查看用户信息',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '外观设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: SwitchListTile(
                  title: const Text(
                    '深色模式',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '启用深色主题',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  value: controller.isDarkMode,
                  onChanged: controller.updateDarkMode,
                  activeColor: const Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '语言',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    controller.language == 'zh' ? '中文' : 'English',
                    style: const TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: DropdownButton<String>(
                      value: controller.language,
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateLanguage(value);
                        }
                      },
                      underline: Container(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF5D4037),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'zh',
                          child: Text(
                            '中文',
                            style: TextStyle(color: Color(0xFF5D4037)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            'English',
                            style: TextStyle(color: Color(0xFF5D4037)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '通知设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: SwitchListTile(
                  title: const Text(
                    '启用通知',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '接收应用通知',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  value: controller.enableNotifications,
                  onChanged: controller.updateNotifications,
                  activeColor: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.backup_outlined,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '备份设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: SwitchListTile(
                  title: const Text(
                    '自动备份',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '自动备份照片到云端',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  value: controller.autoBackup,
                  onChanged: controller.updateAutoBackup,
                  activeColor: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '上传设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: SwitchListTile(
                  title: const Text(
                    '高质量上传',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '上传原始质量的照片',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  value: controller.highQualityUpload,
                  onChanged: controller.updateHighQualityUpload,
                  activeColor: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.storage_outlined,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '存储设置',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '清理缓存',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '清理应用缓存文件',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  onTap: () {
                    // TODO: 实现清理缓存功能
                    Get.snackbar(
                      '提示',
                      '清理缓存功能即将推出',
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '存储管理',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '管理本地存储空间',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  onTap: () {
                    // TODO: 实现存储管理功能
                    Get.snackbar(
                      '提示',
                      '存储管理功能即将推出',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '关于',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4037),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '版本信息',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  onTap: () => controller.showAboutDialog(context),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '帮助与反馈',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '获取帮助或提供反馈',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  onTap: () {
                    Get.snackbar(
                      '提示',
                      '帮助功能即将推出',
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                child: ListTile(
                  title: const Text(
                    '隐私政策',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    '查看隐私政策',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFCC80),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  onTap: () => controller.showPrivacyPolicy(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    
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
              _buildUserSection(context, user, controller),
              const Divider(),

              // 外观设置
              _buildAppearanceSection(context, controller),
              const Divider(),

              // 通知设置
              _buildNotificationSection(context, controller),
              const Divider(),

              // 备份设置
              _buildBackupSection(context, controller),
              const Divider(),

              // 上传设置
              _buildUploadSection(context, controller),
              const Divider(),

              // 存储设置
              _buildStorageSection(context, controller),
              const Divider(),

              // 关于
              _buildAboutSection(context, controller),
            ],
          ),
        );
      },
    );
  }
}