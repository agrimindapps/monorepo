import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Preference Migration Utility
///
/// Migrates user theme preferences from app-specific key to core package key
/// Ensures seamless transition from local ThemeProvider to core ThemeProvider
class ThemePreferenceMigration {
  static const String _oldKey = 'theme_mode_receituagro';
  static const String _newKey = 'theme_mode';
  static const String _migrationCompleteKey = 'theme_migration_completed_v1';

  /// Migrates theme preferences from app-specific to core package key
  ///
  /// Returns true if migration was performed, false if already completed
  static Future<bool> migratePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if migration already completed
      final migrationCompleted = prefs.getBool(_migrationCompleteKey) ?? false;
      if (migrationCompleted) {
        debugPrint('Theme preferences migration already completed');
        return false;
      }

      // Check for old preference
      final oldTheme = prefs.getString(_oldKey);
      if (oldTheme != null) {
        // Check if new key already exists (avoid overwriting)
        final existingNewTheme = prefs.getString(_newKey);
        if (existingNewTheme == null) {
          // Migrate to new key
          await prefs.setString(_newKey, oldTheme);
          debugPrint('Theme preferences migrated: $oldTheme -> $_newKey');
        } else {
          debugPrint('Theme preferences: new key already exists, keeping existing value');
        }

        // Remove old key
        await prefs.remove(_oldKey);
        debugPrint('Old theme preference key removed: $_oldKey');
      } else {
        debugPrint('Theme preferences migration: no old preferences found');
      }

      // Mark migration as completed
      await prefs.setBool(_migrationCompleteKey, true);
      debugPrint('Theme preferences migration completed successfully');
      return true;
    } catch (error, stackTrace) {
      debugPrint('Theme preferences migration failed: $error');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Validates current theme preference setup
  ///
  /// Useful for debugging migration issues
  static Future<void> validatePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final oldTheme = prefs.getString(_oldKey);
      final newTheme = prefs.getString(_newKey);
      final migrationCompleted = prefs.getBool(_migrationCompleteKey) ?? false;

      debugPrint('=== Theme Preferences Validation ===');
      debugPrint('Old key ($_oldKey): $oldTheme');
      debugPrint('New key ($_newKey): $newTheme');
      debugPrint('Migration completed: $migrationCompleted');
      debugPrint('====================================');
    } catch (error) {
      debugPrint('Theme preferences validation failed: $error');
    }
  }

  /// Resets migration state (for testing purposes)
  ///
  /// WARNING: Only use during development/testing
  static Future<void> resetMigrationState() async {
    if (!kDebugMode) {
      debugPrint('Migration reset only allowed in debug mode');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationCompleteKey);
      debugPrint('Theme migration state reset');
    } catch (error) {
      debugPrint('Failed to reset migration state: $error');
    }
  }
}