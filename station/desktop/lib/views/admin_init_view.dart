import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/l10n/app_localizations.dart';
import 'package:family_photo_desktop/domain/admin_init_service.dart';
import 'package:family_photo_desktop/controllers/admin_init_controller.dart';
import 'package:family_photo_desktop/controllers/bootstrap_controller.dart';
import 'package:family_photo_desktop/controllers/settings_controller.dart';

class AdminInitView extends StatelessWidget {
  final AdminInitService service;
  const AdminInitView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ctrl = Get.put(AdminInitController(service));
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController(), permanent: true);
    final usernameCtrl = TextEditingController();
    final displayNameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          // 左侧表单区域
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                       key: formKey,
                       child: SingleChildScrollView(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         const SizedBox(height: 40),
                         // 语言选择（仅中英）
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             Obx(() {
                               final current = settings.locale.value;
                               return Wrap(spacing: 8, children: [
                                 ChoiceChip(
                                   label: Text(t.languageEnglish),
                                   selected: current.languageCode == 'en',
                                   onSelected: (_) => settings.setLocale(const Locale('en')),
                                 ),
                                 ChoiceChip(
                                   label: Text(t.languageChinese),
                                   selected: current.languageCode == 'zh',
                                   onSelected: (_) => settings.setLocale(const Locale('zh')),
                                 ),
                               ]);
                             }),
                           ],
                         ),
                         const SizedBox(height: 16),
                          
                          // 标题
                          Text(
                            t.adminInitTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.adminInitDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 用户名输入框
                          _buildModernTextField(
                            controller: usernameCtrl,
                            label: t.adminUsernameLabel,
                            icon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return t.fieldRequired;
                              if (v.trim().length < 3) return t.fieldMinLength(3);
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 显示名称输入框
                          _buildModernTextField(
                            controller: displayNameCtrl,
                            label: t.adminDisplayNameLabel,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 20),

                          // 密码输入框
                          _buildModernTextField(
                            controller: passwordCtrl,
                            label: t.adminPasswordLabel,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return t.fieldRequired;
                              if (v.trim().length < 6) return t.fieldMinLength(6);
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 确认密码输入框
                          _buildModernTextField(
                            controller: confirmCtrl,
                            label: t.adminPasswordConfirmLabel,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return t.fieldRequired;
                              if (v.trim().length < 6) return t.fieldMinLength(6);
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // 提交按钮和错误信息
                          Obx(() {
                            final submitting = ctrl.isSubmitting.value;
                            final errKey = ctrl.errorKey.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (errKey != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            t.translateErrorKey(errKey),
                                            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: submitting
                                        ? null
                                        : () async {
                                            if (!formKey.currentState!.validate()) return;
                                            final ok = await ctrl.submit(
                                              username: usernameCtrl.text.trim(),
                                              displayName: displayNameCtrl.text.trim().isEmpty ? null : displayNameCtrl.text.trim(),
                                              password: passwordCtrl.text,
                                              confirm: confirmCtrl.text,
                                            );
                                            if (ok) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(t.adminInitSuccess)),
                                              );
                                              // 通知引导控制器刷新状态
                                              Get.find<BootstrapController>().hasAdmin.value = true;
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: submitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            t.adminInitSubmit,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          }),
                         ],
                       ),
                     ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 右侧展示区域
          Expanded(
            flex: 7,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFA855F7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 背景装饰
                  Positioned(
                    top: 100,
                    right: 100,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 200,
                    left: 80,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // 主要内容
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 功能卡片1 - 照片管理
                          _buildFeatureCard(
                            icon: Icons.photo_library_outlined,
                            title: t.featurePhotoManagementTitle,
                            subtitle: t.featurePhotoManagementSubtitle,
                            stats: '10,000+',
                            statsLabel: t.featurePhotoManagementStatsLabel,
                          ),
                          const SizedBox(height: 15),
                          
                          // 功能卡片2 - 相册创建
                          _buildFeatureCard(
                            icon: Icons.collections_outlined,
                            title: t.featureAlbumCreationTitle,
                            subtitle: t.featureAlbumCreationSubtitle,
                            stats: '50+',
                            statsLabel: t.featureAlbumCreationStatsLabel,
                          ),
                          const SizedBox(height: 15),
                          
                          // 功能卡片3 - 安全存储
                          _buildFeatureCard(
                            icon: Icons.security_outlined,
                            title: t.featureSecureStorageTitle,
                            subtitle: t.featureSecureStorageSubtitle,
                            stats: '100%',
                            statsLabel: t.featureSecureStorageStatsLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String stats,
    required String statsLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stats,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statsLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}