import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/features/users/controllers/user_controller.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/features/users/models/user_enums.dart';

class UsersController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    userController.loadUsers();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Getters for reactive values
  RxBool get isLoading => userController.isLoading;
  RxString get error => userController.error;
  RxList<User> get filteredUsers => userController.filteredUsers;
  RxBool get isSelectionMode => userController.isSelectionMode;
  RxSet<String> get selectedUsers => userController.selectedUsers;
  Rx<UserFilterBy> get filterBy => userController.filterBy;
  Rx<UserSortBy> get sortBy => userController.sortBy;

  // Computed properties
  int get selectedCount => userController.selectedCount;
  bool get hasSelection => userController.hasSelection;
  User? get currentUser => authController.user;

  // Methods
  void loadUsers() => userController.loadUsers();
  void refreshUsers() => userController.refreshUsers();
  void searchUsers(String query) => userController.searchUsers(query);
  void setFilterBy(UserFilterBy filter) => userController.setFilterBy(filter);
  void setSortBy(UserSortBy sort) => userController.setSortBy(sort);
  void toggleSelectionMode() => userController.toggleSelectionMode();
  void selectUser(String userId) => userController.selectUser(userId);
  void deleteSelectedUsers() => userController.deleteSelectedUsers();
  void toggleUserActive(String userId) => userController.toggleUserActive(userId);
  void deleteUser(String userId) => userController.deleteUser(userId);

  void inviteUser({required String email, String? displayName}) {
    userController.inviteUser(email: email, displayName: displayName);
  }

  String getSortDisplayName(UserSortBy sort) => userController.getSortDisplayName(sort);

  IconData getSortIcon(UserSortBy sort) {
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

  void handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        showUserDetails(user);
        break;
      case 'activate':
      case 'deactivate':
        showToggleActiveDialog(user);
        break;
      case 'delete':
        showDeleteUserDialog(user);
        break;
    }
  }

  void showUserDetails(User user) {
    Get.dialog(
      AlertDialog(
        title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Username: ${user.username}'),
            Text('Role: ${user.role.toString().split('.').last}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
            Text('Created: ${user.createdAt.toInt()}'),
            if (user.hasStats()) ...[
              const SizedBox(height: 8),
              Text('Photos: ${user.stats.photoCount}'),
              Text('Albums: ${user.stats.albumCount}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showToggleActiveDialog(User user) {
    final action = user.isActive ? 'deactivate' : 'activate';
    Get.dialog(
      AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} User'),
        content: Text('Are you sure you want to $action ${user.displayName.isNotEmpty ? user.displayName : user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              toggleUserActive(user.id);
            },
            child: Text('${action[0].toUpperCase()}${action.substring(1)}'),
          ),
        ],
      ),
    );
  }

  void showDeleteUserDialog(User user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.displayName.isNotEmpty ? user.displayName : user.username}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showDeleteSelectedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Selected Users'),
        content: Text('Are you sure you want to delete $selectedCount users? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteSelectedUsers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showInviteUserDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
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
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                Get.back();
                inviteUser(
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