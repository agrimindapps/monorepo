// Dart imports:
import 'dart:async';

// Project imports:
import '../constants/debug_rules.dart';

/// Gerenciador de erros para streams com retry mechanism e fallback strategies
class ErrorStreamManager {
  static final ErrorStreamManager _instance = ErrorStreamManager._internal();
  factory ErrorStreamManager() => _instance;
  ErrorStreamManager._internal();

  // Configurações de retry
  static const int _maxRetryAttempts = 3;
  static const Duration _initialRetryDelay = Duration(milliseconds: 500);
  static const Duration _maxRetryDelay = Duration(seconds: 30);

  /// Stream para notificar UI sobre erros
  final StreamController<ErrorState> _errorStateController = 
      StreamController<ErrorState>.broadcast();
  ErrorState _currentErrorState = ErrorState.none();

  Stream<ErrorState> get errorStateStream => _errorStateController.stream;
  ErrorState get currentErrorState => _currentErrorState;

  /// Cache de último estado válido por stream
  final Map<String, dynamic> _lastValidStates = {};

  /// Contador de tentativas por stream
  final Map<String, int> _retryCounters = {};

  /// Aplicar error handling robusto em stream
  Stream<T> wrapStreamWithErrorHandling<T>(
    String streamId,
    Stream<T> originalStream, {
    T? fallbackValue,
    bool enableRetry = true,
  }) {
    late StreamController<T> controller;
    
    controller = StreamController<T>(
      onListen: () {
        _subscribeWithRetry(streamId, originalStream, controller, fallbackValue, 0);
      },
    );

    return controller.stream;
  }

  /// Subscribe com retry automático
  void _subscribeWithRetry<T>(
    String streamId,
    Stream<T> stream,
    StreamController<T> controller,
    T? fallbackValue,
    int attemptCount,
  ) {
    stream.listen(
      (data) {
        _cacheLastValidState(streamId, data);
        controller.add(data);
        // Reset retry counter on success
        _retryCounters[streamId] = 0;
        _notifyError(ErrorState.none());
      },
      onError: (error, stackTrace) async {
        _handleStreamError(streamId, error, stackTrace, fallbackValue);
        
        if (attemptCount < _maxRetryAttempts) {
          final delay = _calculateRetryDelay(attemptCount);
          await Future.delayed(delay);
          _subscribeWithRetry(streamId, stream, controller, fallbackValue, attemptCount + 1);
        } else {
          // Max retries reached, use fallback
          final fallback = _getLastValidStateOrFallback<T>(streamId, fallbackValue);
          if (fallback != null) {
            controller.add(fallback);
          } else {
            controller.addError(error, stackTrace);
          }
        }
      },
      onDone: () => controller.close(),
    );
  }

  /// Calcular delay para retry com exponential backoff
  Duration _calculateRetryDelay(int attemptNumber) {
    final delayMs = _initialRetryDelay.inMilliseconds * (1 << attemptNumber);
    return Duration(
      milliseconds: delayMs.clamp(
        _initialRetryDelay.inMilliseconds,
        _maxRetryDelay.inMilliseconds,
      ),
    );
  }

  /// Handle de erro específico do stream
  void _handleStreamError<T>(
    String streamId,
    dynamic error,
    StackTrace? stackTrace,
    T? fallbackValue,
  ) {
    DebugRules.safeLog(
      'Stream error handled',
      {
        'streamId': streamId,
        'error': error.toString(),
        'hasFallback': fallbackValue != null,
      },
    );

    _notifyError(ErrorState(
      streamId: streamId,
      error: error,
      stackTrace: stackTrace,
      retryCount: _retryCounters[streamId] ?? 0,
      isRecoverable: fallbackValue != null || _hasLastValidState(streamId),
    ));
  }

  /// Cache do último estado válido
  void _cacheLastValidState<T>(String streamId, T data) {
    _lastValidStates[streamId] = data;
    
    // Reset retry counter em caso de sucesso
    _retryCounters[streamId] = 0;
    
    // Notificar que stream está saudável
    if (_currentErrorState.streamId == streamId) {
      _notifyError(ErrorState.none());
    }
  }

  /// Obter último estado válido ou fallback
  T? _getLastValidStateOrFallback<T>(String streamId, T? fallbackValue) {
    if (_hasLastValidState(streamId)) {
      return _lastValidStates[streamId] as T;
    }
    
    return fallbackValue;
  }

  /// Verificar se há último estado válido
  bool _hasLastValidState(String streamId) {
    return _lastValidStates.containsKey(streamId);
  }

  /// Notificar sobre erro
  void _notifyError(ErrorState errorState) {
    _currentErrorState = errorState;
    _errorStateController.add(errorState);
  }

  /// Criar stream resiliente simples
  Stream<T> createResilientStream<T>(
    String streamId,
    Stream<T> Function() streamFactory,
    T defaultValue,
  ) {
    return wrapStreamWithErrorHandling(
      streamId,
      streamFactory(),
      fallbackValue: defaultValue,
    );
  }

  /// Limpar recursos para um stream específico
  void clearStreamResources(String streamId) {
    _lastValidStates.remove(streamId);
    _retryCounters.remove(streamId);
  }

  /// Limpar todos os recursos
  void dispose() {
    _lastValidStates.clear();
    _retryCounters.clear();
    _errorStateController.close();
  }

  /// Obter estatísticas de error handling
  Map<String, dynamic> getErrorStats() {
    if (!DebugRules.isDebugEnabled) {
      return {'message': 'Error stats only available in debug mode'};
    }

    return {
      'active_streams': _lastValidStates.length,
      'streams_with_errors': _retryCounters.length,
      'current_error_state': _currentErrorState.toString(),
      'retry_counters': Map.from(_retryCounters),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Reset error state para stream específico
  void resetErrorState(String streamId) {
    _retryCounters.remove(streamId);
    if (_currentErrorState.streamId == streamId) {
      _notifyError(ErrorState.none());
    }
  }
}

/// Estado de erro para streams
class ErrorState {
  final String? streamId;
  final dynamic error;
  final StackTrace? stackTrace;
  final int retryCount;
  final bool isRecoverable;

  const ErrorState({
    this.streamId,
    this.error,
    this.stackTrace,
    this.retryCount = 0,
    this.isRecoverable = false,
  });

  ErrorState.none() : this();

  bool get hasError => error != null;

  @override
  String toString() {
    if (!hasError) return 'ErrorState.none';
    return 'ErrorState(streamId: $streamId, error: $error, retryCount: $retryCount, recoverable: $isRecoverable)';
  }
}