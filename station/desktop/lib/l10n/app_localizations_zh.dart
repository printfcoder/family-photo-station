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
  String get hello => '你好，家人！';

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
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get adminInitTitle => '管理员初始化';

  @override
  String get adminInitDescription => '为桌面端创建首位管理员。其他用户将通过移动端扫码加入。';

  @override
  String get adminUsernameLabel => '管理员用户名';

  @override
  String get adminDisplayNameLabel => '显示名称（可选）';

  @override
  String get adminPasswordLabel => '密码';

  @override
  String get adminPasswordConfirmLabel => '确认密码';

  @override
  String get adminInitSubmit => '创建管理员';

  @override
  String get adminInitSuccess => '管理员创建成功';

  @override
  String get fieldRequired => '该字段为必填项';

  @override
  String fieldMinLength(int min) {
    return '最小长度为 $min';
  }

  @override
  String get passwordNotMatch => '两次输入的密码不一致';

  @override
  String translateErrorKey(String key) {
    return '错误：$key';
  }

  @override
  String get featurePhotoManagementTitle => '智能照片管理';

  @override
  String get featurePhotoManagementSubtitle => '自动整理和分类您的家庭照片';

  @override
  String get featurePhotoManagementStatsLabel => '张照片';

  @override
  String get featureAlbumCreationTitle => '精美相册创建';

  @override
  String get featureAlbumCreationSubtitle => '轻松创建和分享家庭回忆';

  @override
  String get featureAlbumCreationStatsLabel => '个相册';

  @override
  String get featureSecureStorageTitle => '安全私密存储';

  @override
  String get featureSecureStorageSubtitle => '您的数据完全属于您，本地存储更安全';

  @override
  String get featureSecureStorageStatsLabel => '隐私保护';

  @override
  String get navDashboard => '仪表板';

  @override
  String get navLibrary => '照片库';

  @override
  String get navAlbums => '相册';

  @override
  String get navUsers => '用户管理';

  @override
  String get navStorage => '存储管理';

  @override
  String get navBackup => '备份';

  @override
  String get roleAdmin => '管理员';

  @override
  String get loginTitle => '登录';

  @override
  String get loginQrTab => '扫码登录';

  @override
  String get loginPasswordTab => '密码登录';

  @override
  String get loginUsernameLabel => '用户名';

  @override
  String get loginPasswordLabel => '密码';

  @override
  String get loginSignInButton => '登录';

  @override
  String get loginQrInstruction => '请使用手机端扫描二维码';

  @override
  String get loginQrStatusPending => '等待扫码...';

  @override
  String get loginQrStatusScanned => '已扫码，请在手机上确认';

  @override
  String get loginQrStatusCompleted => '已登录';

  @override
  String sessionCurrentUser(String username) {
    return '当前用户：$username';
  }

  @override
  String get actionLogout => '退出登录';

  @override
  String get actionSwitchUser => '切换用户';

  @override
  String get registerTitle => '注册';

  @override
  String get registerQrInstruction => '扫码注册';

  @override
  String get registerStatusPending => '注册中...';

  @override
  String get registerQrStatusPending => '等待扫码...';

  @override
  String get registerStatusCompleted => '注册完成';

  @override
  String get registerQrStatusScanned => '已扫码，等待确认';

  @override
  String get usersAddUser => '新增用户';

  @override
  String get usersEmpty => '暂无用户';

  @override
  String get usersRoleAdmin => '管理员';

  @override
  String get usersRoleMember => '成员';

  @override
  String get usersResetPassword => '重置密码';

  @override
  String get usersDelete => '删除';

  @override
  String get usersDeleteAdminForbidden => '管理员不可删除';

  @override
  String get registerQrStatusReleased => '二维码已释放/过期';

  @override
  String get usersQrRefresh => '刷新二维码';

  @override
  String get usersAddQrDialogTitle => '注册二维码';

  @override
  String get usersAddQrInstruction => '请使用 Photo Mobile 扫码注册';
}
