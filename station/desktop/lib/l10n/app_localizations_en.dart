// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Photo Station';

  @override
  String get hello => 'Hello, Family!';

  @override
  String get resetComplete => 'Reset Completed';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String currentLanguage(String language) {
    return 'Current Language: $language';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get adminInitTitle => 'Initialize Administrator';

  @override
  String get adminInitDescription =>
      'Create the first administrator for the desktop. Other users join by scanning via mobile app.';

  @override
  String get adminUsernameLabel => 'Admin Username';

  @override
  String get adminDisplayNameLabel => 'Display Name (optional)';

  @override
  String get adminPasswordLabel => 'Password';

  @override
  String get adminPasswordConfirmLabel => 'Confirm Password';

  @override
  String get adminInitSubmit => 'Create Administrator';

  @override
  String get adminInitSuccess => 'Administrator created successfully';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String fieldMinLength(int min) {
    return 'Minimum length is $min';
  }

  @override
  String get passwordNotMatch => 'Passwords do not match';

  @override
  String translateErrorKey(String key) {
    return 'Error: $key';
  }

  @override
  String get featurePhotoManagementTitle => 'Smart Photo Management';

  @override
  String get featurePhotoManagementSubtitle =>
      'Automatically organize and categorize your family photos';

  @override
  String get featurePhotoManagementStatsLabel => 'photos';

  @override
  String get featureAlbumCreationTitle => 'Beautiful Album Creation';

  @override
  String get featureAlbumCreationSubtitle =>
      'Create and share family memories easily';

  @override
  String get featureAlbumCreationStatsLabel => 'albums';

  @override
  String get featureSecureStorageTitle => 'Secure Private Storage';

  @override
  String get featureSecureStorageSubtitle =>
      'Your data belongs to you; local storage is safer';

  @override
  String get featureSecureStorageStatsLabel => 'privacy protection';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navLibrary => 'Photo Library';

  @override
  String get navAlbums => 'Albums';

  @override
  String get navUsers => 'User Management';

  @override
  String get navStorage => 'Storage';

  @override
  String get navBackup => 'Backup';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginQrTab => 'Scan to Sign In';

  @override
  String get loginPasswordTab => 'Password Sign In';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginQrInstruction => 'Use the mobile app to scan the QR code';

  @override
  String get loginQrStatusPending => 'Waiting for scan...';

  @override
  String get loginQrStatusScanned => 'Scanned, confirm on mobile';

  @override
  String get loginQrStatusCompleted => 'Signed in';

  @override
  String sessionCurrentUser(String username) {
    return 'Current User: $username';
  }

  @override
  String get actionLogout => 'Log Out';

  @override
  String get actionSwitchUser => 'Switch User';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerQrInstruction => 'Scan to register';

  @override
  String get registerStatusPending => 'Registering...';

  @override
  String get registerQrStatusPending => 'Waiting for scan...';

  @override
  String get registerStatusCompleted => 'Registered';

  @override
  String get registerQrStatusScanned => 'Scanned, awaiting confirmation';

  @override
  String get usersAddUser => 'Add User';

  @override
  String get usersEmpty => 'No users';

  @override
  String get usersRoleAdmin => 'Admin';

  @override
  String get usersRoleMember => 'Member';

  @override
  String get usersResetPassword => 'Reset Password';

  @override
  String get usersDelete => 'Delete';

  @override
  String get usersDeleteAdminForbidden => 'Admin account cannot be deleted';

  @override
  String get registerQrStatusReleased => 'QR code released/expired';

  @override
  String get usersQrRefresh => 'Refresh QR code';

  @override
  String get usersAddQrDialogTitle => 'Register QR Code';

  @override
  String get usersAddQrInstruction => 'Use Photo Mobile to scan to register';
}
