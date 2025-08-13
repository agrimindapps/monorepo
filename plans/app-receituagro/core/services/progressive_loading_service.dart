// Dart imports:
import 'dart:async';

// Flutter imports:

// Project imports:
import 'isolate_data_loader_service.dart';

/// Estados de carregamento progressivo
enum LoadingPhase {
  idle,
  initializing,
  loadingDatabase,
  processingData,
  renderingUI,
  completed,
  error,
}

/// Informações de progresso detalhadas
class ProgressInfo {
  final LoadingPhase phase;
  final double progress;
  final String message;
  final List<dynamic>? partialData;
  final String? errorMessage;

  const ProgressInfo({
    required this.phase,
    required this.progress,
    required this.message,
    this.partialData,
    this.errorMessage,
  });

  factory ProgressInfo.initializing() {
    return const ProgressInfo(
      phase: LoadingPhase.initializing,
      progress: 0.0,
      message: 'Inicializando...',
    );
  }

  factory ProgressInfo.loadingDatabase(double progress) {
    return ProgressInfo(
      phase: LoadingPhase.loadingDatabase,
      progress: progress,
      message: 'Carregando banco de dados...',
    );
  }

  factory ProgressInfo.processingData(double progress, {List<dynamic>? partialData}) {
    return ProgressInfo(
      phase: LoadingPhase.processingData,
      progress: progress,
      message: 'Processando dados...',
      partialData: partialData,
    );
  }

  factory ProgressInfo.renderingUI(double progress, {List<dynamic>? partialData}) {
    return ProgressInfo(
      phase: LoadingPhase.renderingUI,
      progress: progress,
      message: 'Carregando interface...',
      partialData: partialData,
    );
  }

  factory ProgressInfo.completed(List<dynamic> data) {
    return ProgressInfo(
      phase: LoadingPhase.completed,
      progress: 1.0,
      message: 'Concluído',
      partialData: data,
    );
  }

  factory ProgressInfo.error(String error) {
    return ProgressInfo(
      phase: LoadingPhase.error,
      progress: 0.0,
      message: 'Erro',
      errorMessage: error,
    );
  }

