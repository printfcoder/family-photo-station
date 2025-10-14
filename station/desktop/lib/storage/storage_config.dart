import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'user_data_manager.dart';

/// 存储配置类
class StorageConfig {
  /// 存储类型
  final StorageType type;
  
  /// 存储路径
  final String path;
  
  /// 是否启用
  final bool enabled;
  
  /// 最大存储大小（字节，-1表示无限制）
  final int maxSize;
  
  /// 自动清理策略
  final CleanupPolicy cleanupPolicy;
  
  /// 备份配置
  final BackupConfig? backupConfig;
  
  /// 加密配置
  final EncryptionConfig? encryptionConfig;

  const StorageConfig({
    required this.type,
    required this.path,
    this.enabled = true,
    this.maxSize = -1,
    this.cleanupPolicy = CleanupPolicy.manual,
    this.backupConfig,
    this.encryptionConfig,
  });

  /// 从JSON创建配置
  factory StorageConfig.fromJson(Map<String, dynamic> json) {
    return StorageConfig(
      type: StorageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StorageType.local,
      ),
      path: json['path'] ?? '',
      enabled: json['enabled'] ?? true,
      maxSize: json['maxSize'] ?? -1,
      cleanupPolicy: CleanupPolicy.values.firstWhere(
        (e) => e.name == json['cleanupPolicy'],
        orElse: () => CleanupPolicy.manual,
      ),
      backupConfig: json['backupConfig'] != null 
          ? BackupConfig.fromJson(json['backupConfig'])
          : null,
      encryptionConfig: json['encryptionConfig'] != null
          ? EncryptionConfig.fromJson(json['encryptionConfig'])
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'path': path,
      'enabled': enabled,
      'maxSize': maxSize,
      'cleanupPolicy': cleanupPolicy.name,
      'backupConfig': backupConfig?.toJson(),
      'encryptionConfig': encryptionConfig?.toJson(),
    };
  }

  /// 复制并修改配置
  StorageConfig copyWith({
    StorageType? type,
    String? path,
    bool? enabled,
    int? maxSize,
    CleanupPolicy? cleanupPolicy,
    BackupConfig? backupConfig,
    EncryptionConfig? encryptionConfig,
  }) {
    return StorageConfig(
      type: type ?? this.type,
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      maxSize: maxSize ?? this.maxSize,
      cleanupPolicy: cleanupPolicy ?? this.cleanupPolicy,
      backupConfig: backupConfig ?? this.backupConfig,
      encryptionConfig: encryptionConfig ?? this.encryptionConfig,
    );
  }
}

/// 存储类型枚举
enum StorageType {
  /// 本地存储
  local,
  /// 网络存储（SMB/CIFS）
  network,
  /// 云存储
  cloud,
}

/// 清理策略枚举
enum CleanupPolicy {
  /// 手动清理
  manual,
  /// 按时间自动清理
  timeBasedAuto,
  /// 按大小自动清理
  sizeBasedAuto,
  /// 智能清理
  smartAuto,
}

/// 备份配置
class BackupConfig {
  /// 是否启用备份
  final bool enabled;
  
  /// 备份间隔（小时）
  final int intervalHours;
  
  /// 保留备份数量
  final int retainCount;
  
  /// 备份路径
  final String backupPath;
  
  /// 是否压缩备份
  final bool compressed;

  const BackupConfig({
    this.enabled = false,
    this.intervalHours = 24,
    this.retainCount = 7,
    required this.backupPath,
    this.compressed = true,
  });

  factory BackupConfig.fromJson(Map<String, dynamic> json) {
    return BackupConfig(
      enabled: json['enabled'] ?? false,
      intervalHours: json['intervalHours'] ?? 24,
      retainCount: json['retainCount'] ?? 7,
      backupPath: json['backupPath'] ?? '',
      compressed: json['compressed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'intervalHours': intervalHours,
      'retainCount': retainCount,
      'backupPath': backupPath,
      'compressed': compressed,
    };
  }
}

/// 加密配置
class EncryptionConfig {
  /// 是否启用加密
  final bool enabled;
  
