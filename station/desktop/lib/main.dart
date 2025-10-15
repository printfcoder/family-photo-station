import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'l10n/app_localizations.dart';
import 'views/bootstrap_view.dart';
import 'controllers/bootstrap_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/local_server.dart';
import 'controllers/invite_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      // 初始使用默认主题，SettingsController 加载后会通过 Get.changeThemeMode 同步
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      // 初始使用英文，SettingsController 加载后会通过 Get.updateLocale 同步
      locale: const Locale('en'),
      initialBinding: BindingsBuilder(() {
        Get.put(SettingsController(), permanent: true);
        Get.put(BootstrapController(), permanent: true);
        Get.put(AuthController(), permanent: true);
        final server = Get.put(LocalServer(), permanent: true);
        server.start();
        Get.put(InviteController(), permanent: true);
      }),
      home: const BootstrapView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// 语言切换逻辑可后续通过GetX与SharedPreferences持久化集成