  /// Cria uma cópia com novos valores
  ProgressInfo copyWith({
    LoadingPhase? phase,
    double? progress,
    String? message,
    List<dynamic>? partialData,
    String? errorMessage,
  }) {
    return ProgressInfo(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      partialData: partialData ?? this.partialData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Configurações para carregamento progressivo
class ProgressiveLoadingConfig {
  final int batchSize;
  final Duration batchDelay;
  final bool enablePartialRendering;
  final int maxRetryAttempts;
  final Duration retryDelay;

  const ProgressiveLoadingConfig({
    this.batchSize = 50,
    this.batchDelay = const Duration(milliseconds: 16), // ~60fps
    this.enablePartialRendering = true,
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
}

/// Serviço para carregamento progressivo com streams não-bloqueantes
/// Substitui polling síncrono por streams assíncronos
class ProgressiveLoadingService {
  static ProgressiveLoadingService? _instance;
  static ProgressiveLoadingService get instance => _instance ??= ProgressiveLoadingService._();
  
  ProgressiveLoadingService._();

  final IsolateDataLoaderService _isolateLoader = IsolateDataLoaderService.instance;
  final Map<String, StreamController<ProgressInfo>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};

  /// Carrega dados de defensivos com progresso incrementais
  Stream<ProgressInfo> loadDefensivosProgressively({
    required bool isDatabaseLoaded,
    ProgressiveLoadingConfig config = const ProgressiveLoadingConfig(),
    String operationId = 'defensivos_load',
  }) async* {
    // Cria stream controller para esta operação
    if (!_progressControllers.containsKey(operationId)) {
      _progressControllers[operationId] = StreamController<ProgressInfo>.broadcast();
    }

    // Cria cancel token
    _cancelTokens[operationId] = CancelToken();

    try {
      // Fase 1: Inicializando
      yield ProgressInfo.initializing();
      await Future.delayed(const Duration(milliseconds: 50));

      if (_cancelTokens[operationId]?.isCancelled ?? false) return;

      // Fase 2: Carrega dados usando isolate
      await for (final isolateResult in _isolateLoader.loadDefensivosData(
        isDatabaseLoaded: isDatabaseLoaded,
        cancelToken: _cancelTokens[operationId],
      )) {
        if (_cancelTokens[operationId]?.isCancelled ?? false) return;

        if (isolateResult.isSuccess) {
          if (isolateResult.data != null) {
            // Dados carregados - processa em lotes
            yield* _processDataInBatches(
              isolateResult.data!,
              config,
              operationId,
            );
            return;
          } else {
            // Apenas progresso
            if (isolateResult.progress < 0.7) {
              yield ProgressInfo.loadingDatabase(isolateResult.progress);
            } else {
              yield ProgressInfo.processingData(isolateResult.progress);
            }
          }
        } else {
          yield ProgressInfo.error(isolateResult.error ?? 'Erro desconhecido');
          return;
        }
      }
    } catch (e) {
      yield ProgressInfo.error('Erro no carregamento progressivo: ${e.toString()}');
    } finally {
      _cleanupOperation(operationId);
    }
  }

  /// Carrega dados de pragas com progresso incremental
  Stream<ProgressInfo> loadPragasProgressively({
    required String pragaType,
    ProgressiveLoadingConfig config = const ProgressiveLoadingConfig(),
    String operationId = 'pragas_load',
  }) async* {
    // Cria stream controller para esta operação
    if (!_progressControllers.containsKey(operationId)) {
      _progressControllers[operationId] = StreamController<ProgressInfo>.broadcast();
    }

    // Cria cancel token
    _cancelTokens[operationId] = CancelToken();

    try {
      // Fase 1: Inicializando
      yield ProgressInfo.initializing();
      await Future.delayed(const Duration(milliseconds: 50));

      if (_cancelTokens[operationId]?.isCancelled ?? false) return;

      // Fase 2: Carrega dados usando isolate
      await for (final isolateResult in _isolateLoader.loadPragasData(
        pragaType: pragaType,
        cancelToken: _cancelTokens[operationId],
      )) {
        if (_cancelTokens[operationId]?.isCancelled ?? false) return;

        if (isolateResult.isSuccess) {
          if (isolateResult.data != null) {
            // Dados carregados - processa em lotes
            yield* _processDataInBatches(
              isolateResult.data!,
              config,
              operationId,
            );
            return;
          } else {
            // Apenas progresso
            yield ProgressInfo.processingData(isolateResult.progress);
          }
        } else {
          yield ProgressInfo.error(isolateResult.error ?? 'Erro desconhecido');
          return;
        }
      }
    } catch (e) {
      yield ProgressInfo.error('Erro no carregamento de pragas: ${e.toString()}');
    } finally {
      _cleanupOperation(operationId);
    }
  }

  /// Processa dados em lotes para renderização progressiva
  Stream<ProgressInfo> _processDataInBatches(
    List<Map<String, dynamic>> data,
    ProgressiveLoadingConfig config,
    String operationId,
  ) async* {
    if (_cancelTokens[operationId]?.isCancelled ?? false) return;

    final totalItems = data.length;
    final batchSize = config.batchSize;
    final processedItems = <Map<String, dynamic>>[];

    // Processa em lotes para não bloquear a UI
    for (int i = 0; i < totalItems; i += batchSize) {
      if (_cancelTokens[operationId]?.isCancelled ?? false) return;

      final endIndex = (i + batchSize).clamp(0, totalItems);
      final batch = data.sublist(i, endIndex);
      
      // Simula processamento do lote
      await Future.delayed(config.batchDelay);
      
      processedItems.addAll(batch);
      
      final progress = processedItems.length / totalItems;
      
      if (config.enablePartialRendering) {
        // Emite dados parciais para renderização progressiva
        yield ProgressInfo.renderingUI(
          progress,
          partialData: List.from(processedItems),
        );
      } else {
        // Apenas progresso sem dados parciais
        yield ProgressInfo.renderingUI(progress);
      }
    }

    // Emite dados finais
    yield ProgressInfo.completed(processedItems);
  }

  /// Cancela operação específica
  void cancelOperation(String operationId) {
    _cancelTokens[operationId]?.cancel();
    _cleanupOperation(operationId);
  }

  /// Cancela todas as operações
  void cancelAllOperations() {
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cleanupAllOperations();
  }

  /// Limpa recursos de uma operação
  void _cleanupOperation(String operationId) {
    _progressControllers[operationId]?.close();
    _progressControllers.remove(operationId);
    _cancelTokens.remove(operationId);
  }

  /// Limpa todos os recursos
  void _cleanupAllOperations() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _cancelTokens.clear();
  }

  /// Retry com backoff exponencial
  Stream<ProgressInfo> retryOperation(
    Stream<ProgressInfo> Function() operation,
    ProgressiveLoadingConfig config,
  ) async* {
    int attempts = 0;
    
    while (attempts < config.maxRetryAttempts) {
      try {
        await for (final progress in operation()) {
          yield progress;
          
          // Se completou com sucesso, para o retry
          if (progress.phase == LoadingPhase.completed) {
            return;
          }
          
          // Se deu erro, tenta novamente
          if (progress.phase == LoadingPhase.error) {
            break;
          }
        }
      } catch (e) {
        attempts++;
        
        if (attempts >= config.maxRetryAttempts) {
          yield ProgressInfo.error('Falha após $attempts tentativas: ${e.toString()}');
          return;
        }
        
        // Delay exponencial
        final delay = Duration(
          milliseconds: config.retryDelay.inMilliseconds * (1 << attempts),
        );
        
        yield ProgressInfo(
          phase: LoadingPhase.initializing,
          progress: 0.0,
          message: 'Tentativa ${attempts + 1}/${config.maxRetryAttempts}...',
        );
        
        await Future.delayed(delay);
      }
    }
  }

  /// Verifica se uma operação está em andamento
  bool isOperationActive(String operationId) {
    return _progressControllers.containsKey(operationId) && 
           !(_cancelTokens[operationId]?.isCancelled ?? true);
  }

  /// Obtém o progresso atual de uma operação
  Stream<ProgressInfo>? getProgressStream(String operationId) {
    return _progressControllers[operationId]?.stream;
  }

  /// Libera todos os recursos
  void dispose() {
    cancelAllOperations();
    _isolateLoader.dispose();
  }
}