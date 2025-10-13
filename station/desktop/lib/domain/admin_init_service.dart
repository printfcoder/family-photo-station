import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../data/users/user.dart';
import '../data/users/user_repository.dart';

class AdminInitService {
  final UserRepository users;

  AdminInitService(this.users);

  Future<bool> hasAdmin() async {
    return (await users.findAdmin()) != null;
  }

  Future<User> createAdmin({required String username, required String password, String? displayName}) async {
    final existing = await users.findByUsername(username);
    if (existing != null) {
      throw StateError('username_taken');
    }
    final hash = sha256.convert(utf8.encode(password)).toString();
    final now = DateTime.now().millisecondsSinceEpoch;
    return users.insert(User(
      username: username,
      displayName: displayName,
      isAdmin: true,
      passwordHash: hash,
      createdAt: now,
    ));
  }
}