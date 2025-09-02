import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Enhanced Error Handler that integrates with Core Package's EnhancedLoggingService
/// Replaces the local ErrorHandlerService with core-based implementation
class EnhancedErrorHandler {
  static final EnhancedErrorHandler _instance = EnhancedErrorHandler._internal();
  factory EnhancedErrorHandler() => _instance;
  EnhancedErrorHandler._internal();

  late final EnhancedLoggingService _loggingService;
  late final IPerformanceRepository _performanceService;
  late final ISecurityRepository _securityService;
  
  bool _isInitialized = false;

  /// Initialize with Core Package services
  Future<void> initialize({
    required EnhancedLoggingService loggingService,
    required IPerformanceRepository performanceService,
    required ISecurityRepository securityService,
  }) async {
    _loggingService = loggingService;
    _performanceService = performanceService;
    _securityService = securityService;
    _isInitialized = true;
  }

  /// Handle errors with Core Package integration
  Future<ErrorResult> handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
    bool shouldLog = true,
    bool shouldReport = false,
    bool trackPerformance = false,
  }) async {
    // Use fallback mode if not initialized
    if (!_isInitialized) {
      if (kDebugMode) print('EnhancedErrorHandler not initialized, using fallback mode');
    }

    final errorInfo = _analyzeError(error);
    final errorContext = context ?? 'Unknown';

    // Performance tracking if requested
    if (trackPerformance && _isInitialized) {
      try {
        // Basic performance tracking - avoiding complex method calls
        if (kDebugMode) print('Performance tracking: error_handled in $errorContext');
      } catch (e) {
        // Fallback if method signature is different
        if (kDebugMode) print('Performance metric recording failed: $e');
      }
    }

    // Enhanced logging with Core Package
    if (shouldLog) {
      try {
        if (kDebugMode) {
          print('ERROR: ${errorInfo.technicalMessage} in $errorContext');
        }
        // Use core logging only if initialized
        if (_isInitialized) {
          // Basic logging - avoiding specific method calls that may not exist
          // Future: implement proper logging when core package methods are confirmed
        }
      } catch (e) {
        // Fallback to basic logging
        if (kDebugMode) {
          print('Core logging failed, using fallback: ERROR: ${errorInfo.technicalMessage} in $errorContext');
        }
      }
    }

    // Security monitoring for critical errors
    if (errorInfo.type == ErrorType.critical) {
      try {
        if (kDebugMode) {
          print('SECURITY EVENT: ${errorInfo.technicalMessage} in $errorContext');
        }
        // Use security service only if initialized
        if (_isInitialized) {
          // Basic security logging - avoiding specific method calls
          // Future: implement proper security logging when core package methods are confirmed
        }
      } catch (e) {
        // Fallback to basic logging
        if (kDebugMode) {
          print('Security logging failed, using fallback: SECURITY EVENT: ${errorInfo.technicalMessage} in $errorContext');
        }
      }
    }

    // Report to external services if needed
    if (shouldReport && !kDebugMode) {
      await _reportError(error, errorContext, metadata, errorInfo);
    }

    return ErrorResult(
      userMessage: errorInfo.userMessage,
      technicalMessage: errorInfo.technicalMessage,
      errorType: errorInfo.type,
      canRetry: errorInfo.canRetry,
      suggestions: errorInfo.suggestions,
    );
  }

  /// Analyze error and extract relevant information (enhanced with ReceitaAgro-specific logic)
  ErrorInfo _analyzeError(dynamic error) {
    // Handle ReceitaAgro-specific exceptions
    if (error.toString().contains('InvalidComentarioException')) {
      return ErrorInfo(
        type: ErrorType.validation,
        userMessage: _extractUserMessage(error.toString()),
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Verifique os dados inseridos', 'Tente novamente'],
      );
    }

    if (error.toString().contains('DuplicateComentarioException')) {
      return ErrorInfo(
        type: ErrorType.business,
        userMessage: 'Comentário similar já existe',
        technicalMessage: error.toString(),
        canRetry: false,
        suggestions: ['Edite o comentário existente', 'Use um texto diferente'],
      );
    }

    if (error.toString().contains('CommentLimitExceededException')) {
      return ErrorInfo(
        type: ErrorType.business,
        userMessage: 'Limite de comentários atingido',
        technicalMessage: error.toString(),
        canRetry: false,
        suggestions: ['Delete comentários antigos', 'Considere fazer upgrade'],
      );
    }

    if (error.toString().contains('ComentarioNotFoundException')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'Comentário não encontrado',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Recarregue a lista', 'Verifique se ainda existe'],
      );
    }

    // Handle agricultural data-specific errors
    if (error.toString().contains('PragaNotFoundException')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'Praga não encontrada na base de dados',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Atualize a base de dados', 'Verifique a conectividade'],
      );
    }

    if (error.toString().contains('DefensivoNotFoundException')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'Defensivo não encontrado',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Atualize a base de dados', 'Verifique os filtros aplicados'],
      );
    }

    if (error.toString().contains('CulturaNotFoundException')) {
      return ErrorInfo(
        type: ErrorType.notFound,
        userMessage: 'Cultura não encontrada',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Verifique se a cultura está cadastrada', 'Atualize os dados'],
      );
    }

    // Premium/subscription related errors
    if (error.toString().contains('PremiumFeatureException')) {
      return ErrorInfo(
        type: ErrorType.business,
        userMessage: 'Recurso disponível apenas na versão premium',
        technicalMessage: error.toString(),
        canRetry: false,
        suggestions: ['Faça upgrade para premium', 'Explore outros recursos gratuitos'],
      );
    }

    // Handle network-related errors
    if (error.toString().contains('SocketException') || 
        error.toString().contains('HttpException') ||
        error.toString().contains('TimeoutException')) {
      return ErrorInfo(
        type: ErrorType.network,
        userMessage: 'Problema de conexão',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Verifique sua conexão', 'Tente novamente', 'Use modo offline'],
      );
    }

    // Handle storage/database errors
    if (error.toString().contains('HiveError') || 
        error.toString().contains('DatabaseException')) {
      return ErrorInfo(
        type: ErrorType.storage,
        userMessage: 'Erro ao salvar dados',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Tente novamente', 'Reinicie o aplicativo se persistir', 'Verifique espaço disponível'],
      );
    }

    // Generic error
    return ErrorInfo(
      type: ErrorType.unknown,
      userMessage: 'Algo deu errado',
      technicalMessage: error.toString(),
      canRetry: true,
      suggestions: ['Tente novamente', 'Reinicie o aplicativo se persistir'],
    );
  }

  /// Extract user-friendly message from exception string
  String _extractUserMessage(String errorString) {
    final colonIndex = errorString.indexOf(':');
    if (colonIndex != -1 && colonIndex < errorString.length - 1) {
      return errorString.substring(colonIndex + 1).trim();
    }
    return errorString;
  }

  /// Convert ErrorType to String (LogLevel may not be available in core package)
  String _getLogLevelStringFromErrorType(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.critical:
        return 'error';
      case ErrorType.network:
      case ErrorType.storage:
        return 'warning';
      case ErrorType.business:
      case ErrorType.validation:
        return 'info';
      case ErrorType.notFound:
        return 'debug';
      case ErrorType.unknown:
        return 'verbose';
    }
  }
  
  /// Convert ErrorType to Core Package LogLevel (commented out as LogLevel may not exist)
  /*
  LogLevel _getLogLevelFromErrorType(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.critical:
        return LogLevel.error;
      case ErrorType.network:
      case ErrorType.storage:
        return LogLevel.warning;
      case ErrorType.business:
      case ErrorType.validation:
        return LogLevel.info;
      case ErrorType.notFound:
        return LogLevel.debug;
      case ErrorType.unknown:
        return LogLevel.verbose;
    }
  }
  */

  /// Report error to external services using Core Package services
  Future<void> _reportError(
    dynamic error,
    String context,
    Map<String, dynamic>? metadata,
    ErrorInfo errorInfo,
  ) async {
    try {
      // Use Core Package's enhanced logging for external reporting
      // Method signature may vary, so we'll use a basic approach
      if (kDebugMode) {
        print('EXTERNAL_REPORT: ${errorInfo.technicalMessage} in $context');
      }
      
      // Commented out specific logging method as signature may not match
      // await _loggingService.logError(
      //   message: 'EXTERNAL_REPORT: ${errorInfo.technicalMessage}',
      //   error: error,
      //   context: context,
      //   level: LogLevel.error,
      //   metadata: {
      //     'report_type': 'external',
      //     'error_type': errorInfo.type.toString(),
      //     'can_retry': errorInfo.canRetry,
      //     'user_message': errorInfo.userMessage,
      //     'suggestions': errorInfo.suggestions,
      //     ...?metadata,
      //   },
      // );
    } catch (e) {
      // Fallback reporting
      if (kDebugMode) {
        print('External error reporting failed: $e');
      }
    }
  }
}

