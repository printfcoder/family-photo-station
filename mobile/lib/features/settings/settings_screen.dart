import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_mobile/core/controllers/auth_controller.dart';
import 'package:family_photo_mobile/features/settings/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

               // 关于
               _buildAboutSection(context, controller),
            ],
          ),
        );
      },
    );
  }
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

  Widget _buildUserSection(BuildContext context, user, SettingsController controller) {
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

  Widget _buildAppearanceSection(BuildContext context, SettingsController controller) {
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
        Obx(() => SwitchListTile(
          title: const Text('深色模式'),
          subtitle: const Text('使用深色主题'),
          value: controller.isDarkMode,
          onChanged: controller.updateTheme,
          secondary: const Icon(Icons.dark_mode_outlined),
        )),
        Obx(() => ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text('语言'),
          subtitle: Text(controller.language == 'zh' ? '中文' : 'English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => controller.showLanguageDialog(context),
        )),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context, SettingsController controller) {
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
        Obx(() => SwitchListTile(
          title: const Text('推送通知'),
          subtitle: const Text('接收新照片和活动通知'),
          value: controller.enableNotifications,
          onChanged: controller.updateNotifications,
          secondary: const Icon(Icons.notifications_outlined),
        )),
      ],
    );
  }

  Widget _buildBackupSection(BuildContext context, SettingsController controller) {
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
        Obx(() => SwitchListTile(
          title: const Text('自动备份'),
          subtitle: const Text('自动备份新拍摄的照片'),
          value: controller.autoBackup,
          onChanged: controller.updateAutoBackup,
          secondary: const Icon(Icons.backup_outlined),
        )),
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context, SettingsController controller) {
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
        Obx(() => SwitchListTile(
          title: const Text('高质量上传'),
          subtitle: const Text('上传原始质量的照片（消耗更多流量）'),
          value: controller.highQualityUpload,
          onChanged: controller.updateHighQualityUpload,
          secondary: const Icon(Icons.high_quality_outlined),
        )),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, SettingsController controller) {
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
          onTap: () => controller.showAboutDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('隐私政策'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => controller.showPrivacyPolicy(context),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('服务条款'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => controller.showTermsOfService(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}