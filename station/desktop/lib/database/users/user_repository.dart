import 'dart:async';
import '../db/database.dart';
import 'user.dart';

class UserRepository {
  final DatabaseClient db;

  UserRepository(this.db);

  Future<User?> findAdmin() async {
    final rows = await db.rawQuery('SELECT * FROM users WHERE is_admin = 1 LIMIT 1');
    if (rows.isEmpty) return null;
    return User.fromRow(rows.first);
  }

  Future<User?> findByUsername(String username) async {
    final rows = await db.rawQuery('SELECT * FROM users WHERE username = ? LIMIT 1', [username]);
    if (rows.isEmpty) return null;
    return User.fromRow(rows.first);
  }

  Future<User> insert(User user) async {
    await db.rawInsert(
      'INSERT INTO users (username, display_name, is_admin, password_hash, created_at) VALUES (?, ?, ?, ?, ?)',
      [user.username, user.displayName, user.isAdmin ? 1 : 0, user.passwordHash, user.createdAt],
    );
    final created = await findByUsername(user.username);
    if (created == null) {
      throw StateError('Failed to insert user');
    }
    return created;
  }
}