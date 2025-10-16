import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'dart:io' show Platform, File;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:family_photo_mobile/routes/app_pages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? nickname;
  int _selectedAlbum = 0; // 当前选中的系统相册索引

  // 系统相册数据（通过 photo_manager 获取）
  List<AssetPathEntity> _systemAlbums = [];
  Uint8List? _coverThumbBytes; // 当前相册封面缩略图（内存）
  int _photoCount = 0; // 当前相册照片数量
  bool _permissionDenied = false;
  bool _loadingAlbums = true;

  // 顶部下拉连接面板状态
  static const double _panelMaxHeight = 140;
  double _panelOffset = 0; // 0=收起, _panelMaxHeight=展开
  bool _connected = false;
  String? _stationHost;
  int? _stationPort;
  String _healthText = '';
  // 移动端心跳
  Timer? _mobileBeatTimer;

  // 同步状态
  bool _syncing = false;
  bool _cancelSync = false;
  double _syncProgress = 0.0; // 0..1
  String _syncStatusText = '';
  int _syncProcessed = 0;
  int _syncTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _readStationConfig();
    _loadSystemAlbums();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('user.nickname');
    });
    _startMobileHeartbeatIfReady();
  }

  Future<void> _loadSystemAlbums() async {
    try {
      // 仅在移动端(iOS/Android)读取系统相册；桌面预览使用占位图
      if (!(Platform.isAndroid || Platform.isIOS)) {
        setState(() {
          _loadingAlbums = false;
        });
        return;
      }
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        setState(() {
          _permissionDenied = true;
          _loadingAlbums = false;
        });
        return;
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );

      if (paths.isEmpty) {
        setState(() {
          _systemAlbums = [];
          _coverThumbBytes = null;
          _photoCount = 0;
          _loadingAlbums = false;
        });
        return;
      }

      _systemAlbums = paths;
      _selectedAlbum = 0;
      await _refreshCurrentAlbumPreview();
      setState(() {
        _loadingAlbums = false;
      });
    } catch (e) {
      setState(() {
        _permissionDenied = true; // 在不支持平台/异常时以权限失败形式降级
        _loadingAlbums = false;
      });
    }
  }

  Future<void> _refreshCurrentAlbumPreview() async {
    if (_systemAlbums.isEmpty) return;
    final AssetPathEntity current = _systemAlbums[_selectedAlbum];
    final int count = await current.assetCountAsync;
    Uint8List? bytes;
    try {
      final List<AssetEntity> assets = await current.getAssetListPaged(page: 0, size: 1);
      if (assets.isNotEmpty) {
        // 生成缩略图
        bytes = await assets.first.thumbnailDataWithSize(const ThumbnailSize(900, 600));
      }
    } catch (_) {
      bytes = null;
    }
    setState(() {
      _photoCount = count;
      _coverThumbBytes = bytes;
    });
  }

  Future<void> _readStationConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stationHost = prefs.getString('station.host');
      _stationPort = prefs.getInt('station.port');
    });
    _startMobileHeartbeatIfReady();
  }

  Future<void> _checkBackend() async {
    if (_stationHost == null || _stationHost!.isEmpty || _stationPort == null) {
      setState(() {
        _connected = false;
        _healthText = '未配置照片站地址';
      });
      return;
    }
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(milliseconds: 1200), receiveTimeout: const Duration(milliseconds: 1200)));
      final resp = await dio.get('http://$_stationHost:$_stationPort/api/v1/health');
      final ok = resp.statusCode == 200;
      setState(() {
        _connected = ok;
        _healthText = ok ? '服务正常' : '服务异常';
      });
    } catch (_) {
      setState(() {
        _connected = false;
        _healthText = '无法连接到后台';
      });
    }
  }

  void _startMobileHeartbeatIfReady() {
    if (_mobileBeatTimer != null) return;
    if (nickname == null || nickname!.isEmpty) return;
    if (_stationHost == null || _stationHost!.isEmpty || _stationPort == null) return;
    // 立即发送一次心跳
    _sendMobileHeartbeat();
    // 每10秒发送一次心跳
    _mobileBeatTimer = Timer.periodic(const Duration(seconds: 10), (_) => _sendMobileHeartbeat());
  }

  Future<void> _startSyncSelectedAlbum() async {
    if (_syncing) return; // 避免重复触发
    if (!(_stationHost != null && _stationHost!.isNotEmpty && _stationPort != null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先连接家庭照片站')));
      return;
    }
    if (nickname == null || nickname!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先完成注册，设置昵称')));
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前平台不支持系统相册同步演示')));
      return;
    }

    if (_systemAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有可同步的系统相册')));
      return;
    }

    final AssetPathEntity current = _systemAlbums[_selectedAlbum];
    final int totalCount = await current.assetCountAsync;
    setState(() {
      _syncing = true;
      _cancelSync = false;
      _syncStatusText = '准备同步…';
      _syncProcessed = 0;
      _syncTotal = totalCount;
      _syncProgress = 0.0;
    });

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 4000),
      receiveTimeout: const Duration(milliseconds: 8000),
      sendTimeout: const Duration(milliseconds: 8000),
    ));

    const int pageSize = 50;
    int page = 0;
    try {
      while (true) {
        final List<AssetEntity> assets = await current.getAssetListPaged(page: page, size: pageSize);
        if (assets.isEmpty) break;
        for (final asset in assets) {
          if (_cancelSync) {
            setState(() {
              _syncing = false;
              _syncStatusText = '已取消';
            });
            return;
          }

          final File? f = await asset.file;
          if (f == null) {
            _syncProcessed++;
            setState(() => _syncProgress = _syncProcessed / (_syncTotal == 0 ? 1 : _syncTotal));
            continue;
          }
          final String fileName = Uri.file(f.path).pathSegments.isNotEmpty ? Uri.file(f.path).pathSegments.last : (asset.id ?? 'unknown');
          final int totalSize = await f.length();

          // 查询断点状态
          int offset = 0;
          bool skipFile = false;
          try {
            final resp = await dio.get('http://${_stationHost!}:${_stationPort!}/sync/upload/status', queryParameters: {
              'username': nickname,
              'filename': fileName,
            });
            if (resp.statusCode == 200 && resp.data is Map) {
              final Map data = resp.data as Map;
              final bool completed = data['completed'] == true;
              if (completed) {
                skipFile = true;
              } else {
                offset = (data['receivedBytes'] is int) ? (data['receivedBytes'] as int) : 0;
              }
            }
          } catch (_) {
            // 无断点信息时从头开始
            offset = 0;
          }
          if (skipFile) {
            _syncProcessed++;
            setState(() => _syncProgress = _syncProcessed / (_syncTotal == 0 ? 1 : _syncTotal));
            continue;
          }

          setState(() => _syncStatusText = '同步 $fileName');

          // 分片上传
          const int chunkSize = 512 * 1024; // 512KB
          while (offset < totalSize) {
            if (_cancelSync) {
              setState(() {
                _syncing = false;
                _syncStatusText = '已取消';
              });
              return;
            }
            final int end = (offset + chunkSize > totalSize) ? totalSize : (offset + chunkSize);
            final List<int> bytes = await f.openRead(offset, end).fold<List<int>>(<int>[], (p, e) {
              p.addAll(e);
              return p;
            });
            try {
              final resp = await dio.post(
                'http://${_stationHost!}:${_stationPort!}/sync/upload',
                data: bytes,
                options: Options(headers: {'Content-Type': 'application/octet-stream'}, responseType: ResponseType.json),
                queryParameters: {
                  'username': nickname,
                  'filename': fileName,
                  'offset': offset,
                  'totalSize': totalSize,
                  'complete': end == totalSize ? 1 : 0,
                },
              );
              if (resp.statusCode == 200) {
                offset = end;
                final double fileFrac = totalSize == 0 ? 1.0 : (offset / totalSize);
                final double overall = (_syncProcessed + fileFrac) / (_syncTotal == 0 ? 1 : _syncTotal);
                setState(() => _syncProgress = overall);
              } else {
                // 非200视为失败，跳过当前文件
                break;
              }
            } catch (e) {
              // 网络失败，保留断点以便下次续传
              break;
            }
          }

          _syncProcessed++;
          setState(() => _syncProgress = _syncProcessed / (_syncTotal == 0 ? 1 : _syncTotal));
        }
        page++;
      }
    } finally {
      setState(() {
        _syncing = false;
        if (!_cancelSync) {
          _syncStatusText = '同步完成';
        }
      });
    }
  }

  Future<void> _sendMobileHeartbeat() async {
    if (nickname == null || _stationHost == null || _stationPort == null) return;
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(milliseconds: 1200), receiveTimeout: const Duration(milliseconds: 1200)));
      await dio.post('http://${_stationHost!}:${_stationPort!}/presence/heartbeat', data: {
        'username': nickname,
        'deviceType': 'mobile',
      });
    } catch (_) {
      // 忽略心跳失败，不影响前端体验
    }
  }

  @override
  void dispose() {
    _mobileBeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // 顶部问候 + 头像
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${nickname ?? 'Friend'}',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome to Family Photo Station',
                          style: textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFEDEEF1),
                    child: Icon(Icons.person, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 搜索栏 + 设置按钮
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.black54),
                          SizedBox(width: 8),
                          Text('Search'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Text('选择相册', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              // 系统相册 Chips（权限/加载状态处理）
              Builder(builder: (context) {
                if (_loadingAlbums) {
                  return const SizedBox(height: 36, child: Center(child: CircularProgressIndicator()));
                }
                if (_permissionDenied) {
                  return SizedBox(
                    height: 36,
                    child: Row(children: [
                      const Icon(Icons.lock, color: Colors.black54),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('未授权访问照片。请在系统设置中允许。')),
                      TextButton(
                        onPressed: () => PhotoManager.openSetting(),
                        child: const Text('去设置'),
                      ),
                    ]),
                  );
                }
                if (_systemAlbums.isEmpty) {
                  return const SizedBox(height: 36, child: Center(child: Text('此设备没有照片')));
                }
                return SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _systemAlbums.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final selected = index == _selectedAlbum;
                      return ChoiceChip(
                        label: Text(_systemAlbums[index].name),
                        selected: selected,
                        onSelected: (_) async {
                          setState(() => _selectedAlbum = index);
                          await _refreshCurrentAlbumPreview();
                        },
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                        backgroundColor: const Color(0xFFEDEEF1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 14),
              // 大卡片（显示当前选中系统相册封面与数量）
              _FeaturedCard(
                albumName: _systemAlbums.isNotEmpty ? _systemAlbums[_selectedAlbum].name : '相册',
                photoCount: _photoCount,
                coverThumb: _coverThumbBytes,
                onSyncTap: _startSyncSelectedAlbum,
              ),

              const Spacer(),

              // 底部胶囊导航
              _BottomCapsuleNav(),
            ],
              ),
            ),
          ),

          // 顶部下拉连接信息面板 + 手势
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) async {
                await _readStationConfig();
                await _checkBackend();
              },
              onVerticalDragUpdate: (details) {
                final next = (_panelOffset + details.delta.dy).clamp(0.0, _panelMaxHeight);
                setState(() => _panelOffset = next);
              },
              onVerticalDragEnd: (details) {
                // 根据滑动方向与速度进行吸附：一次上划即完全收起；下拉则完全展开
                final v = details.primaryVelocity ?? 0.0; // 负值为向上，正值为向下
                if (v < -100) {
                  // 快速上划，直接收起
                  setState(() => _panelOffset = 0);
                } else if (v > 100) {
                  // 快速下拉，直接展开
                  setState(() => _panelOffset = _panelMaxHeight);
                } else {
                  // 低速滑动，根据当前位移就近吸附
                  final snap = _panelOffset < _panelMaxHeight * 0.5 ? 0.0 : _panelMaxHeight;
                  setState(() => _panelOffset = snap);
                }
              },
              child: Transform.translate(
                offset: Offset(0, -_panelMaxHeight + _panelOffset),
                child: _ConnectionPanel(
                  connected: _connected,
                  host: _stationHost,
                  port: _stationPort,
                  healthText: _healthText,
                  height: _panelMaxHeight,
                  onConnectTap: () => Get.toNamed(Routes.discovery),
                ),
              ),
            ),
          ),

          // 同步进度浮层（底部居中）
          if (_syncing)
            Positioned(
              left: 16,
              right: 16,
              bottom: 72,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync, color: Colors.black87),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_syncStatusText.isEmpty ? '正在同步到照片站…' : _syncStatusText)),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _cancelSync = true;
                                _syncStatusText = '已取消';
                              });
                            },
                            child: const Text('取消'),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: _syncProgress),
                      const SizedBox(height: 6),
                      Text('进度: $_syncProcessed / $_syncTotal')
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String albumName;
  final int photoCount;
  final Uint8List? coverThumb;
  final VoidCallback? onSyncTap;
  const _FeaturedCard({super.key, required this.albumName, required this.photoCount, required this.coverThumb, this.onSyncTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverThumb != null)
                  Image.memory(coverThumb!, fit: BoxFit.cover)
                else
                  const Image(
                    image: NetworkImage('https://picsum.photos/seed/album-placeholder/900/600'),
                    fit: BoxFit.cover,
                  ),
                // 顶部右侧心形按钮
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.favorite_border, color: Colors.black87),
                  ),
                ),
                // 底部信息渐变
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xCC000000), Color(0x00000000)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('相册', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(albumName, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.photo_library, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('$photoCount 张照片', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(18)),
                              child: const Text('查看相册', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onSyncTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                                child: const Text('同步到照片站', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.arrow_forward_ios, size: 18),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  final bool connected;
  final String? host;
  final int? port;
  final String healthText;
  final double height;
  final VoidCallback onConnectTap;

  const _ConnectionPanel({
    super.key,
    required this.connected,
    required this.host,
    required this.port,
    required this.healthText,
    required this.height,
    required this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = connected ? const Color(0xFFDFF5E1) : const Color(0xFFFFE5E5);
    final icon = connected ? Icons.check_circle : Icons.error_outline;
    final iconColor = connected ? Colors.green : Colors.redAccent;
    final title = connected ? '已连接家庭照片站' : '未连接家庭照片站';
    final detail = connected
        ? '地址: ${host ?? '-'}:${port ?? '-'} · $healthText'
        : '请在同一WiFi下连接设备或前往“发现”设置';

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(detail),
              ],
            ),
          ),
          if (!connected)
            TextButton(
              onPressed: onConnectTap,
              child: const Text('去连接'),
            ),
        ],
      ),
    );
  }
}

class _BottomCapsuleNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _NavIcon(icon: Icons.home),
            _NavIcon(icon: Icons.grid_view),
            _NavIcon(icon: Icons.chat_bubble_outline),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  const _NavIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: Colors.black87),
    );
  }
}

// 已移除本地静态 Album 模型，改为从系统相册动态读取