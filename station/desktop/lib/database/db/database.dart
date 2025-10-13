import 'dart:async';

abstract class DatabaseClient {
  Future<void> init();
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? args]);
  Future<int> rawInsert(String sql, [List<Object?>? args]);
  Future<int> rawUpdate(String sql, [List<Object?>? args]);
  Future<int> rawDelete(String sql, [List<Object?>? args]);
  Future<void> execute(String sql, [List<Object?>? args]);
  Future<void> close();
}