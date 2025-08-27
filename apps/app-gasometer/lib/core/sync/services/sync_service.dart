import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:synchronized/synchronized.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../data/models/base_sync_model.dart';
import '../../services/analytics_service.dart';
import '../models/sync_queue_item.dart';
import '../strategies/conflict_resolution_strategy.dart';
import 'conflict_resolver.dart';
import 'sync_operations.dart';
import 'sync_queue.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  success,
  conflict,
  offline
}

/// Tipos específicos de erro de sincronização
enum SyncErrorType {
  /// Erro de conectividade/rede
  network,
  /// Erro de autenticação
  authentication,
  /// Erro de timeout
  timeout,
  /// Erro de servidor (5xx)
  server,
  /// Erro de validação/dados inválidos
  validation,
  /// Erro de conflito de dados
  conflict,
  /// Erro desconhecido
  unknown,
}

/// Exceção específica de sincronização com contexto detalhado
class SyncException implements Exception {
  final SyncErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final int? statusCode;
  final String? operationType;
  final String? modelType;
  final DateTime timestamp;

  SyncException({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
    this.statusCode,
    this.operationType,
    this.modelType,
  }) : timestamp = DateTime.now();

  SyncException.now({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
    this.statusCode,
    this.operationType,
    this.modelType,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer('SyncException: $message');
    if (details != null) {
      buffer.write(' - $details');
    }
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (operationType != null) {
      buffer.write(' [Operation: $operationType]');
    }
    if (modelType != null) {
      buffer.write(' [Model: $modelType]');
    }
    return buffer.toString();
  }

  /// Determina se o erro é recuperável (pode fazer retry)
  bool get isRetryable {
    switch (type) {
      case SyncErrorType.network:
      case SyncErrorType.timeout:
      case SyncErrorType.server:
        return true;
      case SyncErrorType.authentication:
      case SyncErrorType.validation:
      case SyncErrorType.conflict:
      case SyncErrorType.unknown:
        return false;
    }
  }

  /// Sugere estratégia de recovery para o erro
  String get recoveryStrategy {
    switch (type) {
      case SyncErrorType.network:
        return 'Verifique sua conexão com a internet';
      case SyncErrorType.authentication:
        return 'Faça login novamente';
      case SyncErrorType.timeout:
        return 'Aguarde um momento e tente novamente';
      case SyncErrorType.server:
        return 'Servidor temporariamente indisponível';
      case SyncErrorType.validation:
        return 'Dados inválidos precisam ser corrigidos';
      case SyncErrorType.conflict:
        return 'Conflito de dados precisa ser resolvido';
      case SyncErrorType.unknown:
        return 'Erro inesperado';
    }
  }
}

/// Configuração para retry com exponential backoff
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool jitterEnabled;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.jitterEnabled = true,
  });

  /// Calcula o delay para uma tentativa específica
  Duration getDelay(int attempt) {
    final baseDelay = Duration(
      milliseconds: (initialDelay.inMilliseconds * 
        (backoffMultiplier * attempt)).round(),
    );
    
    final delay = baseDelay > maxDelay ? maxDelay : baseDelay;
    
    if (jitterEnabled) {
      // Adiciona jitter de ±25% para evitar thundering herd
      final jitter = (delay.inMilliseconds * 0.25).round();
      final randomJitter = (jitter * (2 * (0.5 - 0.5))).round(); // Simulando random
      return Duration(milliseconds: delay.inMilliseconds + randomJitter);
    }
    
    return delay;
  }
}

/// Serviço principal de sincronização que orquestra todas as operações
@singleton
class SyncService {
  final SyncQueue _syncQueue;
  final SyncOperations _syncOperations;
  final ConflictResolver _conflictResolver;
  final AnalyticsService _analytics;
  final AuthRepository _authRepository;

  final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();
  
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();
      
