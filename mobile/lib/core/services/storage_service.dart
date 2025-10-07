import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:family_photo_mobile/core/constants/app_constants.dart';
import 'package:family_photo_mobile/core/models/user.dart';

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
    
    // 注册Hive适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DeviceAdapter());
    }

    // 打开Hive boxes
    _userBox = await Hive.openBox(HiveBoxes.userBox);
    _settingsBox = await Hive.openBox(HiveBoxes.settingsBox);
    _cacheBox = await Hive.openBox(HiveBoxes.cacheBox);
  }

  // Token管理
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

  // 用户信息管理
  Future<void> saveUser(User user) async {
    await _userBox?.put('current_user', user);
    await _prefs?.setString(AppConstants.userInfoKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    // 优先从Hive获取
    final user = _userBox?.get('current_user') as User?;
    if (user != null) return user;

    // 从SharedPreferences获取
    final userJson = _prefs?.getString(AppConstants.userInfoKey);
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
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

  // 主题设置
  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox?.put(AppConstants.themeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    return _settingsBox?.get(AppConstants.themeKey) as String?;
  }

  // 语言设置
  Future<void> saveLanguage(String language) async {
    await _settingsBox?.put(AppConstants.languageKey, language);
  }

  Future<String?> getLanguage() async {
    return _settingsBox?.get(AppConstants.languageKey) as String?;
  }

  // 缓存管理
  Future<void> saveCache(String key, dynamic value, {Duration? expiry}) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _cacheBox?.put(key, cacheData);
  }

  Future<T?> getCache<T>(String key) async {
    final cacheData = _cacheBox?.get(key) as Map<dynamic, dynamic>?;
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int?;
    final expiry = cacheData['expiry'] as int?;

    if (timestamp != null && expiry != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
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

  // 应用设置
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    final value = _settingsBox?.get(key) as T?;
    return value ?? defaultValue;
  }

  Future<void> removeSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  // 批量操作
  Future<void> saveMultiple(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _prefs?.setString(entry.key, jsonEncode(entry.value));
    }
  }

  Future<Map<String, dynamic>> getMultiple(List<String> keys) async {
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = _prefs?.getString(key);
      if (value != null) {
        try {
          result[key] = jsonDecode(value);
        } catch (e) {
          result[key] = value;
        }
      }
    }
    return result;
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await _prefs?.clear();
    await _userBox?.clear();
    await _settingsBox?.clear();
    await _cacheBox?.clear();
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // 获取存储统计信息
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

  // 清理过期缓存
  Future<void> cleanExpiredCache() async {
    if (_cacheBox == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToDelete = <String>[];

    for (final key in _cacheBox!.keys) {
      final cacheData = _cacheBox!.get(key) as Map<dynamic, dynamic>?;
      if (cacheData != null) {
        final timestamp = cacheData['timestamp'] as int?;
        final expiry = cacheData['expiry'] as int?;

        if (timestamp != null && expiry != null) {
          if (now - timestamp > expiry) {
            keysToDelete.add(key.toString());
          }
        }
      }
    }

    for (final key in keysToDelete) {
      await _cacheBox!.delete(key);
    }
  }

  // 导出数据（用于备份）
  Future<Map<String, dynamic>> exportData() async {
    final user = await getUser();
    final settings = _settingsBox?.toMap() ?? {};
    
    return {
      'user': user?.toJson(),
      'settings': settings,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // 导入数据（用于恢复）
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // 导入用户数据
      if (data['user'] != null) {
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        await saveUser(user);
      }

      // 导入设置
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await _settingsBox?.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('导入数据失败: $e');
    }
  }
}