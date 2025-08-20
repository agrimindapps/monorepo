// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'specific_error_types.dart';

/// Serviço para tratamento específico de erros
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  final Map<Type, ErrorHandler> _handlers = {};
  final List<ErrorLog> _errorLogs = [];

  /// Registra um handler para um tipo específico de erro
  void registerHandler<T extends PluviometroException>(
      ErrorHandler<T> handler) {
    _handlers[T] = handler;
  }

  /// Trata um erro específico
  Future<ErrorResult> handleError(Exception error,
      {BuildContext? context}) async {
    final errorLog = ErrorLog(
      error: error,
      timestamp: DateTime.now(),
      context: context != null ? 'UI Context' : 'Background',
    );

    _errorLogs.add(errorLog);

    // Limita o log a 100 entradas
    if (_errorLogs.length > 100) {
      _errorLogs.removeAt(0);
    }

    if (error is PluviometroException) {
      final handler =
          _handlers[error.runtimeType];
      if (handler != null) {
        return await handler.handle(error, context: context);
      }
    }

    // Handler padrão para erros não específicos
    return _handleGenericError(error, context: context);
  }

  /// Trata erro genérico
  ErrorResult _handleGenericError(Exception error, {BuildContext? context}) {
    final userMessage = _getGenericUserMessage(error);

    if (context != null) {
      _showErrorSnackBar(context, userMessage);
    }

    return ErrorResult(
      isRecoverable: false,
      userMessage: userMessage,
      shouldRetry: false,
      logLevel: LogLevel.error,
    );
  }

  /// Obtém mensagem user-friendly para erro genérico
  String _getGenericUserMessage(Exception error) {
    final message = error.toString();

    if (message.contains('network') || message.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    if (message.contains('timeout')) {
      return 'Operação demorou muito para responder. Tente novamente.';
    }

    if (message.contains('permission')) {
      return 'Permissão negada. Verifique as configurações do aplicativo.';
    }

    return 'Erro inesperado. Tente novamente ou contate o suporte.';
  }

  /// Mostra erro via SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Mostra erro via Dialog
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Executa operação com tratamento de erro automático
  Future<T?> executeWithErrorHandling<T>(Future<T> Function() operation,
      {BuildContext? context}) async {
    try {
      return await operation();
    } catch (error) {
      if (error is Exception) {
        await handleError(error, context: context);
      } else {
        await handleError(
            SystemException(
              component: 'ExecuteWithErrorHandling',
              message: 'Erro não identificado: $error',
            ),
            context: context);
      }
      return null;
    }
  }

  /// Executa operação com retry automático
  Future<T?> executeWithRetry<T>(Future<T> Function() operation,
      {int maxRetries = 3,
      Duration delay = const Duration(seconds: 1),
      BuildContext? context}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;

        if (attempts >= maxRetries) {
          if (error is Exception) {
            await handleError(error, context: context);
          }
          return null;
        }

        // Delay antes da próxima tentativa
        await Future.delayed(delay);
      }
    }

    return null;
  }

  /// Registra handlers padrão
  void registerDefaultHandlers() {
    registerHandler(ValidationErrorHandler());
    registerHandler(PersistenceErrorHandler());
    registerHandler(NetworkErrorHandler());
    registerHandler(TimeoutErrorHandler());
    registerHandler(PermissionErrorHandler());
    registerHandler(DuplicateErrorHandler());
  }

  /// Obtém estatísticas de erro
  ErrorStats getErrorStats() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));
    final lastDay = now.subtract(const Duration(days: 1));

    final errorsLastHour =
        _errorLogs.where((log) => log.timestamp.isAfter(lastHour)).length;
    final errorsLastDay =
        _errorLogs.where((log) => log.timestamp.isAfter(lastDay)).length;

    final errorsByType = <String, int>{};
    for (final log in _errorLogs) {
      final type = log.error.runtimeType.toString();
      errorsByType[type] = (errorsByType[type] ?? 0) + 1;
    }

    return ErrorStats(
      totalErrors: _errorLogs.length,
      errorsLastHour: errorsLastHour,
      errorsLastDay: errorsLastDay,
      errorsByType: errorsByType,
    );
  }

  /// Limpa logs de erro
  void clearErrorLogs() {
    _errorLogs.clear();
  }

  /// Obtém logs de erro
  List<ErrorLog> getErrorLogs() {
    return List.from(_errorLogs);
  }
}

