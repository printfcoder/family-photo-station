import 'dart:async';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart' as sq3;
import 'package:path/path.dart' as p;
import 'package:family_photo_desktop/storage/user_data_manager.dart';

import 'database.dart';

class SqliteClient implements DatabaseClient {
  final String fileName;
  sq3.Database? _db;

  SqliteClient({this.fileName = 'family_photo_station.db'});

  @override
  Future<void> init() async {
    // 使用UserDataManager获取数据库目录
    final userDataManager = UserDataManager.instance;
    await userDataManager.initializeDirectories();
    
    final dbPath = userDataManager.getDatabaseFilePath(fileName);
    print('数据库路径: $dbPath');
    
    _db = sq3.sqlite3.open(dbPath);
    await _migrate();
  }

  Future<void> _migrate() async {
    final db = _ensure();
    
    // 创建用户表
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        display_name TEXT,
        is_admin INTEGER NOT NULL DEFAULT 0,
        password_hash TEXT,
        created_at INTEGER NOT NULL
      );
    ''');
    
    // 创建照片元数据表
    db.execute('''
      CREATE TABLE IF NOT EXISTS photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL UNIQUE,
        file_name TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        mime_type TEXT,
        width INTEGER,
        height INTEGER,
        taken_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      );
    ''');
    
    // 创建相册表
    db.execute('''
      CREATE TABLE IF NOT EXISTS albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        cover_photo_id INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (cover_photo_id) REFERENCES photos (id)
      );
    ''');
    
    // 创建照片-相册关联表
    db.execute('''
      CREATE TABLE IF NOT EXISTS album_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        photo_id INTEGER NOT NULL,
        added_at INTEGER NOT NULL,
        FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE,
        FOREIGN KEY (photo_id) REFERENCES photos (id) ON DELETE CASCADE,
        UNIQUE(album_id, photo_id)
      );
    ''');
    
    // 创建应用配置表
    db.execute('''
      CREATE TABLE IF NOT EXISTS app_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    
    // 创建存储配置表
    db.execute('''
      CREATE TABLE IF NOT EXISTS storage_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL, -- 'local' or 'smb'
        path TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        smb_host TEXT,
        smb_share TEXT,
        smb_username TEXT,
        smb_password TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    
    print('数据库表初始化完成');
  }

  sq3.Database _ensure() {
    final db = _db;
    if (db == null) {
      throw StateError('Database not initialized');
    }
    return db;
  }

  @override
  Future<void> close() async {
    _db?.dispose();
    _db = null;
  }

  @override
  Future<void> execute(String sql, [List<Object?>? args]) async {
    final stmt = _ensure().prepare(sql);
    try {
      stmt.execute(args ?? const []);
    } finally {
      stmt.dispose();
    }
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? args]) async {
    return rawUpdate(sql, args);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? args]) async {
    final stmt = _ensure().prepare(sql);
    try {
      stmt.execute(args ?? const []);
      return _ensure().getUpdatedRows();
    } finally {
      stmt.dispose();
    }
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? args]) async {
    final stmt = _ensure().prepare(sql);
    try {
      final result = stmt.select(args ?? const []);
      final columns = result.columnNames;
      final out = <Map<String, Object?>>[];
      for (final row in result) {
        final map = <String, Object?>{};
        for (var i = 0; i < columns.length; i++) {
          map[columns[i]] = row[i];
        }
        out.add(map);
      }
      return out;
    } finally {
      stmt.dispose();
    }
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? args]) async {
    final stmt = _ensure().prepare(sql);
    try {
      stmt.execute(args ?? const []);
      return _ensure().getUpdatedRows();
    } finally {
      stmt.dispose();
    }
  }
}