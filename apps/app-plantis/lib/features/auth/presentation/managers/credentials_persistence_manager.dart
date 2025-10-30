import 'package:shared_preferences/shared_preferences.dart';

/// Manager for handling credentials persistence
/// Centralizes save/load logic for remembered credentials
class CredentialsPersistenceManager {
  static const String _kRememberedEmailKey = 'remembered_email';
  static const String _kRememberMeKey = 'remember_me';

  /// Saves or removes remembered credentials based on rememberMe flag
  Future<void> saveRememberedCredentials({
    required String email,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString(_kRememberedEmailKey, email);
      await prefs.setBool(_kRememberMeKey, true);
    } else {
      await prefs.remove(_kRememberedEmailKey);
      await prefs.setBool(_kRememberMeKey, false);
    }
  }

  /// Loads remembered credentials from storage
  /// Returns tuple of (email, rememberMe)
  Future<({String? email, bool rememberMe})> loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final rememberedEmail = prefs.getString(_kRememberedEmailKey);
    final rememberMe = prefs.getBool(_kRememberMeKey) ?? false;

    return (
      email: rememberedEmail != null && rememberMe ? rememberedEmail : null,
      rememberMe: rememberMe,
    );
  }

  /// Clears all remembered credentials
  Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRememberedEmailKey);
    await prefs.remove(_kRememberMeKey);
  }
}
