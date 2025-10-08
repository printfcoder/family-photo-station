import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/features/albums/controllers/album_controller.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/widgets/app_sidebar.dart';
import 'package:family_photo_desktop/core/widgets/loading_widget.dart';
import 'package:family_photo_desktop/core/widgets/empty_state_widget.dart';
import 'package:family_photo_desktop/core/models/album.pb.dart' as pb;

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  final AlbumController _albumController = Get.find<AlbumController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedSort = 'newest';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _albumController.loadAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _albumController.searchAlbums(query);
  }

  void _handleSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    
    switch (sort) {
      case 'newest':
        _albumController.setSortBy(AlbumSortBy.newest);
        break;
      case 'oldest':
        _albumController.setSortBy(AlbumSortBy.oldest);
        break;
      case 'name':
        _albumController.setSortBy(AlbumSortBy.name);
        break;
      case 'photos':
        _albumController.setSortBy(AlbumSortBy.photoCount);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          const AppSidebar(currentRoute: '/albums'),
          
          // 主内容区域
          Expanded(
            child: Column(
              children: [
                // 顶部工具栏
                _buildToolbar(),
                
                // 相册内容区域
                Expanded(
                  child: GetBuilder<AlbumController>(
                    builder: (controller) {
                      if (controller.isLoading.value && controller.allAlbums.isEmpty) {
                        return const LoadingWidget(message: '正在加载相册...');
                      }

                      if (controller.error.value.isNotEmpty) {
                        return _buildErrorState(controller.error.value);
                      }

                      if (controller.allAlbums.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.photo_album_outlined,
                          title: '暂无相册',
                          subtitle: '创建您的第一个相册来整理照片吧！',
                        );
                      }

                      return _buildAlbumContent(controller);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 标题
          Text(
            '相册管理',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // 搜索框
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索相册...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _handleSearch,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 排序
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: _handleSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('最新优先'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('最旧优先'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('按名称'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'photos',
                child: Row(
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('按照片数'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 8),
          
          // 视图切换
          ToggleButtons(
            isSelected: [_isGridView, !_isGridView],
            onPressed: (index) {
              setState(() {
                _isGridView = index == 0;
              });
            },
            children: const [
              Icon(Icons.grid_view),
              Icon(Icons.view_list),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // 创建相册按钮
          ElevatedButton.icon(
            onPressed: _showCreateAlbumDialog,
            icon: const Icon(Icons.add),
            label: const Text('创建相册'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumContent(AlbumController controller) {
    final List<pb.Album> albumList = List<pb.Album>.from(controller.filteredAlbums);
    if (controller.viewMode.value == AlbumViewMode.grid) {
      return _buildGridView(albumList);
    } else {
      return _buildListView(albumList);
    }
  }

  Widget _buildGridView(List<pb.Album> albums) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildAlbumCard(album);
      },
    );
  }

  Widget _buildListView(List<pb.Album> albums) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: album.hasCoverPhotoId() && album.coverPhotoId.isNotEmpty
                     ? Image.network(
                        'https://via.placeholder.com/60', // TODO: 使用实际封面图片
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.photo_album),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.photo_album),
                      ),
              ),
            ),
            title: Text(album.hasName() ? album.name : 'Untitled Album'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (album.hasDescription() && album.description.isNotEmpty)
                  Text(
                    album.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${album.hasPhotoCount() ? album.photoCount : 0} 张照片 • ${_formatDateTime(album.hasCreatedAt() ? DateTime.fromMillisecondsSinceEpoch(album.createdAt.toInt()) : DateTime.now())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (album.isPublic)
                  const Icon(Icons.public, size: 16)
                else
                  const Icon(Icons.lock, size: 16),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('查看'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('分享'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleAlbumAction(album, value),
                ),
              ],
            ),
            onTap: () => _handleAlbumTap(album),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(pb.Album album) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleAlbumTap(album),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图片
            Expanded(
              flex: 3,
              child: album.hasCoverPhotoId() && album.coverPhotoId.isNotEmpty
                  ? Image.network(
                      'https://via.placeholder.com/200', // TODO: 使用实际封面图片
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.photo_album, size: 48),
                        );
                      },
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.photo_album, size: 48),
                    ),
            ),
            
            // 相册信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 相册名称
                    Text(
                      album.hasName() ? album.name : 'Untitled Album',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 照片数量
                    Text(
                      '${album.hasPhotoCount() ? album.photoCount : 0} 张照片',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 底部信息
                    Row(
                      children: [
                        Icon(
                          album.hasIsPublic() && album.isPublic ? Icons.public : Icons.lock,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateTime(album.hasCreatedAt() ? DateTime.fromMillisecondsSinceEpoch(album.createdAt.toInt()) : DateTime.now()),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('查看'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('编辑'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share),
                                  SizedBox(width: 8),
                                  Text('分享'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('删除', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) => _handleAlbumAction(album, value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _albumController.loadAlbums(),
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  void _handleAlbumTap(pb.Album album) {
    // TODO: 实现相册详情查看
    Get.snackbar(
      '相册详情',
      '正在查看相册: ${album.hasName() ? album.name : 'Untitled Album'}',
      backgroundColor: Theme.of(context).colorScheme.primary,
      colorText: Colors.white,
    );
  }

  void _handleAlbumAction(pb.Album album, String action) {
    switch (action) {
      case 'view':
        _handleAlbumTap(album);
        break;
      case 'edit':
        _showEditAlbumDialog(album);
        break;
      case 'share':
        Get.snackbar(
          '分享相册',
          '相册分享功能即将推出',
          backgroundColor: Theme.of(context).colorScheme.primary,
          colorText: Colors.white,
        );
        break;
      case 'delete':
        _showDeleteConfirmDialog(album);
        break;
    }
  }

  void _showCreateAlbumDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar(
                    '错误',
                    '请输入相册名称',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                Navigator.of(context).pop();
                _albumController.createAlbum(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
                Get.snackbar(
                  '创建成功',
                  '相册 "${nameController.text.trim()}" 已创建',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAlbumDialog(pb.Album album) {
    final nameController = TextEditingController(text: album.hasName() ? album.name : '');
    final descriptionController = TextEditingController(text: album.hasDescription() ? album.description : '');
    bool isPublic = album.hasIsPublic() ? album.isPublic : false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar(
                    '错误',
                    '请输入相册名称',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                Navigator.of(context).pop();
                _albumController.updateAlbum(
                  albumId: album.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );
                Get.snackbar(
                  '更新成功',
                  '相册信息已更新',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(pb.Album album) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除相册 "${album.hasName() ? album.name : 'Untitled Album'}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _albumController.deleteAlbum(album.hasId() ? album.id : '');
              Get.snackbar(
                '删除成功',
                '相册已删除',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}