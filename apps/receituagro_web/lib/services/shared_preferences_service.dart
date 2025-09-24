import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences _prefs;

  static const String _kDarkMode = 'darkMode';

  void initializeService() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> get isDarkMode async {
    return _prefs.getBool(_kDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_kDarkMode, value);
  }
}
