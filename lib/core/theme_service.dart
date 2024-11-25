import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final ValueNotifier<ThemeMode> _themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  ValueNotifier<ThemeMode> get themeModeNotifier => _themeMode;

  Future<void> loadThemeFromSecureStorage() async {
    final storedTheme = await storage.read(key: 'themeMode');
    if (storedTheme != null) {
      _themeMode.value =
          storedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
  }
  void resetToLight() {
    _themeMode.value = ThemeMode.light;
  }

  void toggleTheme() {
    _themeMode.value = (_themeMode.value == ThemeMode.light)
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToSecureStorage(_themeMode.value);
  }

  Future<void> _saveThemeToSecureStorage(ThemeMode mode) async {
    await storage.write(
      key: 'themeMode',
      value: mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
