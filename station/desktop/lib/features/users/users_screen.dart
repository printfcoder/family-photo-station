import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/core/widgets/search_bar_widget.dart';
import 'package:family_photo_desktop/core/widgets/filter_chip_widget.dart';
import 'package:family_photo_desktop/core/widgets/sort_dropdown_widget.dart';
import 'package:family_photo_desktop/core/widgets/loading_widget.dart';
import 'package:family_photo_desktop/core/widgets/empty_state_widget.dart';
import 'package:family_photo_desktop/features/users/controllers/users_controller.dart';

// Import user enums
import 'models/user_enums.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          Obx(() => controller.isSelectionMode.value
              ? Row(
                  children: [
                    Text('${controller.selectedCount} selected'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: controller.hasSelection
                          ? () => controller.showDeleteSelectedDialog()
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.toggleSelectionMode(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => controller.refreshUsers(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => controller.showInviteUserDialog(),
                    ),
                  ],
                )),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                SearchBarWidget(
                  hintText: 'Search users...',
                  onChanged: (query) => controller.searchUsers(query),
                ),
                const SizedBox(height: 16),
                // Filters and sort
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => FilterChipGroup(
                        chips: [
                          const FilterChipData(
                            label: 'All Users',
                            value: 'all',
                            icon: Icons.people,
                          ),
                          const FilterChipData(
                            label: 'Active',
                            value: 'active',
                            icon: Icons.check_circle,
                          ),
                          const FilterChipData(
                            label: 'Inactive',
                            value: 'inactive',
                            icon: Icons.block,
                          ),
                          const FilterChipData(
                            label: 'Admins',
                            value: 'admin',
                            icon: Icons.admin_panel_settings,
                          ),
                        ],
                        selectedValue: controller.filterBy.value.toString().split('.').last,
                        onSelectionChanged: (value) {
                          switch (value) {
                            case 'all':
                              controller.setFilterBy(UserFilterBy.all);
                              break;
                            case 'active':
                              controller.setFilterBy(UserFilterBy.active);
                              break;
                            case 'inactive':
                              controller.setFilterBy(UserFilterBy.inactive);
                              break;
                            case 'admin':
                              controller.setFilterBy(UserFilterBy.admin);
                              break;
                          }
                        },
                      )),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => SortDropdownWidget<UserSortBy>(
                      selectedValue: controller.sortBy.value,
                      options: UserSortBy.values.map((sort) => SortOption(
                        label: controller.getSortDisplayName(sort),
                        value: sort,
                        icon: controller.getSortIcon(sort),
                      )).toList(),
                      onChanged: (sort) => controller.setSortBy(sort),
                    )),
                  ],
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Loading users...');
              }

              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.error.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => controller.refreshUsers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredUsers.isEmpty) {
                return EmptyUsersWidget(
                  onInvitePressed: () => controller.showInviteUserDialog(),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  final isSelected = controller.selectedUsers.contains(user.id);
                  final isCurrentUser = user.id == controller.currentUser?.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              const Color(0xFFFFF8E1).withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFFF8A65), width: 2)
                              : Border.all(color: const Color(0xFFFFCC80).withValues(alpha: 0.3), width: 1),
                        ),
                        child: InkWell(
                          onTap: () => controller.isSelectionMode.value
                              ? controller.selectUser(user.id)
                              : controller.showUserDetails(user),
                          onLongPress: () => controller.selectUser(user.id),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Avatar with gradient background
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFF8A65).withValues(alpha: 0.2),
                                        const Color(0xFFFFB74D).withValues(alpha: 0.2),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: user.avatar.isNotEmpty
                                        ? NetworkImage(user.avatar)
                                        : null,
                                    child: user.avatar.isEmpty
                                        ? Text(
                                            (user.displayName.isNotEmpty
                                                ? user.displayName.substring(0, 1).toUpperCase()
                                                : user.username.substring(0, 1).toUpperCase()),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF8A65),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // User details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user.displayName.isNotEmpty ? user.displayName : user.username,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF5D4037),
                                              ),
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF81C784).withValues(alpha: 0.2),
                                                    const Color(0xFF64B5F6).withValues(alpha: 0.2),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Text(
                                                '我',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF81C784),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8D6E63),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatusChip(user.isActive),
                                          const SizedBox(width: 8),
                                          _buildRoleChip(user.role),
                                          const Spacer(),
                                          if (user.hasStats())
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.photo_library_rounded,
                                                    size: 14,
                                                    color: Color(0xFF64B5F6),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${user.stats.photoCount}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64B5F6),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions
                                if (controller.isSelectionMode.value)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.only(left: 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF81C784),
                                                Color(0xFF64B5F6),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : const Color(0xFFFFCC80),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? const Color(0xFF81C784).withValues(alpha: 0.15)
                                              : const Color(0xFFFFCC80).withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFFB74D).withValues(alpha: 0.15),
                                          const Color(0xFFFF8A65).withValues(alpha: 0.15),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: Color(0xFFFF8A65),
                                      ),
                                      onSelected: (value) => controller.handleUserAction(value, user),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_rounded, color: Color(0xFF64B5F6)),
                                              SizedBox(width: 8),
                                              Text('查看详情'),
                                            ],
                                          ),
                                        ),
                                        if (!isCurrentUser) ...[
                                          PopupMenuItem(
                                            value: user.isActive ? 'deactivate' : 'activate',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                                                  color: user.isActive ? Color(0xFFEF5350) : Color(0xFF81C784),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(user.isActive ? '停用' : '启用'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_rounded, color: Color(0xFFEF5350)),
                                                SizedBox(width: 8),
                                                Text('删除', style: TextStyle(color: Color(0xFFEF5350))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    final color = role == UserRole.USER_ROLE_ADMIN ? Colors.purple : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
