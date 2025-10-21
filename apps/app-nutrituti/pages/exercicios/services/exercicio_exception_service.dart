// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../constants/exercicio_constants.dart';

/// Base class para todas as exceções relacionadas a exercícios
abstract class ExercicioException implements Exception {
  final String message;
  final String code;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final Exception? originalException;
  
  ExercicioException({
    required this.message,
    required this.code,
    this.context,
    this.originalException,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'ExercicioException [$code]: $message';
  
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'code': code,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'originalException': originalException?.toString(),
    };
  }
}

/// Exceções de validação de dados
class ExercicioValidationException extends ExercicioException {
  final String field;
  final dynamic value;
  
  ExercicioValidationException({
    required super.message,
    required this.field,
    this.value,
    super.context,
  }) : super(
    code: 'VALIDATION_ERROR',
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['field'] = field;
    map['value'] = value;
    return map;
  }
}

/// Exceções de conectividade e rede
class ExercicioNetworkException extends ExercicioException {
  final bool isOffline;
  final int? statusCode;
  
  ExercicioNetworkException({
    required super.message,
    this.isOffline = false,
    this.statusCode,
    super.context,
    super.originalException,
  }) : super(
    code: 'NETWORK_ERROR',
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['isOffline'] = isOffline;
    map['statusCode'] = statusCode;
    return map;
  }
}

/// Exceções de persistência e armazenamento
class ExercicioPersistenceException extends ExercicioException {
  final bool isLocalStorage;
  final String operation;
  
  ExercicioPersistenceException({
    required super.message,
    required this.operation,
    this.isLocalStorage = false,
    super.context,
    super.originalException,
  }) : super(
    code: 'PERSISTENCE_ERROR',
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['isLocalStorage'] = isLocalStorage;
    map['operation'] = operation;
    return map;
  }
}

/// Exceções de autenticação e autorização
class ExercicioAuthException extends ExercicioException {
  final bool requiresReauth;
  
  ExercicioAuthException({
    required super.message,
    this.requiresReauth = false,
    super.context,
    super.originalException,
  }) : super(
    code: 'AUTH_ERROR',
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['requiresReauth'] = requiresReauth;
    return map;
  }
}

/// Exceções de configuração e setup
class ExercicioConfigException extends ExercicioException {
  final String component;
  
  ExercicioConfigException({
    required super.message,
    required this.component,
    super.context,
    super.originalException,
  }) : super(
    code: 'CONFIG_ERROR',
  );
  
  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['component'] = component;
    return map;
  }
}

/// Estratégias de recuperação de erro
enum ErrorRecoveryStrategy {
  retry,
  fallback,
  userAction,
  abort,
  cache,
}

/// Resultado de uma estratégia de recuperação
class RecoveryResult {
  final bool success;
  final dynamic data;
  final String? message;
  final ErrorRecoveryStrategy strategyUsed;
  
  const RecoveryResult({
    required this.success,
    this.data,
    this.message,
    required this.strategyUsed,
  });
}

/// Service responsável pelo tratamento centralizado de exceções
class ExercicioExceptionService {
  static final ExercicioExceptionService _instance = ExercicioExceptionService._internal();
  factory ExercicioExceptionService() => _instance;
  ExercicioExceptionService._internal();

  // Stream para log de erros
  final StreamController<ExercicioException> _errorLogController = 
      StreamController<ExercicioException>.broadcast();

  // Configurações de retry
  static const int _maxRetryAttempts = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  
  // Cache de recovery strategies
  final Map<String, ErrorRecoveryStrategy> _recoveryStrategies = {};

  /// Stream de erros para monitoramento
  Stream<ExercicioException> get errorStream => _errorLogController.stream;

  // ========================================================================
  // MÉTODOS PRINCIPAIS DE TRATAMENTO
  // ========================================================================

  /// Trata uma exceção aplicando estratégias de recuperação
  Future<RecoveryResult> handleException(
    Exception exception, {
    String? operation,
    Map<String, dynamic>? context,
    ErrorRecoveryStrategy? preferredStrategy,
  }) async {
    final exercicioException = _wrapException(exception, operation, context);
    
    // Log do erro
    _logException(exercicioException);
    
    // Determinar estratégia de recuperação
    final strategy = preferredStrategy ?? _determineRecoveryStrategy(exercicioException);
    
    // Aplicar estratégia
    return await _applyRecoveryStrategy(exercicioException, strategy);
  }