/// Interface para handlers de erro
abstract class ErrorHandler<T extends PluviometroException> {
  Future<ErrorResult> handle(T error, {BuildContext? context});
}

/// Handler para erros de validação
class ValidationErrorHandler extends ErrorHandler<ValidationException> {
  @override
  Future<ErrorResult> handle(ValidationException error,
      {BuildContext? context}) async {
    final userMessage = 'Erro de validação: ${error.message}';

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return ErrorResult(
      isRecoverable: true,
      userMessage: userMessage,
      shouldRetry: false,
      logLevel: LogLevel.warning,
    );
  }
}

/// Handler para erros de persistência
class PersistenceErrorHandler extends ErrorHandler<PersistenceException> {
  @override
  Future<ErrorResult> handle(PersistenceException error,
      {BuildContext? context}) async {
    const userMessage = 'Erro ao salvar dados. Tente novamente.';

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(userMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Tentar Novamente',
            textColor: Colors.white,
            onPressed: () {
              // Callback para retry seria implementado aqui
            },
          ),
        ),
      );
    }

    return ErrorResult(
      isRecoverable: true,
      userMessage: userMessage,
      shouldRetry: true,
      logLevel: LogLevel.error,
    );
  }
}

/// Handler para erros de rede
class NetworkErrorHandler extends ErrorHandler<NetworkException> {
  @override
  Future<ErrorResult> handle(NetworkException error,
      {BuildContext? context}) async {
    const userMessage = 'Erro de conexão. Verifique sua internet.';

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }

    return ErrorResult(
      isRecoverable: true,
      userMessage: userMessage,
      shouldRetry: true,
      logLevel: LogLevel.error,
    );
  }
}

/// Handler para erros de timeout
class TimeoutErrorHandler extends ErrorHandler<TimeoutException> {
  @override
  Future<ErrorResult> handle(TimeoutException error,
      {BuildContext? context}) async {
    const userMessage = 'Operação demorou muito. Tente novamente.';

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }

    return ErrorResult(
      isRecoverable: true,
      userMessage: userMessage,
      shouldRetry: true,
      logLevel: LogLevel.warning,
    );
  }
}

/// Handler para erros de permissão
class PermissionErrorHandler extends ErrorHandler<PermissionException> {
  @override
  Future<ErrorResult> handle(PermissionException error,
      {BuildContext? context}) async {
    final userMessage = 'Permissão necessária: ${error.permission}';

    if (context != null) {
      ErrorHandlerService().showErrorDialog(
        context,
        'Permissão Necessária',
        'Esta operação requer a permissão: ${error.permission}',
      );
    }

    return ErrorResult(
      isRecoverable: false,
      userMessage: userMessage,
      shouldRetry: false,
      logLevel: LogLevel.warning,
    );
  }
}

/// Handler para erros de duplicação
class DuplicateErrorHandler extends ErrorHandler<DuplicateException> {
  @override
  Future<ErrorResult> handle(DuplicateException error,
      {BuildContext? context}) async {
    final userMessage = 'Valor já existe: ${error.duplicateValue}';

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return ErrorResult(
      isRecoverable: true,
      userMessage: userMessage,
      shouldRetry: false,
      logLevel: LogLevel.warning,
    );
  }
}

/// Resultado do tratamento de erro
class ErrorResult {
  final bool isRecoverable;
  final String userMessage;
  final bool shouldRetry;
  final LogLevel logLevel;

  ErrorResult({
    required this.isRecoverable,
    required this.userMessage,
    required this.shouldRetry,
    required this.logLevel,
  });
}

/// Log de erro
class ErrorLog {
  final Exception error;
  final DateTime timestamp;
  final String context;

  ErrorLog({
    required this.error,
    required this.timestamp,
    required this.context,
  });
}

/// Estatísticas de erro
class ErrorStats {
  final int totalErrors;
  final int errorsLastHour;
  final int errorsLastDay;
  final Map<String, int> errorsByType;

  ErrorStats({
    required this.totalErrors,
    required this.errorsLastHour,
    required this.errorsLastDay,
    required this.errorsByType,
  });
}

/// Níveis de log
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}
