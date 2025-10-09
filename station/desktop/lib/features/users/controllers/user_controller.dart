import 'package:get/get.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';
import 'package:protobuf/protobuf.dart';

// Import enums from separate file
import '../models/user_enums.dart';

class UserController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  // Observable state
  final RxList<User> _allUsers = <User>[].obs;
  final RxList<User> filteredUsers = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<UserSortBy> sortBy = UserSortBy.newest.obs;
  final Rx<UserFilterBy> filterBy = UserFilterBy.all.obs;

  // Selection mode
  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedUsers = <String>{}.obs;

  // Getters
  List<User> get allUsers => _allUsers;
  bool get hasSelection => selectedUsers.isNotEmpty;
  int get selectedCount => selectedUsers.length;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to changes and update filtered users
    ever(searchQuery, (_) => _updateFilteredUsers());
    ever(sortBy, (_) => _updateFilteredUsers());
    ever(filterBy, (_) => _updateFilteredUsers());
    ever(_allUsers, (_) => _updateFilteredUsers());
  }

  // Load users from API
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final users = await _apiClient.api.getUsers(1, 100);
      _allUsers.assignAll(users);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh users
  Future<void> refreshUsers() async {
    await loadUsers();
  }

  // Search users
  void searchUsers(String query) {
    searchQuery.value = query.toLowerCase();
  }

  // Set sort option
  void setSortBy(UserSortBy sort) {
    sortBy.value = sort;
  }

  // Set filter option
  void setFilterBy(UserFilterBy filter) {
    filterBy.value = filter;
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedUsers.clear();
    }
  }

  // Select/deselect user
  void selectUser(String userId) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
    
    if (selectedUsers.contains(userId)) {
      selectedUsers.remove(userId);
      if (selectedUsers.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedUsers.add(userId);
    }
  }

  // Select all filtered users
  void selectAllUsers() {
    selectedUsers.addAll(filteredUsers.map((user) => user.id));
  }

  // Deselect all users
  void deselectAllUsers() {
    selectedUsers.clear();
    isSelectionMode.value = false;
  }

  // Invite user
  Future<void> inviteUser({
    required String email,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final userData = {
        'email': email,
        if (displayName != null) 'display_name': displayName,
      };
      
      await _apiClient.api.inviteUser(userData);
      
      Get.snackbar(
        'Success',
        'User invitation sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Refresh users list
      await refreshUsers();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to invite user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 切换用户激活状态
  Future<void> toggleUserActive(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final user = _allUsers.firstWhere((u) => u.id == userId);
      final newStatus = !user.isActive;
      
      final statusData = {
        'is_active': newStatus,
      };
      
      await _apiClient.api.updateUserStatus(userId, statusData);
      
      // Update local user
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index] = user.rebuild((u) => u.isActive = newStatus);
      }
      
      Get.snackbar(
        'Success',
        'User status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update user status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.api.deleteUser(userId);
      
      // Remove from local list
      _allUsers.removeWhere((user) => user.id == userId);
      selectedUsers.remove(userId);
      
      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete user: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete selected users
  Future<void> deleteSelectedUsers() async {
    if (selectedUsers.isEmpty) return;
    
    try {
      isLoading.value = true;
      error.value = '';
      final deletedCount = selectedUsers.length;
      
      final userIdsData = {
        'user_ids': selectedUsers.toList(),
      };
      
      await _apiClient.api.deleteUsers(userIdsData);
      
      // Remove from local list
      _allUsers.removeWhere((user) => selectedUsers.contains(user.id));
      selectedUsers.clear();
      isSelectionMode.value = false;
      
      Get.snackbar(
        'Success',
        '$deletedCount users deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final roleData = {
        'role': role.toString().split('.').last,
      };
      
      await _apiClient.api.updateUserRole(userId, roleData);
      
      // Update local user
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].rebuild((u) => u.role = role);
      }
      
      Get.snackbar(
        'Success',
        'User role updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update user role: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user by ID
  User? getUserById(String userId) {
    try {
      return _allUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Update filtered users based on search, sort, and filter
  void _updateFilteredUsers() {
    var users = List<User>.from(_allUsers);
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      users = users.where((user) {
        final query = searchQuery.value.toLowerCase();
        return user.username.toLowerCase().contains(query) ||
               user.email.toLowerCase().contains(query) ||
               user.displayName.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply status filter
    switch (filterBy.value) {
      case UserFilterBy.all:
        // No additional filtering
        break;
      case UserFilterBy.active:
        users = users.where((user) => user.isActive).toList();
        break;
      case UserFilterBy.inactive:
        users = users.where((user) => !user.isActive).toList();
        break;
      case UserFilterBy.admin:
        users = users.where((user) => user.role == UserRole.USER_ROLE_ADMIN).toList();
        break;
    }
    
    // Apply sorting
    switch (sortBy.value) {
      case UserSortBy.newest:
        users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case UserSortBy.oldest:
        users.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case UserSortBy.name:
        users.sort((a, b) {
          final aName = a.displayName.isNotEmpty ? a.displayName : a.username;
          final bName = b.displayName.isNotEmpty ? b.displayName : b.username;
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
      case UserSortBy.email:
        users.sort((a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));
        break;
    }
    
    filteredUsers.assignAll(users);
  }

  // Get display name for sort option
  String getSortDisplayName(UserSortBy sort) {
    switch (sort) {
      case UserSortBy.newest:
        return 'Newest First';
      case UserSortBy.oldest:
        return 'Oldest First';
      case UserSortBy.name:
        return 'Name A-Z';
      case UserSortBy.email:
        return 'Email A-Z';
    }
  }

  // Get display name for filter option
  String getFilterDisplayName(UserFilterBy filter) {
    switch (filter) {
      case UserFilterBy.all:
        return 'All Users';
      case UserFilterBy.active:
        return 'Active Users';
      case UserFilterBy.inactive:
        return 'Inactive Users';
      case UserFilterBy.admin:
        return 'Admins';
    }
  }
}