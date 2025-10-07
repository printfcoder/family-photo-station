import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';

class AppSidebar extends StatefulWidget {
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final _authController = Get.find<AuthController>();

  final List<NavigationRailDestination> _destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('仪表板'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.photo_library_outlined),
      selectedIcon: Icon(Icons.photo_library),
      label: Text('照片'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.photo_album_outlined),
      selectedIcon: Icon(Icons.photo_album),
      label: Text('相册'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('用户'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('设置'),
    ),
  ];

  final List<String> _routes = [
    AppRoutes.dashboard,
    AppRoutes.photos,
    AppRoutes.albums,
    AppRoutes.users,
    AppRoutes.settings,
  ];

  int get _selectedIndex {
    final index = _routes.indexOf(widget.currentRoute);
    return index >= 0 ? index : 0;
  }

  void _onDestinationSelected(int index) {
    if (index < _routes.length) {
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: _destinations,
      leading: Column(
        children: [
          const SizedBox(height: 16),
          // 应用图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 用户头像
                Obx(() => CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: _authController.user?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            _authController.user!.avatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                )),
                const SizedBox(height: 8),
                // 登出按钮
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _authController.logout();
                    if (mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  tooltip: '登出',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}