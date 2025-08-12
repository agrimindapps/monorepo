// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

/// Error categories for better error handling and user messaging
enum ErrorType {
  network,
  validation,
  database,
  permission,
  system,
  unknown,
}

/// Structured error class with user-friendly messages and recovery suggestions
class AppError {
  final ErrorType type;
  final String message;
  final String userMessage;
  final List<String> suggestions;
  final bool canRetry;
  final DateTime timestamp;
  final String? stackTrace;

  AppError({
    required this.type,
    required this.message,
    required this.userMessage,
    this.suggestions = const [],
    this.canRetry = false,
    String? stackTrace,
  })  : timestamp = DateTime.now(),
        stackTrace = stackTrace;

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'message': message,
      'userMessage': userMessage,
      'suggestions': suggestions,
      'canRetry': canRetry,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
    };
  }
}

/// Service responsible for handling all errors in the Odometro module
class ErrorHandlerService extends GetxService {
  final RxList<AppError> _errorHistory = <AppError>[].obs;
  final RxBool _hasActiveError = false.obs;
  final Rx<AppError?> _currentError = Rx<AppError?>(null);

  List<AppError> get errorHistory => _errorHistory;
  bool get hasActiveError => _hasActiveError.value;
  AppError? get currentError => _currentError.value;

  /// Handle and categorize errors with appropriate user messaging
  AppError handleError(dynamic error,
      {StackTrace? stackTrace, String? context}) {
    final appError = _categorizeError(error, stackTrace, context);

    // Log error for development/debugging
    _logError(appError);

    // Update reactive state
    _currentError.value = appError;
    _hasActiveError.value = true;
    _errorHistory.add(appError);

    // Keep only last 50 errors to prevent memory issues
    if (_errorHistory.length > 50) {
      _errorHistory.removeAt(0);
    }

    return appError;
  }

  /// Retry mechanism for operations that can be retried
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) rethrow;

        // Calculate exponential backoff delay
        final retryDelay = Duration(
          milliseconds: (delay.inMilliseconds * attempt).clamp(
            delay.inMilliseconds,
            maxDelay.inMilliseconds,
          ),
        );

        await Future.delayed(retryDelay);
      }
    }

    throw StateError('Should never reach here');
  }

  /// Clear current error state
  void clearError() {
    _currentError.value = null;
    _hasActiveError.value = false;
  }

  /// Get user-friendly error message based on error type
  String getUserMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';
      case ErrorType.validation:
        return 'Dados inválidos. Verifique as informações inseridas.';
      case ErrorType.database:
        return 'Erro ao acessar dados. Tente novamente em alguns instantes.';
      case ErrorType.permission:
        return 'Permissão negada. Verifique as configurações do app.';
      case ErrorType.system:
        return 'Erro do sistema. Reinicie o aplicativo se o problema persistir.';
      case ErrorType.unknown:
        return 'Erro inesperado. Tente novamente ou entre em contato com o suporte.';
    }
  }

  /// Get recovery suggestions based on error type
  List<String> getRecoverySuggestions(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return [
          'Verifique sua conexão com a internet',
          'Tente usar Wi-Fi ou dados móveis',
          'Aguarde alguns instantes e tente novamente',
        ];
      case ErrorType.validation:
        return [
          'Verifique se todos os campos obrigatórios estão preenchidos',
          'Confirme se os números estão no formato correto',
          'Use vírgula ou ponto para valores decimais',
        ];
      case ErrorType.database:
        return [
          'Aguarde alguns instantes e tente novamente',
          'Verifique se há dados sincronizados localmente',
          'Reinicie o aplicativo se necessário',
        ];
      case ErrorType.permission:
        return [
          'Vá em Configurações > Apps > fNutriTuti',
          'Verifique se as permissões necessárias estão habilitadas',
          'Reinicie o aplicativo após alterar permissões',
        ];
      case ErrorType.system:
        return [
          'Feche e abra o aplicativo novamente',
          'Reinicie seu dispositivo se necessário',
          'Verifique se há atualizações disponíveis',
        ];
      case ErrorType.unknown:
        return [
          'Tente a operação novamente',
          'Reinicie o aplicativo',
          'Entre em contato com o suporte se persistir',
        ];
    }
  }

  /// Categorize error based on its type and content
  AppError _categorizeError(
      dynamic error, StackTrace? stackTrace, String? context) {
    String errorMessage = error.toString();
    ErrorType type = ErrorType.unknown;
    bool canRetry = false;

    // Network related errors
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('NetworkException') ||
        errorMessage.contains('TimeoutException') ||
        errorMessage.contains('connection')) {
      type = ErrorType.network;
      canRetry = true;
    }
    // Validation errors
    else if (errorMessage.contains('FormatException') ||
        errorMessage.contains('Invalid') ||
        errorMessage.contains('validation')) {
      type = ErrorType.validation;
      canRetry = false;
    }
    // Database errors
    else if (errorMessage.contains('database') ||
        errorMessage.contains('sql') ||
        errorMessage.contains('firestore')) {
      type = ErrorType.database;
      canRetry = true;
    }
    // Permission errors
    else if (errorMessage.contains('permission') ||
        errorMessage.contains('denied') ||
        errorMessage.contains('unauthorized')) {
      type = ErrorType.permission;
      canRetry = false;
    }
    // System errors
    else if (errorMessage.contains('OutOfMemoryError') ||
        errorMessage.contains('system')) {
      type = ErrorType.system;
      canRetry = false;
    }

    return AppError(
      type: type,
      message: errorMessage,
      userMessage: getUserMessage(type),
      suggestions: getRecoverySuggestions(type),
      canRetry: canRetry,
      stackTrace: stackTrace?.toString(),
    );
  }

  /// Log error with appropriate level
  void _logError(AppError error) {
    final contextInfo =
        error.stackTrace != null ? '\nStack trace: ${error.stackTrace}' : '';

    if (kDebugMode) {
      debugPrint('🔴 [${error.type}] ${error.message}$contextInfo');
    }

    // In production, you might want to send to a logging service
    // like Firebase Crashlytics, Sentry, etc.
  }

  /// Get error statistics for debugging
  Map<String, dynamic> getErrorStatistics() {
    final Map<ErrorType, int> errorCounts = {};

    for (final error in _errorHistory) {
      errorCounts[error.type] = (errorCounts[error.type] ?? 0) + 1;
    }

    return {
      'totalErrors': _errorHistory.length,
      'errorsByType':
          errorCounts.map((key, value) => MapEntry(key.toString(), value)),
      'hasActiveError': _hasActiveError.value,
      'lastErrorTime': _errorHistory.isNotEmpty
          ? _errorHistory.last.timestamp.toIso8601String()
          : null,
    };
  }

  @override
  void onClose() {
    _errorHistory.clear();
    _hasActiveError.close();
    _currentError.close();
    super.onClose();
  }
}
