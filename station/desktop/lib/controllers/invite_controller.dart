import 'dart:async';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum QrRegisterStatus { idle, pending, scanned, completed }

class InviteController extends GetxController {
  final regToken = ''.obs;
  final regStatus = QrRegisterStatus.idle.obs;
  Timer? _timer;

  void startQrRegister() {
    regToken.value = const Uuid().v4();
    regStatus.value = QrRegisterStatus.pending;
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 2), () {
      if (regStatus.value != QrRegisterStatus.completed) {
        release();
      }
    });
  }

  void markRegScanned() {
    if (regStatus.value == QrRegisterStatus.pending) {
      regStatus.value = QrRegisterStatus.scanned;
    }
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 2), () {
      if (regStatus.value != QrRegisterStatus.completed) {
        release();
      }
    });
  }

  void completeRegister() {
    regStatus.value = QrRegisterStatus.completed;
    _timer?.cancel();
    _timer = null;
  }

  void release() {
    regToken.value = '';
    regStatus.value = QrRegisterStatus.idle;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}