  /// 加密算法
  final String algorithm;
  
  /// 密钥长度
  final int keyLength;

  const EncryptionConfig({
    this.enabled = false,
    this.algorithm = 'AES-256-GCM',
    this.keyLength = 256,
  });

  factory EncryptionConfig.fromJson(Map<String, dynamic> json) {
    return EncryptionConfig(
      enabled: json['enabled'] ?? false,
      algorithm: json['algorithm'] ?? 'AES-256-GCM',
      keyLength: json['keyLength'] ?? 256,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'algorithm': algorithm,
      'keyLength': keyLength,
    };
  }
}

/// 存储配置管理器
class StorageConfigManager {
  static StorageConfigManager? _instance;
  static StorageConfigManager get instance => _instance ??= StorageConfigManager._();
  
  StorageConfigManager._();

  late final UserDataManager _userDataManager;
  late final String _configFilePath;
  
  Map<String, StorageConfig> _configs = {};

  /// 初始化配置管理器
  Future<void> initialize() async {
    _userDataManager = UserDataManager.instance;
    await _userDataManager.initializeDirectories();
    
    _configFilePath = _userDataManager.getConfigFilePath('storage_config.json');
    await _loadConfigs();
  }

  /// 加载配置
  Future<void> _loadConfigs() async {
    try {
      final file = File(_configFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        
        _configs = json.map((key, value) => MapEntry(
          key,
          StorageConfig.fromJson(value as Map<String, dynamic>),
        ));
      } else {
        // 创建默认配置
        await _createDefaultConfigs();
      }
    } catch (e) {
      // 如果加载失败，创建默认配置
      await _createDefaultConfigs();
    }
  }

  /// 创建默认配置
  Future<void> _createDefaultConfigs() async {
    _configs = {
      'app_data': StorageConfig(
        type: StorageType.local,
        path: _userDataManager.appDataDirectory,
        enabled: true,
        cleanupPolicy: CleanupPolicy.smartAuto,
      ),
      'config': StorageConfig(
        type: StorageType.local,
        path: _userDataManager.configDirectory,
        enabled: true,
        cleanupPolicy: CleanupPolicy.manual,
      ),
      'cache': StorageConfig(
        type: StorageType.local,
        path: _userDataManager.cacheDirectory,
        enabled: true,
        maxSize: 1024 * 1024 * 1024, // 1GB
        cleanupPolicy: CleanupPolicy.sizeBasedAuto,
      ),
      'database': StorageConfig(
        type: StorageType.local,
        path: _userDataManager.databaseDirectory,
        enabled: true,
        cleanupPolicy: CleanupPolicy.manual,
        backupConfig: BackupConfig(
          enabled: true,
          intervalHours: 24,
          retainCount: 7,
          backupPath: _userDataManager.databaseBackupDirectory,
        ),
      ),
      'logs': StorageConfig(
        type: StorageType.local,
        path: _userDataManager.logsDirectory,
        enabled: true,
        maxSize: 100 * 1024 * 1024, // 100MB
        cleanupPolicy: CleanupPolicy.timeBasedAuto,
      ),
    };
    
    await _saveConfigs();
  }

