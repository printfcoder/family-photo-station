import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:family_photo_desktop/services/local_server.dart';
import 'package:family_photo_desktop/controllers/invite_controller.dart';
import 'package:path/path.dart' as path;

import 'package:family_photo_desktop/controllers/bootstrap_controller.dart';
import 'package:family_photo_desktop/controllers/settings_controller.dart';
import 'package:family_photo_desktop/l10n/app_localizations.dart';
import 'package:family_photo_desktop/controllers/auth_controller.dart';
import 'package:family_photo_desktop/database/db/database.dart';
import 'package:family_photo_desktop/database/users/user_repository.dart';
import 'package:family_photo_desktop/database/users/user.dart';
import 'package:family_photo_desktop/controllers/storage_settings_controller.dart';
import 'package:family_photo_desktop/storage/user_data_manager.dart';

class ShellView extends StatelessWidget {
  final Widget body;
  const ShellView({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Obx(() {
      // 检查是否为初始化状态（没有管理员）
      final bootstrap = Get.isRegistered<BootstrapController>()
          ? Get.find<BootstrapController>()
          : null;
      final isInitializing = bootstrap != null && !bootstrap.hasAdmin.value;
      final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      final isAuthed = auth != null && auth.isAuthenticated.value;

      return Scaffold(
        body: Row(
          children: [
          // 只在非初始化状态显示侧边栏
          if (!isInitializing && isAuthed) ...[
            Container(
              width: 220,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部品牌栏
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () {
                        Get.to(() => const ProfileView(), transition: Transition.noTransition);
                      },
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
                  ),
                  const SizedBox(height: 8),
                  _NavItem(icon: Icons.dashboard, label: t.navDashboard, onTap: () {}),
                  _NavItem(icon: Icons.photo_library, label: t.navLibrary, onTap: () {
                    Get.to(() => const LibraryView(), transition: Transition.noTransition);
                  }),
                  _NavItem(icon: Icons.photo_album, label: t.navAlbums, onTap: () {}),
                  if (auth?.currentUser.value?.isAdmin == true)
                    _NavItem(icon: Icons.people_outline, label: t.navUsers, onTap: () {
                      Get.to(() => const UsersView(), transition: Transition.noTransition);
                    }),
                  _NavItem(icon: Icons.storage, label: t.navStorage, onTap: () {}),
                  _NavItem(icon: Icons.backup, label: t.navBackup, onTap: () {}),
                  const Spacer(),
                  _NavItem(icon: Icons.settings, label: t.settingsTitle, onTap: () {
                    Get.to(() => const SettingsView(), transition: Transition.noTransition);
                  }),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            auth?.currentUser.value?.displayName ?? auth?.currentUser.value?.username ?? t.roleAdmin,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'switch', child: Text(t.actionSwitchUser)),
                            PopupMenuItem(value: 'logout', child: Text(t.actionLogout)),
                          ],
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await auth?.logout();
                              // 返回到登录视图由 BootstrapView 根据状态切换
                            } else if (value == 'switch') {
                              await auth?.startSwitch();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 分界线
            Container(
              width: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
    });
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
    final storageCtrl = Get.put(StorageSettingsController(), permanent: false);
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
                  Icon(Icons.settings, color: Colors.white.withOpacity(0.9), size: 28),
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
            // 分区：通用配置
            Text('通用配置', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
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

            const SizedBox(height: 24),
            // 分区：照片存储
            Text('照片存储', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            // 子分区：存储位置
            Text('2.1 存储位置', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            // 存储类型选择
            Obx(() {
              final type = storageCtrl.storageType.value;
              return Row(children: [
                ChoiceChip(
                  label: const Text('本地目录'),
                  selected: type == StorageUIType.local,
                  onSelected: (_) => storageCtrl.storageType.value = StorageUIType.local,
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('SMB 网络存储'),
                  selected: type == StorageUIType.smb,
                  onSelected: (_) => storageCtrl.storageType.value = StorageUIType.smb,
                ),
              ]);
            }),
            const SizedBox(height: 16),
            // 本地目录选择
            Obx(() {
              if (storageCtrl.storageType.value != StorageUIType.local) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: storageCtrl.localPath.value),
                        decoration: const InputDecoration(labelText: '存储目录', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(onPressed: storageCtrl.pickLocalDirectory, icon: const Icon(Icons.folder_open), label: const Text('浏览')),
                  ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: UserDataManager.instance.getRecommendedStorageLocations().map((p) {
                    return ActionChip(label: Text(p), onPressed: () => storageCtrl.localPath.value = p);
                  }).toList()),
                ],
              );
            }),
            // SMB 输入区域
            Obx(() {
              if (storageCtrl.storageType.value != StorageUIType.smb) return const SizedBox.shrink();
              return Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: storageCtrl.smbHost.value,
                        onChanged: (v) => storageCtrl.smbHost.value = v,
                        decoration: const InputDecoration(labelText: '主机 (例如: fileserver)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: storageCtrl.smbShare.value,
                        onChanged: (v) => storageCtrl.smbShare.value = v,
                        decoration: const InputDecoration(labelText: '共享名 (例如: photos)', border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: storageCtrl.smbUsername.value,
                        onChanged: (v) => storageCtrl.smbUsername.value = v,
                        decoration: const InputDecoration(labelText: '用户名 (可选)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        onChanged: (v) => storageCtrl.smbPassword.value = v,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: '密码 (可选)', border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                ],
              );
            }),
            const SizedBox(height: 12),
            // 验证与保存
            Obx(() {
              return Row(children: [
                ElevatedButton.icon(
                  onPressed: storageCtrl.isValidating.value ? null : storageCtrl.validateAndSave,
                  icon: const Icon(Icons.verified),
                  label: Text(storageCtrl.isValidating.value ? '验证中...' : '验证并保存'),
                ),
                const SizedBox(width: 12),
                if (storageCtrl.validateMessage.value.isNotEmpty)
                  Row(children: [
                    Icon(storageCtrl.validateOk.value ? Icons.check_circle : Icons.error_outline,
                        color: storageCtrl.validateOk.value ? Colors.green : Colors.orange),
                    const SizedBox(width: 6),
                    Text(storageCtrl.validateMessage.value),
                  ]),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = Get.put(_LibraryController(), permanent: false);
    return ShellView(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(t.navLibrary, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Obx(() => TextButton.icon(
                    onPressed: controller.isLoading.value ? null : () => controller.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: Text(controller.isLoading.value ? '刷新中...' : '刷新'),
                  )),
            ]),
            const SizedBox(height: 12),
            // 用户选择 Chips
            Obx(() {
              final users = controller.users;
              final selected = controller.selectedUsername.value;
              if (users.isEmpty) {
                return Text('暂无用户');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: users.map((u) {
                  final label = (u.displayName?.isNotEmpty == true) ? u.displayName! : u.username;
                  final isSelected = selected == u.username;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => controller.selectUser(u.username),
                    ),
                  );
                }).toList()),
              );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final photos = controller.photoPaths;
                if (photos.isEmpty) {
                  return Center(child: Text('该用户暂无照片'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final p = photos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(children: [
                        Positioned.fill(
                          child: Image.file(
                            File(p),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      ]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryController extends GetxController {
  final users = <User>[].obs;
  final selectedUsername = ''.obs;
  final photoPaths = <String>[].obs;
  final isLoading = false.obs;

  late final UserRepository repo;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    repo = auth.users;
    _init();
  }

  Future<void> _init() async {
    await loadUsers();
    // 默认选择当前登录用户或第一个用户
    final auth = Get.find<AuthController>();
    final current = auth.currentUser.value?.username;
    if (users.isNotEmpty) {
      selectedUsername.value = current ?? users.first.username;
      await _loadPhotosFor(selectedUsername.value);
    }
  }

  Future<void> loadUsers() async {
    users.value = await repo.listAll();
  }

  Future<void> selectUser(String username) async {
    if (selectedUsername.value == username) return;
    selectedUsername.value = username;
    await _loadPhotosFor(username);
  }

  Future<void> refresh() async {
    await _loadPhotosFor(selectedUsername.value);
  }

  Future<void> _loadPhotosFor(String username) async {
    if (username.isEmpty) return;
    isLoading.value = true;
    try {
      final root = UserDataManager.instance.appDataDirectory;
      final dir = Directory(path.join(root, 'photos', username));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final patterns = <String>{'jpg', 'jpeg', 'png', 'gif', 'webp'};
      final entries = <_PhotoEntry>[];
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          final ext = entity.path.split('.').last.toLowerCase();
          if (!patterns.contains(ext)) continue;
          try {
            final s = await entity.stat();
            entries.add(_PhotoEntry(entity.path, s.modified));
          } catch (_) {
            // ignore unreadable file
          }
        }
      }
      entries.sort((a, b) => b.modified.compareTo(a.modified));
      photoPaths.value = entries.map((e) => e.path).toList();
    } finally {
      isLoading.value = false;
    }
  }
}

class _PhotoEntry {
  final String path;
  final DateTime modified;
  _PhotoEntry(this.path, this.modified);
}

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = Get.put(_UsersViewController(), permanent: false);

    return ShellView(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(t.navUsers, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserQrDialog(context, controller),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(t.usersAddUser),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final users = controller.users;
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (users.isEmpty) {
                  return Center(child: Text(t.usersEmpty));
                }
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return ListTile(
                      leading: CircleAvatar(child: Icon(u.isAdmin ? Icons.shield : Icons.person)),
                      title: Text(u.displayName?.isNotEmpty == true ? u.displayName! : u.username),
                      subtitle: Text(u.isAdmin ? t.usersRoleAdmin : t.usersRoleMember),
                      trailing: Obx(() {
                        final desktopOnline = controller.presenceDesktop[u.username] ?? false;
                        final mobileOnline = controller.presenceMobile[u.username] ?? false;
                        return Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                          _presenceChip(context, '桌面', desktopOnline, Icons.desktop_windows),
                          _presenceChip(context, '移动', mobileOnline, Icons.phone_iphone),
                          TextButton.icon(
                            onPressed: () => _showResetPasswordDialog(context, controller, u),
                            icon: const Icon(Icons.lock_reset),
                            label: Text(t.usersResetPassword),
                          ),
                          if (!u.isAdmin)
                            TextButton.icon(
                              onPressed: () => _showDeleteUserDialog(context, controller, u),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(t.usersDelete),
                            ),
                        ]);
                      }),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presenceChip(BuildContext context, String label, bool online, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = online ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final fg = online ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    return Chip(
      avatar: Icon(icon, size: 18, color: fg),
      label: Text('$label${online ? "在线" : "离线"}', style: TextStyle(color: fg)),
      backgroundColor: bg,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  void _showAddUserDialog(BuildContext context, _UsersViewController c) {
    final usernameCtrl = TextEditingController();
    final displayNameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增用户'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: '用户名')),
              const SizedBox(height: 12),
              TextField(controller: displayNameCtrl, decoration: const InputDecoration(labelText: '显示名称（可选）')),
              const SizedBox(height: 12),
              TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: '初始密码'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final ok = await c.addUser(
                username: usernameCtrl.text.trim(),
                displayName: displayNameCtrl.text.trim().isEmpty ? null : displayNameCtrl.text.trim(),
                password: passwordCtrl.text,
              );
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('新增失败，检查用户名是否已存在')));
              } else {
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddUserQrDialog(BuildContext context, _UsersViewController c) {
    final t = AppLocalizations.of(context)!;
    final invite = Get.find<InviteController>();
    invite.startQrRegister();
    final server = Get.find<LocalServer>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.usersAddQrDialogTitle),
        content: Obx(() {
          final token = invite.regToken.value;
          final status = invite.regStatus.value;
          final statusText = switch (status) {
            QrRegisterStatus.idle => t.registerQrStatusReleased,
            QrRegisterStatus.pending => t.registerQrStatusPending,
            QrRegisterStatus.scanned => t.registerQrStatusScanned,
            QrRegisterStatus.completed => t.registerStatusCompleted,
          };
          if (status == QrRegisterStatus.completed) {
            // 注册完成后刷新列表并自动关闭对话框
            Future.microtask(() async {
              await c.loadUsers();
              if (Get.isDialogOpen == true) Get.back();
            });
          }
          return SizedBox(
            width: 700,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ColorFiltered(
                          colorFilter: status == QrRegisterStatus.scanned
                              ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                              : const ColorFilter.mode(Colors.transparent, BlendMode.saturation),
                          child: QrImageView(
                            data: 'familyphoto://register?host=${server.hostAddress}&port=${server.listenPort}&token=$token',
                            version: QrVersions.auto,
                            size: 220,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(t.usersAddQrInstruction),
                      const SizedBox(height: 8),
                      Text(statusText, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(onPressed: invite.startQrRegister, child: Text(t.usersQrRefresh)),
          TextButton(onPressed: () => Get.back(), child: const Text('关闭')),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, _UsersViewController c, User u) {
    final t = AppLocalizations.of(context)!;
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.usersResetPassword),
        content: SizedBox(
          width: 360,
          child: TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: '新密码'), obscureText: true),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final ok = await c.resetPassword(u.id!, passwordCtrl.text);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('重置失败')));
              } else {
                Get.back();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, _UsersViewController c, User u) {
    final t = AppLocalizations.of(context)!;
    var removeAll = false;
    if (u.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.usersDeleteAdminForbidden)));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(t.usersDelete),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('确认删除用户 ${u.username}'),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: removeAll,
                  onChanged: (v) => setState(() => removeAll = v ?? false),
                  title: const Text('同时删除该用户所有数据（照片、相册等）'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                final ok = await c.deleteUser(u.id!, removeAllData: removeAll);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('删除失败')));
                } else {
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('删除'),
            ),
          ],
        );
      }),
    );
  }
}

class _UsersViewController extends GetxController {
  final users = <User>[].obs;
  final isLoading = true.obs;
  // 在线状态：username -> device online
  final presenceDesktop = <String, bool>{}.obs;
  final presenceMobile = <String, bool>{}.obs;
  Timer? _presenceTimer;
  // 注册二维码状态由 InviteController 管理

  late final UserRepository repo;
  late final DatabaseClient db;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    repo = auth.users;
    db = repo.db;
    loadUsers();
    _startPresencePolling();
    // 监听注册状态，完成后刷新列表
    if (Get.isRegistered<InviteController>()) {
      final invite = Get.find<InviteController>();
      ever(invite.regStatus, (status) {
        if (status == QrRegisterStatus.completed) {
          loadUsers();
        }
      });
    }
  }

  @override
  void onClose() {
    _presenceTimer?.cancel();
    super.onClose();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    users.value = await repo.listAll();
    isLoading.value = false;
  }

  Future<bool> addUser({required String username, String? displayName, required String password}) async {
    if (username.isEmpty || password.isEmpty) return false;
    final exist = await repo.findByUsername(username);
    if (exist != null) return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.insert(User(username: username, displayName: displayName, isAdmin: false, passwordHash: hash, createdAt: now));
    await loadUsers();
    return true;
  }

  Future<bool> resetPassword(int userId, String newPassword) async {
    if (newPassword.isEmpty) return false;
    final hash = sha256.convert(utf8.encode(newPassword)).toString();
    await repo.updatePasswordHash(userId, hash);
    await loadUsers();
    return true;
  }

  Future<bool> deleteUser(int userId, {bool removeAllData = false}) async {
    try {
      // 防止删除管理员账号
      final admin = await repo.findAdmin();
      if (admin != null && admin.id == userId) {
        return false;
      }
      if (removeAllData) {
        await db.rawDelete('DELETE FROM album_photos WHERE album_id IN (SELECT id FROM albums WHERE user_id = ?)', [userId]);
        await db.rawDelete('DELETE FROM albums WHERE user_id = ?', [userId]);
        await db.rawDelete('DELETE FROM photos WHERE user_id = ?', [userId]);
      }
      await repo.deleteById(userId);
      await loadUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _startPresencePolling() {
    // 立即拉取一次
    _fetchPresenceStatus();
    // 每8秒拉取一次
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 8), (_) => _fetchPresenceStatus());
  }

  Future<void> _fetchPresenceStatus() async {
    try {
      if (!Get.isRegistered<LocalServer>()) return;
      final server = Get.find<LocalServer>();
      final url = Uri.parse('http://${server.hostAddress}:${server.listenPort}/presence/status');
      final client = HttpClient();
      final req = await client.getUrl(url);
      final res = await req.close();
      if (res.statusCode != 200) {
        client.close(force: true);
        return;
      }
      final body = await res.transform(utf8.decoder).join();
      client.close(force: true);
      final data = jsonDecode(body);
      if (data is! Map) return;
      final usersPayload = data['users'];
      if (usersPayload is! List) return;
      final Map<String, bool> d = {};
      final Map<String, bool> m = {};
      for (final item in usersPayload) {
        if (item is Map) {
          final username = item['username'];
          final online = item['online'];
          if (username is String && online is Map) {
            final desktop = online['desktop'] == true;
            final mobile = online['mobile'] == true;
            d[username] = desktop;
            m[username] = mobile;
          }
        }
      }
      presenceDesktop.assignAll(d);
      presenceMobile.assignAll(m);
    } catch (_) {
      // 忽略错误，保持现有状态
    }
  }

}


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController(), permanent: true);
    final languages = const [Locale('en'), Locale('zh')];
    return ShellView(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}