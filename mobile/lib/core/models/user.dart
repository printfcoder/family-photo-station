import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String? displayName;
  
  @HiveField(4)
  final String? avatar;
  
  @HiveField(5)
  final String? bio;
  
  @HiveField(6)
  final UserRole role;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;
  
  @HiveField(10)
  final UserStats? stats;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatar,
    this.bio,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatar,
    String? bio,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }
}

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  user,
  @HiveField(2)
  guest,
}

@JsonSerializable()
@HiveType(typeId: 2)
class UserStats extends HiveObject {
  @HiveField(0)
  final int photoCount;
  
  @HiveField(1)
  final int albumCount;
  
  @HiveField(2)
  final int tagCount;
  
  @HiveField(3)
  final int shareCount;
  
  @HiveField(4)
  final int storageUsed;
  
  @HiveField(5)
  final int storageLimit;

  UserStats({
    required this.photoCount,
    required this.albumCount,
    required this.tagCount,
    required this.shareCount,
    required this.storageUsed,
    required this.storageLimit,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  double get storageUsagePercentage {
    if (storageLimit == 0) return 0.0;
    return (storageUsed / storageLimit).clamp(0.0, 1.0);
  }

  String get formattedStorageUsed {
    return _formatBytes(storageUsed);
  }

  String get formattedStorageLimit {
    return _formatBytes(storageLimit);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

@JsonSerializable()
@HiveType(typeId: 3)
class Device extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String type;
  
  @HiveField(3)
  final String? model;
  
  @HiveField(4)
  final String? osVersion;
  
  @HiveField(5)
  final String? appVersion;
  
  @HiveField(6)
  final bool isActive;
  
  @HiveField(7)
  final DateTime lastActiveAt;
  
  @HiveField(8)
  final DateTime createdAt;

  Device({
    required this.id,
    required this.name,
    required this.type,
    this.model,
    this.osVersion,
    this.appVersion,
    required this.isActive,
    required this.lastActiveAt,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;
  final String? deviceName;
  final String? deviceType;

  LoginRequest({
    required this.username,
    required this.password,
    this.deviceName,
    this.deviceType,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? displayName;
  final String? deviceName;
  final String? deviceType;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
    this.deviceName,
    this.deviceType,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String? displayName;
  final String? bio;
  final String? avatar;

  UpdateProfileRequest({
    this.displayName,
    this.bio,
    this.avatar,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}