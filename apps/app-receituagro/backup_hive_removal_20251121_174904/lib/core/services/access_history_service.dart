import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking access history of defensivos and pragas
/// Uses SharedPreferences for persistence
class AccessHistoryService {
  static const String _keyDefensivosHistory = 'defensivos_access_history';
  static const String _keyPragasHistory = 'pragas_access_history';
  static const int _maxHistoryItems = 50;

  /// Record generic access (for backward compatibility)
  void recordAccess(String entityType, String entityId) {
    // Stub for compatibility
  }

  void recordView(String entityType, String entityId) {
    recordAccess(entityType, entityId);
  }

  void recordInteraction(String entityType, String entityId, String action) {
    recordAccess(entityType, entityId);
  }

  /// Record defensivo access with full details
  Future<void> recordDefensivoAccess({
    String? id,
    String? name,
    String? fabricante,
    String? ingrediente,
    String? classe,
  }) async {
    if (id == null || id.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keyDefensivosHistory);
      final List<Map<String, dynamic>> history = historyJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(historyJson) as List)
          : [];

      // Remove existing entry if present (to update timestamp)
      history.removeWhere((item) => item['id'] == id);

      // Add new entry at the beginning (most recent first)
      history.insert(0, {
        'id': id,
        'name': name ?? '',
        'fabricante': fabricante ?? '',
        'ingrediente': ingrediente ?? '',
        'classe': classe ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only the most recent items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save back to SharedPreferences
      await prefs.setString(_keyDefensivosHistory, jsonEncode(history));
    } catch (e) {
      // Fail silently - history is not critical
    }
  }

  /// Get defensivos history
  Future<List<dynamic>> getDefensivosHistory({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keyDefensivosHistory);

      if (historyJson == null) return [];

      final List<dynamic> history = jsonDecode(historyJson) as List;
      return history.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Record praga access with full details
  Future<void> recordPragaAccess({
    String? id,
    String? nomeComum,
    String? nomeCientifico,
    String? tipoPraga,
  }) async {
    if (id == null || id.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keyPragasHistory);
      final List<Map<String, dynamic>> history = historyJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(historyJson) as List)
          : [];

      // Remove existing entry if present (to update timestamp)
      history.removeWhere((item) => item['id'] == id);

      // Add new entry at the beginning (most recent first)
      history.insert(0, {
        'id': id,
        'nomeComum': nomeComum ?? '',
        'nomeCientifico': nomeCientifico ?? '',
        'tipoPraga': tipoPraga ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only the most recent items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save back to SharedPreferences
      await prefs.setString(_keyPragasHistory, jsonEncode(history));
    } catch (e) {
      // Fail silently - history is not critical
    }
  }

  /// Get pragas history
  Future<List<dynamic>> getPragasHistory({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keyPragasHistory);

      if (historyJson == null) return [];

      final List<dynamic> history = jsonDecode(historyJson) as List;
      return history.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get recent access IDs (for backward compatibility)
  static List<String> getRecentAccess(String entityType, {int limit = 10}) {
    return [];
  }

  /// Get access statistics (for backward compatibility)
  static Map<String, int> getAccessStats(String entityType) {
    return {};
  }

  /// Clear all history (useful for testing/debugging)
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDefensivosHistory);
      await prefs.remove(_keyPragasHistory);
    } catch (e) {
      // Fail silently
    }
  }
}
