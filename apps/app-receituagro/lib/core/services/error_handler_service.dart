import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized error handler for consistent error handling across the app.
/// Provides standardized error logging, user-friendly messages, and error reporting.
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  /// Handle errors with consistent logging and user-friendly messages
  ErrorResult handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? metadata,
    bool shouldLog = true,
    bool shouldReport = false,
  }) {
    final errorInfo = _analyzeError(error);
    final errorContext = context ?? 'Unknown';

    if (shouldLog) {
      _logError(error, errorContext, metadata, errorInfo);
    }

    if (shouldReport && !kDebugMode) {
      _reportError(error, errorContext, metadata, errorInfo);
    }

    return ErrorResult(
      userMessage: errorInfo.userMessage,
      technicalMessage: errorInfo.technicalMessage,
      errorType: errorInfo.type,
      canRetry: errorInfo.canRetry,
      suggestions: errorInfo.suggestions,
    );
  }

  /// Analyze error and extract relevant information
  ErrorInfo _analyzeError(dynamic error) {
    if (error is AppException) {
      return ErrorInfo(
        type: error.type,
        userMessage: error.userMessage,
        technicalMessage: error.technicalMessage ?? error.toString(),
        canRetry: error.canRetry,
        suggestions: error.suggestions ?? [],
      );
    }
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

    if (error.toString().contains('AlreadyDeletedException')) {
      return ErrorInfo(
        type: ErrorType.business,
        userMessage: 'Comentário já foi removido',
        technicalMessage: error.toString(),
        canRetry: false,
        suggestions: ['Recarregue a lista'],
      );
    }

    if (error.toString().contains('DeletionNotAllowedException')) {
      return ErrorInfo(
        type: ErrorType.business,
        userMessage: 'Não é possível remover este comentário',
        technicalMessage: error.toString(),
        canRetry: false,
        suggestions: ['Comentários antigos não podem ser removidos'],
      );
    }
    if (error.toString().contains('SocketException') || 
        error.toString().contains('HttpException') ||
        error.toString().contains('TimeoutException')) {
      return ErrorInfo(
        type: ErrorType.network,
        userMessage: 'Problema de conexão',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Verifique sua conexão', 'Tente novamente'],
      );
    }
    if (error.toString().contains('HiveError') || 
        error.toString().contains('DatabaseException')) {
      return ErrorInfo(
        type: ErrorType.storage,
        userMessage: 'Erro ao salvar dados',
        technicalMessage: error.toString(),
        canRetry: true,
        suggestions: ['Tente novamente', 'Reinicie o aplicativo se persistir'],
      );
    }
    return ErrorInfo(
      type: ErrorType.unknown,
      userMessage: 'Algo deu errado',
      technicalMessage: error.toString(),
      canRetry: true,
      suggestions: ['Tente novamente'],
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

  /// Log error with context
  void _logError(
    dynamic error,
    String context,
    Map<String, dynamic>? metadata,
    ErrorInfo errorInfo,
  ) {
    final logMessage = 'ERROR in $context: ${errorInfo.technicalMessage}';
    
    if (kDebugMode) {
      debugPrint(logMessage);
      if (metadata != null && metadata.isNotEmpty) {
        debugPrint('Metadata: ${metadata.toString()}');
      }
    }
    developer.log(
      logMessage,
      name: 'ErrorHandler',
      error: error,
      level: _getLogLevel(errorInfo.type),
    );
  }

  /// Report error to external service (placeholder for crash reporting)
  void _reportError(
    dynamic error,
    String context,
    Map<String, dynamic>? metadata,
    ErrorInfo errorInfo,
  ) {
    if (kDebugMode) {
      debugPrint('Would report error to crash reporting service: $context');
    }
  }

  /// Get appropriate log level for error type
  int _getLogLevel(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.critical:
        return 1000; // Severe
      case ErrorType.network:
      case ErrorType.storage:
        return 900; // Warning
      case ErrorType.business:
      case ErrorType.validation:
        return 800; // Info
      case ErrorType.notFound:
        return 700; // Config
      case ErrorType.unknown:
        return 500; // Fine
    }
  }
}

/// Result of error handling
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
}

/// Internal error information
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

/// Types of errors for categorization
enum ErrorType {
  validation,
  business,
  network,
  storage,
  notFound,
  critical,
  unknown,
}

/// Base class for application-specific exceptions
abstract class AppException implements Exception {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final bool canRetry;
  final List<String>? suggestions;

  const AppException({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    this.canRetry = true,
    this.suggestions,
  });

  @override
  String toString() => technicalMessage ?? userMessage;
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(
    String message, {
    super.suggestions,
  }) : super(
          type: ErrorType.validation,
          userMessage: message,
          canRetry: true,
        );
}

/// Business rule exception
class BusinessException extends AppException {
  const BusinessException(
    String message, {
    super.canRetry = false,
    super.suggestions,
  }) : super(
          type: ErrorType.business,
          userMessage: message,
        );
}

/// Network exception
class NetworkException extends AppException {
  NetworkException(
    String message, {
    super.technicalMessage,
    List<String>? suggestions,
  }) : super(
          type: ErrorType.network,
          userMessage: message,
          canRetry: true,
          suggestions: suggestions ?? const ['Verifique sua conexão', 'Tente novamente'],
        );
}

/// Storage exception
class StorageException extends AppException {
  StorageException(
    String message, {
    super.technicalMessage,
    List<String>? suggestions,
  }) : super(
          type: ErrorType.storage,
          userMessage: message,
          canRetry: true,
          suggestions: suggestions ?? const ['Tente novamente', 'Reinicie o app se persistir'],
        );
}

/// Not found exception
class NotFoundException extends AppException {
  NotFoundException(
    String message, {
    List<String>? suggestions,
  }) : super(
          type: ErrorType.notFound,
          userMessage: message,
          canRetry: true,
          suggestions: suggestions ?? const ['Recarregue a lista', 'Verifique se ainda existe'],
        );
}