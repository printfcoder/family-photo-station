class Validators {
  // 验证用户名
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少需要3个字符';
    }
    if (value.length > 20) {
      return '用户名不能超过20个字符';
    }
    // 检查是否包含特殊字符
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }
    return null;
  }

  // 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少需要6个字符';
    }
    if (value.length > 50) {
      return '密码不能超过50个字符';
    }
    return null;
  }

  // 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  // 验证确认密码
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '密码不匹配';
    }
    return null;
  }

  // 验证显示名称
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 显示名称可以为空
    }
    if (value.length > 50) {
      return '显示名称不能超过50个字符';
    }
    return null;
  }
}