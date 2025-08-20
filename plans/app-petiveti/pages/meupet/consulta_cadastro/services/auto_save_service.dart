// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../models/consulta_form_model.dart';

class AutoSaveService {
  static const String _keyPrefix = 'consulta_autosave_';
  static const Duration _autoSaveInterval = Duration(seconds: 30);

  Timer? _autoSaveTimer;
  SharedPreferences? _prefs;
  String? _currentKey;

  static AutoSaveService? _instance;
  static AutoSaveService get instance => _instance ??= AutoSaveService._();

  AutoSaveService._();

  /// Initialize the auto-save service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Start auto-save for a specific form session
  void startAutoSave(
      String sessionKey, ConsultaFormModel Function() getFormData) {
    _currentKey = _keyPrefix + sessionKey;

    // Cancel existing timer if any
    _autoSaveTimer?.cancel();

    // Start new auto-save timer
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (timer) async {
      try {
        final formData = getFormData();
        await _saveFormData(formData);
      } catch (e) {
        // Silent fail for auto-save
      }
    });
  }

  /// Stop auto-save and optionally clear saved data
  void stopAutoSave({bool clearSavedData = false}) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;

    if (clearSavedData && _currentKey != null) {
      _prefs?.remove(_currentKey!);
    }

    _currentKey = null;
  }

  /// Manually save form data
  Future<bool> saveFormData(
      String sessionKey, ConsultaFormModel formData) async {
    try {
      _currentKey = _keyPrefix + sessionKey;
      await _saveFormData(formData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Internal method to save form data
  Future<void> _saveFormData(ConsultaFormModel formData) async {
    if (_prefs == null || _currentKey == null) return;

    final dataMap = {
      'animalId': formData.animalId,
      'dataConsulta': formData.dataConsulta,
      'veterinario': formData.veterinario,
      'motivo': formData.motivo,
      'diagnostico': formData.diagnostico,
      'valor': formData.valor,
      'observacoes': formData.observacoes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final jsonString = jsonEncode(dataMap);
    await _prefs!.setString(_currentKey!, jsonString);
  }

  /// Restore saved form data
  Future<ConsultaFormModel?> restoreFormData(String sessionKey) async {
    try {
      if (_prefs == null) await initialize();

      final key = _keyPrefix + sessionKey;
      final jsonString = _prefs!.getString(key);

      if (jsonString == null) return null;

      final dataMap = jsonDecode(jsonString) as Map<String, dynamic>;

      // Check if data is not too old (max 24 hours)
      final savedTimestamp = dataMap['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursDiff = (now - savedTimestamp) / (1000 * 60 * 60);

      if (hoursDiff > 24) {
        // Data too old, remove it
        await _prefs!.remove(key);
        return null;
      }

      return ConsultaFormModel(
        animalId: dataMap['animalId'] ?? '',
        dataConsulta:
            dataMap['dataConsulta'] ?? DateTime.now().millisecondsSinceEpoch,
        veterinario: dataMap['veterinario'] ?? '',
        motivo: dataMap['motivo'] ?? '',
        diagnostico: dataMap['diagnostico'] ?? '',
        valor: (dataMap['valor'] ?? 0.0).toDouble(),
        observacoes: dataMap['observacoes'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if there's saved data for a session
  Future<bool> hasSavedData(String sessionKey) async {
    try {
      if (_prefs == null) await initialize();

      final key = _keyPrefix + sessionKey;
      return _prefs!.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Get timestamp of last save
  Future<DateTime?> getLastSaveTime(String sessionKey) async {
    try {
      if (_prefs == null) await initialize();

      final key = _keyPrefix + sessionKey;
      final jsonString = _prefs!.getString(key);

      if (jsonString == null) return null;

      final dataMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final timestamp = dataMap['timestamp'] as int;

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Clear specific saved data
  Future<void> clearSavedData(String sessionKey) async {
    try {
      if (_prefs == null) await initialize();

      final key = _keyPrefix + sessionKey;
      await _prefs!.remove(key);
    } catch (e) {
      // Silent fail
    }
  }

  /// Clear all auto-saved data
  Future<void> clearAllSavedData() async {
    try {
      if (_prefs == null) await initialize();

      final keys = _prefs!.getKeys();
      final autoSaveKeys = keys.where((key) => key.startsWith(_keyPrefix));

      for (final key in autoSaveKeys) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Get all saved sessions
  Future<List<String>> getSavedSessions() async {
    try {
      if (_prefs == null) await initialize();

      final keys = _prefs!.getKeys();
      final autoSaveKeys = keys.where((key) => key.startsWith(_keyPrefix));

      return autoSaveKeys
          .map((key) => key.substring(_keyPrefix.length))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a unique session key for form
  static String generateSessionKey({String? animalId, String? consultaId}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = consultaId ?? animalId ?? 'new';
    return '${suffix}_$timestamp';
  }

  /// Configure auto-save interval (for testing or user preferences)
  static Duration get autoSaveInterval => _autoSaveInterval;

  /// Dispose resources
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _currentKey = null;
  }
}
