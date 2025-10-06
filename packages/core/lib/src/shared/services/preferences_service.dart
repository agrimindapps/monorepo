import 'dart:developer' as developer;

import 'package:hive/hive.dart';

/// Serviço simplificado de preferências usando Hive
/// Resolve TODOs de preferências do settings_page.dart
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  Box<dynamic>? _prefsBox;
  bool _isInitialized = false;
  static const String _boxName = 'receituagro_user_preferences';
  static const String _keyNotificationsPragas = 'notifications_pragas_detectadas';
  static const String _keyNotificationsLembretes = 'notifications_lembretes_aplicacao';

  /// Inicializa o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefsBox = await Hive.openBox<dynamic>(_boxName);
      _isInitialized = true;
      developer.log('PreferencesService inicializado com sucesso', name: 'PreferencesService');
    } catch (e) {
      developer.log('Erro ao inicializar PreferencesService: $e', name: 'PreferencesService');
      rethrow;
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized || _prefsBox == null) {
      throw StateError('PreferencesService não foi inicializado. Chame initialize() primeiro.');
    }
  }

  /// Notificações de pragas detectadas
  Future<bool> setPragasDetectadasEnabled(bool enabled) async {
    _ensureInitialized();
    try {
      await _prefsBox!.put(_keyNotificationsPragas, enabled);
      developer.log('Notificações de pragas: $enabled', name: 'PreferencesService');
      return true;
    } catch (e) {
      developer.log('Erro ao salvar preferência: $e', name: 'PreferencesService');
      return false;
    }
  }

  bool getPragasDetectadasEnabled() {
    _ensureInitialized();
    return _prefsBox!.get(_keyNotificationsPragas, defaultValue: true) as bool;
  }

  /// Lembretes de aplicação
  Future<bool> setLembretesAplicacaoEnabled(bool enabled) async {
    _ensureInitialized();
    try {
      await _prefsBox!.put(_keyNotificationsLembretes, enabled);
      developer.log('Lembretes de aplicação: $enabled', name: 'PreferencesService');
      return true;
    } catch (e) {
      developer.log('Erro ao salvar preferência: $e', name: 'PreferencesService');
      return false;
    }
  }

  bool getLembretesAplicacaoEnabled() {
    _ensureInitialized();
    return _prefsBox!.get(_keyNotificationsLembretes, defaultValue: true) as bool;
  }

  /// Toggle genérico para notificações
  Future<bool> toggleNotification(String type, bool enabled) async {
    switch (type.toLowerCase()) {
      case 'pragas':
        return await setPragasDetectadasEnabled(enabled);
      case 'lembretes':
        return await setLembretesAplicacaoEnabled(enabled);
      default:
        developer.log('Tipo de notificação não suportado: $type', name: 'PreferencesService');
        return false;
    }
  }

  /// Get genérico para notificações
  bool getNotificationEnabled(String type) {
    switch (type.toLowerCase()) {
      case 'pragas':
        return getPragasDetectadasEnabled();
      case 'lembretes':
        return getLembretesAplicacaoEnabled();
      default:
        developer.log('Tipo de notificação não suportado: $type', name: 'PreferencesService');
        return false;
    }
  }

  /// Reset para padrões
  Future<bool> resetToDefaults() async {
    _ensureInitialized();
    try {
      await _prefsBox!.clear();
      developer.log('Preferências resetadas para padrões', name: 'PreferencesService');
      return true;
    } catch (e) {
      developer.log('Erro ao resetar preferências: $e', name: 'PreferencesService');
      return false;
    }
  }

  /// Estatísticas
  Map<String, dynamic> getStats() {
    _ensureInitialized();
    return {
      'isInitialized': _isInitialized,
      'totalKeys': _prefsBox!.keys.length,
      'pragasDetectadas': getPragasDetectadasEnabled(),
      'lembretesAplicacao': getLembretesAplicacaoEnabled(),
    };
  }
}