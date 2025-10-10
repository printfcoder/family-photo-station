// API请求和响应模型
// 这些模型用于与API通信，与protobuf生成的模型分离

import 'package:fixnum/fixnum.dart';
import 'package:family_photo_desktop/core/models/user.dart';

// 认证相关模型
class LoginRequest {
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;

  LoginRequest({
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'device_name': deviceName,
      'device_type': deviceType,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? displayName;
  final String deviceName;
  final String deviceType;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
    required this.deviceName,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'display_name': displayName,
      'device_name': deviceName,
      'device_type': deviceType,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: _parseUser(json['user'] as Map<String, dynamic>),
    );
  }
}

class UpdateProfileRequest {
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  UpdateProfileRequest({
    this.displayName,
    this.email,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (email != null) data['email'] = email;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}

class Device {
  final String id;
  final String name;
  final String type;
  final DateTime lastSeen;
  final bool isActive;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.lastSeen,
    required this.isActive,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      lastSeen: DateTime.parse(json['last_seen'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'last_seen': lastSeen.toIso8601String(),
      'is_active': isActive,
    };
  }
}

// 辅助函数：从JSON解析User对象
User _parseUser(Map<String, dynamic> json) {
  final user = User();
  
  user.id = json['id'] ?? '';
  user.username = json['username'] ?? '';
  user.email = json['email'] ?? '';
  user.displayName = json['display_name'] ?? '';
  user.avatar = json['avatar_url'] ?? '';
  user.isActive = json['is_active'] ?? false;
  
  // 解析角色
  final roleStr = json['role'] as String?;
  if (roleStr != null) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        user.role = UserRole.USER_ROLE_ADMIN;
        break;
      case 'user':
      default:
        user.role = UserRole.USER_ROLE_USER;
        break;
    }
  }
  
  // 解析时间戳
  if (json['created_at'] != null) {
    user.createdAt = Int64(DateTime.parse(json['created_at']).millisecondsSinceEpoch);
  }
  if (json['updated_at'] != null) {
    user.updatedAt = Int64(DateTime.parse(json['updated_at']).millisecondsSinceEpoch);
  }
  
  // 解析统计信息
  if (json['stats'] != null) {
    final statsJson = json['stats'] as Map<String, dynamic>;
    final stats = UserStats();
    stats.photoCount = statsJson['photo_count'] ?? 0;
    stats.albumCount = statsJson['album_count'] ?? 0;
    stats.totalStorageUsed = Int64(statsJson['total_storage_used'] ?? 0);
    user.stats = stats;
  }
  
  return user;
}
