import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final locale = const Locale('en').obs;
  final themeMode = ThemeMode.light.obs;

  static const _keyLocale = 'settings.locale';
  static const _keyTheme = 'settings.themeMode';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_keyLocale);
    final theme = prefs.getString(_keyTheme);
    if (lang != null) {
      locale.value = Locale(lang);
      Get.updateLocale(locale.value);
    }
    if (theme != null) {
      switch (theme) {
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          break;
        default:
          themeMode.value = ThemeMode.light;
      }
      Get.changeThemeMode(themeMode.value);
    }
  }

  Future<void> setLocale(Locale l) async {
    locale.value = l;
    Get.updateLocale(l);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, l.languageCode);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode.value = m;
    Get.changeThemeMode(m);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, m == ThemeMode.dark ? 'dark' : (m == ThemeMode.system ? 'system' : 'light'));
  }
}