  /// Executa uma operação com tratamento automático de erro
  Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? operationName,
    Map<String, dynamic>? context,
    ErrorRecoveryStrategy? recoveryStrategy,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final result = await handleException(
        e is Exception ? e : Exception(e.toString()),
        operation: operationName,
        context: context,
        preferredStrategy: recoveryStrategy,
      );
      
      if (result.success && result.data is T) {
        return result.data as T;
      } else if (fallbackValue != null) {
        return fallbackValue;
      } else {
        throw _wrapException(e is Exception ? e : Exception(e.toString()), operationName, context);
      }
    }
  }

  /// Executa uma operação com retry automático
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = _maxRetryAttempts,
    Duration delay = _baseRetryDelay,
    bool Function(Exception)? retryCondition,
    String? operationName,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        // Verificar se deve retry
        if (retryCondition != null && !retryCondition(lastException)) {
          break;
        }

        if (attempts >= maxAttempts) {
          break;
        }

        // Delay exponencial
        final retryDelay = Duration(
          milliseconds: delay.inMilliseconds * (1 << (attempts - 1)),
        );
        
        // Log retry attempt using the logger service would create circular dependency
        // Since this is exception service, we keep minimal logging here
        if (kDebugMode) {
          debugPrint('Retry attempt $attempts/$maxAttempts for $operationName after ${retryDelay.inSeconds}s');
        }
        await Future.delayed(retryDelay);
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    throw _wrapException(lastException!, operationName, {'attempts': attempts});
  }

  // ========================================================================
  // ESTRATÉGIAS DE RECUPERAÇÃO
  // ========================================================================

  /// Determina a melhor estratégia de recuperação para um erro
  ErrorRecoveryStrategy _determineRecoveryStrategy(ExercicioException exception) {
    // Estratégias baseadas no tipo de exceção
    if (exception is ExercicioNetworkException) {
      if (exception.isOffline) {
        return ErrorRecoveryStrategy.cache;
      } else if (exception.statusCode != null && 
                 ExercicioConstants.retryableHttpStatusCodes.contains(exception.statusCode)) {
        return ErrorRecoveryStrategy.retry;
      }
      return ErrorRecoveryStrategy.fallback;
    }
    
    if (exception is ExercicioPersistenceException) {
      if (exception.isLocalStorage) {
        return ErrorRecoveryStrategy.fallback;
      }
      return ErrorRecoveryStrategy.retry;
    }
    
    if (exception is ExercicioValidationException) {
      return ErrorRecoveryStrategy.userAction;
    }
    
    if (exception is ExercicioAuthException) {
      return exception.requiresReauth 
          ? ErrorRecoveryStrategy.userAction 
          : ErrorRecoveryStrategy.retry;
    }
    
    if (exception is ExercicioConfigException) {
      return ErrorRecoveryStrategy.fallback;
    }

    // Default strategy
    return ErrorRecoveryStrategy.abort;
  }

  /// Aplica uma estratégia de recuperação específica
  Future<RecoveryResult> _applyRecoveryStrategy(
    ExercicioException exception, 
    ErrorRecoveryStrategy strategy,
  ) async {
    switch (strategy) {
      case ErrorRecoveryStrategy.retry:
        return RecoveryResult(
          success: false,
          message: 'Operação será repetida automaticamente',
          strategyUsed: strategy,
        );
        
      case ErrorRecoveryStrategy.fallback:
        return _applyFallbackStrategy(exception);
        
      case ErrorRecoveryStrategy.cache:
        return _applyCacheStrategy(exception);
        
      case ErrorRecoveryStrategy.userAction:
        return RecoveryResult(
          success: false,
          message: _getUserActionMessage(exception),
          strategyUsed: strategy,
        );
        
      case ErrorRecoveryStrategy.abort:
        return RecoveryResult(
          success: false,
          message: exception.message,
          strategyUsed: strategy,
        );
    }
  }

  /// Estratégia de fallback - usar dados padrão ou alternativos
  Future<RecoveryResult> _applyFallbackStrategy(ExercicioException exception) async {
    // Implementar lógica de fallback baseada no tipo de erro
    if (exception is ExercicioNetworkException) {
      return RecoveryResult(
        success: true,
        data: _getOfflineFallbackData(exception),
        message: 'Usando dados offline',
        strategyUsed: ErrorRecoveryStrategy.fallback,
      );
    }
    
    return const RecoveryResult(
      success: false,
      message: 'Nenhum fallback disponível',
      strategyUsed: ErrorRecoveryStrategy.fallback,
    );
  }

  /// Estratégia de cache - usar dados em cache
  Future<RecoveryResult> _applyCacheStrategy(ExercicioException exception) async {
    // Implementar lógica de cache
    return RecoveryResult(
      success: true,
      data: _getCachedData(exception),
      message: 'Usando dados em cache',
      strategyUsed: ErrorRecoveryStrategy.cache,
    );
  }

  // ========================================================================
  // MÉTODOS AUXILIARES
  // ========================================================================

  /// Converte uma exceção genérica em ExercicioException
  ExercicioException _wrapException(
    Exception exception, 
    String? operation, 
    Map<String, dynamic>? context,
  ) {
    if (exception is ExercicioException) {
      return exception;
    }

    // Detectar tipos específicos de erro
    if (exception is SocketException || exception is TimeoutException) {
      return ExercicioNetworkException(
        message: 'Erro de conectividade: ${exception.toString()}',
        isOffline: exception is SocketException,
        context: context,
        originalException: exception,
      );
    }

    if (exception.toString().contains('auth') || 
        exception.toString().contains('unauthorized')) {
      return ExercicioAuthException(
        message: 'Erro de autenticação: ${exception.toString()}',
        context: context,
        originalException: exception,
      );
    }

    // Exceção genérica
    return ExercicioConfigException(
      message: exception.toString(),
      component: operation ?? 'unknown',
      context: context,
      originalException: exception,
    );
  }

  /// Log da exceção
  void _logException(ExercicioException exception) {
    // Emitir para stream de monitoramento
    _errorLogController.add(exception);
    
    // Log local para debug
    // Log exception using print to avoid circular dependency with logger service
    if (kDebugMode) {
      debugPrint('ExercicioException logged: ${exception.toMap()}');
    }
    
    // Em produção, você pode enviar para serviços de logging como Crashlytics
    // FirebaseCrashlytics.instance.recordError(exception, null);
  }

  /// Mensagem para ação do usuário
  String _getUserActionMessage(ExercicioException exception) {
    if (exception is ExercicioValidationException) {
      return 'Por favor, verifique o campo "${exception.field}": ${exception.message}';
    }
    
    if (exception is ExercicioAuthException) {
      return 'É necessário fazer login novamente para continuar';
    }
    
    return 'Ação necessária: ${exception.message}';
  }

  /// Dados de fallback offline
  dynamic _getOfflineFallbackData(ExercicioException exception) {
    // Implementar lógica para retornar dados padrão baseado no contexto
    if (exception.context?['operation'] == 'loadExercicios') {
      return <dynamic>[]; // Lista vazia como fallback
    }
    
    return null;
  }

  /// Dados em cache
  dynamic _getCachedData(ExercicioException exception) {
    // Implementar lógica para retornar dados em cache
    // Pode integrar com ExercicioCacheService
    return null;
  }

  // ========================================================================
  // CONFIGURAÇÃO E MONITORAMENTO
  // ========================================================================

  /// Configura estratégia de recuperação para um tipo de operação
  void setRecoveryStrategy(String operation, ErrorRecoveryStrategy strategy) {
    _recoveryStrategies[operation] = strategy;
  }

  /// Obtém estatísticas de erros
  Map<String, dynamic> getErrorStats() {
    // Implementar coleta de estatísticas
    return {
      'hasActiveStream': _errorLogController.hasListener,
      'recoveryStrategies': _recoveryStrategies.length,
    };
  }

  /// Limpa logs e redefine configurações
  void reset() {
    _recoveryStrategies.clear();
  }

  /// Dispose do service
  void dispose() {
    _errorLogController.close();
  }

  // ========================================================================
  // FACTORY METHODS PARA EXCEÇÕES COMUNS
  // ========================================================================

  /// Cria exceção de validação
  static ExercicioValidationException validationError(String field, String message, {dynamic value}) {
    return ExercicioValidationException(
      message: message,
      field: field,
      value: value,
    );
  }

  /// Cria exceção de rede
  static ExercicioNetworkException networkError(String message, {bool offline = false, int? statusCode}) {
    return ExercicioNetworkException(
      message: message,
      isOffline: offline,
      statusCode: statusCode,
    );
  }

  /// Cria exceção de persistência
  static ExercicioPersistenceException persistenceError(String operation, String message, {bool local = false}) {
    return ExercicioPersistenceException(
      message: message,
      operation: operation,
      isLocalStorage: local,
    );
  }

  /// Cria exceção de autenticação
  static ExercicioAuthException authError(String message, {bool requiresReauth = false}) {
    return ExercicioAuthException(
      message: message,
      requiresReauth: requiresReauth,
    );
  }

  /// Cria exceção de configuração
  static ExercicioConfigException configError(String component, String message) {
    return ExercicioConfigException(
      message: message,
      component: component,
    );
  }
}
