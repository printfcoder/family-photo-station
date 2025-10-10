import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    
    final List<NavigationRailDestination> destinations = [
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

    return Scaffold(
      body: Column(
        children: [
          // Main content
          Expanded(
            child: Row(
              children: [
                // Sidebar navigation
                Obx(() => NavigationRail(
                  selectedIndex: controller.selectedIndex,
                  onDestinationSelected: controller.onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations,
                  leading: Column(
                    children: [
                      const SizedBox(height: 16),
                      // App icon
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
                            // User avatar
                            Obx(() => CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              child: controller.authController.user?.avatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                        controller.authController.user!.avatar!,
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
                            // Logout button
                            IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: controller.logout,
                              tooltip: '登出',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                
                const VerticalDivider(thickness: 1, width: 1),
                
                // Main content area
                Expanded(
                  child: _buildMainContent(context, controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title and user info
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
                      '欢迎回来，${controller.authController.user?.displayName ?? controller.authController.user?.username ?? '用户'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )),
                  ],
                ),
              ),
              // Quick action buttons
              ElevatedButton.icon(
                onPressed: controller.onUploadPhotos,
                icon: const Icon(Icons.upload),
                label: const Text('上传照片'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Statistics cards - warm card layout
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.3,
              children: [
                Obx(() => _buildStatCard(
                  context: context,
                  title: '珍贵回忆',
                  value: '${controller.authController.userStats?.photoCount ?? 0}',
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFFFF8A65),
                  subtitle: '张照片',
                )),
                Obx(() => _buildStatCard(
                  context: context,
                  title: '美好时光',
                  value: '${controller.authController.userStats?.albumCount ?? 0}',
                  icon: Icons.photo_album_rounded,
                  color: const Color(0xFF81C784).withValues(alpha: 0.15),
                  subtitle: '个相册',
                )),
                _buildStatCard(
                  context: context,
                  title: '温馨标签',
                  value: '0',
                  icon: Icons.label_rounded,
                  color: const Color(0xFF64B5F6),
                  subtitle: '个标签',
                ),
                Obx(() => _buildStatCard(
                  context: context,
                  title: '分享快乐',
                  value: controller.authController.userStats?.totalStorageUsed != null 
                    ? '${(controller.authController.userStats!.totalStorageUsed.toDouble() / (1024 * 1024 * 1024)).toStringAsFixed(1)}'
                    : '0',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFFFB74D),
                  subtitle: 'GB 已用',
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Storage usage - warm card design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFFE0B2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A65).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.cloud_rounded,
                          color: Color(0xFFFF8A65),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '家庭云存储',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final stats = controller.authController.userStats;
                    final usage = stats?.totalStorageUsed != null 
                      ? (stats!.totalStorageUsed.toDouble() / (10 * 1024 * 1024 * 1024)) // Assume 10GB limit
                      : 0.0;
                    return Column(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: usage,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                usage > 0.8 ? const Color(0xFFEF5350) : const Color(0xFF81C784).withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '已使用: ${stats?.totalStorageUsed != null ? controller.formatBytes(stats!.totalStorageUsed.toInt()) : '0 B'}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6D4C41),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '无限容量 ∞',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6D4C41),
                                fontWeight: FontWeight.w500,
                              ),
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
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8D6E63),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6D4C41),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
