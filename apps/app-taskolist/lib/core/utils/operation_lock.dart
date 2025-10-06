import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mutex/Lock implementation para prevenir race conditions
/// Garante que operações críticas sejam executadas atomicamente
class OperationLock {
  final Map<String, Completer<void>> _locks = {};
  final Map<String, int> _lockCounts = {};
  final Map<String, DateTime> _lockTimestamps = {};
  final Duration _defaultTimeout;
  
  OperationLock({
    Duration defaultTimeout = const Duration(seconds: 30),
  }) : _defaultTimeout = defaultTimeout;

  /// Adquire um lock para uma operação específica
  /// Retorna um [LockGuard] que deve ser disposed após uso
  Future<LockGuard> acquire(
    String key, {
    Duration? timeout,
    bool reentrant = false,
  }) async {
    final effectiveTimeout = timeout ?? _defaultTimeout;
    if (reentrant && _locks.containsKey(key)) {
      _lockCounts[key] = (_lockCounts[key] ?? 0) + 1;
      return LockGuard._(this, key, reentrant: true);
    }
    while (_locks.containsKey(key)) {
      final existingLock = _locks[key]!;
      final lockTimestamp = _lockTimestamps[key];
      if (lockTimestamp != null) {
        final elapsed = DateTime.now().difference(lockTimestamp);
        if (elapsed > effectiveTimeout) {
          if (kDebugMode) {
            print('Warning: Lock $key expired after $elapsed');
          }
          _releaseLock(key);
          break;
        }
      }
      try {
        await existingLock.future.timeout(
          effectiveTimeout,
          onTimeout: () {
            throw TimeoutException('Lock acquisition timeout for $key');
          },
        );
      } catch (e) {
        if (e is TimeoutException) {
          _releaseLock(key);
          break;
        }
      }
    }
    final completer = Completer<void>();
    _locks[key] = completer;
    _lockCounts[key] = 1;
    _lockTimestamps[key] = DateTime.now();
    
    return LockGuard._(this, key);
  }

  /// Tenta adquirir um lock sem aguardar
  /// Retorna null se o lock não está disponível
  LockGuard? tryAcquire(String key, {bool reentrant = false}) {
    if (reentrant && _locks.containsKey(key)) {
      _lockCounts[key] = (_lockCounts[key] ?? 0) + 1;
      return LockGuard._(this, key, reentrant: true);
    }
    if (_locks.containsKey(key)) {
      return null;
    }
    final completer = Completer<void>();
    _locks[key] = completer;
    _lockCounts[key] = 1;
    _lockTimestamps[key] = DateTime.now();
    
    return LockGuard._(this, key);
  }

  /// Executa uma operação com lock automático
  Future<T> synchronized<T>(
    String key,
    Future<T> Function() operation, {
    Duration? timeout,
    bool reentrant = false,
  }) async {
    final guard = await acquire(key, timeout: timeout, reentrant: reentrant);
    try {
      return await operation();
    } finally {
      guard.release();
    }
  }

  /// Tenta executar uma operação com lock
  /// Retorna null se o lock não está disponível
  Future<T?> trySynchronized<T>(
    String key,
    Future<T> Function() operation, {
    bool reentrant = false,
  }) async {
    final guard = tryAcquire(key, reentrant: reentrant);
    if (guard == null) return null;
    
    try {
      return await operation();
    } finally {
      guard.release();
    }
  }

  /// Libera um lock específico (uso interno)
  void _releaseLock(String key) {
    final count = _lockCounts[key] ?? 0;
    
    if (count > 1) {
      _lockCounts[key] = count - 1;
    } else {
      final completer = _locks.remove(key);
      _lockCounts.remove(key);
      _lockTimestamps.remove(key);
      
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    }
  }

  /// Verifica se existe lock ativo
  bool isLocked(String key) => _locks.containsKey(key);

  /// Obtém informações sobre locks ativos
  Map<String, LockInfo> get activeLocks {
    final Map<String, LockInfo> info = {};
    
    for (final key in _locks.keys) {
      info[key] = LockInfo(
        key: key,
        count: _lockCounts[key] ?? 0,
        timestamp: _lockTimestamps[key] ?? DateTime.now(),
        elapsed: _lockTimestamps[key] != null
            ? DateTime.now().difference(_lockTimestamps[key]!)
            : Duration.zero,
      );
    }
    
    return info;
  }

