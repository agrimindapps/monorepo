import 'package:shared_preferences/shared_preferences.dart';

/// Manager for handling credentials persistence
/// Centralizes save/load logic for remembered credentials
///
/// Uses injected SharedPreferences instance to avoid duplicate registrations
/// during hot reload and ensure singleton pattern consistency
class CredentialsPersistenceManager {
  static const String _kRememberedEmailKey = 'remembered_email';
  static const String _kRememberMeKey = 'remember_me';

  final SharedPreferences _prefs;

  CredentialsPersistenceManager({required SharedPreferences prefs})
      : _prefs = prefs;

  /// Saves or removes remembered credentials based on rememberMe flag
  Future<void> saveRememberedCredentials({
    required String email,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _prefs.setString(_kRememberedEmailKey, email);
      await _prefs.setBool(_kRememberMeKey, true);
    } else {
      await _prefs.remove(_kRememberedEmailKey);
      await _prefs.setBool(_kRememberMeKey, false);
    }
  }

  /// Loads remembered credentials from storage
  /// Returns tuple of (email, rememberMe)
  Future<({String? email, bool rememberMe})> loadRememberedCredentials() async {
    final rememberedEmail = _prefs.getString(_kRememberedEmailKey);
    final rememberMe = _prefs.getBool(_kRememberMeKey) ?? false;

    return (
      email: rememberedEmail != null && rememberMe ? rememberedEmail : null,
      rememberMe: rememberMe,
    );
  }

  /// Clears all remembered credentials
  Future<void> clearRememberedCredentials() async {
    await _prefs.remove(_kRememberedEmailKey);
    await _prefs.remove(_kRememberMeKey);
  }
}
