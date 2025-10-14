import 'package:get/get.dart';
import 'package:family_photo_desktop/domain/admin_init_service.dart';

class AdminInitController extends GetxController {
  final AdminInitService service;
  AdminInitController(this.service);

  final isSubmitting = false.obs;
  final errorKey = RxnString();

  Future<bool> submit({required String username, String? displayName, required String password, required String confirm}) async {
    if (password != confirm) {
      errorKey.value = 'password_not_match';
      return false;
    }
    isSubmitting.value = true;
    errorKey.value = null;
    try {
      await service.createAdmin(username: username, password: password, displayName: displayName);
      return true;
    } catch (e) {
      errorKey.value = e is StateError ? e.message : 'unknown_error';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}