import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/plant.dart';

/// Optimized search service for plants with FTS5, caching and indexing
class PlantsSearchService {
  static PlantsSearchService? _instance;
  static PlantsSearchService get instance =>
      _instance ??= PlantsSearchService._();

  PlantsSearchService._();

  Database? _database;
  final Map<String, List<Plant>> _searchCache = {};
  final Map<String, Set<String>> _wordIndex = {};
  final Map<String, Plant> _plantsIndex = {};
  final int _maxCacheSize = 100;
  Timer? _cacheCleanupTimer;
  Timer? _debounceTimer;

  static const String _tableName = 'plants_fts';
  static const int _cacheExpirationMinutes = 10;

  // Track cache timestamps for cleanup
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Initialize the FTS database and cleanup timer
  Future<void> initialize() async {
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'plants_search.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDatabase,
    );

    // Start periodic cache cleanup
    _startCacheCleanup();
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create FTS5 virtual table for full-text search
    await db.execute('''
      CREATE VIRTUAL TABLE $_tableName USING fts5(
        id UNINDEXED,
        name,
        species,
        notes,
        content='',
        tokenize='porter unicode61 remove_diacritics 1'
      );
    ''');

    // Create triggers to maintain FTS table
    await db.execute('''
      CREATE TRIGGER plants_fts_insert AFTER INSERT ON plants BEGIN
        INSERT INTO $_tableName(id, name, species, notes)
        VALUES (new.id, new.name, new.species, new.notes);
      END;
    ''');
  }

  /// Update search index with new plant data
  Future<void> updateSearchIndex(List<Plant> plants) async {
    await initialize();
    if (_database == null) return;

    final batch = _database!.batch();

    // Clear existing data
    batch.delete(_tableName);

    // Rebuild index and memory structures
    _plantsIndex.clear();
    _wordIndex.clear();

    for (final plant in plants) {
      // Add to FTS table
      batch.insert(_tableName, {
        'id': plant.id,
        'name': plant.name,
        'species': plant.species ?? '',
        'notes': plant.notes ?? '',
      });

      // Build memory index
      _plantsIndex[plant.id] = plant;
      _buildWordIndex(plant);
    }

    await batch.commit(noResult: true);
  }

  /// Update search index with new plant data (modern entity)
  Future<void> updateSearchIndexFromPlants(List<Plant> plants) async {
    await initialize();
    if (_database == null) return;

    final batch = _database!.batch();

    // Clear existing data
    batch.delete('plant_search');

    // Index each plant
    for (final plant in plants) {
      batch.insert('plant_search', {
        'id': plant.id,
        'name': plant.name,
        'species': plant.species ?? '',
        'notes': plant.notes ?? '',
      });

      // Build memory index
      _plantsIndex[plant.id] = plant;
      _buildWordIndex(plant);
    }

    await batch.commit(noResult: true);
  }

  void _buildWordIndex(Plant plant) {
    final words = <String>{};

    // Extract words from searchable fields
    words.addAll(_extractWords(plant.name ?? ''));
    if (plant.species != null) words.addAll(_extractWords(plant.species!));
    if (plant.notes != null) words.addAll(_extractWords(plant.notes!));

    // Index each word
    for (final word in words) {
      _wordIndex.putIfAbsent(word, () => <String>{}).add(plant.id);
    }
  }

  List<String> _extractWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2)
        .toList();
  }

  /// Optimized search with multiple strategies
  Future<List<Plant>> searchPlants(String query) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();

    // Check cache first
    final cached = _getCachedResult(normalizedQuery);
    if (cached != null) return cached;

    List<Plant> results;

    // Choose search strategy based on query characteristics
    if (normalizedQuery.length <= 3) {
      // Short queries: use memory index for speed
      results = await _searchMemoryIndex(normalizedQuery);
    } else if (normalizedQuery.contains(' ')) {
      // Multi-word queries: use FTS5 for advanced matching
      results = await _searchFTS(normalizedQuery);
    } else {
      // Single word queries: hybrid approach
      results = await _searchHybrid(normalizedQuery);
    }

    // Limit results for performance
    if (results.length > 50) {
      results = results.take(50).toList();
    }

    // Cache results
    _cacheResult(normalizedQuery, results);

    return results;
  }

  /// Fast memory-based search for short queries
  Future<List<Plant>> _searchMemoryIndex(String query) async {
    final matchingIds = <String>{};

    // Find words that start with query
    for (final entry in _wordIndex.entries) {
      if (entry.key.startsWith(query)) {
        matchingIds.addAll(entry.value);
      }
    }

    return matchingIds
        .map((id) => _plantsIndex[id])
        .where((plant) => plant != null)
        .cast<Plant>()
        .toList();
  }

  /// Full-text search using SQLite FTS5
  Future<List<Plant>> _searchFTS(String query) async {
    await initialize();
    if (_database == null) return [];

    try {
      // Use FTS5 match operator for phrase and proximity searches
      final ftsQuery = query
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => '"$word"*')
          .join(' OR ');

      final results = await _database!.query(
        _tableName,
        where: '$_tableName MATCH ?',
        whereArgs: [ftsQuery],
        orderBy: 'rank',
        limit: 50,
      );

      return results
          .map((row) => _plantsIndex[row['id'] as String])
          .where((plant) => plant != null)
          .cast<Plant>()
          .toList();
    } catch (e) {
      // Fallback to memory search if FTS fails
      return _searchMemoryIndex(query);
    }
  }

  /// Hybrid search combining memory and FTS
  Future<List<Plant>> _searchHybrid(String query) async {
    // Start with fast memory search
    final memoryResults = await _searchMemoryIndex(query);

    if (memoryResults.length >= 20) {
      return memoryResults;
    }

    // Enhance with FTS search for better results
    final ftsResults = await _searchFTS(query);

    // Merge results, prioritizing memory results
    final mergedResults = <String, Plant>{};

    for (final plant in memoryResults) {
      mergedResults[plant.id] = plant;
    }

    for (final plant in ftsResults) {
      mergedResults[plant.id] = plant;
    }

    return mergedResults.values.toList();
  }

  List<Plant>? _getCachedResult(String query) {
    final cached = _searchCache[query];
    if (cached == null) return null;

    final timestamp = _cacheTimestamps[query];
    if (timestamp == null) return null;

    // Check if cache is still valid
    final now = DateTime.now();
    if (now.difference(timestamp).inMinutes > _cacheExpirationMinutes) {
      _searchCache.remove(query);
      _cacheTimestamps.remove(query);
      return null;
    }

    return cached;
  }

  void _cacheResult(String query, List<Plant> results) {
    // Implement LRU cache with size limit
    if (_searchCache.length >= _maxCacheSize) {
      final oldestQuery = _findOldestCacheEntry();
      if (oldestQuery != null) {
        _searchCache.remove(oldestQuery);
        _cacheTimestamps.remove(oldestQuery);
      }
    }

    _searchCache[query] = List.from(results);
    _cacheTimestamps[query] = DateTime.now();
  }

  String? _findOldestCacheEntry() {
    if (_cacheTimestamps.isEmpty) return null;

    return _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
  }

  void _startCacheCleanup() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupExpiredCache(),
    );
  }

  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value).inMinutes > _cacheExpirationMinutes) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _searchCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Debounced search to reduce unnecessary calls
  Future<List<Plant>> searchWithDebounce(
    String query,
    Duration delay,
  ) async {
    final completer = Completer<List<Plant>>();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () async {
      try {
        final results = await searchPlants(query);
        if (!completer.isCompleted) {
          completer.complete(results);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  /// Clear all caches
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    _wordIndex.clear();
    _plantsIndex.clear();
  }

  /// Dispose resources
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _debounceTimer?.cancel();
    _database?.close();
    _database = null;
    clearCache();
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _searchCache.length,
      'indexSize': _plantsIndex.length,
      'wordIndexSize': _wordIndex.length,
      'maxCacheSize': _maxCacheSize,
    };
  }
}
