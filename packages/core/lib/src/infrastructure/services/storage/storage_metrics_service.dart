/// Serviço de métricas e estatísticas de storage
///
/// Responsabilidades:
/// - Tracking de operações (read/write)
/// - Cache hit/miss ratio
/// - Estatísticas de uso por storage type
/// - Performance metrics
/// - Reporting
class StorageMetricsService {
  int _readOperations = 0;
  int _writeOperations = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Registra operação de leitura
  void recordRead() {
    _readOperations++;
  }

  /// Registra operação de escrita
  void recordWrite() {
    _writeOperations++;
  }

  /// Registra cache hit
  void recordCacheHit() {
    _cacheHits++;
  }

  /// Registra cache miss
  void recordCacheMiss() {
    _cacheMisses++;
  }

  /// Calcula hit ratio do cache
  double get cacheHitRatio {
    final total = _cacheHits + _cacheMisses;
    if (total == 0) return 0.0;
    return _cacheHits / total;
  }

  /// Obtém total de operações
  int get totalOperations => _readOperations + _writeOperations;

  /// Obtém métricas completas
  StorageMetrics getMetrics() {
    return StorageMetrics(
      readOperations: _readOperations,
      writeOperations: _writeOperations,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      cacheHitRatio: cacheHitRatio,
      totalOperations: totalOperations,
    );
  }

  /// Reseta todas as métricas
  void reset() {
    _readOperations = 0;
    _writeOperations = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
  }
}

/// Métricas de storage
class StorageMetrics {
  final int readOperations;
  final int writeOperations;
  final int cacheHits;
  final int cacheMisses;
  final double cacheHitRatio;
  final int totalOperations;

  StorageMetrics({
    required this.readOperations,
    required this.writeOperations,
    required this.cacheHits,
    required this.cacheMisses,
    required this.cacheHitRatio,
    required this.totalOperations,
  });

  Map<String, dynamic> toMap() {
    return {
      'readOperations': readOperations,
      'writeOperations': writeOperations,
      'cacheHits': cacheHits,
      'cacheMisses': cacheMisses,
      'cacheHitRatio': cacheHitRatio,
      'totalOperations': totalOperations,
    };
  }

  @override
  String toString() {
    return 'StorageMetrics('
        'reads: $readOperations, writes: $writeOperations, '
        'cache: $cacheHits hits / $cacheMisses misses, '
        'hit ratio: ${(cacheHitRatio * 100).toStringAsFixed(1)}%)';
  }
}