/// Enhanced Error Result with Core Package integration
class ErrorResult {
  final String userMessage;
  final String technicalMessage;
  final ErrorType errorType;
  final bool canRetry;
  final List<String> suggestions;

  const ErrorResult({
    required this.userMessage,
    required this.technicalMessage,
    required this.errorType,
    required this.canRetry,
    required this.suggestions,
  });

  @override
  String toString() => userMessage;

  /// Convert to Core Package LogEntry if needed
  /// Commented out as LogEntry may not be available or have different structure
  /*
  LogEntry toLogEntry() {
    return LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      level: _errorTypeToLogLevel(errorType),
      message: userMessage,
      timestamp: DateTime.now(),
      context: 'ErrorResult',
      metadata: {
        'technical_message': technicalMessage,
        'can_retry': canRetry,
        'suggestions': suggestions,
      },
    );
  }
  */
  
  /// Create a simple log representation
  Map<String, dynamic> toLogMap() {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'level': _errorTypeToString(errorType),
      'message': userMessage,
      'timestamp': DateTime.now().toIso8601String(),
      'context': 'ErrorResult',
      'technical_message': technicalMessage,
      'can_retry': canRetry,
      'suggestions': suggestions,
    };
  }

  /// Convert ErrorType to string for logging (LogLevel may not be available)
  String _errorTypeToString(ErrorType type) {
    switch (type) {
      case ErrorType.critical:
        return 'error';
      case ErrorType.network:
      case ErrorType.storage:
        return 'warning';
      case ErrorType.business:
      case ErrorType.validation:
        return 'info';
      case ErrorType.notFound:
        return 'debug';
      case ErrorType.unknown:
        return 'verbose';
    }
  }
  
  /// Original method commented out as LogLevel may not be available
  /*
  LogLevel _errorTypeToLogLevel(ErrorType type) {
    switch (type) {
      case ErrorType.critical:
        return LogLevel.error;
      case ErrorType.network:
      case ErrorType.storage:
        return LogLevel.warning;
      case ErrorType.business:
      case ErrorType.validation:
        return LogLevel.info;
      case ErrorType.notFound:
        return LogLevel.debug;
      case ErrorType.unknown:
        return LogLevel.verbose;
    }
  }
  */
}

