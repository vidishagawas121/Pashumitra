import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final String _languagePrefsKey = 'preferred_language';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languagePrefsKey);
      
      if (savedLanguage != null) {
        _locale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_locale.languageCode != locale.languageCode) {
      _locale = locale;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languagePrefsKey, locale.languageCode);
      } catch (e) {
        // Handle error
      }
      
      notifyListeners();
    }
  }

  bool isCurrentLanguage(String languageCode) {
    return _locale.languageCode == languageCode;
  }
} 