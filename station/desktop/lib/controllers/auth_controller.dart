import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:family_photo_desktop/database/db/sqlite_client.dart';
import 'package:family_photo_desktop/database/users/user_repository.dart';
import 'package:family_photo_desktop/database/users/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

enum QrLoginStatus { idle, pending, scanned, confirmed }

class AuthController extends GetxController {
  final currentUser = Rxn<User>();
  final isAuthenticated = false.obs;
  final isSwitching = false.obs;
  User? _previousUser;

  // QR 登录状态
  final qrStatus = QrLoginStatus.idle.obs;
  final qrToken = ''.obs;

  late final UserRepository users;

  static const _keySessionUser = 'auth.session.username';

  @override
  void onInit() {
    super.onInit();
    _initRepo().then((_) => _loadSession());
  }

  Future<void> _initRepo() async {
    final db = SqliteClient();
    // BootstrapController 已初始化数据库，这里保险起见调用一次 init（若已初始化将快速返回）
    await db.init();
    users = UserRepository(db);
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keySessionUser);
    if (username != null) {
      final user = await users.findByUsername(username);
      currentUser.value = user;
      isAuthenticated.value = user != null;
    }
  }

  Future<void> _saveSession(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keySessionUser);
    } else {
      await prefs.setString(_keySessionUser, user.username);
    }
  }

  Future<bool> loginWithPassword(String username, String password) async {
    final user = await users.findByUsername(username);
    if (user == null || user.passwordHash == null) {
      return false;
    }
    final inputHash = sha256.convert(utf8.encode(password)).toString();
    if (inputHash != user.passwordHash) {
      return false;
    }
    currentUser.value = user;
    isAuthenticated.value = true;
    await _saveSession(user);
    return true;
  }

  void startQrLogin() {
    qrToken.value = const Uuid().v4();
    qrStatus.value = QrLoginStatus.pending;
  }

  void markQrScanned() {
    if (qrStatus.value == QrLoginStatus.pending) {
      qrStatus.value = QrLoginStatus.scanned;
    }
  }

  Future<bool> confirmQrLoginAs(String username) async {
    final user = await users.findByUsername(username);
    if (user == null) return false;
    qrStatus.value = QrLoginStatus.confirmed;
    currentUser.value = user;
    isAuthenticated.value = true;
    await _saveSession(user);
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;
    isAuthenticated.value = false;
    await _saveSession(null);
    qrStatus.value = QrLoginStatus.idle;
    qrToken.value = '';
    isSwitching.value = false;
    _previousUser = null;
  }

  /// Begin switch-user flow: show login view but allow cancel to restore session
  Future<void> startSwitch() async {
    _previousUser = currentUser.value;
    isSwitching.value = true;
    currentUser.value = null;
    isAuthenticated.value = false;
    await _saveSession(null);
    qrStatus.value = QrLoginStatus.idle;
    qrToken.value = '';
  }

  /// Cancel switch and restore previous session (if any)
  Future<void> cancelSwitch() async {
    final prev = _previousUser;
    if (prev != null) {
      currentUser.value = prev;
      isAuthenticated.value = true;
      await _saveSession(prev);
    }
    isSwitching.value = false;
    _previousUser = null;
  }
}