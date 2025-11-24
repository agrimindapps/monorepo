
import '../entities/enums.dart';

/// Service responsible for AI move caching and memoization
///
/// Handles:
/// - Move cache management
/// - Board state serialization
/// - Cache statistics (hits, misses, hit rate)
/// - Cache clearing
class MoveCacheService {
  final Map<String, CachedMove> _cache = {};
  int _cacheHits = 0;
  int _cacheMisses = 0;

  MoveCacheService();

  // ============================================================================
  // Cache Operations
  // ============================================================================

  /// Gets cached move for board state
  CachedMove? getCachedMove({
    required List<List<Player>> board,
    required Player currentPlayer,
    required Difficulty difficulty,
  }) {
    final key = _generateCacheKey(board, currentPlayer, difficulty);

    if (_cache.containsKey(key)) {
      _cacheHits++;
      final cached = _cache[key]!;
      return cached.copyWith(hitCount: cached.hitCount + 1);
    }

    _cacheMisses++;
    return null;
  }

  /// Caches a move for board state
  void cacheMove({
    required List<List<Player>> board,
    required Player currentPlayer,
    required Difficulty difficulty,
    required int row,
    required int col,
  }) {
    final key = _generateCacheKey(board, currentPlayer, difficulty);

    _cache[key] = CachedMove(
      row: row,
      col: col,
      board: board,
      currentPlayer: currentPlayer,
      difficulty: difficulty,
      timestamp: DateTime.now(),
      hitCount: 0,
    );
  }

  /// Checks if move is cached
  bool hasCachedMove({
    required List<List<Player>> board,
    required Player currentPlayer,
    required Difficulty difficulty,
  }) {
    final key = _generateCacheKey(board, currentPlayer, difficulty);
    return _cache.containsKey(key);
  }

  // ============================================================================
  // Cache Key Generation
  // ============================================================================

  /// Generates unique cache key for board state
  String _generateCacheKey(
    List<List<Player>> board,
    Player currentPlayer,
    Difficulty difficulty,
  ) {
    final buffer = StringBuffer();

    // Add board state
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        buffer.write(board[i][j].index);
      }
    }

    // Add current player
    buffer.write('_');
    buffer.write(currentPlayer.index);

    // Add difficulty
    buffer.write('_');
    buffer.write(difficulty.index);

    return buffer.toString();
  }

  /// Generates simple board key (without player and difficulty)
  String generateBoardKey(List<List<Player>> board) {
    final buffer = StringBuffer();

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        buffer.write(board[i][j].index);
      }
    }

    return buffer.toString();
  }

  // ============================================================================
  // Cache Management
  // ============================================================================

  /// Clears all cached moves
  void clearCache() {
    _cache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Clears cache for specific difficulty
  void clearCacheForDifficulty(Difficulty difficulty) {
    _cache.removeWhere((key, value) => value.difficulty == difficulty);
  }

  /// Clears old cache entries (older than specified duration)
  void clearOldEntries(Duration maxAge) {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final age = now.difference(value.timestamp);
      return age > maxAge;
    });
  }

  /// Removes least recently used entries to maintain max size
  void trimCache(int maxSize) {
    if (_cache.length <= maxSize) return;

    // Sort by hit count and timestamp
    final entries = _cache.entries.toList();
    entries.sort((a, b) {
      // First by hit count
      final hitComparison = a.value.hitCount.compareTo(b.value.hitCount);
      if (hitComparison != 0) return hitComparison;

      // Then by timestamp (older first)
      return a.value.timestamp.compareTo(b.value.timestamp);
    });

    // Remove least used entries
    final toRemove = entries.length - maxSize;
    for (int i = 0; i < toRemove; i++) {
      _cache.remove(entries[i].key);
    }
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets cache statistics
  CacheStatistics getStatistics() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRate = totalRequests > 0 ? _cacheHits / totalRequests : 0.0;

    final mostUsedMoves = _cache.values.toList()
      ..sort((a, b) => b.hitCount.compareTo(a.hitCount));

    final averageHitCount = _cache.isEmpty
        ? 0.0
        : _cache.values.fold<int>(0, (sum, move) => sum + move.hitCount) /
            _cache.length;

    return CacheStatistics(
      cacheSize: _cache.length,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      hitRate: hitRate,
      averageHitCount: averageHitCount,
      mostUsedMove: mostUsedMoves.isNotEmpty ? mostUsedMoves.first : null,
    );
  }

  /// Gets cache efficiency level
  CacheEfficiency getEfficiencyLevel() {
    final stats = getStatistics();

    if (stats.hitRate >= 0.8) {
      return CacheEfficiency.excellent;
    } else if (stats.hitRate >= 0.6) {
      return CacheEfficiency.good;
    } else if (stats.hitRate >= 0.4) {
      return CacheEfficiency.fair;
    } else {
      return CacheEfficiency.poor;
    }
  }

  /// Gets all cached moves
  List<CachedMove> getAllCachedMoves() {
    return _cache.values.toList();
  }

  /// Gets cached moves for specific difficulty
  List<CachedMove> getCachedMovesForDifficulty(Difficulty difficulty) {
    return _cache.values
        .where((move) => move.difficulty == difficulty)
        .toList();
  }

  // ============================================================================
  // Analysis
  // ============================================================================

  /// Analyzes cache usage patterns
  CacheAnalysis analyzeCacheUsage() {
    final stats = getStatistics();

    final byDifficulty = <Difficulty, int>{};
    final byPlayer = <Player, int>{};

    for (final move in _cache.values) {
      byDifficulty[move.difficulty] = (byDifficulty[move.difficulty] ?? 0) + 1;
      byPlayer[move.currentPlayer] = (byPlayer[move.currentPlayer] ?? 0) + 1;
    }

    return CacheAnalysis(
      statistics: stats,
      efficiency: getEfficiencyLevel(),
      entriesByDifficulty: byDifficulty,
      entriesByPlayer: byPlayer,
    );
  }

  // ============================================================================
  // Debug
  // ============================================================================

  /// Gets cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'size': _cache.length,
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'hitRate': getStatistics().hitRate,
      'efficiency': getEfficiencyLevel().label,
    };
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Cached move information
class CachedMove {
  final int row;
  final int col;
  final List<List<Player>> board;
  final Player currentPlayer;
  final Difficulty difficulty;
  final DateTime timestamp;
  final int hitCount;

