import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._();

  static final AppSettingsStore instance = AppSettingsStore._();

  Locale _locale = const Locale('en');

  bool _isDarkMode = false;

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString('app_language') ?? 'en';

    final savedDarkMode = prefs.getBool('dark_mode') ?? false;

    _locale = Locale(savedLanguage);

    _isDarkMode = savedDarkMode;

    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString('app_language') ?? 'en';

    _locale = Locale(savedLanguage);

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_language', languageCode);

    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await changeLanguage('en');
    } else {
      await changeLanguage('ar');
    }
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('dark_mode', value);

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }
}
