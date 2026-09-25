import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en', ''); // Always start with safe default

  LocaleProvider() {
    // Don't access SharedValues in constructor - they might not be loaded yet
    // Start with default locale, will be updated later when SharedValues are loaded
  }

  Locale get locale {
    // Always return a valid locale - never access SharedValues here
    return _locale;
  }

  void setLocale(String code) {
    try {
      if (code.isNotEmpty && code != 'null') {
        _locale = Locale(code, '');
      } else {
        _locale = const Locale('en', '');
      }
      notifyListeners();
    } catch (e) {
      print("Error setting locale: $e");
      _locale = const Locale('en', '');
      notifyListeners();
    }
  }
}
