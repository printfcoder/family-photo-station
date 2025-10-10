import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/models/user.dart';
import 'package:family_photo_desktop/core/models/photo.dart';
import 'package:family_photo_desktop/core/models/api_models.dart';
import 'package:family_photo_desktop/core/services/storage_service.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:family_photo_desktop/core/controllers/network_controller.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConstants.apiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 认证相关
  @POST(ApiEndpoints.login)
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST(ApiEndpoints.register)
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST(ApiEndpoints.refreshToken)
  Future<AuthResponse> refreshToken(@Body() Map<String, String> request);

  @POST(ApiEndpoints.logout)
  Future<void> logout();

  // 用户相关
  @GET(ApiEndpoints.userProfile)
  Future<User> getUserProfile();

  @PUT(ApiEndpoints.updateProfile)
  Future<User> updateProfile(@Body() UpdateProfileRequest request);

  @PUT(ApiEndpoints.changePassword)
  Future<void> changePassword(@Body() ChangePasswordRequest request);

  @GET(ApiEndpoints.userDevices)
  Future<List<Device>> getUserDevices();

  // 照片相关
  @GET(ApiEndpoints.photos)
  Future<PhotosResponse> getPhotos(
    @Query('page') int page,
    @Query('page_size') int pageSize,
    @Query('album_id') String? albumId,
    @Query('tag_id') String? tagId,
    @Query('person_id') String? personId,
    @Query('search') String? search,
  );

  @GET(ApiEndpoints.photoDetail)
  Future<Photo> getPhotoDetail(@Path('id') String id);

  @POST(ApiEndpoints.uploadPhoto)
  @MultiPart()
  Future<Photo> uploadPhoto(
    @Part() File file,
    @Part() String filename,
    @Part() String mimeType,
    @Part() int fileSize,
    @Part() String? albumId,
    @Part() List<String>? tags,
    @Part() String? description,
  );

  @DELETE(ApiEndpoints.photoDetail)
  Future<void> deletePhoto(@Path('id') String id);

  @PUT(ApiEndpoints.photoDetail)
  Future<Photo> updatePhoto(@Path('id') String id, @Body() Map<String, dynamic> data);

  // 相册相关
  @GET(ApiEndpoints.albums)
  Future<List<Album>> getAlbums(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @GET(ApiEndpoints.albumDetail)
  Future<Album> getAlbumDetail(@Path('id') String id);

  @POST(ApiEndpoints.albums)
  Future<Album> createAlbum(@Body() Map<String, dynamic> data);

  @PUT(ApiEndpoints.albumDetail)
  Future<Album> updateAlbum(@Path('id') String id, @Body() Map<String, dynamic> data);

  @DELETE(ApiEndpoints.albumDetail)
  Future<void> deleteAlbum(@Path('id') String id);

  @GET(ApiEndpoints.albumPhotos)
  Future<PhotosResponse> getAlbumPhotos(
    @Path('id') String id,
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  // 标签相关
  @GET(ApiEndpoints.tags)
  Future<List<Tag>> getTags();

  @POST(ApiEndpoints.tags)
  Future<Tag> createTag(@Body() Map<String, dynamic> data);

  // 人物相关
  @GET(ApiEndpoints.persons)
  Future<List<Person>> getPersons();

  // 系统管理相关（桌面端特有）
  @GET('/admin/users')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getUsersRaw(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @POST('/admin/users/invite')
  Future<User> inviteUser(@Body() Map<String, dynamic> data);

  @PUT('/admin/users/{id}/status')
  Future<User> updateUserStatus(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @PUT('/admin/users/{id}/role')
  Future<User> updateUserRole(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/admin/users/{id}')
  Future<void> deleteUser(@Path('id') String id);

  @DELETE('/admin/users')
  Future<void> deleteUsers(@Body() Map<String, dynamic> data);

  @GET('/admin/stats')
  Future<SystemStats> getSystemStats();

  @GET('/admin/storage')
  Future<StorageInfo> getStorageInfo();
}

// Extension to add concrete methods
extension ApiServiceExtension on ApiService {
  Future<List<User>> getUsers(int page, int pageSize) async {
    final response = await getUsersRaw(page, pageSize);
    final userList = UserList.fromBuffer(response.data);
    return userList.users;
  }
}

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final ApiService _apiService;
  final StorageService _storageService = StorageService();

  ApiClient._internal() {
    _dio = Dio();
    _setupDio();
    _apiService = ApiService(_dio);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiService get api => _apiService;

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加认证头
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // 处理401错误，尝试刷新token
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // 重试原请求
              final options = error.requestOptions;
              final token = await _storageService.getAccessToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // 重试失败，继续原错误处理
              }
            }
          }
          // 将错误传递给网络控制器用于 UI 显示
          try {
            final networkController = Get.find<NetworkController>();
            networkController.handleNetworkError(error);
          } catch (_) {
            // 如果控制器尚未初始化，则忽略
          }
          handler.next(error);
        },
      ),
    );

    // 添加日志拦截器（仅在调试模式下）
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.refreshToken({
        'refresh_token': refreshToken,
      });

      await _storageService.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      await _storageService.saveUser(response.user);

      return true;
    } catch (e) {
      // 刷新失败，清除本地数据
      await _storageService.clearAll();
      return false;
    }
  }

  // 便捷方法
  Future<AuthResponse> login(String username, String password) async {
    final request = LoginRequest(
      username: username,
      password: password,
      deviceName: await _getDeviceName(),
      deviceType: await _getDeviceType(),
    );
    return _apiService.login(request);
  }

  Future<AuthResponse> register(String username, String email, String password, {String? displayName}) async {
    final request = RegisterRequest(
      username: username,
      email: email,
      password: password,
      displayName: displayName,
      deviceName: await _getDeviceName(),
      deviceType: await _getDeviceType(),
    );
    return _apiService.register(request);
  }

  Future<PhotosResponse> getPhotos({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? albumId,
    String? tagId,
    String? personId,
    String? search,
  }) async {
    return _apiService.getPhotos(page, pageSize, albumId, tagId, personId, search);
  }

  Future<List<Album>> getAlbums({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    return _apiService.getAlbums(page, pageSize);
  }

  Future<String> _getDeviceName() async {
    // 桌面端设备名称
    return 'Desktop Station';
  }

  Future<String> _getDeviceType() async {
    // 桌面端设备类型
    return 'desktop';
  }
}

