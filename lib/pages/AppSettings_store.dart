import 'package:flutter/material.dart';

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._internal();

  static final AppSettingsStore instance = AppSettingsStore._internal();

  ThemeMode themeMode = ThemeMode.light;
  Locale locale = const Locale('en');
  double textScale = 1.0;

  void updateThemeMode(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void updateLocale(String languageCode) {
    locale = Locale(languageCode);
    notifyListeners();
  }

  void updateTextScale(double value) {
    textScale = value;
    notifyListeners();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isArabic => locale.languageCode == 'ar';
}
