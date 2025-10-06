import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface base para serviços de sincronização específicos
/// Cada app implementa seus próprios sync services seguindo esta interface
abstract class ISyncService {
  /// Identificador único do serviço (ex: 'vehicle', 'plant', 'task')
  String get serviceId;
  
  /// Nome legível do serviço para UI
  String get displayName;
  
  /// Versão da implementação do serviço
  String get version;
  
  /// Indica se o serviço pode executar sync no momento
  bool get canSync;
  
  /// Indica se há dados pendentes para sincronização
  Future<bool> get hasPendingSync;
  
  /// Executa sincronização completa do serviço
  Future<Either<Failure, ServiceSyncResult>> sync();

  /// Executa sincronização apenas de itens específicos
  Future<Either<Failure, ServiceSyncResult>> syncSpecific(List<String> ids);
  
  /// Para a sincronização em andamento
  Future<void> stopSync();
  
  /// Verifica status de conectividade necessário para sync
  Future<bool> checkConnectivity();
  
  /// Limpa dados locais do serviço
  Future<Either<Failure, void>> clearLocalData();
  
  /// Obtém estatísticas de sincronização
  Future<SyncStatistics> getStatistics();
  
  /// Stream de status do serviço
  Stream<SyncServiceStatus> get statusStream;
  
  /// Stream de progresso de sincronização
  Stream<ServiceProgress> get progressStream;
  
  /// Inicializa o serviço
  Future<Either<Failure, void>> initialize();
  
  /// Libera recursos do serviço
  Future<void> dispose();
}

/// Resultado de uma operação de sincronização de serviço
class ServiceSyncResult {
  final bool success;
  final int itemsSynced;
  final int itemsFailed;
  final Duration duration;
  final String? error;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  ServiceSyncResult({
    required this.success,
    this.itemsSynced = 0,
    this.itemsFailed = 0,
    required this.duration,
    this.error,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();
  
  factory ServiceSyncResult.success({
    required int itemsSynced,
    required Duration duration,
    Map<String, dynamic> metadata = const {},
  }) {
    return ServiceSyncResult(
      success: true,
      itemsSynced: itemsSynced,
      duration: duration,
      metadata: metadata,
    );
  }
  
  factory ServiceSyncResult.failure({
    required String error,
    required Duration duration,
    int itemsFailed = 0,
    Map<String, dynamic> metadata = const {},
  }) {
    return ServiceSyncResult(
      success: false,
      itemsFailed: itemsFailed,
      duration: duration,
      error: error,
      metadata: metadata,
    );
  }
  
  factory ServiceSyncResult.partial({
    required int itemsSynced,
    required int itemsFailed,
    required Duration duration,
    Map<String, dynamic> metadata = const {},
  }) {
    return ServiceSyncResult(
      success: itemsSynced > 0,
      itemsSynced: itemsSynced,
      itemsFailed: itemsFailed,
      duration: duration,
      metadata: metadata,
    );
  }
  
  int get totalItems => itemsSynced + itemsFailed;
  
  double get successRate => totalItems > 0 ? (itemsSynced / totalItems) * 100 : 0;
  
  @override
  String toString() => 'SyncResult(success: $success, synced: $itemsSynced, failed: $itemsFailed)';
}

/// Progresso específico de um serviço
class ServiceProgress {
  final String serviceId;
  final String operation;
  final int current;
  final int total;
  final String? currentItem;
  final DateTime timestamp;
  
  ServiceProgress({
    required this.serviceId,
    required this.operation,
    required this.current,
    required this.total,
    this.currentItem,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  double get percentage => total > 0 ? (current / total) * 100 : 0;
  
  bool get isCompleted => current >= total;
  
  @override
  String toString() => 'ServiceProgress($serviceId: $operation $current/$total)';
}

/// Estatísticas de sincronização de um serviço
class SyncStatistics {
  final String serviceId;
  final int totalSyncs;
  final int successfulSyncs;
  final int failedSyncs;
  final DateTime? lastSyncTime;
  final Duration? averageSyncDuration;
  final int totalItemsSynced;
  final int pendingItems;
  final Map<String, dynamic> metadata;
  
  const SyncStatistics({
    required this.serviceId,
    this.totalSyncs = 0,
    this.successfulSyncs = 0,
    this.failedSyncs = 0,
    this.lastSyncTime,
    this.averageSyncDuration,
    this.totalItemsSynced = 0,
    this.pendingItems = 0,
    this.metadata = const {},
  });
  
  double get successRate => totalSyncs > 0 ? (successfulSyncs / totalSyncs) * 100 : 0;
  
  bool get hasRecentSync => lastSyncTime != null && 
      DateTime.now().difference(lastSyncTime!).inHours < 24;
  
  @override
  String toString() => 'SyncStatistics($serviceId: $successfulSyncs/$totalSyncs successful)';
}

/// Status de um serviço de sincronização  
enum SyncServiceStatus {
  /// Serviço não inicializado
  uninitialized,
  /// Serviço pronto mas não sincronizando
  idle,
  /// Sincronização em andamento
  syncing,
  /// Sincronização pausada
  paused,
  /// Sincronização completada com sucesso
  completed,
  /// Sincronização falhou
  failed,
  /// Serviço está sendo limpo/disposed
  disposing,
}
