import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:family_photo_mobile/core/constants/app_constants.dart';
import 'package:family_photo_mobile/core/models/user.dart';
import 'package:family_photo_mobile/core/models/photo.dart';
import 'package:family_photo_mobile/core/models/album.dart';
import 'package:family_photo_mobile/core/models/api_models.dart';
import 'package:family_photo_mobile/core/services/storage_service.dart';

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
  );

  @DELETE(ApiEndpoints.photoDetail)
  Future<void> deletePhoto(@Path('id') String id);

  // 相册相关
  @GET(ApiEndpoints.albums)
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> getAlbumsRaw(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @GET(ApiEndpoints.albumDetail)
  Future<Album> getAlbumDetail(@Path('id') String id);

  @POST(ApiEndpoints.albums)
  Future<Album> createAlbum(@Body() CreateAlbumRequest request);

  @PUT(ApiEndpoints.albumDetail)
  Future<Album> updateAlbum(@Path('id') String id, @Body() CreateAlbumRequest request);

  @DELETE(ApiEndpoints.albumDetail)
  Future<void> deleteAlbum(@Path('id') String id);

  @GET(ApiEndpoints.albumPhotos)
  Future<PhotosResponse> getAlbumPhotos(
    @Path('id') String id,
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  @POST(ApiEndpoints.addPhotoToAlbum)
  Future<void> addPhotoToAlbum(@Path('id') String albumId, @Body() Map<String, String> request);

  @DELETE(ApiEndpoints.removePhotoFromAlbum)
  Future<void> removePhotoFromAlbum(@Path('id') String albumId, @Path('photoId') String photoId);

  // 标签相关
  @GET(ApiEndpoints.tags)
  Future<List<Tag>> getTags();

  @GET(ApiEndpoints.tagPhotos)
  Future<PhotosResponse> getTagPhotos(
    @Path('id') String id,
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  // 人物相关
  @GET(ApiEndpoints.persons)
  Future<List<Person>> getPersons();

  @GET(ApiEndpoints.personPhotos)
  Future<PhotosResponse> getPersonPhotos(
    @Path('id') String id,
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );
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
    await _apiService.getAlbumsRaw(page, pageSize);
    // TODO: Parse protobuf response to List<Album>
    // For now, return empty list to avoid compilation error
    return [];
  }

  Future<String> _getDeviceName() async {
    // TODO: 实现获取设备名称的逻辑
    return 'Mobile Device';
  }

  Future<String> _getDeviceType() async {
    // TODO: 实现获取设备类型的逻辑
    return 'mobile';
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