// Flutter imports:
import 'package:flutter/foundation.dart';

/// Tipos de degradação possíveis
enum DegradationLevel {
  none, // Funcionamento normal
  minimal, // Funcionalidades básicas apenas
  offline, // Modo offline completo
  critical, // Apenas funcionalidades essenciais
}

/// Serviços que podem estar indisponíveis
enum ServiceType {
  storage, // PlantasHiveService
  auth, // PlantasAuthController
  license, // LocalLicenseService
  theme, // ThemeManager
  binding, // NovaTarefasBinding
}

/// Informações sobre falha de serviço
class ServiceFailure {
  final ServiceType type;
  final String error;
  final DateTime timestamp;
  final int retryCount;

  const ServiceFailure({
    required this.type,
    required this.error,
    required this.timestamp,
    this.retryCount = 0,
  });

  ServiceFailure copyWith({int? retryCount}) {
    return ServiceFailure(
      type: type,
      error: error,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Serviço para gerenciar modo degradado da aplicação
///
/// Controla que funcionalidades estão disponíveis quando serviços falham
/// e fornece fallbacks apropriados para manter o app funcionando
class DegradedModeService {
  static final DegradedModeService _instance = DegradedModeService._internal();
  factory DegradedModeService() => _instance;
  DegradedModeService._internal();

  final Map<ServiceType, ServiceFailure> _failedServices = {};
  DegradationLevel _currentLevel = DegradationLevel.none;

  /// Nível atual de degradação
  DegradationLevel get currentLevel => _currentLevel;

  /// Verifica se está em modo degradado
  bool get isDegraded => _currentLevel != DegradationLevel.none;

  /// Lista de serviços que falharam
  List<ServiceFailure> get failedServices => _failedServices.values.toList();

  /// Registra falha de um serviço
  void registerServiceFailure(ServiceType serviceType, String error) {
    final failure = ServiceFailure(
      type: serviceType,
      error: error,
      timestamp: DateTime.now(),
    );

    _failedServices[serviceType] = failure;
    _updateDegradationLevel();

    debugPrint('⚠️ Serviço falhou: ${serviceType.name} - $error');
  }

  /// Remove falha de serviço (quando recovery funciona)
  void clearServiceFailure(ServiceType serviceType) {
    _failedServices.remove(serviceType);
    _updateDegradationLevel();

    debugPrint('✅ Serviço recuperado: ${serviceType.name}');
  }

  /// Incrementa contador de retry para um serviço
  void incrementRetryCount(ServiceType serviceType) {
    final failure = _failedServices[serviceType];
    if (failure != null) {
      _failedServices[serviceType] =
          failure.copyWith(retryCount: failure.retryCount + 1);
    }
  }

  /// Verifica se um serviço específico está disponível
  bool isServiceAvailable(ServiceType serviceType) {
    return !_failedServices.containsKey(serviceType);
  }

  /// Verifica se funcionalidade está disponível no modo atual
  bool isFeatureAvailable(String featureName) {
    switch (_currentLevel) {
      case DegradationLevel.none:
        return true;

      case DegradationLevel.minimal:
        return _minimalFeatures.contains(featureName);

      case DegradationLevel.offline:
        return _offlineFeatures.contains(featureName);

      case DegradationLevel.critical:
        return _criticalFeatures.contains(featureName);
    }
  }

  /// Obtém mensagem explicativa do modo atual
  String getCurrentModeMessage() {
    switch (_currentLevel) {
      case DegradationLevel.none:
        return 'Sistema funcionando normalmente';

      case DegradationLevel.minimal:
        return 'Modo limitado: algumas funcionalidades não estão disponíveis';

      case DegradationLevel.offline:
        return 'Modo offline: funcionalidades que requerem conexão estão desabilitadas';

      case DegradationLevel.critical:
        return 'Modo crítico: apenas funcionalidades essenciais estão disponíveis';
    }
  }

  /// Obtém lista de limitações atuais
  List<String> getCurrentLimitations() {
    final limitations = <String>[];

    if (_failedServices.containsKey(ServiceType.storage)) {
      limitations.add('Dados não serão salvos permanentemente');
    }

    if (_failedServices.containsKey(ServiceType.auth)) {
      limitations.add('Login e autenticação indisponíveis');
    }

    if (_failedServices.containsKey(ServiceType.license)) {
      limitations.add('Verificação de licença desabilitada');
    }

    if (_failedServices.containsKey(ServiceType.theme)) {
      limitations.add('Personalização de tema limitada');
    }

    return limitations;
  }

  /// Obtém estatísticas do modo degradado
  Map<String, dynamic> getStats() {
    return {
      'degradation_level': _currentLevel.name,
      'failed_services_count': _failedServices.length,
      'failed_services': _failedServices.keys.map((e) => e.name).toList(),
      'is_degraded': isDegraded,
      'limitations_count': getCurrentLimitations().length,
      'uptime_degraded': isDegraded ? DateTime.now().millisecondsSinceEpoch : 0,
    };
  }

  /// Reset completo do serviço
  void reset() {
    _failedServices.clear();
    _currentLevel = DegradationLevel.none;
    debugPrint('🔄 DegradedModeService resetado');
  }

  void _updateDegradationLevel() {
    if (_failedServices.isEmpty) {
      _currentLevel = DegradationLevel.none;
      return;
    }

    // Critical: storage ou auth falhou
    if (_failedServices.containsKey(ServiceType.storage) ||
        _failedServices.containsKey(ServiceType.auth)) {
      _currentLevel = DegradationLevel.critical;
      return;
    }

    // Offline: múltiplos serviços falharam
    if (_failedServices.length >= 2) {
      _currentLevel = DegradationLevel.offline;
      return;
    }

    // Minimal: apenas um serviço não crítico falhou
    _currentLevel = DegradationLevel.minimal;
  }

  // Funcionalidades disponíveis em cada modo
  static const _minimalFeatures = [
    'view_plants',
    'basic_navigation',
    'settings',
    'help',
  ];

  static const _offlineFeatures = [
    'view_plants',
    'basic_navigation',
  ];

  static const _criticalFeatures = [
    'basic_navigation',
    'error_reporting',
  ];
}
