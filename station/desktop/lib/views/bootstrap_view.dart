import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bootstrap_controller.dart';
import '../views/hello_view.dart';
import '../views/admin_init_view.dart';
import '../views/shell_view.dart';

class BootstrapView extends GetView<BootstrapController> {
  const BootstrapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!controller.hasAdmin.value) {
        return ShellView(body: AdminInitView(service: controller.adminService));
      }
      return const ShellView(body: HelloView());
    });
  }
}