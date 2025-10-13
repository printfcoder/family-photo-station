import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart';
import '../domain/admin_init_service.dart';
import '../controllers/admin_init_controller.dart';
import '../controllers/bootstrap_controller.dart';

class AdminInitView extends StatelessWidget {
  final AdminInitService service;
  const AdminInitView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ctrl = Get.put(AdminInitController(service));
    final usernameCtrl = TextEditingController();
    final displayNameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: Text(t.adminInitTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.adminInitDescription),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(labelText: t.adminUsernameLabel),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return t.fieldRequired;
                        if (v.trim().length < 3) return t.fieldMinLength(3);
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: displayNameCtrl,
                      decoration: InputDecoration(labelText: t.adminDisplayNameLabel),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: t.adminPasswordLabel),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return t.fieldRequired;
                        if (v.trim().length < 6) return t.fieldMinLength(6);
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: t.adminPasswordConfirmLabel),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return t.fieldRequired;
                        if (v.trim().length < 6) return t.fieldMinLength(6);
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final submitting = ctrl.isSubmitting.value;
                      final errKey = ctrl.errorKey.value;
                      return Column(
                        children: [
                          if (errKey != null)
                            Text(
                              t.translateErrorKey(errKey),
                              style: const TextStyle(color: Colors.red),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;
                                      final ok = await ctrl.submit(
                                        username: usernameCtrl.text.trim(),
                                        displayName: displayNameCtrl.text.trim().isEmpty ? null : displayNameCtrl.text.trim(),
                                        password: passwordCtrl.text,
                                        confirm: confirmCtrl.text,
                                      );
                                      if (ok) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(t.adminInitSuccess)),
                                        );
                                        // 通知引导控制器刷新状态
                                        Get.find<BootstrapController>().hasAdmin.value = true;
                                      }
                                    },
                              child: submitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(t.adminInitSubmit),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}