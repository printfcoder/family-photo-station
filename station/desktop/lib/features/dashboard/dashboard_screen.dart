import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
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

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 主要内容
          Expanded(
            child: Row(
              children: [
                // 侧边导航栏
                NavigationRail(
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
                ),
                
                const VerticalDivider(thickness: 1, width: 1),
                
                // 主内容区域
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题和用户信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '仪表板',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '欢迎回来，${_authController.user?.displayName ?? _authController.user?.username ?? '用户'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )),
                  ],
                ),
              ),
              // 快速操作按钮
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 实现快速上传功能
                },
                icon: const Icon(Icons.upload),
                label: const Text('上传照片'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 统计卡片
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: '照片总数',
                  value: '${_authController.userStats?.photoCount ?? 0}',
                  icon: Icons.photo_library,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: '相册数量',
                  value: '${_authController.userStats?.albumCount ?? 0}',
                  icon: Icons.photo_album,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: '标签数量',
                  value: '0', // tagCount not available in UserStats
                  icon: Icons.label,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: '分享数量',
                  value: _authController.userStats?.totalStorageUsed != null 
                    ? '${(_authController.userStats!.totalStorageUsed.toDouble() / (1024 * 1024 * 1024)).toStringAsFixed(1)}%'
                    : '0%',
                  icon: Icons.share,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 存储使用情况
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '存储使用情况',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final stats = _authController.userStats;
                    final usage = stats?.totalStorageUsed != null 
                      ? (stats!.totalStorageUsed.toDouble() / (10 * 1024 * 1024 * 1024)) // Assume 10GB limit
                      : 0.0;
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: usage,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usage > 0.8 ? Colors.red : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '已使用: ${stats?.totalStorageUsed != null ? _formatBytes(stats!.totalStorageUsed.toInt()) : '0 B'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '总容量: 无限制',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}