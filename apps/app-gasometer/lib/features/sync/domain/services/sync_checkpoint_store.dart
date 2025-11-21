import 'package:core/core.dart';

/// Persiste o cursor incremental de cada adapter de sync.
/// Mantém apenas a última timestamp remota processada por usuário+adapter,
/// permitindo que o pull solicite apenas alterações mais recentes.

class SyncCheckpointStore {
  SyncCheckpointStore();

  static const _prefix = 'sync_checkpoint';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<DateTime?> getCursor({
    required String userId,
    required String adapter,
  }) async {
    final prefs = await _instance();
    final raw = prefs.getString(_key(userId, adapter));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveCursor({
    required String userId,
    required String adapter,
    required DateTime timestamp,
  }) async {
    final prefs = await _instance();
    await prefs.setString(
      _key(userId, adapter),
      timestamp.toUtc().toIso8601String(),
    );
  }

  Future<void> clearUser(String userId) async {
    final prefs = await _instance();
    final userPrefix = '$_prefix.${userId.toLowerCase()}.';
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(userPrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> clearAll() async {
    final prefs = await _instance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('$_prefix.'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  String _key(String userId, String adapter) {
    final normalizedUser = userId.toLowerCase();
    final normalizedAdapter = adapter.toLowerCase();
    return '$_prefix.$normalizedUser.$normalizedAdapter';
  }
}
