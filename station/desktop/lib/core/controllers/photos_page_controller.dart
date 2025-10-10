import 'package:get/get.dart';
import 'package:family_photo_desktop/core/models/photo.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';

class PhotosPageController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;
  
  // Photo list state
  final RxList<Photo> _photos = <Photo>[].obs;
  final RxList<Photo> _filteredPhotos = <Photo>[].obs;
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
  List<Photo> get filteredPhotos => _filteredPhotos;
  bool get isLoading => _isLoading.value;
  String get error => _error.value ?? '';
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
      
      _applyFilters();
    } catch (e) {
      _error.value = _getErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Apply filters to photos
  void _applyFilters() {
    List<Photo> filtered = List.from(_photos);
    
    if (_searchQuery.value != null && _searchQuery.value!.isNotEmpty) {
      filtered = filtered.where((photo) {
        return photo.filename.toLowerCase().contains(_searchQuery.value!.toLowerCase()) ||
               photo.originalFilename.toLowerCase().contains(_searchQuery.value!.toLowerCase());
      }).toList();
    }
    
    _filteredPhotos.assignAll(filtered);
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
    _applyFilters();
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

  // Filter by person
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

  // Clear error
  void clearError() {
    _error.value = null;
  }

  // Sort photos
  void sortPhotos(String sortBy) {
    switch (sortBy) {
      case 'date_desc':
        _filteredPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        _filteredPhotos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'name_asc':
        _filteredPhotos.sort((a, b) => a.filename.compareTo(b.filename));
        break;
      case 'name_desc':
        _filteredPhotos.sort((a, b) => b.filename.compareTo(a.filename));
        break;
      case 'size_desc':
        _filteredPhotos.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case 'size_asc':
        _filteredPhotos.sort((a, b) => a.fileSize.compareTo(b.fileSize));
        break;
      default:
        // 默认按创建时间降序排列
        _filteredPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // Delete photo
  Future<bool> deletePhoto(String photoId) async {
    try {
      _isLoading.value = true;
      await _apiClient.api.deletePhoto(photoId);
      
      // Remove photo from local list
      _photos.removeWhere((photo) => photo.id == photoId);
      _filteredPhotos.removeWhere((photo) => photo.id == photoId);
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get error message
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}