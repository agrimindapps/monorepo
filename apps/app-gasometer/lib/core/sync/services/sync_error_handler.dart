import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../services/analytics_service.dart';

/// Types of sync errors with specific handling strategies
enum SyncErrorType {
  /// Network connectivity error
  network,
  /// Authentication error
  authentication,
  /// Timeout error
  timeout,
  /// Server error (5xx)
  server,
  /// Validation/invalid data error
  validation,
  /// Data conflict error
  conflict,
  /// Unknown error
  unknown,
}

/// Specific sync exception with detailed context following SOLID principles
/// 
/// Follows SRP: Single responsibility of representing sync errors
/// Follows OCP: Open for extension via additional error types
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

  /// Determines if the error is retryable
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

  /// Gets user-friendly recovery strategy message
  String get recoveryStrategy {
    switch (type) {
      case SyncErrorType.network:
        return 'Verifique sua conexão e tente novamente';
      case SyncErrorType.authentication:
        return 'Faça login novamente';
      case SyncErrorType.timeout:
        return 'Operação será tentada novamente automaticamente';
      case SyncErrorType.server:
        return 'Servidor temporariamente indisponível, tentando novamente';
      case SyncErrorType.validation:
        return 'Verifique os dados e tente novamente';
      case SyncErrorType.conflict:
        return 'Conflito de dados detectado, resolução necessária';
      case SyncErrorType.unknown:
        return 'Erro inesperado, contate o suporte se persistir';
    }
  }
}

/// Service responsible for handling sync errors following SOLID principles
/// 
/// Follows SRP: Single responsibility of error handling and classification
/// Follows DIP: Depends on abstractions (AnalyticsService)
class SyncErrorHandler {
  final AnalyticsService _analytics;
  final StreamController<SyncException> _errorController = 
      StreamController<SyncException>.broadcast();

  Stream<SyncException> get errorStream => _errorController.stream;
  
  /// Exposes the error controller for direct access (used internally)
  StreamController<SyncException> get errorController => _errorController;

  SyncErrorHandler(this._analytics);

  /// Converts generic error to specific SyncException with context
  SyncException createSyncException({
    required dynamic error,
    StackTrace? stackTrace,
    String? operationType,
    String? modelType,
  }) {
    final errorString = error.toString().toLowerCase();
    
    SyncErrorType type;
    String message;
    String? details;
    int? statusCode;

    // Detect error type based on message/type
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
      operationType: operationType,
      modelType: modelType,
    );
  }

  /// Handles final sync failure with proper logging and notification
  Future<void> handleFinalFailure(
    SyncException error, 
    int attempts, 
    int maxAttempts,
  ) async {
    debugPrint('💥 Sincronização falhou após $attempts tentativas: ${error.toString()}');
    
    // Record analytics
    await _analytics.recordError(error, error.stackTrace);
    
    // Notify listeners
    _notifyError(error);
  }

  /// Notifies error to listeners
  void _notifyError(SyncException error) {
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  /// Disposes resources
  void dispose() {
    _errorController.close();
  }
}