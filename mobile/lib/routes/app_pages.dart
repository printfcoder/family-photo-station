import 'package:get/get.dart';
import '../features/splash/splash_screen.dart';
import '../features/discovery/discovery_screen.dart';

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
  ];
}