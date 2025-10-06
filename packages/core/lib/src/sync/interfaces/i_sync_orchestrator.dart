import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import 'i_sync_service.dart';

/// Interface para orquestração centralizada de sincronização
/// Substitui o UnifiedSyncManager monolítico seguindo Single Responsibility Principle
abstract class ISyncOrchestrator {
  /// Registra um serviço de sync para ser gerenciado pelo orchestrator
  Future<void> registerService(ISyncService service);
  
  /// Remove um serviço de sync do orchestrator
  Future<void> unregisterService(String serviceId);
  
  /// Executa sincronização de todos os serviços registrados
  Future<Either<Failure, void>> syncAll();
  
  /// Executa sincronização de um serviço específico
  Future<Either<Failure, void>> syncSpecific(String serviceId);
  
  /// Lista todos os serviços registrados
  List<String> get registeredServices;
  
  /// Verifica se um serviço está registrado
  bool isServiceRegistered(String serviceId);
  
  /// Stream de progresso de sincronização
  Stream<SyncProgress> get progressStream;
  
  /// Stream de eventos de sincronização
  Stream<SyncEvent> get eventStream;
  
  /// Obtém status atual de um serviço específico
  SyncServiceStatus getServiceStatus(String serviceId);
  
  /// Obtém status geral de sincronização
  GlobalSyncStatus get globalStatus;
  
  /// Limpa todos os dados dos serviços registrados
  Future<Either<Failure, void>> clearAllData();
  
  /// Força parada de todas as sincronizações em andamento
  Future<void> stopAllSync();
  
  /// Libera recursos do orchestrator
  Future<void> dispose();
}

/// Progresso de sincronização
class SyncProgress {
  final int current;
  final int total;
  final String serviceId;
  final String? operation;
  final DateTime timestamp;
  
  SyncProgress({
    required this.current,
    required this.total,
    required this.serviceId,
    this.operation,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  double get percentage => total > 0 ? (current / total) * 100 : 0;
  
  bool get isCompleted => current >= total;
  
  @override
  String toString() => 'SyncProgress($current/$total for $serviceId)';
}

/// Evento de sincronização
class SyncEvent {
  final String serviceId;
  final SyncEventType type;
  final String? message;
  final dynamic data;
  final DateTime timestamp;
  
  SyncEvent({
    required this.serviceId,
    required this.type,
    this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() => 'SyncEvent($type for $serviceId: $message)';
}

/// Tipos de eventos de sincronização
enum SyncEventType {
  started,
  progress,
  completed,
  failed,
  paused,
  resumed,
  cancelled,
}


/// Status global de sincronização
class GlobalSyncStatus {
  final Map<String, SyncServiceStatus> serviceStatuses;
  final bool isAnyServiceSyncing;
  final bool areAllServicesCompleted;
  final int totalServices;
  final int completedServices;
  final int failedServices;
  
  const GlobalSyncStatus({
    required this.serviceStatuses,
    required this.isAnyServiceSyncing,
    required this.areAllServicesCompleted,
    required this.totalServices,
    required this.completedServices,
    required this.failedServices,
  });
  
  factory GlobalSyncStatus.fromServices(Map<String, SyncServiceStatus> services) {
    final total = services.length;
    final completed = services.values.where((s) => s == SyncServiceStatus.completed).length;
    final failed = services.values.where((s) => s == SyncServiceStatus.failed).length;
    final syncing = services.values.where((s) => s == SyncServiceStatus.syncing).length;
    
    return GlobalSyncStatus(
      serviceStatuses: Map.unmodifiable(services),
      isAnyServiceSyncing: syncing > 0,
      areAllServicesCompleted: completed == total && total > 0,
      totalServices: total,
      completedServices: completed,
      failedServices: failed,
    );
  }
  
  @override
  String toString() => 'GlobalSyncStatus($completedServices/$totalServices completed, $failedServices failed)';
}
