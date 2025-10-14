import 'package:get/get.dart';
import 'package:family_photo_desktop/database/db/sqlite_client.dart';
import 'package:family_photo_desktop/database/users/user_repository.dart';
import 'package:family_photo_desktop/domain/admin_init_service.dart';

class BootstrapController extends GetxController {
  final isLoading = true.obs;
  final hasAdmin = false.obs;
  late final AdminInitService adminService;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final db = SqliteClient();
    await db.init();
    final users = UserRepository(db);
    adminService = AdminInitService(users);
    final exists = await adminService.hasAdmin();
    hasAdmin.value = exists;
    isLoading.value = false;
  }
}