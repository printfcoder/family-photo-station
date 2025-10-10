import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_photo_desktop/features/albums/controllers/album_controller.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/widgets/app_sidebar.dart';
import 'package:family_photo_desktop/core/widgets/loading_widget.dart';
import 'package:family_photo_desktop/core/widgets/empty_state_widget.dart';
import 'package:family_photo_desktop/core/models/album.pb.dart' as pb;
import 'albums_controller.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AlbumsController());
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const AppSidebar(currentRoute: '/albums'),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top toolbar
                _buildToolbar(context, controller),
                
                // 相册内容区域
                Expanded(
                  child: GetBuilder<AlbumController>(
                    builder: (albumController) {
                      if (albumController.isLoading.value && albumController.allAlbums.isEmpty) {
                        return const LoadingWidget(message: '正在加载相册...');
                      }

                      if (albumController.error.value.isNotEmpty) {
                        return _buildErrorState(context, albumController.error.value);
                      }

                      if (albumController.allAlbums.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.photo_album_outlined,
                          title: '暂无相册',
                          subtitle: '创建您的第一个相册来整理照片吧！',
                        );
                      }

                      return _buildAlbumContent(context, controller, albumController);
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

  Widget _buildToolbar(BuildContext context, AlbumsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Page title
          Text(
            '相册管理',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(width: 32),
          
          // Search bar
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.handleSearch,
                decoration: InputDecoration(
                  hintText: '搜索相册...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Sort dropdown
          Obx(() => DropdownButton<String>(
            value: controller.selectedSort,
            onChanged: (value) => controller.handleSort(value!),
            items: const [
              DropdownMenuItem(
                value: 'newest',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('最新创建'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('最早创建'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('按名称'),
                  ],
                ),
              ),
              DropdownMenuItem(
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
          )),
          
          const SizedBox(width: 8),
          
          // View toggle
          Obx(() => ToggleButtons(
            isSelected: [controller.isGridView, !controller.isGridView],
            onPressed: (index) {
              controller.setGridView(index == 0);
            },
            children: const [
              Icon(Icons.grid_view),
              Icon(Icons.view_list),
            ],
          )),
          
          const SizedBox(width: 16),
          
          // 创建相册按钮
          ElevatedButton.icon(
            onPressed: controller.showCreateAlbumDialog,
            icon: const Icon(Icons.add),
            label: const Text('创建相册'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
          ElevatedButton(
            onPressed: () => Get.find<AlbumController>().loadAlbums(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumContent(BuildContext context, AlbumsController controller, AlbumController albumController) {
    final List<pb.Album> albumList = List<pb.Album>.from(albumController.filteredAlbums);
    return Obx(() {
      if (controller.isGridView) {
        return _buildGridView(context, controller, albumList);
      } else {
        return _buildListView(context, controller, albumList);
      }
    });
  }

  Widget _buildGridView(BuildContext context, AlbumsController controller, List<pb.Album> albums) {
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
        return _buildAlbumCard(context, controller, album);
      },
    );
  }

  Widget _buildListView(BuildContext context, AlbumsController controller, List<pb.Album> albums) {
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
                  '${album.hasPhotoCount() ? album.photoCount : 0} 张照片 • ${controller.formatDateTime(album.hasCreatedAt() ? DateTime.fromMillisecondsSinceEpoch(album.createdAt.toInt()) : DateTime.now())}',
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
                  onSelected: (value) => controller.handleAlbumAction(album, value),
                ),
              ],
            ),
            onTap: () => controller.handleAlbumTap(album),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(BuildContext context, AlbumsController controller, pb.Album album) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81C784).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => controller.handleAlbumTap(album),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 封面图片
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF3E0),
                        Color(0xFFFFE0B2),
                      ],
                    ),
                  ),
                  child: album.hasCoverPhotoId() && album.coverPhotoId.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.network(
                            'https://via.placeholder.com/300x200', // TODO: 使用实际封面图片
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFF3E0),
                                      Color(0xFFFFE0B2),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.photo_album_rounded,
                                    size: 48,
                                    color: Color(0xFFFF8A65),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.photo_album_rounded,
                            size: 48,
                            color: Color(0xFFFF8A65),
                          ),
                        ),
                ),
              ),
              
              // 相册信息
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 相册名称和隐私状态
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              album.hasName() ? album.name : 'Untitled Album',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5D4037),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            album.isPublic ? Icons.public : Icons.lock,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // 相册描述
                      if (album.hasDescription() && album.description.isNotEmpty) ...[
                        Text(
                          album.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        const SizedBox(height: 12),
                      ],
                      
                      // 照片数量和创建时间
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${album.hasPhotoCount() ? album.photoCount : 0} 张照片',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF8D6E63),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
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
                                  onSelected: (value) => controller.handleAlbumAction(album, value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.formatDateTime(album.hasCreatedAt() ? DateTime.fromMillisecondsSinceEpoch(album.createdAt.toInt()) : DateTime.now()),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8D6E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
