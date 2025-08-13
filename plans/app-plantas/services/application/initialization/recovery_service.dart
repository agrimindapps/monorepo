// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../infrastructure/degraded_mode_service.dart';
import 'interfaces.dart';

/// Serviço dedicado ao recovery inteligente de serviços falhos
///
/// Responsabilidades:
/// - Auto-recovery em background
/// - Recovery inteligente baseado no tipo de falha
/// - Gerenciamento de serviços recuperáveis
/// - Notificação de eventos de recovery
class RecoveryService implements IRecoveryService {
  final DegradedModeService _degradedModeService;
  final Map<String, IRecoverableService> _recoverableServices = {};
  final StreamController<RecoveryEvent> _recoveryStreamController =
      StreamController<RecoveryEvent>.broadcast();

  Timer? _autoRecoveryTimer;
  bool _isAutoRecoveryActive = false;

  RecoveryService({
    required DegradedModeService degradedModeService,
  }) : _degradedModeService = degradedModeService;

  @override
  Stream<RecoveryEvent> get recoveryStream => _recoveryStreamController.stream;

  @override
  bool get isAutoRecoveryActive => _isAutoRecoveryActive;

  @override
  void registerRecoverableService(
      String serviceName, IRecoverableService service) {
    _recoverableServices[serviceName] = service;
    debugPrint(
        '🔧 [RecoveryService] Serviço recuperável registrado: $serviceName');
  }

  @override
  Future<void> performIntelligentRecovery(List<ServiceFailure> failures) async {
    if (failures.isEmpty) {
      debugPrint('📋 [RecoveryService] Nenhuma falha para recuperar');
      return;
    }

    debugPrint(
        '🔄 [RecoveryService] Iniciando recovery inteligente para ${failures.length} falhas');

    _emitRecoveryEvent(RecoveryEventType.started, 'IntelligentRecovery',
        'Iniciando recovery para ${failures.length} serviços');

    int successCount = 0;
    int failureCount = 0;

    for (final failure in failures) {
      final success = await _attemptServiceRecovery(failure);
      if (success) {
        successCount++;
      } else {
        failureCount++;
      }
    }

    final message =
        'Recovery concluído: $successCount sucessos, $failureCount falhas';
    debugPrint('📊 [RecoveryService] $message');

    _emitRecoveryEvent(
        RecoveryEventType.completed, 'IntelligentRecovery', message);
  }

