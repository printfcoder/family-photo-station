import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:family_photo_desktop/controllers/bootstrap_controller.dart';
import 'package:family_photo_desktop/controllers/settings_controller.dart';
import 'package:family_photo_desktop/l10n/app_localizations.dart';

class ShellView extends StatelessWidget {
  final Widget body;
  const ShellView({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    // 检查是否为初始化状态（没有管理员）
    final bootstrap = Get.isRegistered<BootstrapController>()
        ? Get.find<BootstrapController>()
        : null;
    final isInitializing = bootstrap != null && !bootstrap.hasAdmin.value;
    
    return Scaffold(
      body: Row(
        children: [
          // 只在非初始化状态显示侧边栏
          if (!isInitializing) ...[
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部品牌栏
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 项目Logo
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.photo_library_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.appTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _NavItem(icon: Icons.dashboard, label: t.navDashboard, onTap: () {}),
                  _NavItem(icon: Icons.photo_library, label: t.navLibrary, onTap: () {}),
                  _NavItem(icon: Icons.photo_album, label: t.navAlbums, onTap: () {}),
                  _NavItem(icon: Icons.people_outline, label: t.navUsers, onTap: () {}),
                  _NavItem(icon: Icons.storage, label: t.navStorage, onTap: () {}),
                  _NavItem(icon: Icons.backup, label: t.navBackup, onTap: () {}),
                  const Spacer(),
                  _NavItem(icon: Icons.settings, label: t.settingsTitle, onTap: () {
                    Get.to(() => SettingsView());
                  }),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.roleAdmin,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // 分界线
            Container(
              width: 1,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ],
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ]),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  final languages = const [Locale('en'), Locale('zh')];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController(), permanent: true);
    return ShellView(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部黑紫色主卡片
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF120D2B), Color(0xFF3E2476)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white.withValues(alpha: 0.9), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.appTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 语言设置
            Text(t.settingsLanguage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              final current = settings.locale.value;
              return Wrap(spacing: 12, children: languages.map((l) {
                final selected = l.languageCode == current.languageCode;
                return ChoiceChip(
                  label: Text(l.languageCode == 'en' ? t.languageEnglish : t.languageChinese),
                  selected: selected,
                  onSelected: (_) => settings.setLocale(l),
                );
              }).toList());
            }),

            const SizedBox(height: 24),
            // 主题设置
            Text(t.settingsTheme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              final mode = settings.themeMode.value;
              return Wrap(spacing: 12, children: [
                ChoiceChip(label: Text(t.themeLight), selected: mode == ThemeMode.light, onSelected: (_) => settings.setThemeMode(ThemeMode.light)),
                ChoiceChip(label: Text(t.themeDark), selected: mode == ThemeMode.dark, onSelected: (_) => settings.setThemeMode(ThemeMode.dark)),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}