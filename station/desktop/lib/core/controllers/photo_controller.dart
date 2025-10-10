import 'package:get/get.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';
import 'package:family_photo_desktop/core/models/photo.dart';

class PhotoController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  
  // Photo list state
  final RxList<Photo> _photos = <Photo>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;

  // Search and filter state
  final RxnString _searchQuery = RxnString();
  final RxnString _selectedAlbumId = RxnString();
  final RxnString _selectedTagId = RxnString();
  final RxnString _selectedPersonId = RxnString();

  // Getters
  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;
  String? get searchQuery => _searchQuery.value;
  String? get selectedAlbumId => _selectedAlbumId.value;
  String? get selectedTagId => _selectedTagId.value;
  String? get selectedPersonId => _selectedPersonId.value;

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  // Load photo list
  Future<void> loadPhotos({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _photos.clear();
      _hasMore.value = true;
    }

    if (_isLoading.value || !_hasMore.value) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _apiClient.getPhotos(
        page: _currentPage.value,
        albumId: _selectedAlbumId.value,
        tagId: _selectedTagId.value,
        personId: _selectedPersonId.value,
        search: _searchQuery.value,
      );

      if (refresh) {
        _photos.assignAll(response.photos);
      } else {
        _photos.addAll(response.photos);
      }

      _currentPage.value++;
      _hasMore.value = response.photos.length >= response.pageSize;
      _error.value = null;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh photo list
  @override
  Future<void> refresh() async {
    await loadPhotos(refresh: true);
  }

  // Load more photos
  Future<void> loadMore() async {
    await loadPhotos();
  }

  // Search photos
  Future<void> searchPhotos(String query) async {
    _searchQuery.value = query.isEmpty ? null : query;
    await loadPhotos(refresh: true);
  }

  // Filter by album
  Future<void> filterByAlbum(String? albumId) async {
    _selectedAlbumId.value = albumId;
    await loadPhotos(refresh: true);
  }

  // Filter by tags
  Future<void> filterByTag(String? tagId) async {
    _selectedTagId.value = tagId;
    await loadPhotos(refresh: true);
  }

  // Filter by people
  Future<void> filterByPerson(String? personId) async {
    _selectedPersonId.value = personId;
    await loadPhotos(refresh: true);
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _searchQuery.value = null;
    _selectedAlbumId.value = null;
    _selectedTagId.value = null;
    _selectedPersonId.value = null;
    await loadPhotos(refresh: true);
  }

  // Get photo by ID
  Photo? getPhotoById(String photoId) {
    try {
      return _photos.firstWhere((photo) => photo.id == photoId);
    } catch (e) {
      return null;
    }
  }

  // Get photo details
  Future<Photo?> getPhotoDetail(String photoId) async {
    try {
      _isLoading.value = true;
      final photo = await _apiClient.api.getPhotoDetail(photoId);
      
      // Update photo info in local list
      final index = _photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        _photos[index] = photo;
      }
      
      return photo;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      _isLoading.value = true;
      await _apiClient.api.deletePhoto(photoId);
      
      // Remove from local list
      _photos.removeWhere((photo) => photo.id == photoId);
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 更新照片信息
  Future<bool> updatePhoto(String photoId, Map<String, dynamic> data) async {
    try {
      _isLoading.value = true;
      final updatedPhoto = await _apiClient.api.updatePhoto(photoId, data);
      
      // Update photo info in local list
      final index = _photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        _photos[index] = updatedPhoto;
      }
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // 批量删除照片
  Future<bool> deletePhotos(List<String> photoIds) async {
    try {
      _isLoading.value = true;
      
      // 逐个删除（如果API支持批量删除，可以优化）
      for (final photoId in photoIds) {
        await _apiClient.api.deletePhoto(photoId);
      }
      
      // Remove from local list
      _photos.removeWhere((photo) => photoIds.contains(photo.id));
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
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

  // 按日期排序
  void sortByDate({bool ascending = false}) {
    _photos.sort((a, b) {
      return ascending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
  }

  // 按名称排序
  void sortByName({bool ascending = true}) {
    _photos.sort((a, b) {
      return ascending 
          ? a.filename.compareTo(b.filename)
          : b.filename.compareTo(a.filename);
    });
  }

  // 按文件大小排序
  void sortBySize({bool ascending = false}) {
    _photos.sort((a, b) {
      return ascending 
          ? a.fileSize.compareTo(b.fileSize)
          : b.fileSize.compareTo(a.fileSize);
    });
  }

  // 按日期范围过滤
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    // 这里可以实现本地过滤或者调用API过滤
    // 暂时使用本地过滤
    final filteredPhotos = _photos.where((photo) {
      final photoDate = DateTime.fromMillisecondsSinceEpoch(photo.createdAt.toInt());
      return photoDate.isAfter(startDate) && photoDate.isBefore(endDate);
    }).toList();
    _photos.assignAll(filteredPhotos);
  }

  // Filter by tags
  Future<void> filterByTags(List<String> tags) async {
    if (tags.isEmpty) {
      // 过滤未标记的照片
      final filteredPhotos = _photos.where((photo) {
        return photo.tags == null || photo.tags!.isEmpty;
      }).toList();
      _photos.assignAll(filteredPhotos);
    } else {
      // 过滤包含指定标签的照片
      final filteredPhotos = _photos.where((photo) {
        if (photo.tags == null) return false;
        return tags.any((tag) => photo.tags!.contains(tag));
      }).toList();
      _photos.assignAll(filteredPhotos);
    }
  }
}
