import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/core/widgets/search_bar_widget.dart';
import 'package:family_photo_desktop/core/widgets/filter_chip_widget.dart';
import 'package:family_photo_desktop/core/widgets/sort_dropdown_widget.dart';
import 'package:family_photo_desktop/core/widgets/loading_widget.dart';
import 'package:family_photo_desktop/core/widgets/empty_state_widget.dart';
import 'package:family_photo_desktop/features/users/controllers/user_controller.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';

// Import user enums
import 'models/user_enums.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    userController.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          Obx(() => userController.isSelectionMode.value
              ? Row(
                  children: [
                    Text('${userController.selectedCount} selected'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: userController.hasSelection
                          ? () => _showDeleteSelectedDialog()
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => userController.toggleSelectionMode(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => userController.refreshUsers(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => _showInviteUserDialog(),
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
                  onChanged: (query) => userController.searchUsers(query),
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
                        selectedValue: userController.filterBy.value.toString().split('.').last,
                        onSelectionChanged: (value) {
                          switch (value) {
                            case 'all':
                              userController.setFilterBy(UserFilterBy.all);
                              break;
                            case 'active':
                              userController.setFilterBy(UserFilterBy.active);
                              break;
                            case 'inactive':
                              userController.setFilterBy(UserFilterBy.inactive);
                              break;
                            case 'admin':
                              userController.setFilterBy(UserFilterBy.admin);
                              break;
                          }
                        },
                      )),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => SortDropdownWidget<UserSortBy>(
                      selectedValue: userController.sortBy.value,
                      options: UserSortBy.values.map((sort) => SortOption(
                        label: userController.getSortDisplayName(sort),
                        value: sort,
                        icon: _getSortIcon(sort),
                      )).toList(),
                      onChanged: (sort) => userController.setSortBy(sort),
                    )),
                  ],
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: Obx(() {
              if (userController.isLoading.value) {
                return const LoadingWidget(message: 'Loading users...');
              }

              if (userController.error.value.isNotEmpty) {
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
                        userController.error.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => userController.refreshUsers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (userController.filteredUsers.isEmpty) {
                return EmptyUsersWidget(
                  onInvitePressed: () => _showInviteUserDialog(),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userController.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = userController.filteredUsers[index];
                  final isSelected = userController.selectedUsers.contains(user.id);
                  final isCurrentUser = user.id == authController.user?.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => userController.isSelectionMode.value
                          ? userController.selectUser(user.id)
                          : _showUserDetails(user),
                      onLongPress: () => userController.selectUser(user.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: user.avatar != null
                                  ? NetworkImage(user.avatar!)
                                  : null,
                              child: user.avatar == null
                                  ? Text(
                                      (user.displayName?.isNotEmpty == true
                                  ? user.displayName!.substring(0, 1).toUpperCase()
                                  : user.username.substring(0, 1).toUpperCase()),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // User details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.displayName ?? user.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (isCurrentUser)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'You',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatusChip(user.isActive),
                                      const SizedBox(width: 8),
                                      _buildRoleChip(user.role),
                                      const Spacer(),
                                      if (user.stats != null)
                                        Text(
                                          '${user.stats!.photoCount} photos',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Actions
                            if (userController.isSelectionMode.value)
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              )
                            else
                              PopupMenuButton<String>(
                                onSelected: (value) => _handleUserAction(value, user),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility),
                                        SizedBox(width: 8),
                                        Text('View Details'),
                                      ],
                                    ),
                                  ),
                                  if (!isCurrentUser) ...[
                                    PopupMenuItem(
                                      value: user.isActive ? 'deactivate' : 'activate',
                                      child: Row(
                                        children: [
                                          Icon(user.isActive ? Icons.block : Icons.check_circle),
                                          const SizedBox(width: 8),
                                          Text(user.isActive ? 'Deactivate' : 'Activate'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
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
    final color = role == UserRole.admin ? Colors.purple : Colors.blue;
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

  IconData _getSortIcon(UserSortBy sort) {
    switch (sort) {
      case UserSortBy.newest:
        return Icons.schedule;
      case UserSortBy.oldest:
        return Icons.history;
      case UserSortBy.name:
        return Icons.sort_by_alpha;
      case UserSortBy.email:
        return Icons.email;
    }
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'activate':
      case 'deactivate':
        _showToggleActiveDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName ?? user.username),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Username: ${user.username}'),
            Text('Role: ${user.role.toString().split('.').last}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
            Text('Created: ${user.createdAt.toString().split(' ')[0]}'),
            if (user.stats != null) ...[
              const SizedBox(height: 8),
              Text('Photos: ${user.stats!.photoCount}'),
              Text('Albums: ${user.stats!.albumCount}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showToggleActiveDialog(User user) {
    final action = user.isActive ? 'deactivate' : 'activate';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize ?? action} User'),
        content: Text('Are you sure you want to $action ${user.displayName ?? user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              userController.toggleUserActive(user.id);
            },
            child: Text(action.capitalize ?? action),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.displayName ?? user.username}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              userController.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Users'),
        content: Text('Are you sure you want to delete ${userController.selectedCount} users? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              userController.deleteSelectedUsers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInviteUserDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter user email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name (Optional)',
                hintText: 'Enter display name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Navigator.of(context).pop();
                userController.inviteUser(
                  email: emailController.text,
                  displayName: nameController.text.isNotEmpty ? nameController.text : null,
                );
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}