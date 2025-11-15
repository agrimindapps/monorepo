import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist connectivity state between app sessions
///
/// Follows SRP: Single responsibility of managing connectivity state persistence
class ConnectivityStateManager {
  static const String _key = 'last_connectivity_state';
  static const String _lastCheckKey = 'last_connectivity_check';

  /// Save the current connectivity state
  Future<void> saveState(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isOnline);
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Load the last saved connectivity state
  Future<bool> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);

    // If no state saved or check is too old (>24h), assume online
    if (lastCheck == null) {
      return true;
    }

    final checkAge = DateTime.now().millisecondsSinceEpoch - lastCheck;
    const maxAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

    if (checkAge > maxAge) {
      // State is too old, assume online
      return true;
    }

    return prefs.getBool(_key) ?? true;
  }

  /// Clear saved connectivity state
  Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_lastCheckKey);
  }

  /// Get the timestamp of the last connectivity check
  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCheckKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }
}
