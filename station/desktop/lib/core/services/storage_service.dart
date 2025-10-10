import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:fixnum/fixnum.dart';

class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;
  Box? _userBox;
  Box? _settingsBox;
  Box? _cacheBox;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  factory StorageService() => instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    
    // Simplified Hive initialization, no longer using adapters
    // Open Hive boxes
    _userBox = await Hive.openBox('userBox');
    _settingsBox = await Hive.openBox('settingsBox');
    _cacheBox = await Hive.openBox('cacheBox');
  }

  Future<void> _initHive() async {
    // Remove Hive initialization since we're using pure protobuf models
    // No longer need to register adapters
  }

  // Token management
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs?.setString(AppConstants.accessTokenKey, accessToken);
    await _prefs?.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _prefs?.getString(AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _prefs?.getString(AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _prefs?.remove(AppConstants.accessTokenKey);
    await _prefs?.remove(AppConstants.refreshTokenKey);
  }

  // User info management - Simplified without Hive and JSON serialization
  Future<void> saveUser(User user) async {
    // Store user data as JSON string in SharedPreferences
    final userJson = jsonEncode({
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'displayName': user.displayName,
      'avatar': user.avatar,
      'bio': user.bio,
      'role': user.role.value,
      'isActive': user.isActive,
      'createdAt': user.createdAt.toString(),
      'updatedAt': user.updatedAt.toString(),
    });
    await _prefs?.setString(AppConstants.userInfoKey, userJson);
  }

  Future<User?> getUser() async {
    // Get from SharedPreferences
    final userJson = _prefs?.getString(AppConstants.userInfoKey);
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User(
          id: userData['id'] as String? ?? '',
          username: userData['username'] as String? ?? '',
          email: userData['email'] as String? ?? '',
          displayName: userData['displayName'] as String?,
          avatar: userData['avatar'] as String?,
          bio: userData['bio'] as String?,
          role: UserRole.valueOf(userData['role'] as int? ?? 0) ?? UserRole.USER_ROLE_UNSPECIFIED,
          isActive: userData['isActive'] as bool? ?? false,
          createdAt: Int64.parseInt(userData['createdAt'] as String? ?? '0'),
          updatedAt: Int64.parseInt(userData['updatedAt'] as String? ?? '0'),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearUser() async {
    await _userBox?.delete('current_user');
    await _prefs?.remove(AppConstants.userInfoKey);
  }

  // Theme settings
  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox?.put(AppConstants.themeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    return _settingsBox?.get(AppConstants.themeKey) as String?;
  }

  // Language settings
  Future<void> saveLanguage(String language) async {
    await _settingsBox?.put(AppConstants.languageKey, language);
  }

  Future<String?> getLanguage() async {
    return _settingsBox?.get(AppConstants.languageKey) as String?;
  }

  // Cache management
  Future<void> saveCache(String key, dynamic value, {Duration? expiry}) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _cacheBox?.put(key, cacheData);
  }

  Future<T?> getCache<T>(String key) async {
    final cacheData = _cacheBox?.get(key) as Map<String, dynamic>?;
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int;
    final expiry = cacheData['expiry'] as int?;

    // Check if expired
    if (expiry != null) {
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(timestamp + expiry);
      if (DateTime.now().isAfter(expiryTime)) {
        await _cacheBox?.delete(key);
        return null;
      }
    }

    return cacheData['value'] as T?;
  }

  Future<void> clearCache([String? key]) async {
    if (key != null) {
      await _cacheBox?.delete(key);
    } else {
      await _cacheBox?.clear();
    }
  }

  // App settings
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> removeSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  // Batch operations
  Future<void> saveMultiple(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _prefs?.setString(entry.key, entry.value.toString());
    }
  }

  Future<Map<String, String?>> getMultiple(List<String> keys) async {
    final result = <String, String?>{};
    for (final key in keys) {
      result[key] = _prefs?.getString(key);
    }
    return result;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
    await _userBox?.clear();
    await _settingsBox?.clear();
    await _cacheBox?.clear();
  }

  // Check if initialized
  bool get isInitialized => _prefs != null && _userBox != null;

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final prefsKeys = _prefs?.getKeys().length ?? 0;
    final userBoxLength = _userBox?.length ?? 0;
    final settingsBoxLength = _settingsBox?.length ?? 0;
    final cacheBoxLength = _cacheBox?.length ?? 0;

    return {
      'preferences_keys': prefsKeys,
      'user_box_items': userBoxLength,
      'settings_box_items': settingsBoxLength,
      'cache_box_items': cacheBoxLength,
      'total_items': prefsKeys + userBoxLength + settingsBoxLength + cacheBoxLength,
    };
  }

  // Data export
  Future<Map<String, dynamic>> exportData() async {
    final userData = await getUser();
    final settings = _settingsBox?.toMap() ?? {};
    final cache = _cacheBox?.toMap() ?? {};

    return {
      'user': userData != null ? {
        'id': userData.id,
        'username': userData.username,
        'email': userData.email,
        'displayName': userData.displayName,
        'avatar': userData.avatar,
        'bio': userData.bio,
        'role': userData.role.value,
        'isActive': userData.isActive,
        'createdAt': userData.createdAt.toString(),
        'updatedAt': userData.updatedAt.toString(),
      } : null,
      'settings': settings,
      'cache': cache,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Data import
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import user data
      if (data['user'] != null) {
        final userData = data['user'] as Map<String, dynamic>;
        final user = User(
          id: userData['id'] as String? ?? '',
          username: userData['username'] as String? ?? '',
          email: userData['email'] as String? ?? '',
          displayName: userData['displayName'] as String?,
          avatar: userData['avatar'] as String?,
          bio: userData['bio'] as String?,
          role: UserRole.valueOf(userData['role'] as int? ?? 0) ?? UserRole.USER_ROLE_UNSPECIFIED,
          isActive: userData['isActive'] as bool? ?? false,
          createdAt: Int64.parseInt(userData['createdAt'] as String? ?? '0'),
          updatedAt: Int64.parseInt(userData['updatedAt'] as String? ?? '0'),
        );
        await saveUser(user);
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await _settingsBox?.put(entry.key, entry.value);
        }
      }

      // Import cache (optional)
      if (data['cache'] != null) {
        final cache = data['cache'] as Map<String, dynamic>;
        for (final entry in cache.entries) {
          await _cacheBox?.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('数据导入失败: $e');
    }
  }

  // Data backup
  Future<void> backup() async {
    // TODO: 实现数据备份逻辑
  }

  // Data restore
  Future<void> restore() async {
    // TODO: 实现数据恢复逻辑
  }

  // Close all connections
  Future<void> dispose() async {
    await _userBox?.close();
    await _settingsBox?.close();
    await _cacheBox?.close();
  }
}
