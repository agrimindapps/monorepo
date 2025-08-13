// Dart imports:
import 'dart:async';
import 'dart:collection';

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Service para gerenciar operações concorrentes e evitar race conditions
class ConcurrencyService {
  static const ConcurrencyService _instance = ConcurrencyService._internal();
  factory ConcurrencyService() => _instance;
  const ConcurrencyService._internal();

  // Mapas para controlar operações em progresso
  static final Map<String, Completer<void>> _operationLocks = {};
  static final Map<String, Timer> _debounceTimers = {};
  static final Queue<Future<void> Function()> _operationQueue = Queue();
  static bool _processingQueue = false;
  static final Map<String, CancelToken> _cancelTokens = {};

  /// Executa uma operação com lock para evitar execução simultânea
  static Future<T> withLock<T>(
      String lockKey, Future<T> Function() operation) async {
    // Se já existe uma operação com essa chave, esperar ela completar
    if (_operationLocks.containsKey(lockKey)) {
      await _operationLocks[lockKey]!.future;
    }

    // Criar novo lock para esta operação
    final completer = Completer<void>();
    _operationLocks[lockKey] = completer;

    try {
      final result = await operation();
      return result;
    } finally {
      // Liberar o lock
      _operationLocks.remove(lockKey);
      completer.complete();
    }
  }

  /// Executa operação com debounce para evitar chamadas excessivas
  static void debounce(String key, Duration delay, VoidCallback operation) {
    // Cancelar timer anterior se existir
    _debounceTimers[key]?.cancel();

    // Criar novo timer
    _debounceTimers[key] = Timer(delay, () {
      _debounceTimers.remove(key);
      operation();
    });
  }

  /// Executa operação com debounce e retorna Future
  static Future<T> debounceAsync<T>(
      String key, Duration delay, Future<T> Function() operation) async {
    final completer = Completer<T>();

    // Cancelar timer anterior se existir
    _debounceTimers[key]?.cancel();

    // Criar novo timer
    _debounceTimers[key] = Timer(delay, () async {
      _debounceTimers.remove(key);
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Adiciona operação à fila de execução sequencial
  static Future<void> enqueue(Future<void> Function() operation) async {
    final completer = Completer<void>();

    _operationQueue.add(() async {
      try {
        await operation();
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    if (!_processingQueue) {
      _processQueue();
    }

    return completer.future;
  }

  /// Processa a fila de operações sequencialmente
  static Future<void> _processQueue() async {
    _processingQueue = true;

    while (_operationQueue.isNotEmpty) {
      final operation = _operationQueue.removeFirst();
      try {
        await operation();
      } catch (e) {
        // Log do erro mas continua processando outras operações
        debugPrint('Erro na operação da fila: $e');
      }
    }

    _processingQueue = false;
  }

  /// Cancela operação em progresso usando token
  static void cancelOperation(String tokenKey) {
    final token = _cancelTokens[tokenKey];
    if (token != null) {
      token.cancel();
      _cancelTokens.remove(tokenKey);
    }
  }

  /// Executa operação com token de cancelamento
  static Future<T> withCancelToken<T>(
      String tokenKey, Future<T> Function(CancelToken token) operation) async {
    // Cancelar operação anterior se existir
    cancelOperation(tokenKey);

    // Criar novo token
    final token = CancelToken();
    _cancelTokens[tokenKey] = token;

    try {
      final result = await operation(token);
      return result;
    } finally {
      _cancelTokens.remove(tokenKey);
    }
  }

  /// Executa múltiplas operações com timeout
  static Future<List<T>> executeWithTimeout<T>(
      List<Future<T>> futures, Duration timeout) async {
    try {
      return await Future.wait(futures).timeout(timeout);
    } on TimeoutException {
      throw Exception(
          'Operações excederam tempo limite de ${timeout.inSeconds}s');
    }
  }

  /// Limpa todos os recursos
  static void dispose() {
    // Cancelar todos os timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    // Cancelar todas as operações
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();

    // Limpar locks
    _operationLocks.clear();

    // Limpar fila
    _operationQueue.clear();
    _processingQueue = false;
  }

  /// Verifica se existe operação em progresso para uma chave
  static bool isOperationInProgress(String key) {
    return _operationLocks.containsKey(key);
  }

  /// Aguarda todas as operações pendentes completarem
  static Future<void> waitForAll() async {
    final pendingOperations =
        _operationLocks.values.map((c) => c.future).toList();
    if (pendingOperations.isNotEmpty) {
      await Future.wait(pendingOperations);
    }
  }
}

/// Token para cancelamento de operações
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const OperationCancelledException();
    }
  }
}

/// Exceção lançada quando operação é cancelada
class OperationCancelledException implements Exception {
  final String message;

  const OperationCancelledException([this.message = 'Operação cancelada']);

  @override
  String toString() => 'OperationCancelledException: $message';
}
