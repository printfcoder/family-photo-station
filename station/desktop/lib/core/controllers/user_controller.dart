import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';
import 'package:family_photo_desktop/core/models/user.dart';

class UserController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  
  // 用户列表状态
  final RxList<User> _users = <User>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;

  // 系统统计状态
  final Rxn<SystemStats> _systemStats = Rxn<SystemStats>();
  final Rxn<StorageInfo> _storageInfo = Rxn<StorageInfo>();

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;
  SystemStats? get systemStats => _systemStats.value;
  StorageInfo? get storageInfo => _storageInfo.value;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadSystemStats();
    loadStorageInfo();
  }

  // 加载用户列表
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _users.clear();
      _hasMore.value = true;
    }

    if (_isLoading.value || !_hasMore.value) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final users = await _apiClient.api.getUsers(
        _currentPage.value,
        20, // 页面大小
      );

      if (refresh) {
        _users.assignAll(users);
      } else {
        _users.addAll(users);
      }

      _currentPage.value++;
      _hasMore.value = users.length >= 20;
      _error.value = null;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // 刷新用户列表
  @override
  Future<void> refresh() async {
    await loadUsers(refresh: true);
    await loadSystemStats();
    await loadStorageInfo();
  }

  // 加载更多用户
  Future<void> loadMore() async {
    await loadUsers();
  }

  // 加载系统统计信息
  Future<void> loadSystemStats() async {
    try {
      final stats = await _apiClient.api.getSystemStats();
      _systemStats.value = stats;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    }
  }

  // 加载存储信息
  Future<void> loadStorageInfo() async {
    try {
      final info = await _apiClient.api.getStorageInfo();
      _storageInfo.value = info;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    }
  }

  // 根据ID获取用户
  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // 搜索用户
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    return _users.where((user) {
      return user.username.toLowerCase().contains(query.toLowerCase()) ||
             user.email.toLowerCase().contains(query.toLowerCase()) ||
             (user.displayName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // 按角色过滤用户
  List<User> filterUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  // 按状态过滤用户
  List<User> filterUsersByStatus(bool isActive) {
    return _users.where((user) => user.isActive == isActive).toList();
  }

  // 获取活跃用户数量
  int get activeUsersCount {
    return _users.where((user) => user.isActive).length;
  }

  // 获取管理员用户数量
  int get adminUsersCount {
    return _users.where((user) => user.role == UserRole.admin).length;
  }

  // 获取普通用户数量
  int get regularUsersCount {
    return _users.where((user) => user.role == UserRole.user).length;
  }

  // 按注册时间排序
  void sortByCreatedAt({bool ascending = false}) {
    _users.sort((a, b) {
      return ascending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
  }

  // 按用户名排序
  void sortByUsername({bool ascending = true}) {
    _users.sort((a, b) {
      return ascending 
          ? a.username.compareTo(b.username)
          : b.username.compareTo(a.username);
    });
  }

  // 按存储使用量排序
  void sortByStorageUsage({bool ascending = false}) {
    _users.sort((a, b) {
      final aUsage = a.stats?.storageUsed ?? 0;
      final bUsage = b.stats?.storageUsed ?? 0;
      return ascending 
          ? aUsage.compareTo(bUsage)
          : bUsage.compareTo(aUsage);
    });
  }

  // 获取存储使用统计
  Map<String, double> getStorageUsageStats() {
    double totalUsed = 0;
    double maxUsage = 0;
    double minUsage = double.infinity;
    
    for (final user in _users) {
      final usage = (user.stats?.storageUsed ?? 0).toDouble();
      totalUsed += usage;
      if (usage > maxUsage) maxUsage = usage;
      if (usage < minUsage && usage > 0) minUsage = usage;
    }
    
    return {
      'total': totalUsed,
      'average': _users.isNotEmpty ? totalUsed / _users.length : 0,
      'max': maxUsage,
      'min': minUsage == double.infinity ? 0 : minUsage,
    };
  }

  // 获取用户活动统计
  Map<String, int> getUserActivityStats() {
    int activeUsers = 0;
    int inactiveUsers = 0;
    int adminUsers = 0;
    int regularUsers = 0;
    
    for (final user in _users) {
      if (user.isActive) {
        activeUsers++;
      } else {
        inactiveUsers++;
      }
      
      if (user.role == UserRole.admin) {
        adminUsers++;
      } else {
        regularUsers++;
      }
    }
    
    return {
      'active': activeUsers,
      'inactive': inactiveUsers,
      'admin': adminUsers,
      'regular': regularUsers,
      'total': _users.length,
    };
  }

  // 清除错误
  void clearError() {
    _error.value = null;
  }

  // 获取错误消息
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}