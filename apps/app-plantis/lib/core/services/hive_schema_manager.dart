import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Schema migration manager for Hive boxes
/// Handles version upgrades and data transformations
class HiveSchemaManager {
  static const String _versionKey = 'schema_version';
  static const int currentVersion = 2;

  /// Run migrations if needed
  static Future<void> migrate() async {
    final prefs = await Hive.openBox<dynamic>('preferences');
    final oldVersion = prefs.get(_versionKey, defaultValue: 1) as int;

    if (oldVersion < currentVersion) {
      await _runMigrations(oldVersion, currentVersion);
      await prefs.put(_versionKey, currentVersion);

      if (kDebugMode) {
        print('✅ Hive schema migrated from v$oldVersion to v$currentVersion');
      }
    } else {
      if (kDebugMode) {
        print('ℹ️ Hive schema is up to date (v$currentVersion)');
      }
    }

    await prefs.close();
  }

  /// Execute migrations in sequence
  static Future<void> _runMigrations(int from, int to) async {
    for (int version = from + 1; version <= to; version++) {
      switch (version) {
        case 2:
          await _migrateV1ToV2();
          break;
        // Add future migrations here
        // case 3:
        //   await _migrateV2ToV3();
        //   break;
        default:
          if (kDebugMode) {
            print('⚠️ No migration defined for version $version');
          }
      }
    }
  }

  /// Migration v1 → v2: Add wateringFrequency field to plants
  static Future<void> _migrateV1ToV2() async {
    if (kDebugMode) {
      print('🔄 Migrating plants box v1 → v2');
    }

    try {
      final box = await Hive.openBox<dynamic>('plants');

      for (final key in box.keys) {
        final plantData = box.get(key);
        if (plantData is Map) {
          final mutableData = Map<String, dynamic>.from(plantData);

          // Add missing wateringFrequency field with default value
          if (!mutableData.containsKey('wateringFrequency')) {
            mutableData['wateringFrequency'] = 7; // Default: water every 7 days
          }

          // Ensure version field exists
          if (!mutableData.containsKey('version')) {
            mutableData['version'] = 1;
          }

          await box.put(key, mutableData);
        }
      }

      await box.close();

      if (kDebugMode) {
        print('✅ Plants migration v1 → v2 completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Plants migration v1 → v2 failed: $e');
      }
      rethrow;
    }
  }

  /// Add future migrations here
  // static Future<void> _migrateV2ToV3() async {
  //   // Future migration logic
  // }

  /// Force reset schema version (for testing/debugging)
  static Future<void> resetVersion() async {
    final prefs = await Hive.openBox<dynamic>('preferences');
    await prefs.delete(_versionKey);
    await prefs.close();

    if (kDebugMode) {
      print('🔄 Schema version reset');
    }
  }

  /// Get current schema version
  static Future<int> getCurrentVersion() async {
    final prefs = await Hive.openBox<dynamic>('preferences');
    final version = prefs.get(_versionKey, defaultValue: 1) as int;
    await prefs.close();
    return version;
  }
}
