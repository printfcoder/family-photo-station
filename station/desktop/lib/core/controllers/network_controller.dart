import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';

class NetworkController extends GetxController {
  final Dio _dio = Dio();
  
  bool _isConnected = true;
  String _errorMessage = '';
  
  bool get isConnected => _isConnected;
  String get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    _setupDio();
    checkConnection();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    );
  }

  Future<void> checkConnection() async {
    try {
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        _setConnectionStatus(true, '');
      } else {
        _setConnectionStatus(false, '服务器响应异常 (${response.statusCode})');
      }
    } on DioException catch (e) {
      String errorMsg = '';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMsg = '连接超时，请检查网络连接';
          break;
        case DioExceptionType.connectionError:
          errorMsg = '无法连接到服务器，请检查后端服务是否启动';
          break;
        case DioExceptionType.badResponse:
          errorMsg = '服务器错误 (${e.response?.statusCode})';
          break;
        case DioExceptionType.cancel:
          errorMsg = '请求已取消';
          break;
        case DioExceptionType.unknown:
        default:
          errorMsg = '网络连接失败，请稍后重试';
          break;
      }
      _setConnectionStatus(false, errorMsg);
    } catch (e) {
      _setConnectionStatus(false, '未知错误: ${e.toString()}');
    }
  }

  void _setConnectionStatus(bool connected, String message) {
    if (_isConnected != connected || _errorMessage != message) {
      _isConnected = connected;
      _errorMessage = message;
      update();
    }
  }

  // 监听网络错误
  void handleNetworkError(dynamic error) {
    if (error is DioException) {
      String errorMsg = '';
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMsg = '连接超时，请检查网络连接';
          break;
        case DioExceptionType.connectionError:
          errorMsg = '无法连接到服务器，请检查后端服务是否启动';
          break;
        case DioExceptionType.badResponse:
          errorMsg = '服务器错误 (${error.response?.statusCode})';
          break;
        case DioExceptionType.cancel:
          errorMsg = '请求已取消';
          break;
        case DioExceptionType.unknown:
        default:
          errorMsg = '网络连接失败，请稍后重试';
          break;
      }
      _setConnectionStatus(false, errorMsg);
    } else {
      _setConnectionStatus(false, '网络连接异常: ${error.toString()}');
    }
  }

  // 重置连接状态
  void resetConnectionStatus() {
    _setConnectionStatus(true, '');
  }
}