import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// 跨平台用户数据存储管理器
class UserDataManager {
  static UserDataManager? _instance;
  static UserDataManager get instance => _instance ??= UserDataManager._();
  
  UserDataManager._();

  /// 获取应用数据根目录
  String get appDataDirectory {
    if (Platform.isWindows) {
      // Windows: %APPDATA%\FamilyPhotoStation
      final appData = Platform.environment['APPDATA'];
      if (appData != null) {
        return path.join(appData, 'FamilyPhotoStation');
      }
      // 备用方案：用户目录
      return path.join(Platform.environment['USERPROFILE'] ?? '', 'AppData', 'Roaming', 'FamilyPhotoStation');
    } else if (Platform.isMacOS) {
      // macOS: ~/Library/Application Support/FamilyPhotoStation
      final home = Platform.environment['HOME'];
      if (home != null) {
        return path.join(home, 'Library', 'Application Support', 'FamilyPhotoStation');
      }
    } else if (Platform.isLinux) {
      // Linux: ~/.local/share/FamilyPhotoStation
      final home = Platform.environment['HOME'];
      if (home != null) {
        final xdgDataHome = Platform.environment['XDG_DATA_HOME'];
        if (xdgDataHome != null) {
          return path.join(xdgDataHome, 'FamilyPhotoStation');
        }
        return path.join(home, '.local', 'share', 'FamilyPhotoStation');
      }
    }
    
    // 默认备用方案：当前目录下的data文件夹
    return path.join(Directory.current.path, 'data', 'user');
  }

  /// 获取配置文件目录
  String get configDirectory {
    if (Platform.isWindows) {
      return path.join(appDataDirectory, 'config');
    } else if (Platform.isMacOS) {
      return path.join(appDataDirectory, 'config');
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final xdgConfigHome = Platform.environment['XDG_CONFIG_HOME'];
        if (xdgConfigHome != null) {
          return path.join(xdgConfigHome, 'FamilyPhotoStation');
        }
        return path.join(home, '.config', 'FamilyPhotoStation');
      }
    }
    return path.join(appDataDirectory, 'config');
  }

  /// 获取缓存目录
  String get cacheDirectory {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        return path.join(localAppData, 'FamilyPhotoStation', 'cache');
      }
      return path.join(appDataDirectory, 'cache');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        return path.join(home, 'Library', 'Caches', 'FamilyPhotoStation');
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final xdgCacheHome = Platform.environment['XDG_CACHE_HOME'];
        if (xdgCacheHome != null) {
          return path.join(xdgCacheHome, 'FamilyPhotoStation');
        }
        return path.join(home, '.cache', 'FamilyPhotoStation');
      }
    }
    return path.join(appDataDirectory, 'cache');
  }

  /// 获取数据库目录
  String get databaseDirectory => path.join(appDataDirectory, 'database');

  /// 获取日志目录
  String get logsDirectory => path.join(appDataDirectory, 'logs');

  /// 获取安全文件目录
  String get securityDirectory => path.join(appDataDirectory, 'security');

  /// 获取临时文件目录
  String get tempDirectory => path.join(cacheDirectory, 'temp');

  /// 获取缩略图缓存目录
  String get thumbnailCacheDirectory => path.join(cacheDirectory, 'thumbnails');

  /// 获取网络缓存目录
  String get networkCacheDirectory => path.join(cacheDirectory, 'network');

  /// 获取数据库备份目录
  String get databaseBackupDirectory => path.join(databaseDirectory, 'backups');

  /// 获取密钥文件目录
  String get keysDirectory => path.join(securityDirectory, 'keys');

  /// 获取证书文件目录
  String get certificatesDirectory => path.join(securityDirectory, 'certificates');

  /// 初始化所有必要的目录
  Future<void> initializeDirectories() async {
    final directories = [
      appDataDirectory,
      configDirectory,
      cacheDirectory,
      databaseDirectory,
      logsDirectory,
      securityDirectory,
      tempDirectory,
      thumbnailCacheDirectory,
      networkCacheDirectory,
      databaseBackupDirectory,
      keysDirectory,
      certificatesDirectory,
    ];

    for (final dir in directories) {
      final directory = Directory(dir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  /// 获取配置文件路径
  String getConfigFilePath(String fileName) {
    return path.join(configDirectory, fileName);
  }

  /// 获取数据库文件路径
  String getDatabaseFilePath(String fileName) {
    return path.join(databaseDirectory, fileName);
  }

  /// 获取日志文件路径
  String getLogFilePath(String fileName) {
    return path.join(logsDirectory, fileName);
  }

  /// 清理缓存
  Future<void> clearCache() async {
    final cacheDir = Directory(cacheDirectory);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
  }

  /// 清理临时文件
  Future<void> clearTempFiles() async {
    final tempDir = Directory(tempDirectory);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      await tempDir.create(recursive: true);
    }
  }

  /// 获取目录大小（字节）
  Future<int> getDirectorySize(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return 0;

    int totalSize = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          totalSize += stat.size;
        } catch (e) {
          // 忽略无法访问的文件
        }
      }
    }
    return totalSize;
  }

  /// 获取存储使用情况
  Future<Map<String, int>> getStorageUsage() async {
    return {
      'config': await getDirectorySize(configDirectory),
      'database': await getDirectorySize(databaseDirectory),
      'cache': await getDirectorySize(cacheDirectory),
      'logs': await getDirectorySize(logsDirectory),
      'security': await getDirectorySize(securityDirectory),
      'total': await getDirectorySize(appDataDirectory),
    };
  }

  /// 导出用户数据信息
  Map<String, dynamic> exportDataInfo() {
    return {
      'platform': Platform.operatingSystem,
      'appDataDirectory': appDataDirectory,
      'configDirectory': configDirectory,
      'cacheDirectory': cacheDirectory,
      'databaseDirectory': databaseDirectory,
      'logsDirectory': logsDirectory,
      'securityDirectory': securityDirectory,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 验证目录权限
  Future<bool> checkDirectoryPermissions(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      
      // 检查目录是否存在
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 尝试创建测试文件来验证写权限
      final testFile = File(path.join(directoryPath, '.permission_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取平台特定的推荐存储位置
  List<String> getRecommendedStorageLocations() {
    final locations = <String>[];
    
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        locations.addAll([
          path.join(userProfile, 'Documents', 'FamilyPhotoStation'),
          path.join(userProfile, 'Desktop', 'FamilyPhotoStation'),
        ]);
      }
      
      // 添加其他驱动器
      for (int i = 67; i <= 90; i++) { // C到Z
        final drive = String.fromCharCode(i);
        final drivePath = '$drive:\\FamilyPhotoStation';
        if (Directory(drivePath).existsSync()) {
          locations.add(drivePath);
        }
      }
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        locations.addAll([
          path.join(home, 'Documents', 'FamilyPhotoStation'),
          path.join(home, 'Desktop', 'FamilyPhotoStation'),
          '/Applications/FamilyPhotoStation',
        ]);
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        locations.addAll([
          path.join(home, 'Documents', 'FamilyPhotoStation'),
          path.join(home, 'Desktop', 'FamilyPhotoStation'),
          '/opt/FamilyPhotoStation',
          '/usr/local/share/FamilyPhotoStation',
        ]);
      }
    }
    
    return locations;
  }
}