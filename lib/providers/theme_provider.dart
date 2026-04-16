import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currentColorSchemeName = 'sunset';
  
  ThemeMode get themeMode => _themeMode;
  String get currentColorSchemeName => _currentColorSchemeName;
  ColorScheme get currentColorScheme => AppTheme.colorSchemes[_currentColorSchemeName]!;
  
  List<String> get availableColorSchemes => AppTheme.colorSchemes.keys.toList();
  
  ThemeProvider() {
    _loadPreferences();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
  }
  
  void setColorScheme(String schemeName) {
    if (AppTheme.colorSchemes.containsKey(schemeName)) {
      _currentColorSchemeName = schemeName;
      _savePreferences();
      notifyListeners();
    }
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _savePreferences();
    notifyListeners();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _currentColorSchemeName = prefs.getString('color_scheme') ?? 'sunset';
    notifyListeners();
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setString('color_scheme', _currentColorSchemeName);
  }
  
  // 获取主题色彩的中文名称
  String getColorSchemeName(String key) {
    const names = {
      'sunset': '日落橙',
      'ocean': '海洋蓝',
      'forest': '森林紫',
      'cherry': '樱花粉',
    };
    return names[key] ?? key;
  }
}