  /// Força liberação de todos os locks (use com cuidado!)
  void forceReleaseAll() {
    for (final completer in _locks.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _locks.clear();
    _lockCounts.clear();
    _lockTimestamps.clear();
  }

  /// Limpa locks expirados
  void cleanupExpiredLocks({Duration? maxAge}) {
    final effectiveMaxAge = maxAge ?? _defaultTimeout;
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _lockTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > effectiveMaxAge) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      if (kDebugMode) {
        print('Cleaning up expired lock: $key');
      }
      _releaseLock(key);
    }
  }
}

/// Guard para garantir que locks sejam liberados
class LockGuard {
  final OperationLock _lock;
  final String _key;
  bool _released = false;

  LockGuard._(this._lock, this._key, {bool reentrant = false});

  /// Libera o lock
  void release() {
    if (!_released) {
      _released = true;
      _lock._releaseLock(_key);
    }
  }

  /// Garante que o lock seja liberado mesmo se esquecer de chamar release()
  /// Não confie nisso - sempre chame release() explicitamente!
  void dispose() {
    release();
  }
}

/// Informações sobre um lock ativo
class LockInfo {
  final String key;
  final int count;
  final DateTime timestamp;
  final Duration elapsed;

  const LockInfo({
    required this.key,
    required this.count,
    required this.timestamp,
    required this.elapsed,
  });

  bool get isExpired => elapsed > const Duration(seconds: 30);

  @override
  String toString() => 'LockInfo($key, count: $count, elapsed: $elapsed)';
}

/// Singleton global para locks da aplicação
class GlobalLocks {
  static final GlobalLocks _instance = GlobalLocks._();
  static GlobalLocks get instance => _instance;
  
  GlobalLocks._();
  
  final OperationLock _lock = OperationLock();
  
  /// Lock para operações de criação
  Future<LockGuard> acquireCreateLock(String entityType, {String? entityId}) {
    final key = entityId != null 
        ? 'create_${entityType}_$entityId'
        : 'create_$entityType';
    return _lock.acquire(key);
  }
  
  /// Lock para operações de atualização
  Future<LockGuard> acquireUpdateLock(String entityType, String entityId) {
    return _lock.acquire('update_${entityType}_$entityId');
  }
  
  /// Lock para operações de deleção
  Future<LockGuard> acquireDeleteLock(String entityType, String entityId) {
    return _lock.acquire('delete_${entityType}_$entityId');
  }
  
  /// Lock para operações batch
  Future<LockGuard> acquireBatchLock(String operationType) {
    return _lock.acquire('batch_$operationType', timeout: const Duration(minutes: 5));
  }
  
  /// Executa operação com lock automático
  Future<T> synchronized<T>(
    String key,
    Future<T> Function() operation, {
    Duration? timeout,
  }) {
    return _lock.synchronized(key, operation, timeout: timeout);
  }
  
  /// Limpa locks expirados periodicamente
  void startCleanupTimer() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      _lock.cleanupExpiredLocks();
    });
  }
}

/// Exemplo de uso
class TaskService {
  final _locks = GlobalLocks.instance;
  
  Future<String> createTask(Task task) async {
    final guard = await _locks.acquireCreateLock('task', entityId: task.id);
    try {
      return await _performCreateTask(task);
    } finally {
      guard.release();
    }
  }
  
  Future<void> updateTask(Task task) async {
    await _locks.synchronized(
      'update_task_${task.id}',
      () async {
        await _performUpdateTask(task);
      },
    );
  }
  
  Future<void> batchDelete(List<String> taskIds) async {
    await _locks.synchronized(
      'batch_delete_tasks',
      () async {
        for (final id in taskIds) {
          await _deleteTask(id);
        }
      },
      timeout: const Duration(minutes: 5),
    );
  }
  
  Future<String> _performCreateTask(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 'task_id';
  }
  
  Future<void> _performUpdateTask(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  
  Future<void> _deleteTask(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

class Task {
  final String id;
  final String title;
  
  Task({required this.id, required this.title});
}