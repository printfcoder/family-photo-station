import 'package:get/get.dart';
import 'package:family_photo_mobile/core/models/photo.dart';

class AlbumController extends GetxController {
  // 相册列表状态
  final RxList<Album> _albums = <Album>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();

  // Getters
  List<Album> get albums => _albums;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadAlbums();
  }

  // 加载相册列表
  Future<void> loadAlbums() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      // TODO: 实现实际的API调用
      // final albums = await _apiService.getAlbums();
      
      // 模拟数据
      await Future.delayed(const Duration(seconds: 1));
      final mockAlbums = List.generate(10, (index) {
        return Album(
          id: 'album_${index + 1}',
          name: '相册 ${index + 1}',
          description: '这是第 ${index + 1} 个相册的描述',
          coverPhotoId: 'photo_${index + 1}',
          creatorId: 'user_1',
          isPublic: index % 2 == 0,
          photoCount: (index + 1) * 10,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          updatedAt: DateTime.now().subtract(Duration(days: index)),
        );
      });
      
      _albums.assignAll(mockAlbums);
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

      // TODO: 实现实际的API调用
      // final album = await _apiService.createAlbum(name: name, description: description);
      
      // 模拟创建
      await Future.delayed(const Duration(seconds: 1));
      final newAlbum = Album(
        id: 'album_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description ?? '',
        coverPhotoId: 'photo_${_albums.length + 1}',
        creatorId: 'user_1',
        isPublic: true,
        photoCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _albums.insert(0, newAlbum);
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
      // TODO: 实现实际的API调用
      // final updatedAlbum = await _apiService.updateAlbum(albumId, name: name, description: description);
      
      // 模拟更新
      await Future.delayed(const Duration(seconds: 1));
      final index = _albums.indexWhere((album) => album.id == albumId);
      if (index != -1) {
        final album = _albums[index];
        _albums[index] = album.copyWith(
          name: name,
          description: description,
          updatedAt: DateTime.now(),
        );
      }
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 删除相册
  Future<bool> deleteAlbum(String albumId) async {
    try {
      // TODO: 实现实际的API调用
      // await _apiService.deleteAlbum(albumId);
      
      // 模拟删除
      await Future.delayed(const Duration(seconds: 1));
      _albums.removeWhere((album) => album.id == albumId);
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 添加照片到相册
  Future<bool> addPhotoToAlbum(String albumId, String photoId) async {
    try {
      // TODO: 实现实际的API调用
      // await _apiService.addPhotoToAlbum(albumId, photoId);
      
      // 模拟添加
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _albums.indexWhere((album) => album.id == albumId);
      if (index != -1) {
        final album = _albums[index];
        _albums[index] = album.copyWith(
          photoCount: album.photoCount + 1,
          updatedAt: DateTime.now(),
        );
      }
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
    }
  }

  // 从相册移除照片
  Future<bool> removePhotoFromAlbum(String albumId, String photoId) async {
    try {
      // TODO: 实现实际的API调用
      // await _apiService.removePhotoFromAlbum(albumId, photoId);
      
      // 模拟移除
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _albums.indexWhere((album) => album.id == albumId);
      if (index != -1) {
        final album = _albums[index];
        _albums[index] = album.copyWith(
          photoCount: album.photoCount > 0 ? album.photoCount - 1 : 0,
          updatedAt: DateTime.now(),
        );
      }
      
      return true;
    } catch (e) {
      _error.value = _getErrorMessage(e);
      return false;
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

  // 清除错误
  void clearError() {
    _error.value = null;
  }

  String _getErrorMessage(dynamic error) {
    return error.toString();
  }
}
