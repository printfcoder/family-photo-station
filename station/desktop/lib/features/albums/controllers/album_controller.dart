import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:family_photo_desktop/core/models/photo.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';

enum AlbumSortBy { newest, oldest, name, photoCount }
enum AlbumViewMode { grid, list }

class AlbumController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable state
  final RxList<Album> _allAlbums = <Album>[].obs;
  final RxList<Album> filteredAlbums = <Album>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<AlbumSortBy> sortBy = AlbumSortBy.newest.obs;
  final Rx<AlbumViewMode> viewMode = AlbumViewMode.grid.obs;
  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedAlbums = <String>{}.obs;

  // Getters
  List<Album> get allAlbums => _allAlbums;
  int get totalAlbums => _allAlbums.length;
  int get selectedCount => selectedAlbums.length;
  bool get hasSelection => selectedAlbums.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadAlbums();
    
    // Listen to changes and update filtered albums
    ever(searchQuery, (_) => _updateFilteredAlbums());
    ever(sortBy, (_) => _updateFilteredAlbums());
  }

  Future<void> loadAlbums() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final albums = await _apiService.getAlbums();
      _allAlbums.assignAll(albums);
      _updateFilteredAlbums();
    } catch (e) {
      error.value = 'Failed to load albums: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to load albums',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAlbums() async {
    await loadAlbums();
  }

  void searchAlbums(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void setSortBy(AlbumSortBy sort) {
    sortBy.value = sort;
  }

  void setViewMode(AlbumViewMode mode) {
    viewMode.value = mode;
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedAlbums.clear();
    }
  }

  void selectAlbum(String albumId) {
    if (selectedAlbums.contains(albumId)) {
      selectedAlbums.remove(albumId);
    } else {
      selectedAlbums.add(albumId);
    }
  }

  void selectAllAlbums() {
    selectedAlbums.addAll(filteredAlbums.map((album) => album.id));
  }

  void clearSelection() {
    selectedAlbums.clear();
  }

  Future<void> createAlbum({
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    try {
      isLoading.value = true;
      
      final album = await _apiService.createAlbum(
        name: name,
        description: description,
        isPrivate: isPrivate,
      );
      
      _allAlbums.insert(0, album);
      _updateFilteredAlbums();
      
      Get.snackbar(
        'Success',
        'Album "$name" created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create album: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    bool? isPrivate,
  }) async {
    try {
      final albumIndex = _allAlbums.indexWhere((album) => album.id == albumId);
      if (albumIndex == -1) return;

      final updatedAlbum = await _apiService.updateAlbum(
        albumId: albumId,
        name: name,
        description: description,
        isPrivate: isPrivate,
      );
      
      _allAlbums[albumIndex] = updatedAlbum;
      _updateFilteredAlbums();
      
      Get.snackbar(
        'Success',
        'Album updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update album: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAlbum(String albumId) async {
    try {
      await _apiService.deleteAlbum(albumId);
      _allAlbums.removeWhere((album) => album.id == albumId);
      selectedAlbums.remove(albumId);
      _updateFilteredAlbums();
      
      Get.snackbar(
        'Success',
        'Album deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete album: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteSelectedAlbums() async {
    if (selectedAlbums.isEmpty) return;

    try {
      isLoading.value = true;
      final albumIds = selectedAlbums.toList();
      
      for (final albumId in albumIds) {
        await _apiService.deleteAlbum(albumId);
        _allAlbums.removeWhere((album) => album.id == albumId);
      }
      
      selectedAlbums.clear();
      isSelectionMode.value = false;
      _updateFilteredAlbums();
      
      Get.snackbar(
        'Success',
        '${albumIds.length} albums deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete albums: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Photo>> getAlbumPhotos(String albumId) async {
    try {
      return await _apiService.getAlbumPhotos(albumId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load album photos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }

  Future<void> addPhotosToAlbum(String albumId, List<String> photoIds) async {
    try {
      await _apiService.addPhotosToAlbum(albumId, photoIds);
      
      // Update album photo count
      final albumIndex = _allAlbums.indexWhere((album) => album.id == albumId);
      if (albumIndex != -1) {
        final album = _allAlbums[albumIndex];
        _allAlbums[albumIndex] = album.copyWith(
          photoCount: album.photoCount + photoIds.length,
        );
        _updateFilteredAlbums();
      }
      
      Get.snackbar(
        'Success',
        '${photoIds.length} photos added to album',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add photos to album: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removePhotosFromAlbum(String albumId, List<String> photoIds) async {
    try {
      await _apiService.removePhotosFromAlbum(albumId, photoIds);
      
      // Update album photo count
      final albumIndex = _allAlbums.indexWhere((album) => album.id == albumId);
      if (albumIndex != -1) {
        final album = _allAlbums[albumIndex];
        _allAlbums[albumIndex] = album.copyWith(
          photoCount: album.photoCount - photoIds.length,
        );
        _updateFilteredAlbums();
      }
      
      Get.snackbar(
        'Success',
        '${photoIds.length} photos removed from album',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove photos from album: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateFilteredAlbums() {
    List<Album> filtered = List.from(_allAlbums);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((album) {
        return album.name?.toLowerCase().contains(searchQuery.value) ?? false ||
               (album.description?.toLowerCase().contains(searchQuery.value) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case AlbumSortBy.newest:
        filtered.sort((a, b) {
          final bDate = b.createdAt ?? DateTime(0);
          final aDate = a.createdAt ?? DateTime(0);
          return bDate.compareTo(aDate);
        });
        break;
      case AlbumSortBy.oldest:
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(0);
          final bDate = b.createdAt ?? DateTime(0);
          return aDate.compareTo(bDate);
        });
        break;
      case AlbumSortBy.name:
        filtered.sort((a, b) {
          final aName = a.name ?? '';
          final bName = b.name ?? '';
          return aName.compareTo(bName);
        });
        break;
      case AlbumSortBy.photoCount:
        filtered.sort((a, b) {
          final bCount = b.photoCount ?? 0;
          final aCount = a.photoCount ?? 0;
          return bCount.compareTo(aCount);
        });
        break;
    }

    filteredAlbums.assignAll(filtered);
  }

  String getSortDisplayName(AlbumSortBy sort) {
    switch (sort) {
      case AlbumSortBy.newest:
        return 'Newest';
      case AlbumSortBy.oldest:
        return 'Oldest';
      case AlbumSortBy.name:
        return 'Name';
      case AlbumSortBy.photoCount:
        return 'Photo Count';
    }
  }
}