import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:family_photo_desktop/core/constants/app_constants.dart';
import 'package:family_photo_desktop/core/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final _selectedIndex = 0.obs;
  final AuthController authController = Get.find<AuthController>();

  int get selectedIndex => _selectedIndex.value;

  final List<String> routes = [
    AppRoutes.dashboard,
    AppRoutes.photos,
    AppRoutes.albums,
    AppRoutes.users,
    AppRoutes.settings,
  ];

  void onDestinationSelected(int index) {
    _selectedIndex.value = index;
    Get.context?.go(routes[index]);
  }

  Future<void> logout() async {
    await authController.logout();
    Get.context?.go(AppRoutes.login);
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  void onUploadPhotos() {
    // TODO: 实现快速上传功能
  }
}