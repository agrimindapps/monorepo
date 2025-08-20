// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Service centralizado para tratamento de erros em operações assíncronas
/// 
/// Categoriza diferentes tipos de erro, fornece mensagens apropriadas ao usuário,
/// registra logs para debug e garante feedback visual consistente.
class ErrorHandlerService extends GetxService {
  
  // ========== SINGLETON PATTERN ==========
  
  static ErrorHandlerService? _instance;
  static ErrorHandlerService get instance => _instance ??= ErrorHandlerService._();
  ErrorHandlerService._();

  // ========== CONFIGURAÇÕES ==========
  
  /// Se deve mostrar detalhes técnicos ao usuário (apenas em debug)
  final bool _showTechnicalDetails = kDebugMode;
  
  /// Se deve registrar logs detalhados
  final bool _enableDetailedLogging = true;
  
  /// Duração padrão para snackbars de erro
  final Duration _snackbarDuration = const Duration(seconds: 4);

  // ========== INICIALIZAÇÃO ==========
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🚨 ErrorHandlerService: Inicializando sistema de tratamento de erros');
  }

  // ========== MÉTODOS PÚBLICOS ==========

  /// Trata erro de forma centralizada com feedback visual
  Future<void> handleError(
    dynamic error, {
    String? context,
    String? customMessage,
    bool showToUser = true,
    bool logError = true,
    VoidCallback? onRetry,
  }) async {
    final errorInfo = _categorizeError(error);
    
    if (logError) {
      _logError(error, context, errorInfo);
    }
    
    if (showToUser) {
      await _showErrorToUser(errorInfo, customMessage, onRetry);
    }
  }

  /// Trata erro com loading state específico
  Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
    String? customErrorMessage,
    bool showLoading = true,
    VoidCallback? onError,
  }) async {
    try {
      if (showLoading && operationName != null) {
        _showLoading(operationName);
      }
      
      final result = await operation();
      
      if (showLoading) {
        _hideLoading();
      }
      
      return result;
    } catch (error) {
      if (showLoading) {
        _hideLoading();
      }
      
      await handleError(
        error,
        context: operationName,
        customMessage: customErrorMessage,
      );
      
      onError?.call();
      return null;
    }
  }

  /// Executa operação com retry automático
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    String? operationName,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries) {
          await handleError(
            error,
            context: operationName,
            customMessage: 'Operação falhou após $maxRetries tentativas',
          );
          return null;
        }
        
        debugPrint('⏳ ErrorHandlerService: Tentativa ${attempts + 1} de $maxRetries para: $operationName');
        await Future.delayed(retryDelay);
      }
    }
    
    return null;
  }

  /// Valida se operação pode ser executada (conectividade, autenticação, etc.)
  Future<bool> validateOperation({
    bool requiresNetwork = true,
    bool requiresAuth = false,
    String? operationName,
  }) async {
    try {
      // Verificar conectividade
      if (requiresNetwork && !await _hasNetworkConnection()) {
        await _showNetworkError(operationName);
        return false;
      }
      
      // Verificar autenticação (se necessário)
      if (requiresAuth && !_isAuthenticated()) {
        await _showAuthError(operationName);
        return false;
      }
      
      return true;
    } catch (error) {
      await handleError(error, context: 'validateOperation');
      return false;
    }
  }

  // ========== MÉTODOS PRIVADOS - CATEGORIZAÇÃO ==========

  /// Categoriza erro para tratamento apropriado
  ErrorInfo _categorizeError(dynamic error) {
    if (error is SocketException) {
      return ErrorInfo(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        userMessage: 'Problema de conexão com a internet',
        technicalMessage: error.message,
        actionable: true,
      );
    }
    
    if (error is HttpException) {
      return ErrorInfo(
        type: ErrorType.server,
        severity: ErrorSeverity.medium,
        userMessage: 'Erro no servidor. Tente novamente em alguns instantes',
        technicalMessage: error.message,
        actionable: true,
      );
    }
    
    if (error is FormatException) {
      return ErrorInfo(
        type: ErrorType.data,
        severity: ErrorSeverity.low,
        userMessage: 'Dados inválidos recebidos',
        technicalMessage: error.message,
        actionable: false,
      );
    }
    
    if (error is TimeoutException) {
      return ErrorInfo(
        type: ErrorType.timeout,
        severity: ErrorSeverity.medium,
        userMessage: 'Operação demorou muito para responder',
        technicalMessage: error.toString(),
        actionable: true,
      );
    }
    
    if (error is StateError) {
      return ErrorInfo(
        type: ErrorType.state,
        severity: ErrorSeverity.medium,
        userMessage: 'Estado inválido da aplicação',
        technicalMessage: error.message,
        actionable: false,
      );
    }
    
    if (error is ArgumentError) {
      return ErrorInfo(
        type: ErrorType.validation,
        severity: ErrorSeverity.low,
        userMessage: 'Dados informados são inválidos',
        technicalMessage: error.message,
        actionable: true,
      );
    }
    
    // Erro genérico/desconhecido
    return ErrorInfo(
      type: ErrorType.unknown,
      severity: ErrorSeverity.high,
      userMessage: 'Ocorreu um erro inesperado',
      technicalMessage: error.toString(),
      actionable: false,
    );
  }

  // ========== MÉTODOS PRIVADOS - LOGGING ==========

  /// Registra erro para debug
  void _logError(dynamic error, String? context, ErrorInfo errorInfo) {
    if (!_enableDetailedLogging) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context ?? 'Unknown';
    
    debugPrint('🚨 ErrorHandlerService: [$timestamp] ERROR in $contextStr');
    debugPrint('   Type: ${errorInfo.type}');
    debugPrint('   Severity: ${errorInfo.severity}');
    debugPrint('   User Message: ${errorInfo.userMessage}');
    debugPrint('   Technical: ${errorInfo.technicalMessage}');
    debugPrint('   Actionable: ${errorInfo.actionable}');
    debugPrint('   Stack: ${StackTrace.current}');
    
    // TODO: Implementar envio de logs para serviço externo em produção
  }

  // ========== MÉTODOS PRIVADOS - UI FEEDBACK ==========

  /// Mostra erro ao usuário de forma apropriada
  Future<void> _showErrorToUser(ErrorInfo errorInfo, String? customMessage, VoidCallback? onRetry) async {
    final message = customMessage ?? errorInfo.userMessage;
    final title = _getErrorTitle(errorInfo.type);
    
    // Para erros críticos, mostrar dialog
    if (errorInfo.severity == ErrorSeverity.high) {
      await _showErrorDialog(title, message, errorInfo, onRetry);
    } else {
      // Para erros menos críticos, mostrar snackbar
      _showErrorSnackbar(title, message, errorInfo, onRetry);
    }
  }

  /// Mostra dialog de erro para casos críticos
  Future<void> _showErrorDialog(String title, String message, ErrorInfo errorInfo, VoidCallback? onRetry) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (_showTechnicalDetails && errorInfo.technicalMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Detalhes técnicos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                errorInfo.technicalMessage,
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null && errorInfo.actionable)
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text('Tentar Novamente'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Mostra snackbar de erro
  void _showErrorSnackbar(String title, String message, ErrorInfo errorInfo, VoidCallback? onRetry) {
    final context = Get.context;
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message),
          ],
        ),
        backgroundColor: _getErrorColor(errorInfo.severity),
        duration: _snackbarDuration,
        action: onRetry != null && errorInfo.actionable
            ? SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Mostra erro específico de rede
  Future<void> _showNetworkError(String? operationName) async {
    await _showErrorDialog(
      'Sem Conexão',
      'Verifique sua conexão com a internet e tente novamente.',
      ErrorInfo(
        type: ErrorType.network,
        severity: ErrorSeverity.medium,
        userMessage: 'Sem conexão com a internet',
        technicalMessage: 'Network not available for: $operationName',
        actionable: true,
      ),
      null,
    );
  }

  /// Mostra erro específico de autenticação
  Future<void> _showAuthError(String? operationName) async {
    await _showErrorDialog(
      'Não Autorizado',
      'Você precisa estar logado para realizar esta operação.',
      ErrorInfo(
        type: ErrorType.auth,
        severity: ErrorSeverity.medium,
        userMessage: 'Autenticação necessária',
        technicalMessage: 'Authentication required for: $operationName',
        actionable: true,
      ),
      null,
    );
  }

  // ========== MÉTODOS PRIVADOS - LOADING ==========

  /// Mostra indicador de loading
  void _showLoading(String operationName) {
    // TODO: Implementar loading overlay centralizado
    debugPrint('🔄 ErrorHandlerService: Loading: $operationName');
  }

  /// Esconde indicador de loading
  void _hideLoading() {
    // TODO: Implementar hide loading overlay centralizado
    debugPrint('✅ ErrorHandlerService: Loading hidden');
  }

  // ========== MÉTODOS PRIVADOS - VALIDAÇÕES ==========

  /// Verifica se há conexão de rede
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se usuário está autenticado
  bool _isAuthenticated() {
    // TODO: Implementar verificação real de autenticação
    return true;
  }

  // ========== MÉTODOS PRIVADOS - HELPERS ==========

  /// Obtém título apropriado para o tipo de erro
  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Erro de Conexão';
      case ErrorType.server:
        return 'Erro do Servidor';
      case ErrorType.data:
        return 'Erro de Dados';
      case ErrorType.timeout:
        return 'Tempo Esgotado';
      case ErrorType.auth:
        return 'Erro de Autenticação';
      case ErrorType.validation:
        return 'Dados Inválidos';
      case ErrorType.state:
        return 'Erro de Estado';
      case ErrorType.unknown:
        return 'Erro Inesperado';
    }
  }

  /// Obtém cor apropriada para a severidade do erro
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
    }
  }

  // ========== CLEANUP ==========

  @override
  void onClose() {
    debugPrint('🔚 ErrorHandlerService: Sistema de tratamento de erros finalizado');
    super.onClose();
  }
}

// ========== CLASSES DE APOIO ==========

/// Tipos de erro suportados
enum ErrorType {
  network,
  server,
  data,
  timeout,
  auth,
  validation,
  state,
  unknown,
}

/// Níveis de severidade do erro
enum ErrorSeverity {
  low,      // Aviso, não impede uso
  medium,   // Impede operação específica
  high,     // Crítico, pode afetar funcionamento
}

/// Informações detalhadas sobre um erro
class ErrorInfo {
  final ErrorType type;
  final ErrorSeverity severity;
  final String userMessage;
  final String technicalMessage;
  final bool actionable;

  ErrorInfo({
    required this.type,
    required this.severity,
    required this.userMessage,
    required this.technicalMessage,
    required this.actionable,
  });

  @override
  String toString() => 'ErrorInfo(type: $type, severity: $severity, actionable: $actionable)';
}

/// Exception customizada para timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}