  Future<bool> _attemptServiceRecovery(ServiceFailure failure) async {
    final serviceName = _getServiceNameForFailure(failure);
    final service = _recoverableServices[serviceName];

    if (service == null) {
      debugPrint(
          '⚠️ [RecoveryService] Serviço $serviceName não registrado para recovery');
      _emitRecoveryEvent(RecoveryEventType.failure, serviceName,
          'Serviço não registrado para recovery');
      return false;
    }

    if (!service.canRecover) {
      debugPrint(
          '⚠️ [RecoveryService] Serviço $serviceName não pode ser recuperado');
      _emitRecoveryEvent(RecoveryEventType.failure, serviceName,
          'Máximo de tentativas de recovery atingido');
      return false;
    }

    debugPrint('🔄 [RecoveryService] Tentando recuperar: $serviceName');
    _emitRecoveryEvent(RecoveryEventType.started, serviceName,
        'Iniciando tentativa de recovery');

    try {
      final success = await service.recover();

      if (success) {
        debugPrint('✅ [RecoveryService] $serviceName recuperado com sucesso');
        _emitRecoveryEvent(RecoveryEventType.success, serviceName,
            'Serviço recuperado com sucesso');
        return true;
      } else {
        debugPrint('❌ [RecoveryService] Falha na recuperação de $serviceName');
        _emitRecoveryEvent(RecoveryEventType.failure, serviceName,
            'Falha na tentativa de recovery');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [RecoveryService] Erro no recovery de $serviceName: $e');
      _emitRecoveryEvent(
          RecoveryEventType.failure, serviceName, 'Erro durante recovery: $e');
      return false;
    }
  }

  String _getServiceNameForFailure(ServiceFailure failure) {
    switch (failure.type) {
      case ServiceType.storage:
        return 'CoreServicesInitializer';
      case ServiceType.license:
        return 'CoreServicesInitializer';
      case ServiceType.binding:
        return 'ControllersInitializer';
      case ServiceType.theme:
        return 'ControllersInitializer';
      case ServiceType.auth:
        return 'ControllersInitializer';
    }
  }

  @override
  void startAutoRecovery() {
    if (_isAutoRecoveryActive) {
      debugPrint('⚠️ [RecoveryService] Auto-recovery já está ativo');
      return;
    }

    _autoRecoveryTimer = Timer.periodic(
      const Duration(minutes: 2), // Verificar a cada 2 minutos
      (timer) => _performAutoRecoveryCheck(),
    );

    _isAutoRecoveryActive = true;
    debugPrint(
        '🔄 [RecoveryService] Auto-recovery iniciado (verificação a cada 2 minutos)');

    _emitRecoveryEvent(
        RecoveryEventType.started, 'AutoRecovery', 'Auto-recovery iniciado');
  }

  @override
  void stopAutoRecovery() {
    _autoRecoveryTimer?.cancel();
    _autoRecoveryTimer = null;
    _isAutoRecoveryActive = false;

    debugPrint('⏹️ [RecoveryService] Auto-recovery parado');
    _emitRecoveryEvent(
        RecoveryEventType.completed, 'AutoRecovery', 'Auto-recovery parado');
  }

  Future<void> _performAutoRecoveryCheck() async {
    if (!_degradedModeService.isDegraded) {
      // Se não há mais degradação, parar auto-recovery
      stopAutoRecovery();
      return;
    }

    debugPrint(
        '🔄 [RecoveryService] Executando verificação de auto-recovery...');

    final failures = _degradedModeService.failedServices;
    if (failures.isEmpty) {
      stopAutoRecovery();
      return;
    }

    // Executar recovery apenas para serviços que podem ser recuperados
    final recoverableFailures = failures.where((failure) {
      final serviceName = _getServiceNameForFailure(failure);
      final service = _recoverableServices[serviceName];
      return service?.canRecover ?? false;
    }).toList();

    if (recoverableFailures.isEmpty) {
      debugPrint(
          '📋 [RecoveryService] Nenhum serviço pode ser recuperado no momento');
      return;
    }

    await performIntelligentRecovery(recoverableFailures);
  }

  void _emitRecoveryEvent(
      RecoveryEventType type, String serviceName, String? message) {
    final event = RecoveryEvent(
      type: type,
      serviceName: serviceName,
      message: message,
    );

    _recoveryStreamController.add(event);
  }

  /// Obtém estatísticas do serviço de recovery
  Map<String, dynamic> getStats() {
    final serviceStats = <String, Map<String, dynamic>>{};

    for (final entry in _recoverableServices.entries) {
      serviceStats[entry.key] = {
        'can_recover': entry.value.canRecover,
        'recovery_attempts': entry.value.recoveryAttempts,
      };
    }

    return {
      'auto_recovery_active': _isAutoRecoveryActive,
      'registered_services_count': _recoverableServices.length,
      'registered_services': _recoverableServices.keys.toList(),
      'degraded_mode_active': _degradedModeService.isDegraded,
      'failed_services_count': _degradedModeService.failedServices.length,
      'service_stats': serviceStats,
    };
  }

  /// Força recovery de um serviço específico
  Future<bool> forceRecoveryForService(String serviceName) async {
    final service = _recoverableServices[serviceName];

    if (service == null) {
      debugPrint('❌ [RecoveryService] Serviço $serviceName não encontrado');
      return false;
    }

    debugPrint('🔄 [RecoveryService] Forçando recovery de $serviceName');

    try {
      final success = await service.recover();

      if (success) {
        _emitRecoveryEvent(RecoveryEventType.success, serviceName,
            'Recovery forçado bem-sucedido');
      } else {
        _emitRecoveryEvent(
            RecoveryEventType.failure, serviceName, 'Recovery forçado falhou');
      }

      return success;
    } catch (e) {
      _emitRecoveryEvent(RecoveryEventType.failure, serviceName,
          'Erro no recovery forçado: $e');
      return false;
    }
  }

  /// Reseta contadores de retry para todos os serviços
  void resetAllRetryCounters() {
    for (final service in _recoverableServices.values) {
      service.resetRecoveryAttempts();
    }

    debugPrint(
        '🔄 [RecoveryService] Contadores de retry resetados para todos os serviços');
  }

  /// Libera recursos do serviço
  Future<void> dispose() async {
    stopAutoRecovery();
    await _recoveryStreamController.close();
    _recoverableServices.clear();

    debugPrint('🔄 [RecoveryService] Recursos liberados');
  }
}
