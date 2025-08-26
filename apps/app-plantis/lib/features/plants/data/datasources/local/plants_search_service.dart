import 'dart:async';

import '../../../domain/entities/plant.dart';

/// Simplified search service for plants using in-memory search only
/// Consistent with monorepo architecture using only Hive for persistence
class PlantsSearchService {
  static PlantsSearchService? _instance;
  static PlantsSearchService get instance =>
      _instance ??= PlantsSearchService._();

  PlantsSearchService._();

  // In-memory cache and indexes
  final Map<String, List<Plant>> _searchCache = {};
  final Map<String, Set<String>> _wordIndex = {};
  final Map<String, Plant> _plantsIndex = {};
  final int _maxCacheSize = 100;
  Timer? _cacheCleanupTimer;
  Timer? _debounceTimer;

  static const int _cacheExpirationMinutes = 10;

  // Track cache timestamps for cleanup
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Initialize the search service and cleanup timer
  Future<void> initialize() async {
    // Start periodic cache cleanup
    _startCacheCleanup();
  }

  /// Update search index with new plant data
  Future<void> updateSearchIndex(List<Plant> plants) async {
    // Rebuild memory structures
    _plantsIndex.clear();
    _wordIndex.clear();

    for (final plant in plants) {
      // Build memory index
      _plantsIndex[plant.id] = plant;
      _buildWordIndex(plant);
    }
  }

  /// Update search index with new plant data (modern entity)
  Future<void> updateSearchIndexFromPlants(List<Plant> plants) async {
    // Same as updateSearchIndex - keeping both methods for compatibility
    await updateSearchIndex(plants);
  }

  void _buildWordIndex(Plant plant) {
    final words = <String>{};

    // Extract words from searchable fields
    words.addAll(_extractWords(plant.name));
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

  /// Optimized in-memory search
  Future<List<Plant>> searchPlants(String query) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();

    // Check cache first
    final cached = _getCachedResult(normalizedQuery);
    if (cached != null) return cached;

    List<Plant> results;

    // Use memory-based search for all queries
    if (normalizedQuery.contains(' ')) {
      // Multi-word queries: search for all words
      results = await _searchMultiWord(normalizedQuery);
    } else {
      // Single word queries: use word index
      results = await _searchSingleWord(normalizedQuery);
    }

    // Limit results for performance
    if (results.length > 50) {
      results = results.take(50).toList();
    }

    // Cache results
    _cacheResult(normalizedQuery, results);

    return results;
  }

  /// Search for plants containing all words in the query
  Future<List<Plant>> _searchMultiWord(String query) async {
    final queryWords = query
        .split(' ')
        .where((word) => word.isNotEmpty && word.length > 2)
        .toList();

    if (queryWords.isEmpty) return [];

    // Find plants that match all query words
    Set<String>? matchingIds;

    for (final queryWord in queryWords) {
      final currentMatches = <String>{};

      // Find words in index that contain the query word
      for (final entry in _wordIndex.entries) {
        if (entry.key.contains(queryWord)) {
          currentMatches.addAll(entry.value);
        }
      }

      // Intersect with previous results (AND operation)
      if (matchingIds == null) {
        matchingIds = currentMatches;
      } else {
        matchingIds = matchingIds.intersection(currentMatches);
      }

      // If no matches found for this word, no results possible
      if (matchingIds.isEmpty) break;
    }

    return (matchingIds ?? <String>{})
        .map((id) => _plantsIndex[id])
        .where((plant) => plant != null)
        .cast<Plant>()
        .toList();
  }

  /// Search for plants with single word query
  Future<List<Plant>> _searchSingleWord(String query) async {
    final matchingIds = <String>{};

    // Find words that contain the query (partial matching)
    for (final entry in _wordIndex.entries) {
      if (entry.key.contains(query)) {
        matchingIds.addAll(entry.value);
      }
    }

    return matchingIds
        .map((id) => _plantsIndex[id])
        .where((plant) => plant != null)
        .cast<Plant>()
        .toList();
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