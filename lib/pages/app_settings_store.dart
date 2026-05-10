import 'package:flutter/material.dart';

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._();

  static final AppSettingsStore instance = AppSettingsStore._();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