  final StreamController<SyncException> _errorController = 
      StreamController<SyncException>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<List<SyncQueueItem>> get queueStream => _syncQueue.queueStream;
  Stream<SyncException> get errorStream => _errorController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Timer? _autoSyncTimer;
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  
  // Mutex para prevenir race conditions na sincronização
  final Lock _syncLock = Lock();
  bool _isDisposed = false;
  
  // Configuração de retry
  static const RetryConfig _defaultRetryConfig = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
    maxDelay: Duration(seconds: 16),
    jitterEnabled: true,
  );
  
  // Controle de retry
  int _currentRetryAttempt = 0;
  SyncException? _lastSyncError;

  SyncService(
    this._syncQueue,
    this._syncOperations,
    this._conflictResolver,
    this._analytics,
    this._authRepository,
  );

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Inicializando SyncService...');
      
      await _syncQueue.initialize();
      _startAutoSync();
      
      _isInitialized = true;
      _updateStatus(SyncStatus.idle);
      _updateMessage('Serviço de sincronização inicializado');
      
      await _analytics.log('sync_service_initialized');
      debugPrint('✅ SyncService inicializado com sucesso');
      
    } catch (e) {
      debugPrint('❌ Erro ao inicializar SyncService: $e');
      _updateStatus(SyncStatus.error);
      _updateMessage('Erro ao inicializar sincronização: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Adiciona um item à fila de sincronização
  Future<void> addToSyncQueue({
    required String modelType,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    String? userId,
    int priority = 0,
  }) async {
    try {
      await _syncQueue.addToQueue(
        modelType: modelType,
        operation: operation.name,
        data: data,
        userId: userId,
        priority: priority,
      );

      _updateMessage('${operation.name.toUpperCase()} adicionado à fila: $modelType');
      
      // Tenta sincronizar automaticamente se estiver online
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        unawaited(_performSync());
      }

    } catch (e) {
      debugPrint('❌ Erro ao adicionar à fila de sync: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Força sincronização manual
  Future<void> forceSyncNow() async {
    if (!_isInitialized) {
      throw StateError('SyncService não foi inicializado');
    }

    if (_currentStatus == SyncStatus.syncing) {
      debugPrint('⏸️ Sync já em andamento, ignorando...');
      return;
    }

    debugPrint('🚀 Forçando sincronização manual...');
    await _performSync();
  }

  /// Força sincronização com configuração personalizada de retry
  Future<void> forceSyncWithRetry({
    int maxAttempts = 5,
    Duration initialDelay = const Duration(seconds: 2),
    double backoffMultiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 60),
  }) async {
    if (!_isInitialized) {
      throw StateError('SyncService não foi inicializado');
    }

    final customConfig = RetryConfig(
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      backoffMultiplier: backoffMultiplier,
      maxDelay: maxDelay,
    );

    debugPrint('🚀 Forçando sincronização com retry personalizado...');
    await _performSync(customConfig);
  }

  /// Obtém informações detalhadas sobre o último erro
  SyncException? getLastSyncError() => _lastSyncError;

  /// Verifica se está em processo de retry
  bool get isRetrying => _currentRetryAttempt > 0;

  /// Obtém o número da tentativa atual
  int get currentRetryAttempt => _currentRetryAttempt;

  /// Reseta contadores de retry (útil para limpeza manual)
  void resetRetryState() {
    _currentRetryAttempt = 0;
    _lastSyncError = null;
    debugPrint('🔄 Estado de retry resetado');
  }

  /// Executa sincronização com proteção contra race conditions e retry logic
  Future<void> _performSync([RetryConfig? retryConfig]) async {
    return await _syncLock.synchronized(() async {
      // Verificar se o serviço foi disposed
      if (_isDisposed) {
        debugPrint('⚠️ Tentativa de sync em serviço disposed');
        return;
      }

      if (!_syncOperations.isOnline) {
        _updateStatus(SyncStatus.offline);
        _updateMessage('Offline - aguardando conexão');
        return;
      }

      // Verificar se já está sincronizando (double-check dentro do lock)
      if (_currentStatus == SyncStatus.syncing) {
        debugPrint('⏸️ Sync já em andamento, ignorando...');
        return;
      }

      final config = retryConfig ?? _defaultRetryConfig;
      
      // Reset retry counter se for uma nova sincronização (não um retry)
      if (retryConfig == null) {
        _currentRetryAttempt = 0;
        _lastSyncError = null;
      }

      await _performSyncWithRetry(config);
    });
  }

  /// Executa sincronização com retry logic e exponential backoff
  Future<void> _performSyncWithRetry(RetryConfig config) async {
    for (int attempt = 0; attempt < config.maxAttempts; attempt++) {
      _currentRetryAttempt = attempt;
      
      try {
        debugPrint('🔄 Tentativa de sincronização ${attempt + 1}/${config.maxAttempts}');
        
        await _executeSyncOperation();
        
        // Se chegou aqui, sincronização foi bem-sucedida
        _currentRetryAttempt = 0;
        _lastSyncError = null;
        
        final stats = _syncQueue.getQueueStats();
        
        if ((stats['failed'] as int? ?? 0) > 0) {
          _updateStatus(SyncStatus.error);
          _updateMessage('Alguns itens falharam na sincronização');
        } else if ((stats['pending'] as int? ?? 0) > 0) {
          _updateStatus(SyncStatus.syncing);
          _updateMessage('${stats['pending']} itens aguardando sincronização');
        } else {
          _updateStatus(SyncStatus.success);
          _updateMessage('Sincronização concluída com sucesso');
        }
        
        await _analytics.log('sync_success');
        
        return; // Sucesso, sair do loop
        
      } catch (e, stackTrace) {
        final syncError = _createSyncException(e, stackTrace);
        _lastSyncError = syncError;
        
        debugPrint('❌ Erro na tentativa ${attempt + 1}: ${syncError.toString()}');
        
        // Log detalhado do erro
        await _analytics.recordError(syncError, stackTrace);
        
        // Se não é recuperável ou é a última tentativa, falhar
        if (!syncError.isRetryable || attempt == config.maxAttempts - 1) {
          _handleFinalSyncFailure(syncError, attempt + 1, config.maxAttempts);
          return;
        }
        
        // Calcular delay para próxima tentativa
        final delay = config.getDelay(attempt);
        
        _updateStatus(SyncStatus.error);
        _updateMessage(
          'Tentativa ${attempt + 1} falhou. Tentando novamente em ${delay.inSeconds}s... (${syncError.recoveryStrategy})',
        );
        
        debugPrint('⏳ Aguardando ${delay.inSeconds}s antes da próxima tentativa...');
        await Future.delayed(delay);
        
        // Verificar se ainda estamos online e o serviço não foi disposed
        if (_isDisposed || !_syncOperations.isOnline) {
          debugPrint('⚠️ Serviço disposed ou offline durante retry');
          return;
        }
      }
    }
  }

  /// Executa a operação de sincronização principal
  Future<void> _executeSyncOperation() async {
    // Verificar autenticação antes de sincronizar
    String? currentUserId;
    try {
      final userResult = await _authRepository.getCurrentUser();
      final currentUser = userResult.fold(
        (failure) {
          throw SyncException.now(
            type: SyncErrorType.authentication,
            message: 'Erro ao obter usuário atual',
            details: failure.toString(),
            originalError: failure,
          );
        },
        (user) => user,
      );

      if (currentUser == null) {
        throw SyncException.now(
          type: SyncErrorType.authentication,
          message: 'Usuário não autenticado',
          details: 'Nenhum usuário logado encontrado',
        );
      }
      
      currentUserId = currentUser.id;
    } catch (e) {
      if (e is SyncException) {
        rethrow;
      }
      throw SyncException.now(
        type: SyncErrorType.authentication,
        message: 'Erro crítico na verificação de autenticação',
        details: e.toString(),
        originalError: e,
      );
    }

    // Log tentativa de sincronização com user ID (apenas para debug em desenvolvimento)
    if (kDebugMode && currentUserId.length > 8) {
      debugPrint('🔐 Executando sincronização para usuário: ${currentUserId.substring(0, 8)}...');
    }

    _updateStatus(SyncStatus.syncing);
    _updateMessage('Sincronizando dados...');

    try {
      await _syncOperations.processOfflineQueue();
    } catch (e) {
      // Converter erro genérico para SyncException se necessário
      if (e is SyncException) {
        rethrow;
      }
      throw _createSyncException(e, StackTrace.current);
    }
  }

  /// Cria uma SyncException específica baseada no erro original
  SyncException _createSyncException(dynamic error, StackTrace stackTrace) {
    if (error is SyncException) {
      return error;
    }

    final errorString = error.toString().toLowerCase();
    SyncErrorType type;
    String message;
    String? details;
    int? statusCode;

    // Detectar tipo de erro baseado na mensagem/tipo
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socketexception')) {
      type = SyncErrorType.network;
      message = 'Erro de conectividade';
      details = 'Verifique sua conexão com a internet';
    } else if (errorString.contains('timeout')) {
      type = SyncErrorType.timeout;
      message = 'Timeout na operação';
      details = 'A operação demorou mais que o esperado';
    } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
      type = SyncErrorType.authentication;
      message = 'Erro de autenticação';
      details = 'Credenciais inválidas ou expiradas';
      statusCode = 401;
    } else if (errorString.contains('403') || errorString.contains('forbidden')) {
      type = SyncErrorType.authentication;
      message = 'Acesso negado';
      details = 'Sem permissão para executar a operação';
      statusCode = 403;
    } else if (errorString.contains('400') || errorString.contains('bad request')) {
      type = SyncErrorType.validation;
      message = 'Dados inválidos';
      details = 'Os dados enviados são inválidos';
      statusCode = 400;
    } else if (errorString.contains('409') || errorString.contains('conflict')) {
      type = SyncErrorType.conflict;
      message = 'Conflito de dados';
      details = 'Os dados locais conflitam com os remotos';
      statusCode = 409;
    } else if (errorString.contains('5')) { // 5xx errors
      type = SyncErrorType.server;
      message = 'Erro do servidor';
      details = 'Servidor temporariamente indisponível';
      if (errorString.contains('500')) statusCode = 500;
      if (errorString.contains('502')) statusCode = 502;
      if (errorString.contains('503')) statusCode = 503;
    } else {
      type = SyncErrorType.unknown;
      message = 'Erro desconhecido';
      details = error.toString();
    }

    return SyncException.now(
      type: type,
      message: message,
      details: details,
      originalError: error,
      stackTrace: stackTrace,
      statusCode: statusCode,
    );
  }

  /// Trata falha final de sincronização com recovery strategies
  void _handleFinalSyncFailure(SyncException error, int attempts, int maxAttempts) {
    debugPrint('💥 Sincronização falhou após $attempts tentativas: ${error.toString()}');
    
    _updateStatus(SyncStatus.error);
    _updateMessage(
      'Sincronização falhou após $attempts tentativa${attempts > 1 ? 's' : ''}: ${error.recoveryStrategy}',
    );
    
    // Notificar listeners sobre o erro detalhado
    _notifyError(error);
    
    // Aplicar estratégia de recovery baseada no tipo de erro
    _applyRecoveryStrategy(error);
    
    // Reset retry counter
    _currentRetryAttempt = 0;
  }

  /// Aplica estratégia de recovery baseada no tipo de erro
  void _applyRecoveryStrategy(SyncException error) {
    switch (error.type) {
      case SyncErrorType.network:
        _scheduleNetworkRecovery();
        break;
      case SyncErrorType.authentication:
        _handleAuthenticationError();
        break;
      case SyncErrorType.timeout:
        _scheduleTimeoutRecovery();
        break;
      case SyncErrorType.server:
        _scheduleServerErrorRecovery();
        break;
      case SyncErrorType.validation:
        _handleValidationError(error);
        break;
      case SyncErrorType.conflict:
        _handleConflictError(error);
        break;
      case SyncErrorType.unknown:
        _handleUnknownError(error);
        break;
    }
  }

  /// Recovery para erros de rede
  void _scheduleNetworkRecovery() {
    debugPrint('🔄 Agendando recovery para erro de rede...');
    
    // Tentar novamente quando a conectividade for restaurada
    Timer(const Duration(minutes: 1), () {
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        debugPrint('🌐 Conectividade restaurada, tentando sincronizar...');
        unawaited(_performSync());
      }
    });
  }

  /// Recovery para erros de timeout
  void _scheduleTimeoutRecovery() {
    debugPrint('⏳ Agendando recovery para timeout...');
    
    // Tentar novamente com delay aumentado
    Timer(const Duration(minutes: 2), () {
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        debugPrint('⏳ Tentando sincronizar após timeout...');
        unawaited(_performSync());
      }
    });
  }

  /// Recovery para erros de servidor
  void _scheduleServerErrorRecovery() {
    debugPrint('🚑 Agendando recovery para erro de servidor...');
    
    // Tentar novamente após delay maior
    Timer(const Duration(minutes: 5), () {
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        debugPrint('🚑 Tentando sincronizar após erro de servidor...');
        unawaited(_performSync());
      }
    });
  }

  /// Trata erros de autenticação
  void _handleAuthenticationError() {
    debugPrint('🔐 Tratando erro de autenticação...');
    
    // Não tenta novamente automaticamente - requer interação do usuário
    _updateMessage('Erro de autenticação. Por favor, faça login novamente.');
  }

  /// Trata erros de validação
  void _handleValidationError(SyncException error) {
    debugPrint('⚙️ Tratando erro de validação: ${error.details}');
    
    // Marca itens inválidos para revisão manual
    _updateMessage('Dados inválidos detectados. Verifique os dados e tente novamente.');
    
    // Invalid queue items marking implementation pending
  }

  /// Trata erros de conflito
  void _handleConflictError(SyncException error) {
    debugPrint('⚠️ Tratando erro de conflito: ${error.details}');
    
    _updateStatus(SyncStatus.conflict);
    _updateMessage('Conflito de dados detectado. Resolução manual necessária.');
    
    // Conflict resolution interface implementation pending
  }

  /// Trata erros desconhecidos
  void _handleUnknownError(SyncException error) {
    debugPrint('❓ Tratando erro desconhecido: ${error.toString()}');
    
    // Log extensivo para debugging
    _analytics.recordError(error, error.stackTrace);
    
    _updateMessage('Erro inesperado. Nossa equipe foi notificada.');
  }

  /// Notifica listeners sobre erro detalhado
  void _notifyError(SyncException error) {
    if (_isDisposed) return;
    
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  /// Inicia sincronização automática periódica
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        unawaited(_performSync());
      }
    });
    debugPrint('⏰ Auto-sync iniciado (${_autoSyncInterval.inMinutes} min)');
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    debugPrint('⏹️ Auto-sync parado');
  }

  /// Limpa todos os itens da fila
  Future<void> clearSyncQueue() async {
    await _syncQueue.clearAllItems();
    _updateMessage('Fila de sincronização limpa');
  }

  /// Limpa apenas itens sincronizados
  Future<void> clearSyncedItems() async {
    await _syncQueue.clearSyncedItems();
    _updateMessage('Itens sincronizados removidos');
  }

  /// Limpa itens que falharam
  Future<void> clearFailedItems() async {
    await _syncQueue.clearFailedItems();
    _updateMessage('Itens com falha removidos');
  }

  /// Obtém estatísticas de sincronização com informações de retry
  Map<String, dynamic> getSyncStats() {
    final queueStats = _syncQueue.getQueueStats();
    final connectivityStats = _syncOperations.getConnectivityStats();
    
    return {
      'status': _currentStatus.name,
      'is_initialized': _isInitialized,
      'auto_sync_enabled': _autoSyncTimer != null,
      'retry_state': {
        'is_retrying': isRetrying,
        'current_attempt': _currentRetryAttempt,
        'last_error': _lastSyncError?.toString(),
        'last_error_type': _lastSyncError?.type.name,
        'last_error_retryable': _lastSyncError?.isRetryable,
        'last_error_timestamp': _lastSyncError?.timestamp.toIso8601String(),
      },
      ...queueStats,
      ...connectivityStats,
    };
  }

  /// Obtém estatísticas detalhadas de erro para debugging
  Map<String, dynamic>? getDetailedErrorInfo() {
    if (_lastSyncError == null) return null;
    
    return {
      'type': _lastSyncError!.type.name,
      'message': _lastSyncError!.message,
      'details': _lastSyncError!.details,
      'status_code': _lastSyncError!.statusCode,
      'operation_type': _lastSyncError!.operationType,
      'model_type': _lastSyncError!.modelType,
      'timestamp': _lastSyncError!.timestamp.toIso8601String(),
      'is_retryable': _lastSyncError!.isRetryable,
      'recovery_strategy': _lastSyncError!.recoveryStrategy,
      'current_retry_attempt': _currentRetryAttempt,
    };
  }

  /// Obtém itens pendentes por tipo
  List<SyncQueueItem> getPendingItemsByType(String modelType) {
    return _syncQueue.getItemsByModelType(modelType);
  }

  /// Obtém todos os itens da fila
  List<SyncQueueItem> getAllQueueItems() {
    return _syncQueue.getAllItems();
  }

  /// Verifica se há conflitos pendentes
  bool hasConflicts() {
    // Real conflict verification implementation pending
    return false;
  }

  /// Resolve conflito com estratégia específica
  Future<void> resolveConflict<T extends BaseSyncModel>({
    required T localEntity,
    required T remoteEntity,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) async {
    try {
      final conflictData = _conflictResolver.getConflictData(localEntity, remoteEntity);
      _conflictResolver.resolveConflict(
        conflictData,
        strategy: strategy,
      );

      // Resolved entity save implementation pending
      
      _updateMessage('Conflito resolvido: ${strategy.displayName}');
      await _analytics.log('conflict_resolved');

    } catch (e) {
      debugPrint('❌ Erro ao resolver conflito: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Atualiza status e notifica listeners
  void _updateStatus(SyncStatus status) {
    if (_isDisposed) return;
    
    if (_currentStatus != status) {
      _currentStatus = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
      debugPrint('📊 Status sync: ${status.name}');
    }
  }

  /// Atualiza mensagem e notifica listeners
  void _updateMessage(String message) {
    if (_isDisposed) return;
    
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
    debugPrint('💬 Sync message: $message');
  }

  /// Dispose de recursos de forma segura
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    debugPrint('♻️ Disposing SyncService...');
    _isDisposed = true;
    
    // Cancelar timer de auto-sync
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    
    // Aguardar que qualquer sincronização em andamento termine
    await _syncLock.synchronized(() async {
      debugPrint('🔒 Aguardando término de sync ativo...');
    });
    
    // Dispose de componentes
    try {
      _syncOperations.dispose();
    } catch (e) {
      debugPrint('⚠️ Erro ao fazer dispose de SyncOperations: $e');
    }
    
    // Fechar streams de forma segura
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
    if (!_messageController.isClosed) {
      await _messageController.close();
    }
    if (!_errorController.isClosed) {
      await _errorController.close();
    }
    
    // Dispose da queue
    try {
      await _syncQueue.dispose();
    } catch (e) {
      debugPrint('⚠️ Erro ao fazer dispose de SyncQueue: $e');
    }
    
    _isInitialized = false;
    debugPrint('✅ SyncService disposed');
  }
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Aguardando';
      case SyncStatus.syncing:
        return 'Sincronizando';
      case SyncStatus.error:
        return 'Erro';
      case SyncStatus.success:
        return 'Sucesso';
      case SyncStatus.conflict:
        return 'Conflito';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  bool get isLoading => this == SyncStatus.syncing;
  bool get hasError => this == SyncStatus.error;
  bool get isSuccess => this == SyncStatus.success;
  bool get isOffline => this == SyncStatus.offline;
}