// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Tipos de erro classificados para tratamento específico
enum ErrorType {
  network,
  validation,
  storage,
  permission,
  timeout,
  database,
  image,
  unknown,
}

/// Contexto para melhor tratamento de erro
enum ErrorContext {
  plantCreation,
  imageSelection,
  spaceLoading,
  spaceCreation,
  formValidation,
  dataLoading,
}

/// Modelo para representar erros estruturados
class AppError {
  final ErrorType type;
  final ErrorContext context;
  final String message;
  final String? technicalMessage;
  final String? userFriendlyMessage;
  final bool canRetry;
  final VoidCallback? retryAction;
  final Exception? originalException;

  const AppError({
    required this.type,
    required this.context,
    required this.message,
    this.technicalMessage,
    this.userFriendlyMessage,
    this.canRetry = false,
    this.retryAction,
    this.originalException,
  });

  String get displayMessage => userFriendlyMessage ?? message;
}

/// Service centralizado para tratamento de erros
class ErrorHandlerService {
  static const ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  const ErrorHandlerService._internal();

  /// Trata erro e retorna AppError estruturado
  static AppError handleError(
    Exception exception,
    ErrorContext context, {
    VoidCallback? retryAction,
  }) {
    final errorMessage = exception.toString();

    // Classificar tipo de erro baseado na mensagem
    final errorType = _classifyError(errorMessage);

    // Gerar mensagem amigável ao usuário
    final userMessage = _generateUserFriendlyMessage(errorType, context);

    // Determinar se pode tentar novamente
    final canRetry = _canRetryError(errorType);

    final appError = AppError(
      type: errorType,
      context: context,
      message: errorMessage,
      technicalMessage: errorMessage,
      userFriendlyMessage: userMessage,
      canRetry: canRetry,
      retryAction: canRetry ? retryAction : null,
      originalException: exception,
    );

    // Log estruturado para debug
    _logError(appError);

    return appError;
  }

  /// Mostra erro para o usuário de forma consistente
  static void showError(AppError error) {
    if (Get.context == null) return;

    // Para erros críticos, mostrar dialog
    if (_isCriticalError(error.type)) {
      _showErrorDialog(error);
    } else {
      // Para erros menores, mostrar snackbar
      _showErrorSnackbar(error);
    }
  }

  /// Trata erro de forma completa (handle + show)
  static void processError(
    Exception exception,
    ErrorContext context, {
    VoidCallback? retryAction,
  }) {
    final appError = handleError(exception, context, retryAction: retryAction);
    showError(appError);
  }

  static ErrorType _classifyError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();

    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection')) {
      return ErrorType.network;
    }
    if (lowerMessage.contains('timeout')) {
      return ErrorType.timeout;
    }
    if (lowerMessage.contains('permission') ||
        lowerMessage.contains('denied')) {
      return ErrorType.permission;
    }
    if (lowerMessage.contains('storage') || lowerMessage.contains('space')) {
      return ErrorType.storage;
    }
    if (lowerMessage.contains('database') || lowerMessage.contains('sql')) {
      return ErrorType.database;
    }
    if (lowerMessage.contains('image') || lowerMessage.contains('photo')) {
      return ErrorType.image;
    }
    if (lowerMessage.contains('validation') ||
        lowerMessage.contains('invalid')) {
      return ErrorType.validation;
    }

    return ErrorType.unknown;
  }

  static String _generateUserFriendlyMessage(
      ErrorType type, ErrorContext context) {
    switch (type) {
      case ErrorType.network:
        return _getNetworkMessage(context);
      case ErrorType.timeout:
        return 'A operação demorou mais que o esperado. Verifique sua conexão e tente novamente.';
      case ErrorType.permission:
        return _getPermissionMessage(context);
      case ErrorType.storage:
        return 'Não há espaço suficiente no dispositivo. Libere espaço e tente novamente.';
      case ErrorType.database:
        return 'Erro interno do aplicativo. Tente fechar e abrir o app novamente.';
      case ErrorType.image:
        return _getImageMessage(context);
      case ErrorType.validation:
        return _getValidationMessage(context);
      case ErrorType.unknown:
        return _getUnknownMessage(context);
    }
  }

  static String _getNetworkMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.spaceLoading:
        return 'Não foi possível carregar os espaços. Verifique sua conexão.';
      case ErrorContext.plantCreation:
        return 'Não foi possível salvar a planta. Verifique sua conexão.';
      default:
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
  }

  static String _getPermissionMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.imageSelection:
        return 'Permissão negada para acessar fotos. Verifique as configurações do app.';
      default:
        return 'Permissão necessária foi negada. Verifique as configurações.';
    }
  }

  static String _getImageMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.imageSelection:
        return 'Não foi possível processar a imagem. Tente com outra foto.';
      default:
        return 'Erro ao processar imagem. Verifique o formato e tamanho.';
    }
  }

  static String _getValidationMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.formValidation:
        return 'Alguns campos precisam ser corrigidos antes de continuar.';
      case ErrorContext.plantCreation:
        return 'Dados da planta inválidos. Verifique as informações inseridas.';
      default:
        return 'Dados inválidos. Verifique as informações e tente novamente.';
    }
  }

  static String _getUnknownMessage(ErrorContext context) {
    switch (context) {
      case ErrorContext.plantCreation:
        return 'Não foi possível criar a planta. Tente novamente.';
      case ErrorContext.spaceCreation:
        return 'Não foi possível criar o espaço. Tente novamente.';
      case ErrorContext.imageSelection:
        return 'Não foi possível selecionar a imagem. Tente novamente.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  static bool _canRetryError(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.unknown:
      case ErrorType.image:
        return true;
      case ErrorType.permission:
      case ErrorType.storage:
      case ErrorType.validation:
      case ErrorType.database:
        return false;
    }
  }

  static bool _isCriticalError(ErrorType type) {
    switch (type) {
      case ErrorType.database:
      case ErrorType.storage:
        return true;
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.permission:
      case ErrorType.image:
      case ErrorType.validation:
      case ErrorType.unknown:
        return false;
    }
  }

  static void _showErrorDialog(AppError error) {
    if (Get.context == null) return;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Erro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.displayMessage),
            if (kDebugMode && error.technicalMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                'Detalhes técnicos: ${error.technicalMessage}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (error.canRetry && error.retryAction != null)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                error.retryAction!();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showErrorSnackbar(AppError error) {
    Get.snackbar(
      'Erro',
      error.displayMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      mainButton: error.canRetry && error.retryAction != null
          ? TextButton(
              onPressed: error.retryAction,
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
    );
  }

  static void _logError(AppError error) {
    debugPrint('🚨 [ERROR] ${error.context.name}');
    debugPrint('   Type: ${error.type.name}');
    debugPrint('   Message: ${error.message}');
    debugPrint('   User Message: ${error.displayMessage}');
    debugPrint('   Can Retry: ${error.canRetry}');
    if (error.originalException != null) {
      debugPrint('   Original: ${error.originalException}');
    }
  }

  /// Mostra sucesso de forma consistente
  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Sucesso',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF20B2AA),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  /// Mostra aviso de forma consistente
  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Atenção',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.warning_outlined,
        color: Colors.white,
      ),
    );
  }
}
