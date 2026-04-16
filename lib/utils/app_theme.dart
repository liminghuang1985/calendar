import 'package:flutter/material.dart';

class AppTheme {
  // 多彩主题色彩方案
  static const Map<String, ColorScheme> colorSchemes = {
    'sunset': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFF6B6B),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFE66D),
      onSecondary: Color(0xFF2D3436),
      surface: Color(0xFFFFF5F5),
      onSurface: Color(0xFF2D3436),
      error: Color(0xFFE74C3C),
      onError: Colors.white,
    ),
    'ocean': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4ECDC4),
      onPrimary: Colors.white,
      secondary: Color(0xFF45B7D1),
      onSecondary: Colors.white,
      surface: Color(0xFFF0FDFC),
      onSurface: Color(0xFF2D3436),
      error: Color(0xFFE74C3C),
      onError: Colors.white,
    ),
    'forest': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF6C5CE7),
      onPrimary: Colors.white,
      secondary: Color(0xFF00B894),
      onSecondary: Colors.white,
      surface: Color(0xFFF8F9FF),
      onSurface: Color(0xFF2D3436),
      error: Color(0xFFE74C3C),
      onError: Colors.white,
    ),
    'cherry': ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFE84393),
      onPrimary: Colors.white,
      secondary: Color(0xFFFF7675),
      onSecondary: Colors.white,
      surface: Color(0xFFFFF5F8),
      onSurface: Color(0xFF2D3436),
      error: Color(0xFFE74C3C),
      onError: Colors.white,
    ),
  };

  static ThemeData lightTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: colorScheme.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // 浮动按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.primary),
      ),
    );
  }

  static ThemeData darkTheme(ColorScheme colorScheme) {
    final darkColorScheme = ColorScheme.dark(
      primary: colorScheme.primary,
      secondary: colorScheme.secondary,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
    );
    
    return lightTheme(darkColorScheme).copyWith(
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
