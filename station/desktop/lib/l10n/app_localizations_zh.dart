// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '家庭照片站';

  @override
  String get hello => '你好，家庭！';

  @override
  String get resetComplete => '重置完成';

  @override
  String get changeLanguage => '切换语言';

  @override
  String currentLanguage(String language) {
    return '当前语言：$language';
  }

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChinese => '中文';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言设置';

  @override
  String get settingsTheme => '主题设置';

  @override
  String get themeLight => '白天模式';

  @override
  String get themeDark => '夜间模式';

  @override
  String get adminInitTitle => '初始化管理员';

  @override
  String get adminInitDescription => '在桌面端创建首个管理员。其他成员通过手机扫码加入。';

  @override
  String get adminUsernameLabel => '管理员用户名';

  @override
  String get adminDisplayNameLabel => '显示名（可选）';

  @override
  String get adminPasswordLabel => '密码';

  @override
  String get adminPasswordConfirmLabel => '确认密码';

  @override
  String get adminInitSubmit => '创建管理员';

  @override
  String get adminInitSuccess => '管理员创建成功';

  @override
  String get fieldRequired => '该字段为必填';

  @override
  String fieldMinLength(int min) {
    return '最小长度为 $min';
  }

  @override
  String get passwordNotMatch => '两次密码不一致';

  @override
  String translateErrorKey(String key) {
    return '错误：$key';
  }
}
