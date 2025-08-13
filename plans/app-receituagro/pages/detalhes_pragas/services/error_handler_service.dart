// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

/// Tipos de erro específicos para melhor categorização
enum ErrorType {
  network,
  server,
  data,
  validation,
  cache,
  unknown,
}

/// Exceções específicas para o módulo de detalhes de pragas
abstract class PragaException implements Exception {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  
  const PragaException(this.message, this.type, [this.originalError]);
  
  @override
  String toString() => 'PragaException($type): $message';
}

class DataLoadException extends PragaException {
  const DataLoadException(String message, [dynamic originalError])
      : super(message, ErrorType.data, originalError);
}

class RepositoryException extends PragaException {
  const RepositoryException(String message, [dynamic originalError])
      : super(message, ErrorType.server, originalError);
}

class NavigationException extends PragaException {
  const NavigationException(String message, [dynamic originalError])
      : super(message, ErrorType.validation, originalError);
}

class NetworkException extends PragaException {
  const NetworkException(String message, [dynamic originalError])
      : super(message, ErrorType.network, originalError);
}

class CacheException extends PragaException {
  const CacheException(String message, [dynamic originalError])
      : super(message, ErrorType.cache, originalError);
}

/// Níveis de logging estruturado
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Service para tratamento robusto de exceções e logging estruturado
class ErrorHandlerService extends GetxService {
  static const int maxRetryAttempts = 3;
  static const Duration baseRetryDelay = Duration(milliseconds: 1000);
  
