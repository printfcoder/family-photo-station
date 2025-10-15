import 'package:get/get.dart';
import 'package:family_photo_mobile/splash/splash_screen.dart';
import 'package:family_photo_mobile/discovery/discovery_screen.dart';
import 'package:family_photo_mobile/register/register_screen.dart';
import 'package:family_photo_mobile/home/home_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.discovery,
      page: () => const DiscoveryScreen(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
    ),
  ];
}