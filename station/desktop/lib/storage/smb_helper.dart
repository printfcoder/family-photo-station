import 'dart:io';

/// SMB 辅助工具，仅在 Windows 上尝试使用 `net use` 建立会话
class SmbHelper {
  /// 连接到 SMB 共享，返回是否成功
  static Future<bool> connectShare({
    required String host,
    required String share,
    required String username,
    required String password,
  }) async {
    if (!Platform.isWindows) {
      // 非 Windows 暂不支持主动连接，依赖系统已挂载
      return false;
    }
    final unc = r"\\" + host + r"\" + share;
    try {
      final result = await Process.run('net', ['use', unc, password, '/USER:$username']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// 断开 SMB 共享连接
  static Future<void> disconnectShare({
    required String host,
    required String share,
  }) async {
    if (!Platform.isWindows) return;
    final unc = r"\\" + host + r"\" + share;
    try {
      await Process.run('net', ['use', unc, '/delete']);
    } catch (_) {}
  }

  /// 构造 UNC 路径
  static String buildUnc({required String host, required String share, String? subPath}) {
    final base = r"\\" + host + r"\" + share;
    if (subPath == null || subPath.isEmpty) return base;
    return base + (subPath.startsWith('\\') ? subPath : '\\' + subPath);
  }
}