import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/recent_access.dart';

/// Local data source for recent access storage using SharedPreferences
abstract class RecentAccessLocalDataSource {
  /// Get recent access entries by type
  Future<List<RecentAccess>> getRecentByType(RecentAccessType type);

  /// Add a new recent access entry
  Future<void> addRecentAccess(RecentAccess access);

  /// Clear all recent access history for a type
  Future<void> clearHistory(RecentAccessType type);

  /// Clear all recent access history
  Future<void> clearAllHistory();
}

/// Implementation of RecentAccessLocalDataSource using SharedPreferences
class RecentAccessLocalDataSourceImpl implements RecentAccessLocalDataSource {
  final SharedPreferences _prefs;

  /// Maximum items to store per type
  static const int maxItemsPerType = 10;

  RecentAccessLocalDataSourceImpl(this._prefs);

  @override
  Future<List<RecentAccess>> getRecentByType(RecentAccessType type) async {
    final jsonString = _prefs.getString(type.storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => RecentAccess.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  @override
  Future<void> addRecentAccess(RecentAccess access) async {
    // Get existing items
    final existingItems = await getRecentByType(access.type);

    // Remove existing entry for the same itemId if exists
    existingItems.removeWhere((item) => item.itemId == access.itemId);

    // Add new entry at the beginning
    existingItems.insert(0, access);

    // Trim to max items
    final trimmedItems = existingItems.take(maxItemsPerType).toList();

    // Save to storage
    final jsonString = json.encode(
      trimmedItems.map((item) => item.toJson()).toList(),
    );
    await _prefs.setString(access.type.storageKey, jsonString);
  }

  @override
  Future<void> clearHistory(RecentAccessType type) async {
    await _prefs.remove(type.storageKey);
  }

  @override
  Future<void> clearAllHistory() async {
    for (final type in RecentAccessType.values) {
      await _prefs.remove(type.storageKey);
    }
  }
}