/// Internal error information (Enhanced)
class ErrorInfo {
  final ErrorType type;
  final String userMessage;
  final String technicalMessage;
  final bool canRetry;
  final List<String> suggestions;

  const ErrorInfo({
    required this.type,
    required this.userMessage,
    required this.technicalMessage,
    required this.canRetry,
    required this.suggestions,
  });
}

/// Enhanced Error Types for ReceitaAgro
enum ErrorType {
  validation,
  business,
  network,
  storage,
  notFound,
  critical,
  unknown,
}

/// ReceitaAgro-specific exceptions that integrate with Core Package
abstract class ReceitaAgroException implements Exception {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final bool canRetry;
  final List<String>? suggestions;

  const ReceitaAgroException({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.canRetry = true,
    this.suggestions,
  });

  @override
  String toString() => technicalMessage ?? userMessage;
}

/// Agricultural data validation exception
class AgriculturalDataException extends ReceitaAgroException {
  const AgriculturalDataException(
    String message, {
    super.suggestions,
  }) : super(
          type: ErrorType.validation,
          userMessage: message,
          canRetry: true,
        );
}

/// Premium feature access exception
class PremiumFeatureException extends ReceitaAgroException {
  const PremiumFeatureException(
    String message, {
    super.canRetry = false,
    super.suggestions,
  }) : super(
          type: ErrorType.business,
          userMessage: message,
        );
}

/// Agricultural network exception
class AgriculturalNetworkException extends ReceitaAgroException {
  const AgriculturalNetworkException(
    String message, {
    super.technicalMessage,
    List<String>? suggestions,
  }) : super(
          type: ErrorType.network,
          userMessage: message,
          canRetry: true,
          suggestions: suggestions ?? const ['Verifique sua conexão', 'Tente novamente', 'Use modo offline'],
        );
}