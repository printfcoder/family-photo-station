import 'package:get/get.dart';
import 'package:family_photo_mobile/core/models/photo.dart';

class PhotoController extends GetxController {
  // 照片列表状态
  final RxList<Photo> _photos = <Photo>[].obs;
  final RxBool _isLoading = false.obs;
  final RxnString _error = RxnString();

  // Getters
  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  // 加载照片列表
  Future<void> loadPhotos() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      // TODO: 实现实际的API调用
      // final photos = await _apiService.getPhotos();
      
      // 模拟数据
      await Future.delayed(const Duration(seconds: 1));
      final mockPhotos = List.generate(20, (index) {
        return Photo(
          id: 'photo_${index + 1}',
          filename: 'IMG_${index + 1}.jpg',
          originalFilename: 'IMG_${index + 1}.jpg',
          mimeType: 'image/jpeg',
          fileSize: 1024 * 1024 * (index + 1),
          hash: 'hash_${index + 1}',
          width: 1920,
          height: 1080,
          thumbnailPath: '/thumbnails/thumb_${index + 1}.jpg',
          thumbnailUrl: 'https://picsum.photos/300/200?random=${index + 1}',
          url: 'https://picsum.photos/1920/1080?random=${index + 1}',
          originalUrl: 'https://picsum.photos/1920/1080?random=${index + 1}',
          mediumUrl: 'https://picsum.photos/800/600?random=${index + 1}',
          exifData: ExifData(
            takenAt: DateTime.now().subtract(Duration(days: index + 1)),
            camera: 'iPhone ${index % 3 + 12}',
            lens: 'iPhone ${index % 3 + 12} back camera',
            iso: 100 + (index % 10) * 50,
            aperture: 1.8 + (index % 5) * 0.2,
            shutterSpeed: '1/${100 + index * 10}',
            focalLength: 26.0 + (index % 3) * 2.0,
            orientation: 'Horizontal (normal)',
          ),
          location: null,
          uploaderId: 'user_1',
          deviceId: 'device_1',
          isProcessed: true,
          tags: ['tag_${index % 3 + 1}'],
          qualityScore: 0.8 + (index % 3) * 0.1,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          updatedAt: DateTime.now().subtract(Duration(days: index)),
          deletedAt: null,
          takenAt: DateTime.now().subtract(Duration(days: index + 1)),
          albumIds: ['album_${index % 5 + 1}'],
          metadata: {'camera': 'iPhone ${index % 3 + 12}'},
        );
      });
      
      _photos.assignAll(mockPhotos);
      _error.value = null;
    } catch (e) {
      _error.value = _getErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  // 刷新照片列表
  @override
  Future<void> refresh() async {
    await loadPhotos();
  }

  // 根据ID获取照片
  Photo? getPhotoById(String photoId) {
    try {
      return _photos.firstWhere((photo) => photo.id == photoId);
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