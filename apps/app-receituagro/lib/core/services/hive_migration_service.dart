import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart'; // Changed from hive_flutter to hive (core dependency)

/// Service responsible for managing Hive schema migrations
/// Ensures data integrity across app versions
///
/// ✅ FIXED (P0.4): Created to prevent data corruption when models change
class HiveMigrationService {
  HiveMigrationService._(); // Private constructor - utility class

  /// Current schema version
  /// Increment this when adding new migrations
  static const int currentVersion = 1;

  /// Name of the box that stores the current schema version
  static const String versionBoxName = 'receituagro_schema_version';

  /// Runs all necessary migrations from installed version to current version
  ///
  /// This should be called AFTER Hive.initFlutter() but BEFORE opening any data boxes
  static Future<void> runMigrations() async {
    try {
      // Open version box (lightweight, non-persistent)
      final versionBox = await Hive.openBox<int>(versionBoxName);

      // Get installed schema version (default: 0 for fresh installs)
      final installedVersion = versionBox.get('schema_version', defaultValue: 0);

      if (kDebugMode) {
        debugPrint(
          '📦 [HiveMigrationService] Installed version: $installedVersion, '
          'Current version: $currentVersion',
        );
      }

      // Run migrations if needed
      if (installedVersion! < currentVersion) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HiveMigrationService] Running migrations from v$installedVersion to v$currentVersion...',
          );
        }

        await _migrate(installedVersion, currentVersion);

        // Update schema version
        await versionBox.put('schema_version', currentVersion);

        if (kDebugMode) {
          debugPrint('✅ [HiveMigrationService] Migrations completed successfully');
        }
      } else {
        if (kDebugMode) {
          debugPrint('✅ [HiveMigrationService] Schema is up-to-date (v$currentVersion)');
        }
      }

      // Close version box
      await versionBox.close();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [HiveMigrationService] Migration failed: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      rethrow; // Critical error - app should not continue with corrupted data
    }
  }

  /// Execute migrations incrementally from one version to another
  static Future<void> _migrate(int fromVersion, int toVersion) async {
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      if (kDebugMode) {
        debugPrint('🔄 [HiveMigrationService] Applying migration v$version...');
      }

      switch (version) {
        case 1:
          await _migrateToV1();
          break;
        // Future migrations go here:
        // case 2:
        //   await _migrateToV2();
        //   break;
        default:
          if (kDebugMode) {
            debugPrint('⚠️ [HiveMigrationService] No migration defined for v$version');
          }
      }
    }
  }

  /// Migration to version 1
  /// Initial migration - sets up baseline for future migrations
  static Future<void> _migrateToV1() async {
    if (kDebugMode) {
      debugPrint('📝 [HiveMigrationService.v1] Initial migration - baseline setup');
    }

    // V1 migration tasks:
    // - No data changes needed (fresh schema)
    // - Just establishes version tracking

    // Future example:
    // If you need to add a field to an existing model:
    // 1. Open affected boxes
    // 2. Iterate over all entries
    // 3. Update entries with new field (with default value)
    // 4. Close boxes

    if (kDebugMode) {
      debugPrint('✅ [HiveMigrationService.v1] Migration completed');
    }
  }

  /// Example: Migration to version 2 (for future reference)
  ///
  /// Use this pattern when you need to modify existing data
  // static Future<void> _migrateToV2() async {
  //   if (kDebugMode) {
  //     debugPrint('📝 [HiveMigrationService.v2] Adding newField to DiagnosticoHive');
  //   }
  //
  //   // Open affected box
  //   final box = await Hive.openBox<DiagnosticoHive>('receituagro_diagnosticos');
  //
  //   try {
  //     final keysToUpdate = box.keys.toList();
  //
  //     for (final key in keysToUpdate) {
  //       final item = box.get(key);
  //       if (item != null) {
  //         // Update item with new field
  //         final updatedItem = item.copyWith(
  //           newField: 'default_value',
  //         );
  //         await box.put(key, updatedItem);
  //       }
  //     }
  //
  //     if (kDebugMode) {
  //       debugPrint('✅ [HiveMigrationService.v2] Updated ${keysToUpdate.length} items');
  //     }
  //   } finally {
  //     await box.close();
  //   }
  // }

  /// Gets current schema version from storage
  /// Returns 0 if version box doesn't exist (fresh install)
  static Future<int> getCurrentVersion() async {
    try {
      if (!Hive.isBoxOpen(versionBoxName)) {
        final versionBox = await Hive.openBox<int>(versionBoxName);
        final version = versionBox.get('schema_version', defaultValue: 0);
        await versionBox.close();
        return version!;
      } else {
        final versionBox = Hive.box<int>(versionBoxName);
        return versionBox.get('schema_version', defaultValue: 0)!;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [HiveMigrationService] Error getting version: $e');
      }
      return 0; // Assume fresh install on error
    }
  }

  /// Checks if migrations are needed
  static Future<bool> needsMigration() async {
    final installedVersion = await getCurrentVersion();
    return installedVersion < currentVersion;
  }

  /// Resets schema version (FOR TESTING ONLY - DO NOT USE IN PRODUCTION)
  @visibleForTesting
  static Future<void> resetSchemaVersion() async {
    try {
      final versionBox = await Hive.openBox<int>(versionBoxName);
      await versionBox.clear();
      await versionBox.close();

      if (kDebugMode) {
        debugPrint('🔄 [HiveMigrationService] Schema version reset (TEST MODE)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HiveMigrationService] Error resetting version: $e');
      }
    }
  }
}
