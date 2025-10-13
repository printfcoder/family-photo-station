import 'dart:async';
import 'package:sqlite3/sqlite3.dart' as sq3;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

class SqliteClient implements DatabaseClient {
  final String fileName;
  sq3.Database? _db;

  SqliteClient({this.fileName = 'family_station.db'});

  @override
  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, fileName);
    _db = sq3.sqlite3.open(dbPath);
    await _migrate();
  }

  Future<void> _migrate() async {
    final db = _ensure();
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