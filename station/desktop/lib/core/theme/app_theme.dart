import 'package:flutter/material.dart';

class AppTheme {
  // 温馨家庭风格的颜色配置 - 参考Kidory的温暖色调
  static const Color _primaryColor = Color(0xFFFF8A65); // 温暖的橙色
  static const Color _secondaryColor = Color(0xFF81C784); // 温和的绿色
  static const Color _accentColor = Color(0xFF64B5F6); // 天空蓝
  static const Color _backgroundColor = Color(0xFFFFF8E1); // 温暖的米色背景
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _cardColor = Color(0xFFFFF3E0); // 浅橙色卡片背景
  static const Color _errorColor = Color(0xFFEF5350);
  
  // 深色主题颜色 - 保持温馨感
  static const Color _darkBackgroundColor = Color(0xFF2E2E2E);
  static const Color _darkSurfaceColor = Color(0xFF3E3E3E);
  static const Color _darkOnSurface = Color(0xFFE0E0E0);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        primaryContainer: Color(0xFFFFE0B2), // 浅橙色容器
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFFC8E6C9), // 浅绿色容器
        tertiary: _accentColor,
        tertiaryContainer: Color(0xFFE1F5FE), // 浅蓝色容器
        surface: _backgroundColor,
        surfaceContainerHighest: Color(0xFFFFF8E1),
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF5D4037), // 温暖的棕色文字
        onError: Colors.white,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor,
        foregroundColor: Color(0xFF5D4037),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF5D4037),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      
      // 卡片主题 - 更温馨的圆角和阴影
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 4,
        shadowColor: _primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 更大的圆角
        ),
      ),
      
      // 按钮主题 - 更圆润的设计
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: _primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 圆角按钮
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: BorderSide(color: _primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // 输入框主题 - 温馨的圆角设计
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFF8E1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE1E8ED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFCC80)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Color(0xFF8D6E63),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 文本主题 - 温馨的字体颜色和样式
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5D4037),
          fontFamily: 'Roboto',
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5D4037),
          fontFamily: 'Roboto',
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5D4037),
          fontFamily: 'Roboto',
          letterSpacing: 0,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5D4037),
          fontFamily: 'Roboto',
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5D4037),
          fontFamily: 'Roboto',
          letterSpacing: 0.15,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6D4C41),
          fontFamily: 'Roboto',
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6D4C41),
          fontFamily: 'Roboto',
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8D6E63),
          fontFamily: 'Roboto',
          letterSpacing: 0.4,
          height: 1.3,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        primaryContainer: Color(0xFF4C4DDB),
        secondary: _secondaryColor,
        secondaryContainer: Color(0xFF5A9B7A),
        surface: _darkBackgroundColor,
        surfaceContainerHighest: Color(0xFF3C4043),
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkOnSurface,
        onError: Colors.white,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurfaceColor,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // 卡片主题
      cardTheme: const CardThemeData(
        color: _darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(
            color: Color(0xFF3C4043),
            width: 1,
          ),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF191B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3C4043)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3C4043)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Color(0xFF606984),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 文本主题 - 深色模式下的温馨字体样式
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: 0,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: 0.15,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _darkOnSurface,
          fontFamily: 'Roboto',
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF606984),
          fontFamily: 'Roboto',
          letterSpacing: 0.4,
          height: 1.3,
        ),
      ),
    );
  }
}