  /// Logger estruturado com diferentes níveis
  void log(LogLevel level, String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'PragaDetails';
    final logMessage = '[$timestamp] [$level] [$logTag] $message';
    
    // Log metadata se fornecido
    if (metadata != null) {
      debugPrint('$logMessage - Metadata: $metadata');
    } else {
      debugPrint(logMessage);
    }
    
    // Log erro detalhado se fornecido
    if (error != null) {
      debugPrint('Error details: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    
    // Em produção, aqui você enviaria para serviços como Crashlytics, Sentry, etc.
    _sendToExternalLogging(level, message, error, stackTrace, metadata);
  }
  
  /// Executa operação com retry automático e backoff exponencial
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetryAttempts,
    Duration baseDelay = baseRetryDelay,
    String? operationName,
  }) async {
    int attempt = 0;
    
    while (attempt < maxAttempts) {
      try {
        log(LogLevel.debug, 'Tentativa ${attempt + 1}/$maxAttempts para $operationName');
        return await operation();
      } catch (e, stackTrace) {
        attempt++;
        
        if (attempt >= maxAttempts) {
          log(
            LogLevel.error,
            'Operação falhou após $maxAttempts tentativas: $operationName',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
        
        // Calcula delay com backoff exponencial
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * pow(2, attempt).toInt(),
        );
        
        log(
          LogLevel.warning,
          'Tentativa $attempt falhou para $operationName, tentando novamente em ${delay.inMilliseconds}ms',
          error: e,
        );
        
        await Future.delayed(delay);
      }
    }
    
    throw StateError('Método withRetry não deveria chegar aqui');
  }
  
  /// Trata exceções com recuperação graceful
  Future<T?> handleWithFallback<T>(
    Future<T> Function() operation,
    T? Function() fallback, {
    String? operationName,
    bool showUserMessage = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      log(
        LogLevel.error,
        'Operação falhou: $operationName',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Tenta fallback
      try {
        final fallbackResult = fallback();
        if (fallbackResult != null) {
          log(LogLevel.info, 'Fallback bem-sucedido para $operationName');
          
          if (showUserMessage) {
            _showUserMessage(
              'Dados carregados do cache',
              'Os dados mais recentes não estão disponíveis, mas encontramos dados salvos anteriormente.',
              isWarning: true,
            );
          }
        }
        return fallbackResult;
      } catch (fallbackError, fallbackStackTrace) {
        log(
          LogLevel.error,
          'Fallback também falhou para $operationName',
          error: fallbackError,
          stackTrace: fallbackStackTrace,
        );
        
        if (showUserMessage) {
          _showUserErrorMessage(e);
        }
        
        return null;
      }
    }
  }
  
  /// Mostra mensagem de erro específica para o usuário com ação de retry
  void showUserErrorWithRetry(
    dynamic error, 
    VoidCallback onRetry, {
    String? customMessage,
  }) {
    String title = 'Erro';
    String message = customMessage ?? 'Algo deu errado. Tente novamente.';
    Color backgroundColor = Get.theme.colorScheme.error;
    
    if (error is PragaException) {
      switch (error.type) {
        case ErrorType.network:
          title = 'Sem conexão';
          message = 'Verifique sua conexão com a internet e tente novamente.';
          backgroundColor = Colors.red.shade600;
          break;
        case ErrorType.server:
          title = 'Servidor indisponível';
          message = 'Nossos servidores estão temporariamente indisponíveis.';
          backgroundColor = Colors.orange.shade600;
          break;
        case ErrorType.data:
          title = 'Dados corrompidos';
          message = 'Os dados estão corrompidos. Tentando recarregar...';
          backgroundColor = Colors.purple.shade600;
          break;
        case ErrorType.validation:
          title = 'Dados inválidos';
          message = 'Os dados fornecidos são inválidos.';
          backgroundColor = Colors.amber.shade600;
          break;
        case ErrorType.cache:
          title = 'Erro de cache';
          message = 'Problema com dados salvos. Limpando cache...';
          backgroundColor = Colors.blue.shade600;
          break;
        case ErrorType.unknown:
          backgroundColor = Colors.grey.shade600;
          break;
      }
    }
    
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      mainButton: TextButton.icon(
        onPressed: () {
          Get.back();
          onRetry();
        },
        icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
        label: const Text(
          'Tentar novamente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  /// Mostra mensagem de erro específica para o usuário
  void _showUserErrorMessage(dynamic error) {
    String title = 'Erro';
    String message = 'Algo deu errado. Tente novamente.';
    
    if (error is PragaException) {
      switch (error.type) {
        case ErrorType.network:
          title = 'Sem conexão';
          message = 'Verifique sua conexão com a internet e tente novamente.';
          break;
        case ErrorType.server:
          title = 'Servidor indisponível';
          message = 'Nossos servidores estão temporariamente indisponíveis.';
          break;
        case ErrorType.data:
          title = 'Dados corrompidos';
          message = 'Os dados estão corrompidos. Tentando recarregar...';
          break;
        case ErrorType.validation:
          title = 'Dados inválidos';
          message = 'Os dados fornecidos são inválidos.';
          break;
        case ErrorType.cache:
          title = 'Erro de cache';
          message = 'Problema com dados salvos. Limpando cache...';
          break;
        case ErrorType.unknown:
          // Usa mensagem padrão
          break;
      }
    }
    
    Get.snackbar(
      title,
      message,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'Tentar novamente',
          style: TextStyle(color: Get.theme.colorScheme.onError),
        ),
      ),
    );
  }
  
  /// Mostra mensagem informativa para o usuário
  void _showUserMessage(String title, String message, {bool isWarning = false}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isWarning 
          ? Get.theme.colorScheme.secondary 
          : Get.theme.colorScheme.primary,
      colorText: isWarning 
          ? Get.theme.colorScheme.onSecondary 
          : Get.theme.colorScheme.onPrimary,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Simula envio para serviços externos de logging
  void _sendToExternalLogging(
    LogLevel level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  ) {
    // Em produção, aqui você integraria com:
    // - Firebase Crashlytics
    // - Sentry
    // - DataDog
    // - Ou outro serviço de logging
    
    // Por enquanto, apenas log local em modo debug
    if (kDebugMode && level.index >= LogLevel.error.index) {
      debugPrint('🚨 EXTERNAL LOG: $level - $message');
      if (error != null) {
        debugPrint('🚨 ERROR DETAILS: $error');
      }
    }
  }
  
  /// Cria exceção específica baseada no tipo de erro
  PragaException createException(
    String message,
    dynamic originalError, {
    ErrorType? type,
  }) {
    final errorType = type ?? _inferErrorType(originalError);
    
    switch (errorType) {
      case ErrorType.network:
        return NetworkException(message, originalError);
      case ErrorType.server:
        return RepositoryException(message, originalError);
      case ErrorType.data:
        return DataLoadException(message, originalError);
      case ErrorType.validation:
        return NavigationException(message, originalError);
      case ErrorType.cache:
        return CacheException(message, originalError);
      case ErrorType.unknown:
        return DataLoadException(message, originalError);
    }
  }
  
  /// Infere o tipo de erro baseado na exceção original
  ErrorType _inferErrorType(dynamic error) {
    if (error == null) return ErrorType.unknown;
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socket') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return ErrorType.network;
    }
    
    if (errorString.contains('server') || 
        errorString.contains('http') ||
        errorString.contains('timeout')) {
      return ErrorType.server;
    }
    
    if (errorString.contains('cache') || 
        errorString.contains('storage')) {
      return ErrorType.cache;
    }
    
    if (errorString.contains('format') || 
        errorString.contains('parse') ||
        errorString.contains('json')) {
      return ErrorType.data;
    }
    
    return ErrorType.unknown;
  }
}
