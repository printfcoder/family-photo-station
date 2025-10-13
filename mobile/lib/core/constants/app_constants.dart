class AppConstants {
  // API配置
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';
  
  // 存储键名
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userInfoKey = 'user_info';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 文件上传配置
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/heic',
    'image/heif',
  ];
  
  // 缓存配置
  static const int imageCacheMaxAge = 7 * 24 * 60 * 60; // 7天
  static const int thumbnailCacheMaxAge = 30 * 24 * 60 * 60; // 30天
  
  // 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // 网络配置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请稍后重试';
  static const String authErrorMessage = '认证失败，请重新登录';
  
  // 正则表达式
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,20}$';
  
  // 应用信息
  static const String appName = 'Family Photo Station';
  static const String appVersion = '1.0.0';
  static const String appDescription = '家庭照片管理和分享平台';
}

class ApiEndpoints {
  // 认证相关
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // 用户相关
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/password';
  static const String userDevices = '/user/devices';
  
  // 照片相关
  static const String photos = '/photos';
  static const String uploadPhoto = '/photos/upload';
  static const String photoDetail = '/photos/{id}';
  static const String photoThumbnail = '/photos/{id}/thumbnail';
  static const String photoDownload = '/photos/{id}/download';
  static const String photoTags = '/photos/{id}/tags';
  static const String photoFaces = '/photos/{id}/faces';
  
  // 相册相关
  static const String albums = '/albums';
  static const String albumDetail = '/albums/{id}';
  static const String albumPhotos = '/albums/{id}/photos';
  static const String addPhotoToAlbum = '/albums/{id}/photos';
  static const String removePhotoFromAlbum = '/albums/{id}/photos/{photoId}';
  
  // 标签相关
  static const String tags = '/tags';
  static const String tagDetail = '/tags/{id}';
  static const String tagPhotos = '/tags/{id}/photos';
  
  // 人物相关
  static const String persons = '/persons';
  static const String personDetail = '/persons/{id}';
  static const String personPhotos = '/persons/{id}/photos';
  
  // 社交相关
  static const String photoComments = '/photos/{id}/comments';
  static const String photoLikes = '/photos/{id}/likes';
  static const String photoShares = '/photos/{id}/shares';
  
  // 同步相关
  static const String syncStatus = '/sync/status';
  static const String syncHistory = '/sync/history';
  static const String startSync = '/sync/start';
  
  // 系统相关
  static const String systemConfig = '/system/config';
  static const String systemStats = '/system/stats';
}

class HiveBoxes {
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String photosBox = 'photos_box';
  static const String albumsBox = 'albums_box';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String photos = '/photos';
  static const String photoDetail = '/photos/:id';
  static const String albums = '/albums';
  static const String albumDetail = '/albums/:id';
  static const String tags = '/tags';
  static const String persons = '/persons';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String upload = '/upload';
  static const String search = '/search';
}