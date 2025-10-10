import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:window_manager/window_manager.dart';

import 'package:family_photo_desktop/core/controllers/auth_controller.dart';
import 'package:family_photo_desktop/core/controllers/photo_controller.dart';
import 'package:family_photo_desktop/core/controllers/photos_page_controller.dart';
import 'package:family_photo_desktop/core/controllers/album_controller.dart';
import 'package:family_photo_desktop/core/controllers/user_controller.dart';
import 'package:family_photo_desktop/core/controllers/network_controller.dart';
import 'package:family_photo_desktop/core/services/storage_service.dart';
import 'package:family_photo_desktop/core/services/api_service.dart';
import 'package:family_photo_desktop/core/theme/app_theme.dart';
import 'package:family_photo_desktop/core/router/app_router.dart';
import 'package:family_photo_desktop/core/widgets/error_bottom_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  await StorageService().init();
  
  // 初始化API服务和控制器
  final dio = Dio();
  Get.put(ApiService(dio));
  Get.put(AuthController());
  Get.put(PhotoController()); // Core PhotoController
  Get.put(PhotosPageController()); // Features PhotosPageController
  Get.put(AlbumController());
  Get.put(UserController());
  Get.put(NetworkController());
  
  runApp(const FamilyPhotoDesktopApp());
}

class FamilyPhotoDesktopApp extends StatelessWidget {
  const FamilyPhotoDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: '家庭照片站 - 管理端',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ErrorBottomBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}
