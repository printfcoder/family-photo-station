import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Family Photo Station'**
  String get appTitle;

  /// Greeting text
  ///
  /// In en, this message translates to:
  /// **'Hello, Family!'**
  String get hello;

  /// Reset status
  ///
  /// In en, this message translates to:
  /// **'Reset Completed'**
  String get resetComplete;

  /// Button to change language
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Shows the current language
  ///
  /// In en, this message translates to:
  /// **'Current Language: {language}'**
  String currentLanguage(String language);

  /// English label
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Chinese label
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @adminInitTitle.
  ///
  /// In en, this message translates to:
  /// **'Initialize Administrator'**
  String get adminInitTitle;

  /// No description provided for @adminInitDescription.
  ///
  /// In en, this message translates to:
  /// **'Create the first administrator for the desktop. Other users join by scanning via mobile app.'**
  String get adminInitDescription;

  /// No description provided for @adminUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Username'**
  String get adminUsernameLabel;

  /// No description provided for @adminDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name (optional)'**
  String get adminDisplayNameLabel;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPasswordLabel;

  /// No description provided for @adminPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get adminPasswordConfirmLabel;

  /// No description provided for @adminInitSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create Administrator'**
  String get adminInitSubmit;

  /// No description provided for @adminInitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Administrator created successfully'**
  String get adminInitSuccess;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Minimum length validation message
  ///
  /// In en, this message translates to:
  /// **'Minimum length is {min}'**
  String fieldMinLength(int min);

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// Translate backend error key
  ///
  /// In en, this message translates to:
  /// **'Error: {key}'**
  String translateErrorKey(String key);

  /// No description provided for @featurePhotoManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Photo Management'**
  String get featurePhotoManagementTitle;

  /// No description provided for @featurePhotoManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically organize and categorize your family photos'**
  String get featurePhotoManagementSubtitle;

  /// No description provided for @featurePhotoManagementStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'photos'**
  String get featurePhotoManagementStatsLabel;

  /// No description provided for @featureAlbumCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Album Creation'**
  String get featureAlbumCreationTitle;

  /// No description provided for @featureAlbumCreationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and share family memories easily'**
  String get featureAlbumCreationSubtitle;

  /// No description provided for @featureAlbumCreationStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'albums'**
  String get featureAlbumCreationStatsLabel;

  /// No description provided for @featureSecureStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Private Storage'**
  String get featureSecureStorageTitle;

  /// No description provided for @featureSecureStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data belongs to you; local storage is safer'**
  String get featureSecureStorageSubtitle;

  /// No description provided for @featureSecureStorageStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'privacy protection'**
  String get featureSecureStorageStatsLabel;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get navLibrary;

  /// No description provided for @navAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get navAlbums;

  /// No description provided for @navUsers.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get navUsers;

  /// No description provided for @navStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get navStorage;

  /// No description provided for @navBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get navBackup;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginQrTab.
  ///
  /// In en, this message translates to:
  /// **'Scan to Sign In'**
  String get loginQrTab;

  /// No description provided for @loginPasswordTab.
  ///
  /// In en, this message translates to:
  /// **'Password Sign In'**
  String get loginPasswordTab;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsernameLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use the mobile app to scan the QR code'**
  String get loginQrInstruction;

  /// No description provided for @loginQrStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for scan...'**
  String get loginQrStatusPending;

  /// No description provided for @loginQrStatusScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned, confirm on mobile'**
  String get loginQrStatusScanned;

  /// No description provided for @loginQrStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get loginQrStatusCompleted;

  /// Display the current user
  ///
  /// In en, this message translates to:
  /// **'Current User: {username}'**
  String sessionCurrentUser(String username);

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get actionLogout;

  /// No description provided for @actionSwitchUser.
  ///
  /// In en, this message translates to:
  /// **'Switch User'**
  String get actionSwitchUser;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan to register'**
  String get registerQrInstruction;

  /// No description provided for @registerStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registerStatusPending;

  /// No description provided for @registerQrStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for scan...'**
  String get registerQrStatusPending;

  /// No description provided for @registerStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registerStatusCompleted;

  /// No description provided for @registerQrStatusScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned, awaiting confirmation'**
  String get registerQrStatusScanned;

  /// No description provided for @usersAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get usersAddUser;

  /// No description provided for @usersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get usersEmpty;

  /// No description provided for @usersRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get usersRoleAdmin;

  /// No description provided for @usersRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get usersRoleMember;

  /// No description provided for @usersResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get usersResetPassword;

  /// No description provided for @usersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get usersDelete;

  /// No description provided for @usersDeleteAdminForbidden.
  ///
  /// In en, this message translates to:
  /// **'Admin account cannot be deleted'**
  String get usersDeleteAdminForbidden;

  /// No description provided for @registerQrStatusReleased.
  ///
  /// In en, this message translates to:
  /// **'QR code released/expired'**
  String get registerQrStatusReleased;

  /// No description provided for @usersQrRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh QR code'**
  String get usersQrRefresh;

  /// No description provided for @usersAddQrDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Register QR Code'**
  String get usersAddQrDialogTitle;

  /// No description provided for @usersAddQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use Photo Mobile to scan to register'**
  String get usersAddQrInstruction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
