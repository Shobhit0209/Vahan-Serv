import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vahanserv/Screens/CCE%20Section/cce_dashboard_screen.dart';

class LanguageProvider with ChangeNotifier {
  Locale? _appLocale;
  bool _isInitializing = false;
  Locale? get appLocale => _appLocale;
  bool get isInitializing => _isInitializing;

  Language? get currentLanguage {
    if (_appLocale?.languageCode == 'en') {
      return Language.english;
    } else if (_appLocale?.languageCode == 'hi') {
      return Language.hindi;
    }
    return null;
  }

  // Helper method to check if a specific language is selected
  bool isLanguageSelected(Language language) {
    return currentLanguage == language;
  }

  Future<void> initializeLanguage(String langCode) async {
    if (_isInitializing || _appLocale != null) return;
    _isInitializing = true;
    notifyListeners();
    if (langCode.isNotEmpty) {
      _appLocale = Locale(langCode);
    } else {
      _appLocale = Locale('en'); // Default fallback
    }
    _isInitializing = false;
    notifyListeners();
  }

  void changeLang(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (type == Locale('en')) {
      await sp.setString('lang_code', 'en');
    } else {
      await sp.setString('lang_code', 'hi');
    }
    _appLocale = type;
    notifyListeners();
  }
}
