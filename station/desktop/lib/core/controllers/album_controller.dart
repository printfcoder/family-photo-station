import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';
import 'package:family_photo_desktop/core/models/photo.dart';

class AlbumController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  
  // 相册列表状态
  final RxList<Album> _albums = <Album>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;

  // Getters
  List<Album> get albums => _albums;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;

  @override
  void onInit() {
    super.onInit();
    loadAlbums();
  }

  // 加载相册列表
  Future<void> loadAlbums({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _albums.clear();
      _hasMore.value = true;
    }

    if (_isLoading.value || !_hasMore.value) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final albums = await _apiClient.getAlbums(
        page: _currentPage.value,
      );

      if (refresh) {
        _albums.assignAll(albums);
      } else {
        _albums.addAll(albums);
      }

      _currentPage.value++;
      _hasMore.value = albums.length >= 20; // 默认页面大小
      _error.value = null;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // 刷新相册列表
  @override
  Future<void> refresh() async {
    await loadAlbums(refresh: true);
  }

  // 加载更多相册
  Future<void> loadMore() async {
    await loadAlbums();
  }

  // 创建新相册
  Future<bool> createAlbum({
    required String name,
    String? description,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final album = await _apiClient.api.createAlbum({
        'name': name,
        'description': description ?? '',
      });
      
      _albums.insert(0, album);
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 更新相册信息
  Future<bool> updateAlbum(String albumId, {
    String? name,
    String? description,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final updatedAlbum = await _apiClient.api.updateAlbum(albumId, data);
      
      // 更新本地列表中的相册信息
      final index = _albums.indexWhere((album) => album.id == albumId);
      if (index != -1) {
        _albums[index] = updatedAlbum;
      }
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 删除相册
  Future<bool> deleteAlbum(String albumId) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      await _apiClient.api.deleteAlbum(albumId);
      
      // 从本地列表中移除
      _albums.removeWhere((album) => album.id == albumId);
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 获取相册详情
  Future<Album?> getAlbumDetail(String albumId) async {
    try {
      _isLoading.value = true;
      final album = await _apiClient.api.getAlbumDetail(albumId);
      
      // 更新本地列表中的相册信息
      final index = _albums.indexWhere((a) => a.id == albumId);
      if (index != -1) {
        _albums[index] = album;
      }
      
      return album;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // 获取相册中的照片
  Future<PhotosResponse?> getAlbumPhotos(String albumId, {int page = 1}) async {
    try {
      _isLoading.value = true;
      final response = await _apiClient.api.getAlbumPhotos(albumId, page, 20);
      return response;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // 根据ID获取相册
  Album? getAlbumById(String albumId) {
    try {
      return _albums.firstWhere((album) => album.id == albumId);
    } catch (e) {
      return null;
    }
  }

  // 搜索相册
  List<Album> searchAlbums(String query) {
    if (query.isEmpty) return _albums;
    
    return _albums.where((album) {
      return album.name.toLowerCase().contains(query.toLowerCase()) ||
             (album.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // 按创建时间排序
  void sortByCreatedAt({bool ascending = false}) {
    _albums.sort((a, b) {
      return ascending 
          ? (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0))
          : (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });
  }

  // 按名称排序
  void sortByName({bool ascending = true}) {
    _albums.sort((a, b) {
      return ascending 
          ? (a.name ?? '').compareTo(b.name ?? '')
          : (b.name ?? '').compareTo(a.name ?? '');
    });
  }

  // 按照片数量排序
  void sortByPhotoCount({bool ascending = false}) {
    _albums.sort((a, b) {
      return ascending 
          ? (a.photoCount ?? 0).compareTo(b.photoCount ?? 0)
          : (b.photoCount ?? 0).compareTo(a.photoCount ?? 0);
    });
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