import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import '../entities/base_sync_entity.dart';

/// Interface para repositórios de sincronização
/// Define contratos para operações offline-first com Firebase
abstract class ISyncRepository<T extends BaseSyncEntity> {
  /// Inicializa o repositório
  Future<Either<Failure, void>> initialize();

  /// Cria um novo item
  Future<Either<Failure, String>> create(T item);

  /// Cria múltiplos itens em lote
  Future<Either<Failure, List<String>>> createBatch(List<T> items);

  /// Atualiza um item existente
  Future<Either<Failure, void>> update(String id, T item);

  /// Atualiza múltiplos itens em lote
  Future<Either<Failure, void>> updateBatch(Map<String, T> items);

  /// Remove um item (soft delete)
  Future<Either<Failure, void>> delete(String id);

  /// Remove múltiplos itens em lote
  Future<Either<Failure, void>> deleteBatch(List<String> ids);

  /// Busca um item por ID
  Future<Either<Failure, T?>> findById(String id);

  /// Busca todos os itens
  Future<Either<Failure, List<T>>> findAll();

  /// Busca itens com filtros
  Future<Either<Failure, List<T>>> findWhere(Map<String, dynamic> filters);

  /// Busca itens recentes
  Future<Either<Failure, List<T>>> findRecent({
    Duration? since,
    int? limit,
  });

  /// Busca de texto completo local
  Future<Either<Failure, List<T>>> fullTextSearch(
    String query, {
    List<String>? searchFields,
  });

  /// Força sincronização manual
  Future<Either<Failure, void>> forceSync();

  /// Obtém itens não sincronizados
  Future<Either<Failure, List<T>>> getUnsyncedItems();

  /// Obtém itens em conflito
  Future<Either<Failure, List<T>>> getConflictedItems();

  /// Resolve conflito manualmente
  Future<Either<Failure, void>> resolveConflict(String id, T resolution);

  /// Limpa dados locais
  Future<Either<Failure, void>> clearLocalData();

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo();

  /// Stream de dados atualizado
  Stream<List<T>> get dataStream;

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream;

  /// Stream de conectividade
  Stream<bool> get connectivityStream;
}

/// Interface para gerenciamento de conectividade
abstract class IConnectivityRepository {
  /// Inicializa o monitoramento de conectividade
  Future<Either<Failure, void>> initialize();

  /// Verifica se está online
  Future<Either<Failure, bool>> isOnline();

  /// Stream de mudanças de conectividade
  Stream<bool> get connectivityStream;

  /// Força verificação de conectividade
  Future<Either<Failure, bool>> checkConnectivity();

  /// Obtém tipo de conexão atual
  Future<Either<Failure, ConnectivityType>> getConnectivityType();
}

/// Interface para operações Firebase específicas
abstract class IFirebaseRepository<T extends BaseSyncEntity> {
  /// Inicializa conexão com Firebase
  Future<Either<Failure, void>> initialize();

  /// Sincroniza dados locais com Firebase
  Future<Either<Failure, SyncResult<T>>> syncWithFirebase(T item);

  /// Sincronização em lote
  Future<Either<Failure, List<SyncResult<T>>>> batchSync(List<T> items);

  /// Puxa dados do Firebase
  Future<Either<Failure, List<T>>> pullFromFirebase({
    DateTime? since,
    int? limit,
  });

  /// Envia dados para Firebase
  Future<Either<Failure, void>> pushToFirebase(List<T> items);

  /// Configura listeners de tempo real
  Future<Either<Failure, void>> setupRealtimeListeners();

  /// Remove listeners de tempo real
  Future<Either<Failure, void>> removeRealtimeListeners();

  /// Obtém dados do usuário atual
  Future<Either<Failure, List<T>>> getUserData(String userId);

  /// Define regras de particionamento
  String getCollectionPath(String userId);

  /// Valida permissões
  Future<Either<Failure, bool>> hasPermission(String userId, String operation);
}

/// Status de sincronização
enum SyncStatus {
  /// Offline - sem conectividade
  offline,
  
  /// Apenas local - online mas não autenticado
  localOnly,
  
  /// Sincronizando - online e autenticado
  syncing,
  
  /// Sincronizado - tudo em ordem
  synced,
  
  /// Erro - problema na sincronização
  error,
  
  /// Conflito - dados conflitantes
  conflict,
}

/// Tipos de conectividade expandido para compatibilidade
enum ConnectivityType {
  none,
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
  offline, // = none
  online,  // = wifi/mobile/ethernet (usado genericamente)
}

/// Configuração de sincronização
class SyncConfig {
  const SyncConfig({
    this.syncInterval = const Duration(minutes: 5),
    this.batchSize = 50,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
    this.enableRealtimeSync = true,
    this.enableOfflineMode = true,
    this.conflictResolution = ConflictResolutionStrategy.timestamp,
  });

  /// Intervalo entre sincronizações automáticas
  final Duration syncInterval;

  /// Tamanho do lote para operações
  final int batchSize;

  /// Máximo de tentativas em caso de erro
  final int maxRetries;

  /// Delay entre tentativas
  final Duration retryDelay;

  /// Se deve sincronizar em tempo real
  final bool enableRealtimeSync;

  /// Se deve operar offline
  final bool enableOfflineMode;

  /// Estratégia de resolução de conflitos
  final ConflictResolutionStrategy conflictResolution;
}

/// Estratégias de resolução de conflitos
enum ConflictResolutionStrategy {
  /// Usar timestamp mais recente
  timestamp,
  
  /// Usar versão maior
  version,
  
  /// Priorizar versão local
  localWins,
  
  /// Priorizar versão remota
  remoteWins,
  
  /// Resolução manual
  manual,
}

/// Métricas de performance da sincronização
class SyncMetrics {
  const SyncMetrics({
    required this.collectionName,
    required this.localItemsCount,
    required this.lastSyncAt,
    required this.syncStatus,
    this.isOnline = false,
    this.canSync = false,
    this.pendingSyncCount = 0,
    this.errorCount = 0,
    this.conflictCount = 0,
  });

  final String collectionName;
  final int localItemsCount;
  final DateTime? lastSyncAt;
  final SyncStatus syncStatus;
  final bool isOnline;
  final bool canSync;
  final int pendingSyncCount;
  final int errorCount;
  final int conflictCount;

  Map<String, dynamic> toMap() {
    return {
      'collection_name': collectionName,
      'local_items_count': localItemsCount,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_status': syncStatus.name,
      'is_online': isOnline,
      'can_sync': canSync,
      'pending_sync_count': pendingSyncCount,
      'error_count': errorCount,
      'conflict_count': conflictCount,
      'last_report_time': DateTime.now().toIso8601String(),
    };
  }
}

/// Interface para estratégias de resolução de conflitos
abstract class IConflictResolver<T extends BaseSyncEntity> {
  /// Resolve conflito entre versões local e remota
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion);

  /// Verifica se pode resolver automaticamente
  bool canAutoResolve(T localVersion, T remoteVersion);

  /// Obtém estratégia de resolução
  ConflictResolutionStrategy get strategy;
}

/// Factory para criar repositórios de sincronização
abstract class ISyncRepositoryFactory {
  /// Cria repositório para um tipo específico
  ISyncRepository<T> create<T extends BaseSyncEntity>(
    String collectionName,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap, {
    SyncConfig? config,
  });

  /// Registra resolver de conflitos customizado
  void registerConflictResolver<T extends BaseSyncEntity>(
    IConflictResolver<T> resolver,
  );

  /// Obtém resolver de conflitos
  IConflictResolver<T>? getConflictResolver<T extends BaseSyncEntity>();
}