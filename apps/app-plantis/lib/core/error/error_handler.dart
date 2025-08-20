import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'app_error.dart';

/// Centralizador para tratamento de erros da aplicação
/// Responsável por logging, reporting e notificação de erros
class ErrorHandler {
  static ErrorHandler? _instance;
  
  /// Singleton instance
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  
  ErrorHandler._();

  final List<ErrorListener> _listeners = [];
  final List<AppError> _errorHistory = [];
  final int _maxHistorySize = 100;

  /// Adiciona um listener para erros
  void addListener(ErrorListener listener) {
    _listeners.add(listener);
  }

  /// Remove um listener
  void removeListener(ErrorListener listener) {
    _listeners.remove(listener);
  }

  /// Trata um erro capturado
  void handleError(AppError error) {
    // Adiciona ao histórico
    _addToHistory(error);
    
    // Log do erro
    _logError(error);
    
    // Notifica listeners
    _notifyListeners(error);
    
    // Report para serviços externos (Crashlytics, etc.)
    _reportToExternalServices(error);
  }

  /// Cria um erro a partir de uma exceção
  AppError createErrorFromException(
    dynamic exception,
    StackTrace stackTrace, {
    String? customMessage,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    String message = customMessage ?? 'Erro inesperado';
    
    if (exception is AppError) {
      return exception;
    }
    
    // Mapear exceções conhecidas para tipos específicos de erro
    if (exception is ArgumentError || 
        exception is FormatException ||
        exception is RangeError) {
      return ValidationError(
        message: customMessage ?? 'Erro de validação: ${exception.toString()}',
        details: exception.toString(),
        stackTrace: stackTrace,
        severity: severity,
      );
    }
    
    if (exception is StateError) {
      return BusinessError(
        message: customMessage ?? 'Estado inválido: ${exception.toString()}',
        details: exception.toString(),
        stackTrace: stackTrace,
        severity: severity,
      );
    }
    
    // Erro genérico
    return UnknownError(
      message: '$message: ${exception.toString()}',
      details: exception.toString(),
      stackTrace: stackTrace,
      severity: severity,
      originalError: exception,
    );
  }

  /// Reporta um erro para análise posterior
  void reportError(AppError error) {
    handleError(error);
    
    // Pode ser expandido para enviar relatórios específicos
    if (kDebugMode) {
      developer.log(
        'Error reported by user',
        error: error.message,
        stackTrace: error.stackTrace,
      );
    }
  }

  /// Obtém histórico de erros
  List<AppError> getErrorHistory() {
    return List.unmodifiable(_errorHistory);
  }

  /// Limpa o histórico de erros
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Obtém estatísticas de erros
  ErrorStatistics getStatistics() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last7days = now.subtract(const Duration(days: 7));
    
    final recent24h = _errorHistory.where((e) => e.timestamp.isAfter(last24h)).length;
    final recent7days = _errorHistory.where((e) => e.timestamp.isAfter(last7days)).length;
    
    final byCategory = <ErrorCategory, int>{};
    final bySeverity = <ErrorSeverity, int>{};
    
    for (final error in _errorHistory) {
      byCategory[error.category] = (byCategory[error.category] ?? 0) + 1;
      bySeverity[error.severity] = (bySeverity[error.severity] ?? 0) + 1;
    }
    
    return ErrorStatistics(
      totalErrors: _errorHistory.length,
      errorsLast24h: recent24h,
      errorsLast7days: recent7days,
      errorsByCategory: byCategory,
      errorsBySeverity: bySeverity,
      mostRecentError: _errorHistory.isNotEmpty ? _errorHistory.last : null,
    );
  }

  void _addToHistory(AppError error) {
    _errorHistory.add(error);
    
    // Limita o tamanho do histórico
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }
  }

  void _logError(AppError error) {
    final logMessage = '[${error.category.name.toUpperCase()}] ${error.message}';
    
    switch (error.severity) {
      case ErrorSeverity.low:
        developer.log(logMessage, level: 500); // INFO
        break;
      case ErrorSeverity.medium:
        developer.log(logMessage, level: 900); // WARNING
        break;
      case ErrorSeverity.high:
        developer.log(logMessage, level: 1000, error: error.details); // ERROR
        break;
      case ErrorSeverity.critical:
        developer.log(
          logMessage,
          level: 1200, // SEVERE
          error: error.details,
          stackTrace: error.stackTrace,
        );
        break;
    }
    
    // Debug log detalhado
    if (kDebugMode) {
      developer.log(
        'Error Details: ${error.toMap()}',
        name: 'ErrorHandler',
      );
    }
  }

  void _notifyListeners(AppError error) {
    for (final listener in _listeners) {
      try {
        listener.onError(error);
      } catch (e) {
        // Evita loop infinito se o listener falhar
        developer.log(
          'Error in ErrorListener: $e',
          name: 'ErrorHandler',
          level: 1000,
        );
      }
    }
  }

  void _reportToExternalServices(AppError error) {
    // TODO: Integrar com Crashlytics ou outros serviços
    // Exemplo:
    // if (error.severity == ErrorSeverity.critical) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error,
    //     error.stackTrace,
    //     fatal: true,
    //   );
    // }
  }
}

/// Interface para listeners de erro
abstract class ErrorListener {
  void onError(AppError error);
}

/// Estatísticas de erros
class ErrorStatistics {
  final int totalErrors;
  final int errorsLast24h;
  final int errorsLast7days;
  final Map<ErrorCategory, int> errorsByCategory;
  final Map<ErrorSeverity, int> errorsBySeverity;
  final AppError? mostRecentError;

  const ErrorStatistics({
    required this.totalErrors,
    required this.errorsLast24h,
    required this.errorsLast7days,
    required this.errorsByCategory,
    required this.errorsBySeverity,
    this.mostRecentError,
  });
}

/// Implementação de ErrorListener que mostra notificações
class NotificationErrorListener implements ErrorListener {
  final void Function(String message, {bool isError}) showNotification;

  const NotificationErrorListener(this.showNotification);

  @override
  void onError(AppError error) {
    // Só mostra notificação para erros de severidade média ou alta
    if (error.severity == ErrorSeverity.medium || 
        error.severity == ErrorSeverity.high ||
        error.severity == ErrorSeverity.critical) {
      
      String message = _getUserFriendlyMessage(error);
      showNotification(message, isError: true);
    }
  }

  String _getUserFriendlyMessage(AppError error) {
    switch (error.category) {
      case ErrorCategory.network:
        return 'Problema de conectividade. Verifique sua internet.';
      case ErrorCategory.authentication:
        return 'Problema de autenticação. Faça login novamente.';
      case ErrorCategory.validation:
        return 'Dados inválidos informados.';
      case ErrorCategory.storage:
        return 'Problema ao salvar dados localmente.';
      case ErrorCategory.permission:
        return 'Permissão necessária não foi concedida.';
      case ErrorCategory.business:
        return error.message; // Mensagens de negócio são user-friendly
      case ErrorCategory.external:
        return 'Serviço temporariamente indisponível.';
      case ErrorCategory.general:
      default:
        return 'Ops! Algo inesperado aconteceu.';
    }
  }
}