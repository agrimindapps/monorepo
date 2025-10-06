import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface para gerenciamento de cache específico de sincronização
/// Separada do UnifiedSyncManager seguindo Single Responsibility Principle
abstract class ICacheManager {
  /// Inicializa o cache manager
  Future<Either<Failure, void>> initialize();

  /// Armazena dados no cache com TTL opcional
  Future<Either<Failure, void>> put(
    String key,
    dynamic data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  });

  /// Recupera dados do cache
  Future<Either<Failure, T?>> get<T>(String key);

  /// Verifica se uma chave existe no cache
  Future<bool> exists(String key);

  /// Remove uma entrada específica do cache
  Future<Either<Failure, void>> remove(String key);

  /// Remove múltiplas entradas do cache
  Future<Either<Failure, void>> removeMany(List<String> keys);

  Future<Either<Failure, void>> clear();

  /// Limpa cache expirado
  Future<Either<Failure, void>> clearExpired();

  /// Aquece o cache com dados essenciais
  Future<Either<Failure, void>> warmup({
    List<String>? essentialKeys,
    Map<String, dynamic>? preloadData,
  });

  /// Obtém estatísticas do cache
  Future<CacheStatistics> getStatistics();

  /// Obtém informações de uma entrada específica
  Future<CacheEntryInfo?> getEntryInfo(String key);

  /// Lista todas as chaves disponíveis
  Future<List<String>> getAllKeys();

  /// Define estratégia de limpeza automática
  void setCleanupStrategy(CacheCleanupStrategy strategy);

  /// Stream de eventos do cache
  Stream<CacheEvent> get eventStream;

  /// Verifica integridade do cache
  Future<CacheHealthCheck> checkHealth();

  /// Libera recursos do cache manager
  Future<void> dispose();
}

/// Estatísticas do cache
class CacheStatistics {
  final int totalEntries;
  final int expiredEntries;
  final int memoryUsageBytes;
  final int hitCount;
  final int missCount;
  final DateTime lastCleanup;
  final Map<String, int> entriesByType;

  const CacheStatistics({
    required this.totalEntries,
    required this.expiredEntries,
    required this.memoryUsageBytes,
    required this.hitCount,
    required this.missCount,
    required this.lastCleanup,
    this.entriesByType = const {},
  });

  double get hitRate =>
      (hitCount + missCount) > 0
          ? (hitCount / (hitCount + missCount)) * 100
          : 0;

  double get memoryUsageMB => memoryUsageBytes / (1024 * 1024);

  @override
  String toString() =>
      'CacheStats(entries: $totalEntries, hit rate: ${hitRate.toStringAsFixed(1)}%)';
}

/// Informações de uma entrada específica do cache
class CacheEntryInfo {
  final String key;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int sizeBytes;
  final Map<String, dynamic> metadata;
  final bool isExpired;

  const CacheEntryInfo({
    required this.key,
    required this.createdAt,
    this.expiresAt,
    required this.sizeBytes,
    this.metadata = const {},
    required this.isExpired,
  });

  Duration get age => DateTime.now().difference(createdAt);

  Duration? get timeToLive => expiresAt?.difference(DateTime.now());

  @override
  String toString() =>
      'CacheEntry($key, age: ${age.inMinutes}min, size: ${sizeBytes}b)';
}

/// Evento do cache
class CacheEvent {
  final CacheEventType type;
  final String key;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  CacheEvent({
    required this.type,
    required this.key,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'CacheEvent($type: $key)';
}

/// Tipos de eventos do cache
enum CacheEventType {
  entryAdded,
  entryUpdated,
  entryRemoved,
  entryExpired,
  cacheCleared,
  cacheFull,
  cleanupStarted,
  cleanupCompleted,
}

/// Estratégia de limpeza do cache
class CacheCleanupStrategy {
  final Duration cleanupInterval;
  final int maxEntries;
  final int maxMemoryBytes;
  final Duration defaultTtl;
  final bool enableAutoCleanup;

  const CacheCleanupStrategy({
    this.cleanupInterval = const Duration(minutes: 30),
    this.maxEntries = 1000,
    this.maxMemoryBytes = 50 * 1024 * 1024, // 50MB
    this.defaultTtl = const Duration(hours: 24),
    this.enableAutoCleanup = true,
  });
}

/// Resultado de verificação de saúde do cache
class CacheHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final Map<String, dynamic> metrics;
  final DateTime checkedAt;

  CacheHealthCheck({
    required this.isHealthy,
    this.issues = const [],
    this.metrics = const {},
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  @override
  String toString() =>
      'CacheHealth(healthy: $isHealthy, issues: ${issues.length})';
}
