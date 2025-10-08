import 'package:family_photo_mobile/core/models/user.dart';
import 'package:family_photo_mobile/core/models/photo.dart';// Authentication models
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
      user: User.fromBuffer((json['user'] as String).codeUnits),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.writeToJson(),
    };
  }
}

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

class UpdateProfileRequest {
  final String? displayName;
  final String? bio;
  final String? avatar;

  UpdateProfileRequest({
    this.displayName,
    this.bio,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (avatar != null) data['avatar'] = avatar;
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

// Device model
class Device {
  final String id;
  final String name;
  final String type;
  final String? lastActiveAt;
  final bool isActive;

  Device({
    required this.id,
    required this.name,
    required this.type,
    this.lastActiveAt,
    required this.isActive,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      lastActiveAt: json['last_active_at'],
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'last_active_at': lastActiveAt,
      'is_active': isActive,
    };
  }
}

// Photos response model
class PhotosResponse {
  final List<Photo> photos;
  final int total;
  final int page;
  final int pageSize;

  PhotosResponse({
    required this.photos,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PhotosResponse.fromJson(Map<String, dynamic> json) {
    return PhotosResponse(
      photos: (json['photos'] as List<dynamic>?)
          ?.map((item) => Photo.fromBuffer((item as String).codeUnits))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photos': photos.map((photo) => photo.writeToJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
    };
  }
}

// Album creation request
class CreateAlbumRequest {
  final String name;
  final String? description;
  final bool isPublic;

  CreateAlbumRequest({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'is_public': isPublic,
    };
  }
}

// Tag model
class Tag {
  final String id;
  final String name;
  final int photoCount;

  Tag({
    required this.id,
    required this.name,
    required this.photoCount,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoCount: json['photo_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_count': photoCount,
    };
  }
}

// Person model
class Person {
  final String id;
  final String name;
  final String? avatarUrl;
  final int photoCount;

  Person({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.photoCount,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      photoCount: json['photo_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'photo_count': photoCount,
    };
  }
}