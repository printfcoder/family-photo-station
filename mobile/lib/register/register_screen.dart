import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_photo_mobile/routes/app_pages.dart';
import 'package:dio/dio.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nicknameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  File? _avatarFile;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _avatarFile = File(img.path);
      });
    }
  }

  Future<void> _submit() async {
    final nickname = _nicknameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入昵称')));
      return;
    }
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请设置至少6位密码')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('station.host');
    final port = prefs.getInt('station.port');
    final token = prefs.getString('qr.token');
    if (host == null || port == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('缺少连接信息，请返回并重新扫描/连接')));
      return;
    }
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)));
      final resp = await dio.post('http://$host:$port/qr/register/confirm', data: {
        'token': token,
        'username': nickname,
        'displayName': nickname,
        'password': password,
      });
      if (resp.statusCode == 200) {
        await prefs.setString('user.nickname', nickname);
        if (_avatarFile != null) {
          await prefs.setString('user.avatarPath', _avatarFile!.path);
        }
        await prefs.setBool('first_run_completed', true);
        Get.offAllNamed(Routes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册失败')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('注册失败，昵称可能已存在或连接异常')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('快速注册')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('设置您的昵称与头像，完成后立即开始使用'),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                  child: _avatarFile == null ? const Icon(Icons.person, size: 36) : null,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.photo),
                  label: const Text('选择头像'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameCtrl,
              decoration: const InputDecoration(labelText: '昵称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: '密码（至少6位）'),
              obscureText: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('完成注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}