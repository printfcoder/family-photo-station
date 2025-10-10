import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/features/albums/controllers/album_controller.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/models/album.pb.dart' as pb;

class AlbumsController extends GetxController {
  final AlbumController albumController = Get.find<AlbumController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController searchController = TextEditingController();
  
  final RxString _selectedSort = 'newest'.obs;
  final RxBool _isGridView = true.obs;

  String get selectedSort => _selectedSort.value;
  bool get isGridView => _isGridView.value;

  @override
  void onInit() {
    super.onInit();
    albumController.loadAlbums();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void handleSearch(String query) {
    albumController.searchAlbums(query);
  }

  void handleSort(String sort) {
    _selectedSort.value = sort;
    
    switch (sort) {
      case 'newest':
        albumController.setSortBy(AlbumSortBy.newest);
        break;
      case 'oldest':
        albumController.setSortBy(AlbumSortBy.oldest);
        break;
      case 'name':
        albumController.setSortBy(AlbumSortBy.name);
        break;
      case 'photos':
        albumController.setSortBy(AlbumSortBy.photoCount);
        break;
    }
  }

  void toggleViewMode() {
    _isGridView.value = !_isGridView.value;
  }

  void setGridView(bool isGrid) {
    _isGridView.value = isGrid;
  }

  void handleAlbumTap(pb.Album album) {
    // TODO: 实现相册详情查看
    Get.snackbar(
      '相册详情',
      '正在查看相册: ${album.hasName() ? album.name : 'Untitled Album'}',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void handleAlbumAction(pb.Album album, String action) {
    switch (action) {
      case 'view':
        handleAlbumTap(album);
        break;
      case 'edit':
        showEditAlbumDialog(album);
        break;
      case 'share':
        Get.snackbar(
          '分享相册',
          '相册分享功能即将推出',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        break;
      case 'delete':
        showDeleteConfirmDialog(album);
        break;
    }
  }

  void showCreateAlbumDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final RxBool isPublic = false.obs;

    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('创建相册'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '相册名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '相册描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('公开相册'),
                subtitle: const Text('其他用户可以查看此相册'),
                value: isPublic.value,
                onChanged: (value) {
                  isPublic.value = value ?? false;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入相册名称',
                  backgroundColor: Get.theme.colorScheme.error,
                  colorText: Get.theme.colorScheme.onError,
                );
                return;
              }

              Get.back();
              albumController.createAlbum(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );
              Get.snackbar(
                '创建成功',
                '相册 "${nameController.text.trim()}" 已创建',
                backgroundColor: Get.theme.colorScheme.primary,
                colorText: Get.theme.colorScheme.onPrimary,
              );
            },
            child: const Text('创建'),
          ),
        ],
      )),
    );
  }

  void showEditAlbumDialog(pb.Album album) {
    final nameController = TextEditingController(text: album.hasName() ? album.name : '');
    final descriptionController = TextEditingController(text: album.hasDescription() ? album.description : '');
    final RxBool isPublic = (album.hasIsPublic() ? album.isPublic : false).obs;

    Get.dialog(
      Obx(() => AlertDialog(
        title: const Text('编辑相册'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '相册名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '相册描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('公开相册'),
                subtitle: const Text('其他用户可以查看此相册'),
                value: isPublic.value,
                onChanged: (value) {
                  isPublic.value = value ?? false;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入相册名称',
                  backgroundColor: Get.theme.colorScheme.error,
                  colorText: Get.theme.colorScheme.onError,
                );
                return;
              }

              Get.back();
              // TODO: 实现编辑相册功能
              Get.snackbar(
                '编辑成功',
                '相册 "${nameController.text.trim()}" 已更新',
                backgroundColor: Get.theme.colorScheme.primary,
                colorText: Get.theme.colorScheme.onPrimary,
              );
            },
            child: const Text('保存'),
          ),
        ],
      )),
    );
  }

  void showDeleteConfirmDialog(pb.Album album) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除相册'),
        content: Text('确定要删除相册 "${album.hasName() ? album.name : 'Untitled Album'}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: 实现删除相册功能
              Get.snackbar(
                '删除成功',
                '相册已删除',
                backgroundColor: Get.theme.colorScheme.primary,
                colorText: Get.theme.colorScheme.onPrimary,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} 年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} 个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} 天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} 小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} 分钟前';
    } else {
      return '刚刚';
    }
  }
}