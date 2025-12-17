import 'package:flutter/foundation.dart';

/// Manager for checking if email already exists
/// Extracted from register_notifier for better separation of concerns
class EmailCheckerManager {
  /// Checks if email already exists in the system
  /// This is a placeholder implementation - should be replaced with actual API call
  Future<bool> checkExists(String email) async {
    try {
      // Simulate API call delay
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Placeholder: in reality, this should call an API endpoint
      final exists = email.toLowerCase() == 'test@test.com';

      return exists;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email: $e');
      }
      return false;
    }
  }
}