// 异常处理
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message';

  static ApiException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(AppConstants.networkErrorMessage);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? AppConstants.serverErrorMessage;
        return ApiException(message, statusCode: statusCode, data: error.response?.data);
      case DioExceptionType.cancel:
        return ApiException('请求已取消');
      case DioExceptionType.unknown:
      default:
        return ApiException(AppConstants.unknownErrorMessage);
    }
  }
}

// 桌面端特有的数据模型
class SystemStats {
  final int totalUsers;
  final int totalPhotos;
  final int totalAlbums;
  final int totalTags;
  final double storageUsed;
  final double storageTotal;

  SystemStats({
    required this.totalUsers,
    required this.totalPhotos,
    required this.totalAlbums,
    required this.totalTags,
    required this.storageUsed,
    required this.storageTotal,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      totalUsers: json['total_users'] ?? 0,
      totalPhotos: json['total_photos'] ?? 0,
      totalAlbums: json['total_albums'] ?? 0,
      totalTags: json['total_tags'] ?? 0,
      storageUsed: (json['storage_used'] ?? 0).toDouble(),
      storageTotal: (json['storage_total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_photos': totalPhotos,
      'total_albums': totalAlbums,
      'total_tags': totalTags,
      'storage_used': storageUsed,
      'storage_total': storageTotal,
    };
  }
}

class StorageInfo {
  final double used;
  final double total;
  final double available;
  final List<StorageBreakdown> breakdown;

  StorageInfo({
    required this.used,
    required this.total,
    required this.available,
    required this.breakdown,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    return StorageInfo(
      used: (json['used'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      available: (json['available'] ?? 0).toDouble(),
      breakdown: (json['breakdown'] as List<dynamic>?)
          ?.map((item) => StorageBreakdown.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'used': used,
      'total': total,
      'available': available,
      'breakdown': breakdown.map((item) => item.toJson()).toList(),
    };
  }
}

class StorageBreakdown {
  final String category;
  final double size;
  final int count;

  StorageBreakdown({
    required this.category,
    required this.size,
    required this.count,
  });

  factory StorageBreakdown.fromJson(Map<String, dynamic> json) {
    return StorageBreakdown(
      category: json['category'] ?? '',
      size: (json['size'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'size': size,
      'count': count,
    };
  }
}

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
          ?.map((item) => Photo.fromBuffer((item as Map<String, dynamic>).toString().codeUnits))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
    );
  }
}

class Album {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int photoCount;
  final DateTime createdAt;

  Album({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.photoCount,
    required this.createdAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: json['cover_url'],
      photoCount: json['photo_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_url': coverUrl,
      'photo_count': photoCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

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