  const CachedMove({
    required this.row,
    required this.col,
    required this.board,
    required this.currentPlayer,
    required this.difficulty,
    required this.timestamp,
    required this.hitCount,
  });

  /// Gets position as tuple
  (int, int) get position => (row, col);

  /// Gets age of cache entry
  Duration get age => DateTime.now().difference(timestamp);

  /// Checks if entry is old (more than 5 minutes)
  bool get isOld => age.inMinutes > 5;

  /// Checks if entry is frequently used (5+ hits)
  bool get isFrequentlyUsed => hitCount >= 5;

  CachedMove copyWith({
    int? row,
    int? col,
    List<List<Player>>? board,
    Player? currentPlayer,
    Difficulty? difficulty,
    DateTime? timestamp,
    int? hitCount,
  }) {
    return CachedMove(
      row: row ?? this.row,
      col: col ?? this.col,
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      difficulty: difficulty ?? this.difficulty,
      timestamp: timestamp ?? this.timestamp,
      hitCount: hitCount ?? this.hitCount,
    );
  }
}

/// Cache statistics
class CacheStatistics {
  final int cacheSize;
  final int cacheHits;
  final int cacheMisses;
  final double hitRate;
  final double averageHitCount;
  final CachedMove? mostUsedMove;

  const CacheStatistics({
    required this.cacheSize,
    required this.cacheHits,
    required this.cacheMisses,
    required this.hitRate,
    required this.averageHitCount,
    required this.mostUsedMove,
  });

  /// Gets hit rate as percentage
  double get hitRatePercentage => hitRate * 100;

  /// Gets total requests
  int get totalRequests => cacheHits + cacheMisses;

  /// Checks if cache is effective (>50% hit rate)
  bool get isEffective => hitRate > 0.5;
}

/// Cache efficiency level
enum CacheEfficiency {
  excellent,
  good,
  fair,
  poor;

  String get label {
    switch (this) {
      case CacheEfficiency.excellent:
        return 'Excelente';
      case CacheEfficiency.good:
        return 'Boa';
      case CacheEfficiency.fair:
        return 'Razoável';
      case CacheEfficiency.poor:
        return 'Fraca';
    }
  }

  String get emoji {
    switch (this) {
      case CacheEfficiency.excellent:
        return '🚀';
      case CacheEfficiency.good:
        return '✅';
      case CacheEfficiency.fair:
        return '⚠️';
      case CacheEfficiency.poor:
        return '❌';
    }
  }
}

/// Cache usage analysis
class CacheAnalysis {
  final CacheStatistics statistics;
  final CacheEfficiency efficiency;
  final Map<Difficulty, int> entriesByDifficulty;
  final Map<Player, int> entriesByPlayer;

  const CacheAnalysis({
    required this.statistics,
    required this.efficiency,
    required this.entriesByDifficulty,
    required this.entriesByPlayer,
  });

  /// Gets most cached difficulty
  Difficulty? get mostCachedDifficulty {
    if (entriesByDifficulty.isEmpty) return null;

    return entriesByDifficulty.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets most cached player
  Player? get mostCachedPlayer {
    if (entriesByPlayer.isEmpty) return null;

    return entriesByPlayer.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gets summary message
  String get summary {
    return '${efficiency.emoji} Cache ${efficiency.label}: '
        '${statistics.cacheSize} entradas, '
        '${statistics.hitRatePercentage.toStringAsFixed(1)}% taxa de acerto';
  }
}
