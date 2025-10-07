// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import 'package:family_photo_mobile/main.dart';
import 'package:family_photo_mobile/core/controllers/auth_controller.dart';
import 'package:family_photo_mobile/core/controllers/photo_controller.dart';
import 'package:family_photo_mobile/core/controllers/album_controller.dart';
import 'package:family_photo_mobile/core/services/storage_service.dart';
import 'package:family_photo_mobile/core/services/api_service.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // 初始化测试环境
    await Hive.initFlutter();
    await StorageService().init();
    
    // 初始化GetX服务
    final dio = Dio();
    Get.put(ApiService(dio));
    Get.put(AuthController());
    Get.put(PhotoController());
    Get.put(AlbumController());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FamilyPhotoApp());

    // 验证应用是否正常启动
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
