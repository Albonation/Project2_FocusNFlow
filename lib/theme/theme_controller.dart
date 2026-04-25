import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;

  bool get isLoaded => _isLoaded;

  bool get isDark => _themeMode == ThemeMode.dark;

  bool get isLight => _themeMode == ThemeMode.light;

  bool get isSystem => _themeMode == ThemeMode.system;

  Future<void> loadTheme() async {
    final savedTheme = await _prefs.getString(_themeKey);

    _themeMode = _themeModeFromString(savedTheme);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
