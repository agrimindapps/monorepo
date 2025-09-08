import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Gerenciador robusto de retry para operações de favoritos
/// Implementa estratégias de recuperação e fallbacks para operações críticas
class FavoritoRetryManager {
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(milliseconds: 100);

  /// Executa operação com retry automático e backoff exponencial
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    bool Function(dynamic)? shouldRetry,
    String? operationName,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 [Retry] Tentativa $attempt/$maxRetries para: ${operationName ?? 'operação'}');
        final result = await operation();
        
        if (attempt > 1) {
          debugPrint('✅ [Retry] Sucesso na tentativa $attempt para: ${operationName ?? 'operação'}');
        }
        
        return result;
      } catch (error) {
        final isLastAttempt = attempt == maxRetries;
        final shouldRetryOperation = shouldRetry?.call(error) ?? _defaultShouldRetry(error);
        
        debugPrint('❌ [Retry] Tentativa $attempt falhou para ${operationName ?? 'operação'}: $error');
        
        if (isLastAttempt || !shouldRetryOperation) {
          debugPrint('🚫 [Retry] Esgotadas tentativas para: ${operationName ?? 'operação'}');
          rethrow;
        }
        
        // Backoff exponencial com jitter
        final delay = _calculateDelay(attempt, baseDelay);
        debugPrint('⏳ [Retry] Aguardando ${delay.inMilliseconds}ms antes da próxima tentativa...');
        await Future<void>.delayed(delay);
      }
    }
    
    throw StateError('Retry loop terminou sem resultado');
  }

  /// Operação de favorito com retry específico
  static Future<bool> retryFavoritoOperation(
    Future<bool> Function() operation,
    String tipo,
    String itemId,
    String operationType,
  ) async {
    return withRetry<bool>(
      operation,
      operationName: '$operationType favorito $tipo:$itemId',
      shouldRetry: (error) => _isFavoritoRetryableError(error),
    );
  }

  /// Operação de leitura com retry
  static Future<T?> retryReadOperation<T>(
    Future<T?> Function() operation,
    String tipo,
    String itemId,
  ) async {
    return withRetry<T?>(
      operation,
      operationName: 'leitura favorito $tipo:$itemId',
      maxRetries: 2, // Menos tentativas para leitura
      shouldRetry: (error) => _isReadRetryableError(error),
    );
  }

  /// Operação batch com retry parcial
  static Future<List<T>> retryBatchOperation<T>(
    Future<List<T>> Function() operation,
    String operationName,
  ) async {
    return withRetry<List<T>>(
      operation,
      operationName: 'batch $operationName',
      maxRetries: 2,
      shouldRetry: (error) => _isBatchRetryableError(error),
    );
  }

  /// Calcula delay com backoff exponencial + jitter
  static Duration _calculateDelay(int attempt, Duration baseDelay) {
    // Backoff exponencial: baseDelay * (2 ^ (attempt - 1))
    final exponentialDelay = baseDelay * (1 << (attempt - 1));
    
    // Adiciona jitter (variação aleatória) para evitar thundering herd
    final jitterMs = (exponentialDelay.inMilliseconds * 0.1).round();
    final jitter = Duration(milliseconds: jitterMs);
    
    return exponentialDelay + jitter;
  }

  /// Determina se erro padrão é recuperável
  static bool _defaultShouldRetry(dynamic error) {
    if (error is HiveError) {
      return _isHiveRetryableError(error);
    }
    
    if (error is TimeoutException) {
      return true;
    }
    
    if (error is StateError) {
      return false; // Erros de estado geralmente não são recuperáveis
    }
    
    // Para outros erros, tenta uma vez
    return true;
  }

  /// Específico para erros de favoritos
  static bool _isFavoritoRetryableError(dynamic error) {
    if (error is HiveError) {
      return _isHiveRetryableError(error);
    }
    
    if (error is ArgumentError || error is FormatException) {
      return false; // Erros de dados não são recuperáveis
    }
    
    return _defaultShouldRetry(error);
  }

  /// Específico para erros de leitura
  static bool _isReadRetryableError(dynamic error) {
    if (error is HiveError) {
      return _isHiveRetryableError(error);
    }
    
    return error is TimeoutException;
  }

  /// Específico para erros de operações batch
  static bool _isBatchRetryableError(dynamic error) {
    // Operações batch são mais tolerantes a falhas
    return _defaultShouldRetry(error);
  }

  /// Classifica erros Hive como recuperáveis ou não
  static bool _isHiveRetryableError(HiveError error) {
    final message = error.message.toLowerCase();
    
    // Erros de concorrência - recuperáveis
    if (message.contains('box is already open') ||
        message.contains('database is locked') ||
        message.contains('busy')) {
      return true;
    }
    
    // Erros de corrupção - não recuperáveis
    if (message.contains('corrupt') ||
        message.contains('invalid') ||
        message.contains('malformed')) {
      return false;
    }
    
    // Por padrão, tenta recuperar
    return true;
  }
}

/// Exception customizada para operações de favoritos
class FavoritoOperationException implements Exception {
  final String message;
  final String tipo;
  final String itemId;
  final String operation;
  final dynamic originalError;
  final int attemptCount;

  const FavoritoOperationException({
    required this.message,
    required this.tipo,
    required this.itemId,
    required this.operation,
    this.originalError,
    this.attemptCount = 1,
  });

  @override
  String toString() => 
      'FavoritoOperationException: $message (tipo: $tipo, item: $itemId, op: $operation, tentativas: $attemptCount)';
}

/// Wrapper para operações críticas com logging
class FavoritoCriticalOperation {
  final String name;
  final String tipo;
  final String itemId;
  
  const FavoritoCriticalOperation({
    required this.name,
    required this.tipo,
    required this.itemId,
  });

  /// Executa operação crítica com full logging
  Future<T> execute<T>(Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('🚀 [Critical] Iniciando $name para $tipo:$itemId');
      
      final result = await FavoritoRetryManager.withRetry<T>(
        operation,
        operationName: '$name $tipo:$itemId',
      );
      
      stopwatch.stop();
      debugPrint('✅ [Critical] $name concluído em ${stopwatch.elapsedMilliseconds}ms');
      
      return result;
    } catch (error) {
      stopwatch.stop();
      debugPrint('💥 [Critical] $name falhou após ${stopwatch.elapsedMilliseconds}ms: $error');
      
      throw FavoritoOperationException(
        message: 'Operação crítica falhou: $name',
        tipo: tipo,
        itemId: itemId,
        operation: name,
        originalError: error,
      );
    }
  }
}