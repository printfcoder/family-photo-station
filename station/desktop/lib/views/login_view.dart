import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:family_photo_desktop/services/local_server.dart';

import 'package:family_photo_desktop/l10n/app_localizations.dart';
import 'package:family_photo_desktop/controllers/auth_controller.dart';
// ShellView is provided by BootstrapView; do not wrap again here.

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmUsernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    auth.startQrLogin();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocusNode.dispose();
    _confirmUsernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();

    return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(t.loginTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Obx(() {
                        final switching = auth.isSwitching.value;
                        if (!switching) return const SizedBox.shrink();
                        return OutlinedButton.icon(
                          onPressed: () async {
                            await auth.cancelSwitch();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('返回'),
                        );
                      })
                    ],
                  ),
                  const SizedBox(height: 16),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(tabs: [
                          Tab(text: t.loginQrTab),
                          Tab(text: t.loginPasswordTab),
                        ]),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 380,
                          child: TabBarView(children: [
                            // 扫码登录
                            Obx(() {
                              final token = auth.qrToken.value;
                              final status = auth.qrStatus.value;
                              final server = Get.find<LocalServer>();
                              final statusText = switch (status) {
                                QrLoginStatus.idle => t.loginQrStatusPending,
                                QrLoginStatus.pending => t.loginQrStatusPending,
                                QrLoginStatus.scanned => t.loginQrStatusScanned,
                                QrLoginStatus.confirmed => t.loginQrStatusCompleted,
                              };

                              return Row(
                                children: [
                                  // 左：二维码
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: QrImageView(
                                            data: 'familyphoto://login?host=${server.hostAddress}&port=${server.listenPort}&token=$token',
                                            version: QrVersions.auto,
                                            size: 220,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(t.loginQrInstruction),
                                        const SizedBox(height: 8),
                                        Text(statusText, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // 右：模拟区（开发阶段）
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Dev Helper'),
                                        const SizedBox(height: 8),
                                        Wrap(spacing: 12, children: [
                                          ElevatedButton(onPressed: auth.markQrScanned, child: const Text('标记已扫码')),
                                        ]),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: _confirmUsernameCtrl,
                                          decoration: const InputDecoration(labelText: '确认为用户名'),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final name = _confirmUsernameCtrl.text.trim();
                                            if (name.isEmpty) return;
                                            final ok = await auth.confirmQrLoginAs(name);
                                            if (!ok && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('用户不存在')),
                                              );
                                            }
                                          },
                                          child: const Text('模拟确认并登录'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }),

                            // 密码登录
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _usernameCtrl,
                                  decoration: InputDecoration(labelText: t.loginUsernameLabel),
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _passwordCtrl,
                                  obscureText: true,
                                  decoration: InputDecoration(labelText: t.loginPasswordLabel),
                                  focusNode: _passwordFocusNode,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) async {
                                    final auth = Get.find<AuthController>();
                                    final ok = await auth.loginWithPassword(
                                      _usernameCtrl.text.trim(),
                                      _passwordCtrl.text,
                                    );
                                    if (!ok && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('用户名或密码错误')),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    final ok = await auth.loginWithPassword(
                                      _usernameCtrl.text.trim(),
                                      _passwordCtrl.text,
                                    );
                                    if (!ok && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('用户名或密码错误')),
                                      );
                                    }
                                  },
                                  child: Text(t.loginSignInButton),
                                )
                              ],
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}