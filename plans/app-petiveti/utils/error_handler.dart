// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Types of errors that can occur in the application
enum ErrorType {
  network,
  database,
  validation,
  authentication,
  permission,
  timeout,
  unknown
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical
}

/// Structured error information
class AppError {
  final String code;
  final String message;
  final String? details;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  AppError({
    required this.code,
    required this.message,
    this.details,
    required this.type,
    required this.severity,
    StackTrace? stackTrace,
  }) : timestamp = DateTime.now(),
       stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return 'AppError(code: $code, message: $message, type: $type, severity: $severity)';
  }
}

/// Centralized error handler service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final List<AppError> _errorLog = [];

  /// Handle an error with appropriate user feedback and logging
  void handleError(
    dynamic error, {
    String? userMessage,
    ErrorType? type,
    ErrorSeverity? severity,
    bool showUserFeedback = true,
    StackTrace? stackTrace,
  }) {
    final appError = _createAppError(
      error,
      type: type,
      severity: severity,
      stackTrace: stackTrace,
    );

    // Log the error
    _logError(appError);

    // Show user feedback if requested
    if (showUserFeedback) {
      _showUserFeedback(appError, userMessage);
    }
  }

  /// Create retry mechanism for failed operations
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? operationName,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        attempts++;
        return await operation();
      } catch (error, stackTrace) {
        if (attempts >= maxRetries) {
          handleError(
            error,
            userMessage: 'Falha após $maxRetries tentativas${operationName != null ? ' em $operationName' : ''}',
            type: ErrorType.unknown,
            severity: ErrorSeverity.high,
            stackTrace: stackTrace,
          );
          rethrow;
        }
        
        // Log retry attempt
        debugPrint('Retry attempt $attempts/$maxRetries for ${operationName ?? 'operation'}');
        
        // Wait before next attempt
        await Future.delayed(delay * attempts);
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  /// Execute operation with timeout
  Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    String? operationName,
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      final error = AppError(
        code: 'TIMEOUT',
        message: 'Operação excedeu o tempo limite',
        details: operationName,
        type: ErrorType.timeout,
        severity: ErrorSeverity.medium,
      );
      
      handleError(error);
      rethrow;
    }
  }

  /// Get error log for debugging
  List<AppError> get errorLog => List.unmodifiable(_errorLog);

  /// Clear error log
  void clearErrorLog() {
    _errorLog.clear();
  }

  AppError _createAppError(
    dynamic error, {
    ErrorType? type,
    ErrorSeverity? severity,
    StackTrace? stackTrace,
  }) {
    if (error is AppError) {
      return error;
    }

    String message;
    String code;
    ErrorType errorType = type ?? ErrorType.unknown;
    ErrorSeverity errorSeverity = severity ?? ErrorSeverity.medium;

    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
      code = error.runtimeType.toString();
    } else {
      message = error.toString();
      code = 'UNKNOWN';
    }

    // Detect error type from message content
    if (type == null) {
      errorType = _detectErrorType(message);
    }

    return AppError(
      code: code,
      message: message,
      type: errorType,
      severity: errorSeverity,
      stackTrace: stackTrace,
    );
  }

  ErrorType _detectErrorType(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('network') || lowerMessage.contains('internet')) {
      return ErrorType.network;
    } else if (lowerMessage.contains('database') || lowerMessage.contains('sql')) {
      return ErrorType.database;
    } else if (lowerMessage.contains('timeout')) {
      return ErrorType.timeout;
    } else if (lowerMessage.contains('permission') || lowerMessage.contains('unauthorized')) {
      return ErrorType.permission;
    } else if (lowerMessage.contains('validation') || lowerMessage.contains('invalid')) {
      return ErrorType.validation;
    }
    
    return ErrorType.unknown;
  }

  void _logError(AppError error) {
    _errorLog.add(error);
    
    // Keep only last 100 errors
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }

    // Debug logging
    if (kDebugMode) {
      debugPrint('🔴 ERROR: ${error.toString()}');
      if (error.stackTrace != null && error.severity == ErrorSeverity.critical) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }
  }

  void _showUserFeedback(AppError error, String? userMessage) {
    final message = userMessage ?? _getUserFriendlyMessage(error);
    final backgroundColor = _getErrorColor(error.severity);

    Get.snackbar(
      _getErrorTitle(error.severity),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: _getErrorDuration(error.severity),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      mainButton: error.severity == ErrorSeverity.critical 
        ? TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          )
        : null,
    );
  }

  String _getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'Problema de conexão. Verifique sua internet.';
      case ErrorType.database:
        return 'Erro no banco de dados. Tente novamente.';
      case ErrorType.timeout:
        return 'Operação demorou muito. Tente novamente.';
      case ErrorType.permission:
        return 'Você não tem permissão para esta ação.';
      case ErrorType.validation:
        return 'Dados inválidos. Verifique as informações.';
      default:
        return error.message.isNotEmpty ? error.message : 'Erro inesperado. Tente novamente.';
    }
  }

  String _getErrorTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'Aviso';
      case ErrorSeverity.medium:
        return 'Erro';
      case ErrorSeverity.high:
        return 'Erro Crítico';
      case ErrorSeverity.critical:
        return 'Falha do Sistema';
    }
  }

  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.red;
      case ErrorSeverity.high:
        return Colors.red[700]!;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  Duration _getErrorDuration(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Duration(seconds: 2);
      case ErrorSeverity.medium:
        return const Duration(seconds: 3);
      case ErrorSeverity.high:
        return const Duration(seconds: 5);
      case ErrorSeverity.critical:
        return const Duration(seconds: 8);
    }
  }
}
