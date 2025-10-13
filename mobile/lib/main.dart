import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import 'package:family_photo_mobile/core/controllers/auth_controller.dart';
import 'package:family_photo_mobile/core/controllers/photo_controller.dart';
import 'package:family_photo_mobile/core/controllers/album_controller.dart';
import 'package:family_photo_mobile/core/services/storage_service.dart';
import 'package:family_photo_mobile/core/services/api_service.dart';
import 'package:family_photo_mobile/core/theme/app_theme.dart';
import 'package:family_photo_mobile/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  await StorageService().init();
  
  // 初始化API服务
  final dio = Dio();
  Get.put(ApiService(dio));
  Get.put(AuthController());
  Get.put(PhotoController());
  Get.put(AlbumController());
  
  runApp(const FamilyPhotoApp());
}

class FamilyPhotoApp extends StatelessWidget {
  const FamilyPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: '家庭照片站',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
