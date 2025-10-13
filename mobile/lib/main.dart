import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_mobile/core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const FamilyPhotoApp());
}

class FamilyPhotoApp extends StatelessWidget {
  const FamilyPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '家庭照片站',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
