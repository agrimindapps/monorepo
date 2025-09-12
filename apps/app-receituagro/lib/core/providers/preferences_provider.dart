import 'package:flutter/foundation.dart';
import 'package:core/core.dart'; // PreferencesService moved to core

/// Provider para gerenciar estado das preferências de usuário
/// Integra com PreferencesService para resolver TODOs do settings_page.dart
class PreferencesProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();
  
  bool _pragasDetectadasEnabled = true;
  bool _lembretesAplicacaoEnabled = true;
  bool _isInitialized = false;

  // Getters
  bool get pragasDetectadasEnabled => _pragasDetectadasEnabled;
  bool get lembretesAplicacaoEnabled => _lembretesAplicacaoEnabled;
  bool get isInitialized => _isInitialized;

  /// Inicializa o provider e carrega preferências
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _preferencesService.initialize();
      await _loadPreferences();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Em caso de erro, usa valores padrão
      _pragasDetectadasEnabled = true;
      _lembretesAplicacaoEnabled = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Carrega preferências do storage
  Future<void> _loadPreferences() async {
    _pragasDetectadasEnabled = _preferencesService.getPragasDetectadasEnabled();
    _lembretesAplicacaoEnabled = _preferencesService.getLembretesAplicacaoEnabled();
  }

  /// Toggle notificações de pragas detectadas
  Future<void> togglePragasDetectadas(bool enabled) async {
    final success = await _preferencesService.setPragasDetectadasEnabled(enabled);
    if (success) {
      _pragasDetectadasEnabled = enabled;
      notifyListeners();
    }
  }

  /// Toggle lembretes de aplicação
  Future<void> toggleLembretesAplicacao(bool enabled) async {
    final success = await _preferencesService.setLembretesAplicacaoEnabled(enabled);
    if (success) {
      _lembretesAplicacaoEnabled = enabled;
      notifyListeners();
    }
  }

  /// Toggle genérico para qualquer tipo de notificação
  Future<void> toggleNotification(String type, bool enabled) async {
    switch (type.toLowerCase()) {
      case 'pragas':
        await togglePragasDetectadas(enabled);
        break;
      case 'lembretes':
        await toggleLembretesAplicacao(enabled);
        break;
      default:
        // Para tipos não implementados, ainda mostra feedback visual
        break;
    }
  }

  /// Obtém status de uma notificação específica
  bool getNotificationEnabled(String type) {
    switch (type.toLowerCase()) {
      case 'pragas':
        return _pragasDetectadasEnabled;
      case 'lembretes':
        return _lembretesAplicacaoEnabled;
      default:
        return false;
    }
  }

  /// Reset para configurações padrão
  Future<void> resetToDefaults() async {
    final success = await _preferencesService.resetToDefaults();
    if (success) {
      _pragasDetectadasEnabled = true;
      _lembretesAplicacaoEnabled = true;
      notifyListeners();
    }
  }

  /// Refresh das preferências (reload from storage)
  Future<void> refresh() async {
    await _loadPreferences();
    notifyListeners();
  }

  /// Estatísticas das preferências
  Map<String, dynamic> getStats() {
    return _preferencesService.getStats();
  }
}