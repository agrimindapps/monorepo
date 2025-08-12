// Flutter imports:
import 'package:flutter/foundation.dart';

/// Categories of errors that can occur in the module
enum ErrorCategory {
  network,
  validation,
  storage,
  business,
  system,
  unknown
}

/// Error severity levels for logging and handling
enum ErrorSeverity {
  low,
  medium,
  high,
  critical
}

/// Centralized error handling for the despesas_cadastro module
/// 
/// Categorizes errors, provides user-friendly messages, and implements
/// retry logic where appropriate. Integrates with logging for debugging.
class DespesaErrorHandler {
  static const String _tag = 'DespesaErrorHandler';
  
  /// Categorizes an error based on its type and content
  static ErrorCategory categorizeError(dynamic error) {
    if (error == null) return ErrorCategory.unknown;
    
    final errorString = error.toString().toLowerCase();
    
    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('http') ||
        errorString.contains('socket')) {
      return ErrorCategory.network;
    }
    
    // Storage/Database errors
    if (errorString.contains('database') ||
        errorString.contains('storage') ||
        errorString.contains('repository') ||
        errorString.contains('persistence')) {
      return ErrorCategory.storage;
    }
    
    // Validation errors
    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('required') ||
        errorString.contains('formato')) {
      return ErrorCategory.validation;
    }
    
    // Business logic errors
    if (errorString.contains('business') ||
        errorString.contains('rule') ||
        errorString.contains('despesa') ||
        errorString.contains('valor') ||
        errorString.contains('animal')) {
      return ErrorCategory.business;
    }
    
    // System errors
    if (errorString.contains('system') ||
        errorString.contains('memory') ||
        errorString.contains('exception') ||
        errorString.contains('illegal') ||
        errorString.contains('state')) {
      return ErrorCategory.system;
    }
    
    return ErrorCategory.unknown;
  }
  
  /// Determines error severity based on category and content
  static ErrorSeverity determineErrorSeverity(ErrorCategory category, dynamic error) {
    switch (category) {
      case ErrorCategory.network:
        return ErrorSeverity.medium;
      case ErrorCategory.validation:
        return ErrorSeverity.low;
      case ErrorCategory.storage:
        return ErrorSeverity.high;
      case ErrorCategory.business:
        return ErrorSeverity.medium;
      case ErrorCategory.system:
        return ErrorSeverity.critical;
      case ErrorCategory.unknown:
        return ErrorSeverity.medium;
    }
  }
  
  /// Provides user-friendly error messages based on error category
  static String getUserFriendlyMessage(ErrorCategory category, dynamic error) {
    switch (category) {
      case ErrorCategory.network:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';
      case ErrorCategory.validation:
        return _getValidationMessage(error);
      case ErrorCategory.storage:
        return 'Erro ao salvar dados. Tente novamente em alguns instantes.';
      case ErrorCategory.business:
        return _getBusinessMessage(error);
      case ErrorCategory.system:
        return 'Erro interno do sistema. Reinicie o aplicativo se o problema persistir.';
      case ErrorCategory.unknown:
        return 'Erro inesperado. Tente novamente ou entre em contato com o suporte.';
    }
  }
  
  /// Gets specific validation error message
  static String _getValidationMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('animal')) {
      return 'Selecione um animal válido.';
    }
    if (errorString.contains('tipo')) {
      return 'Selecione um tipo de despesa válido.';
    }
    if (errorString.contains('valor')) {
      return 'Informe um valor válido para a despesa.';
    }
    if (errorString.contains('data')) {
      return 'Informe uma data válida.';
    }
    if (errorString.contains('descricao') || errorString.contains('descrição')) {
      return 'Verifique a descrição da despesa.';
    }
    
    return 'Verifique os dados informados e tente novamente.';
  }
  
  /// Gets specific business logic error message
  static String _getBusinessMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('duplicata') || errorString.contains('duplicate')) {
      return 'Esta despesa já foi registrada.';
    }
    if (errorString.contains('limite') || errorString.contains('limit')) {
      return 'Valor da despesa excede o limite permitido.';
    }
    if (errorString.contains('animal') && errorString.contains('inativo')) {
      return 'Não é possível registrar despesas para um animal inativo.';
    }
    
    return 'Erro nas regras de negócio. Verifique os dados e tente novamente.';
  }
  
  /// Determines if an error should have retry capability
  static bool shouldRetry(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
      case ErrorCategory.storage:
        return true;
      case ErrorCategory.validation:
      case ErrorCategory.business:
      case ErrorCategory.system:
      case ErrorCategory.unknown:
        return false;
    }
  }
  
  /// Gets retry delay based on attempt number
  static Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff with jitter
    final baseDelay = Duration(seconds: 1 << (attemptNumber - 1));
    final jitter = Duration(milliseconds: 100 + (attemptNumber * 50));
    return baseDelay + jitter;
  }
  
  /// Main error handling method - use this for all error processing
  static DespesaErrorResult handleError(
    dynamic error, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final category = categorizeError(error);
    final severity = determineErrorSeverity(category, error);
    final userMessage = getUserFriendlyMessage(category, error);
    final canRetry = shouldRetry(category);
    
    // Log the error with context
    _logError(error, category, severity, context, additionalData);
    
    return DespesaErrorResult(
      category: category,
      severity: severity,
      userMessage: userMessage,
      canRetry: canRetry,
      originalError: error,
      context: context,
    );
  }
  
  /// Logs error with appropriate level based on severity
  static void _logError(
    dynamic error,
    ErrorCategory category,
    ErrorSeverity severity,
    String? context,
    Map<String, dynamic>? additionalData,
  ) {
    final logMessage = [
      '[$_tag]',
      if (context != null) '[$context]',
      '[${category.name.toUpperCase()}]',
      '[${severity.name.toUpperCase()}]',
      error.toString(),
      if (additionalData != null) 'Data: $additionalData',
    ].join(' ');
    
    switch (severity) {
      case ErrorSeverity.low:
        debugPrint('INFO: $logMessage');
        break;
      case ErrorSeverity.medium:
        debugPrint('WARNING: $logMessage');
        break;
      case ErrorSeverity.high:
        debugPrint('ERROR: $logMessage');
        break;
      case ErrorSeverity.critical:
        debugPrint('CRITICAL: $logMessage');
        // In a real app, you might want to send this to crash reporting
        break;
    }
  }
  
  /// Executes a function with automatic retry logic for retryable errors
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    String? context,
  }) async {
    int attempt = 1;
    
    while (attempt <= maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        final errorResult = handleError(
          error,
          context: context,
          additionalData: {'attempt': attempt, 'maxAttempts': maxAttempts},
        );
        
        if (!errorResult.canRetry || attempt >= maxAttempts) {
          rethrow;
        }
        
        final delay = getRetryDelay(attempt);
        debugPrint('[$_tag] Retrying in ${delay.inMilliseconds}ms (attempt $attempt/$maxAttempts)');
        await Future.delayed(delay);
        
        attempt++;
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
  
  /// Creates a user-friendly error dialog title based on category
  static String getErrorDialogTitle(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return 'Problema de Conexão';
      case ErrorCategory.validation:
        return 'Dados Inválidos';
      case ErrorCategory.storage:
        return 'Erro ao Salvar';
      case ErrorCategory.business:
        return 'Regra de Negócio';
      case ErrorCategory.system:
        return 'Erro do Sistema';
      case ErrorCategory.unknown:
        return 'Erro Inesperado';
    }
  }
  
  /// Gets appropriate icon for error category
  static String getErrorIcon(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return '🌐';
      case ErrorCategory.validation:
        return '⚠️';
      case ErrorCategory.storage:
        return '💾';
      case ErrorCategory.business:
        return '📋';
      case ErrorCategory.system:
        return '⚙️';
      case ErrorCategory.unknown:
        return '❓';
    }
  }
}

/// Result of error handling containing all relevant information
class DespesaErrorResult {
  final ErrorCategory category;
  final ErrorSeverity severity;
  final String userMessage;
  final bool canRetry;
  final dynamic originalError;
  final String? context;
  
  const DespesaErrorResult({
    required this.category,
    required this.severity,
    required this.userMessage,
    required this.canRetry,
    required this.originalError,
    this.context,
  });
  
  @override
  String toString() {
    return 'DespesaErrorResult(category: $category, severity: $severity, message: $userMessage, canRetry: $canRetry)';
  }
}

/// Helper extension for easy error handling
extension DespesaErrorHandling on Future {
  /// Handles errors automatically with the DespesaErrorHandler
  Future<T> handleDespesaErrors<T>({String? context}) async {
    try {
      return await this;
    } catch (error) {
      final errorResult = DespesaErrorHandler.handleError(error, context: context);
      throw DespesaErrorException(errorResult);
    }
  }
}

/// Custom exception that wraps the error result
class DespesaErrorException implements Exception {
  final DespesaErrorResult errorResult;
  
  const DespesaErrorException(this.errorResult);
  
  @override
  String toString() => errorResult.userMessage;
}