  /// 保存配置
  Future<void> _saveConfigs() async {
    try {
      final json = _configs.map((key, value) => MapEntry(key, value.toJson()));
      final content = jsonEncode(json);
      
      final file = File(_configFilePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('保存存储配置失败: $e');
    }
  }

  /// 获取配置
  StorageConfig? getConfig(String name) {
    return _configs[name];
  }

  /// 获取所有配置
  Map<String, StorageConfig> getAllConfigs() {
    return Map.unmodifiable(_configs);
  }

  /// 设置配置
  Future<void> setConfig(String name, StorageConfig config) async {
    _configs[name] = config;
    await _saveConfigs();
  }

  /// 删除配置
  Future<void> removeConfig(String name) async {
    _configs.remove(name);
    await _saveConfigs();
  }

  /// 验证存储路径
  Future<bool> validateStoragePath(String path) async {
    try {
      final directory = Directory(path);
      
      // 检查路径是否存在或可以创建
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // 检查读写权限
      final testFile = File(pathJoin(path, '.test_permission'));
      await testFile.writeAsString('test');
      await testFile.delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取存储使用统计
  Future<Map<String, dynamic>> getStorageStats() async {
    final stats = <String, dynamic>{};
    
    for (final entry in _configs.entries) {
      final config = entry.value;
      if (config.enabled) {
        final size = await _userDataManager.getDirectorySize(config.path);
        stats[entry.key] = {
          'path': config.path,
          'size': size,
          'maxSize': config.maxSize,
          'usage': config.maxSize > 0 ? (size / config.maxSize * 100).round() : 0,
        };
      }
    }
    
    return stats;
  }

  /// 清理存储
  Future<void> cleanupStorage(String name) async {
    final config = _configs[name];
    if (config == null || !config.enabled) return;

    switch (config.cleanupPolicy) {
      case CleanupPolicy.manual:
        // 手动清理，不执行任何操作
        break;
      case CleanupPolicy.timeBasedAuto:
        await _timeBasedCleanup(config);
        break;
      case CleanupPolicy.sizeBasedAuto:
        await _sizeBasedCleanup(config);
        break;
      case CleanupPolicy.smartAuto:
        await _smartCleanup(config);
        break;
    }
  }

  /// 基于时间的清理
  Future<void> _timeBasedCleanup(StorageConfig config) async {
    final directory = Directory(config.path);
    if (!await directory.exists()) return;

    final cutoffTime = DateTime.now().subtract(const Duration(days: 30));
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete();
          }
        } catch (e) {
          // 忽略删除失败的文件
        }
      }
    }
  }

  /// 基于大小的清理
  Future<void> _sizeBasedCleanup(StorageConfig config) async {
    if (config.maxSize <= 0) return;

    final currentSize = await _userDataManager.getDirectorySize(config.path);
    if (currentSize <= config.maxSize) return;

    // 获取所有文件并按修改时间排序
    final files = <FileSystemEntity>[];
    final directory = Directory(config.path);
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        files.add(entity);
      }
    }

    // 按修改时间排序（最旧的在前）
    final fileStats = <FileSystemEntity, FileStat>{};
    for (final file in files) {
      fileStats[file] = await file.stat();
    }
    
    files.sort((a, b) {
      final statA = fileStats[a]!;
      final statB = fileStats[b]!;
      return statA.modified.compareTo(statB.modified);
    });

    // 删除最旧的文件直到满足大小限制
    int deletedSize = 0;
    for (final file in files) {
      if (currentSize - deletedSize <= config.maxSize) break;
      
      try {
        final stat = await file.stat();
        await file.delete();
        deletedSize += stat.size;
      } catch (e) {
        // 忽略删除失败的文件
      }
    }
  }

  /// 智能清理
  Future<void> _smartCleanup(StorageConfig config) async {
    // 结合时间和大小的智能清理策略
    await _timeBasedCleanup(config);
    await _sizeBasedCleanup(config);
  }

  /// 导出配置
  Map<String, dynamic> exportConfigs() {
    return {
      'configs': _configs.map((key, value) => MapEntry(key, value.toJson())),
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// 导入配置
  Future<void> importConfigs(Map<String, dynamic> data) async {
    try {
      final configs = data['configs'] as Map<String, dynamic>;
      _configs = configs.map((key, value) => MapEntry(
        key,
        StorageConfig.fromJson(value as Map<String, dynamic>),
      ));
      
      await _saveConfigs();
    } catch (e) {
      throw Exception('导入存储配置失败: $e');
    }
  }
}

/// 路径连接辅助函数
String pathJoin(String part1, String part2) {
  return path.join(part1, part2);
}