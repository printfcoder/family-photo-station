import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:family_photo_mobile/core/controllers/album_controller.dart';
import 'package:family_photo_mobile/core/models/photo.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<XFile> _selectedImages = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedAlbumId;
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _uploadPhotos() async {
    if (_selectedImages.isEmpty) {
      Get.snackbar(
        '提示',
        '请选择要上传的照片',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: 实现实际的上传逻辑
      // 这里应该调用 photo controller 的上传方法
      await Future.delayed(const Duration(seconds: 2)); // 模拟上传

      if (mounted) {
        Get.snackbar(
          '成功',
          '照片上传成功！',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          '错误',
          '上传失败: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传照片'),
        actions: [
          if (_selectedImages.isNotEmpty)
            TextButton(
              onPressed: _isUploading ? null : _uploadPhotos,
              child: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('上传'),
            ),
        ],
      ),
      body: _selectedImages.isEmpty ? _buildEmptyState() : _buildUploadForm(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '选择要上传的照片',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '从相册中选择照片或拍摄新照片',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  label: '从相册选择',
                  onPressed: _pickImages,
                ),
                _buildActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: '拍摄照片',
                  onPressed: _takePicture,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选中的照片预览
          _buildImagePreview(),
          const SizedBox(height: 24),

          // 添加更多照片按钮
          _buildAddMoreButton(),
          const SizedBox(height: 24),

          // 标题输入
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '标题（可选）',
              hintText: '为这些照片添加一个标题',
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // 描述输入
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '描述（可选）',
              hintText: '描述这些照片的内容或故事',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          // 相册选择
          _buildAlbumSelector(),
          const SizedBox(height: 16),

          // 标签输入
          _buildTagInput(),
          const SizedBox(height: 16),

          // 标签显示
          if (_tags.isNotEmpty) _buildTagsDisplay(),

          const SizedBox(height: 100), // 底部间距
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选中的照片 (${_selectedImages.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final image = _selectedImages[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(image.path),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('添加更多照片'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _takePicture,
          child: const Icon(Icons.camera_alt_outlined),
        ),
      ],
    );
  }

  Widget _buildAlbumSelector() {
    return GetBuilder<AlbumController>(
      builder: (albumController) {
        return DropdownButtonFormField<String>(
          value: _selectedAlbumId,
          decoration: const InputDecoration(
            labelText: '选择相册（可选）',
            prefixIcon: Icon(Icons.photo_album_outlined),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('不添加到相册'),
            ),
            ...albumController.albums.map((Album album) => DropdownMenuItem(
              value: album.id,
              child: Text(album.name),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedAlbumId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTagInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _tagController,
            decoration: const InputDecoration(
              labelText: '添加标签',
              hintText: '输入标签名称',
              prefixIcon: Icon(Icons.label_outline),
            ),
            onFieldSubmitted: (_) => _addTag(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _addTag,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildTagsDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _removeTag(tag),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}