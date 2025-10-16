import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../storage/storage_config.dart';
import '../storage/user_data_manager.dart';
import '../storage/smb_helper.dart';

enum StorageUIType { local, smb }

class StorageSettingsController extends GetxController {
  final storageType = StorageUIType.local.obs;
  final localPath = ''.obs;
  final smbHost = ''.obs;
  final smbShare = ''.obs;
  final smbUsername = ''.obs;
  final smbPassword = ''.obs;
  final isValidating = false.obs;
  final validateOk = false.obs;
  final validateMessage = ''.obs;

  late final StorageConfigManager _configMgr;
  late final UserDataManager _dataMgr;

  @override
  void onInit() {
    super.onInit();
    _configMgr = StorageConfigManager.instance;
    _dataMgr = UserDataManager.instance;
    _initConfigs();
  }

  Future<void> _initConfigs() async {
    await _configMgr.initialize();
    final photos = _configMgr.getConfig('photos');
    if (photos != null) {
      if (photos.type == StorageType.local) {
        storageType.value = StorageUIType.local;
        localPath.value = photos.path;
      } else if (photos.type == StorageType.network) {
        storageType.value = StorageUIType.smb;
        // 简单解析 UNC 获取 host/share
        final p = photos.path.replaceAll('\\\\', '');
        final parts = p.split('\\');
        if (parts.length >= 2) {
          smbHost.value = parts[0];
          smbShare.value = parts[1];
        }
      }
    } else {
      // 默认推荐路径
      final recs = _dataMgr.getRecommendedStorageLocations();
      if (recs.isNotEmpty) localPath.value = recs.first;
    }
  }

  Future<void> pickLocalDirectory() async {
    final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: '选择照片存储目录');
    if (dir != null) {
      localPath.value = dir;
      validateOk.value = false;
      validateMessage.value = '';
    }
  }

  Future<void> validateAndSave() async {
    isValidating.value = true;
    validateOk.value = false;
    validateMessage.value = '';
    try {
      bool ok = false;
      String path = '';
      if (storageType.value == StorageUIType.local) {
        path = localPath.value.trim();
        if (path.isEmpty) {
          validateMessage.value = '请先选择本地目录';
        } else {
          ok = await _configMgr.validateStoragePath(path);
        }
      } else {
        final host = smbHost.value.trim();
        final share = smbShare.value.trim();
        final user = smbUsername.value.trim();
        final pwd = smbPassword.value;
        if (host.isEmpty || share.isEmpty) {
          validateMessage.value = '请填写SMB主机与共享名';
        } else {
          // Windows上尝试连接
          if (Platform.isWindows && user.isNotEmpty) {
            await SmbHelper.connectShare(host: host, share: share, username: user, password: pwd);
          }
          path = SmbHelper.buildUnc(host: host, share: share);
          ok = await _configMgr.validateStoragePath(path);
        }
      }

      if (ok) {
        final cfg = StorageConfig(
          type: storageType.value == StorageUIType.local ? StorageType.local : StorageType.network,
          path: path,
          enabled: true,
          cleanupPolicy: CleanupPolicy.smartAuto,
        );
        await _configMgr.setConfig('photos', cfg);
        validateOk.value = true;
        validateMessage.value = '存储位置可用，已保存配置';
      } else {
        validateOk.value = false;
        if (validateMessage.value.isEmpty) validateMessage.value = '存储位置不可用，请检查权限或路径';
      }
    } finally {
      isValidating.value = false;
    }
  }
}