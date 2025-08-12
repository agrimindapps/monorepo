// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';

/// High-performance indexing service for vehicle operations
///
/// This service creates and maintains multiple indexes for fast vehicle lookups,
/// search operations, and filtering. Uses binary search, hash maps, and caching
/// to optimize performance for large datasets.
class VeiculoIndex {
  static VeiculoIndex? _instance;
  static VeiculoIndex get instance => _instance ??= VeiculoIndex._internal();

  VeiculoIndex._internal();

  /// ========================================
  /// INDEX STORAGE
  /// ========================================

  /// Primary indexes for O(1) lookups
  final Map<String, VeiculoCar> _idIndex = <String, VeiculoCar>{};
  final Map<String, VeiculoCar> _placaIndex = <String, VeiculoCar>{};

  /// Secondary indexes for efficient filtering
  final Map<String, Set<VeiculoCar>> _marcaIndex = <String, Set<VeiculoCar>>{};
  final Map<String, Set<VeiculoCar>> _modeloIndex = <String, Set<VeiculoCar>>{};
  final Map<int, Set<VeiculoCar>> _anoIndex = <int, Set<VeiculoCar>>{};
  final Map<int, Set<VeiculoCar>> _combustivelIndex = <int, Set<VeiculoCar>>{};
  final Map<String, Set<VeiculoCar>> _corIndex = <String, Set<VeiculoCar>>{};

  /// Full-text search index for flexible querying
  final Map<String, Set<VeiculoCar>> _fullTextIndex =
      <String, Set<VeiculoCar>>{};

  /// Sorted lists for range queries and binary search
  List<VeiculoCar> _sortedByAno = <VeiculoCar>[];
  List<VeiculoCar> _sortedByOdometro = <VeiculoCar>[];
  List<VeiculoCar> _sortedByMarca = <VeiculoCar>[];

  /// Cache for complex queries
  final Map<String, QueryResult> _queryCache = <String, QueryResult>{};

  /// Index state tracking
  bool _isBuilt = false;
  int _lastDataHash = 0;
  DateTime? _lastBuildTime;

  /// Statistics
  final IndexStats _stats = IndexStats();

  /// ========================================
  /// INDEX BUILDING
  /// ========================================

  /// Build all indexes from vehicle list
  Future<void> buildIndexes(List<VeiculoCar> veiculos) async {
    final stopwatch = Stopwatch()..start();

    _clearIndexes();

    // Calculate data hash to detect changes
    final newDataHash = _calculateDataHash(veiculos);
    if (_isBuilt && newDataHash == _lastDataHash) {
      debugPrint('VeiculoIndex: Data unchanged, skipping rebuild');
      return;
    }

    await _buildIndexesInternal(veiculos);

    _lastDataHash = newDataHash;
    _lastBuildTime = DateTime.now();
    _isBuilt = true;

    stopwatch.stop();
    _stats.lastBuildTime = stopwatch.elapsedMilliseconds;
    _stats.totalVehicles = veiculos.length;

    debugPrint(
        'VeiculoIndex: Built indexes for ${veiculos.length} vehicles in ${stopwatch.elapsedMilliseconds}ms');
  }

  /// Internal index building implementation
  Future<void> _buildIndexesInternal(List<VeiculoCar> veiculos) async {
    for (final veiculo in veiculos) {
      if (veiculo.isDeleted) continue; // Skip inactive vehicles

      _addToIndexes(veiculo);
    }

    // Build sorted lists for binary search
    _buildSortedLists(veiculos.where((v) => !v.isDeleted).toList());

    // Build full-text search index
    _buildFullTextIndex();

    // Clear cache as data has changed
    _queryCache.clear();
  }

  /// Add vehicle to all relevant indexes
  void _addToIndexes(VeiculoCar veiculo) {
    // Primary indexes
    _idIndex[veiculo.id] = veiculo;
    _placaIndex[_normalizeString(veiculo.placa)] = veiculo;

    // Secondary indexes
    _addToSetIndex(_marcaIndex, _normalizeString(veiculo.marca), veiculo);
    _addToSetIndex(_modeloIndex, _normalizeString(veiculo.modelo), veiculo);
    _addToSetIndex(_anoIndex, veiculo.ano, veiculo);
    _addToSetIndex(_combustivelIndex, veiculo.combustivel, veiculo);
    _addToSetIndex(_corIndex, _normalizeString(veiculo.cor), veiculo);
  }

  /// Helper to add to set-based indexes
  void _addToSetIndex<K>(
      Map<K, Set<VeiculoCar>> index, K key, VeiculoCar veiculo) {
    if (key == null || (key is String && key.isEmpty)) return;
    index.putIfAbsent(key, () => <VeiculoCar>{}).add(veiculo);
  }

  /// Build sorted lists for binary search operations
  void _buildSortedLists(List<VeiculoCar> veiculos) {
    _sortedByAno = List.from(veiculos)..sort((a, b) => a.ano.compareTo(b.ano));
    _sortedByOdometro = List.from(veiculos)
      ..sort((a, b) => a.odometroAtual.compareTo(b.odometroAtual));
    _sortedByMarca = List.from(veiculos)
      ..sort((a, b) => a.marca.compareTo(b.marca));
  }

  /// Build full-text search index for flexible queries
  void _buildFullTextIndex() {
    for (final veiculo in _idIndex.values) {
      final searchableText = _getSearchableText(veiculo);
      final words = _extractSearchTerms(searchableText);

      for (final word in words) {
        _addToSetIndex(_fullTextIndex, word, veiculo);
      }
    }
  }

  /// ========================================
  /// FAST LOOKUP OPERATIONS
  /// ========================================

  /// Find vehicle by ID - O(1)
  VeiculoCar? findById(String id) {
    _stats.recordQuery('findById');
    return _idIndex[id];
  }

  /// Find vehicle by placa - O(1)
  VeiculoCar? findByPlaca(String placa) {
    _stats.recordQuery('findByPlaca');
    return _placaIndex[_normalizeString(placa)];
  }

  /// Find vehicles by marca - O(1) for index access
  Set<VeiculoCar> findByMarca(String marca) {
    _stats.recordQuery('findByMarca');
    return _marcaIndex[_normalizeString(marca)] ?? <VeiculoCar>{};
  }

  /// Find vehicles by modelo - O(1) for index access
  Set<VeiculoCar> findByModelo(String modelo) {
    _stats.recordQuery('findByModelo');
    return _modeloIndex[_normalizeString(modelo)] ?? <VeiculoCar>{};
  }

  /// Find vehicles by ano - O(1) for index access
  Set<VeiculoCar> findByAno(int ano) {
    _stats.recordQuery('findByAno');
    return _anoIndex[ano] ?? <VeiculoCar>{};
  }

  /// Find vehicles by combustivel - O(1) for index access
  Set<VeiculoCar> findByCombustivel(int combustivel) {
    _stats.recordQuery('findByCombustivel');
    return _combustivelIndex[combustivel] ?? <VeiculoCar>{};
  }

  /// ========================================
  /// RANGE QUERIES WITH BINARY SEARCH
  /// ========================================

  /// Find vehicles within year range - O(log n)
  List<VeiculoCar> findByAnoRange(int minAno, int maxAno) {
    _stats.recordQuery('findByAnoRange');

    final startIndex = _binarySearchAno(minAno);
    final endIndex = _binarySearchAno(maxAno + 1);

    return _sortedByAno.sublist(startIndex, endIndex);
  }

  /// Find vehicles within odometer range - O(log n)
  List<VeiculoCar> findByOdometroRange(double minOdometro, double maxOdometro) {
    _stats.recordQuery('findByOdometroRange');

    final startIndex = _binarySearchOdometro(minOdometro);
    final endIndex = _binarySearchOdometro(maxOdometro + 0.1);

    return _sortedByOdometro.sublist(startIndex, endIndex);
  }

  /// Binary search for year position
  int _binarySearchAno(int targetAno) {
    int left = 0;
    int right = _sortedByAno.length;

    while (left < right) {
      final mid = left + (right - left) ~/ 2;
      if (_sortedByAno[mid].ano < targetAno) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left;
  }

  /// Binary search for odometer position
  int _binarySearchOdometro(double targetOdometro) {
    int left = 0;
    int right = _sortedByOdometro.length;

    while (left < right) {
      final mid = left + (right - left) ~/ 2;
      if (_sortedByOdometro[mid].odometroAtual < targetOdometro) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left;
  }

  /// ========================================
  /// FULL-TEXT SEARCH
  /// ========================================

  /// Full-text search across all vehicle fields
  Future<List<VeiculoCar>> search(
    String query, {
    bool fuzzyMatch = false,
    int maxResults = 50,
  }) async {
    if (query.isEmpty) return [];

    _stats.recordQuery('search');

    final cacheKey = 'search_${query}_$fuzzyMatch';
    if (_queryCache.containsKey(cacheKey)) {
      final cached = _queryCache[cacheKey]!;
      if (!cached.isExpired) {
        return cached.results.cast<VeiculoCar>();
      }
    }

    final results = await _performSearch(query, fuzzyMatch, maxResults);

    // Cache results
    _queryCache[cacheKey] = QueryResult(results.cast<dynamic>());

    return results;
  }

  /// Internal search implementation
  Future<List<VeiculoCar>> _performSearch(
      String query, bool fuzzyMatch, int maxResults) async {
    final searchTerms = _extractSearchTerms(query.toLowerCase());
    final matchingVehicles = <VeiculoCar, double>{};

    for (final term in searchTerms) {
      // Exact matches
      final exactMatches = _fullTextIndex[term] ?? <VeiculoCar>{};
      for (final vehicle in exactMatches) {
        matchingVehicles[vehicle] = (matchingVehicles[vehicle] ?? 0) + 1.0;
      }

      // Fuzzy matches
      if (fuzzyMatch && term.length > 2) {
        for (final indexTerm in _fullTextIndex.keys) {
          if (_isFuzzyMatch(term, indexTerm)) {
            final fuzzyMatches = _fullTextIndex[indexTerm] ?? <VeiculoCar>{};
            for (final vehicle in fuzzyMatches) {
              matchingVehicles[vehicle] =
                  (matchingVehicles[vehicle] ?? 0) + 0.5;
            }
          }
        }
      }
    }

    // Sort by relevance score and return top results
    final sortedResults = matchingVehicles.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedResults.take(maxResults).map((entry) => entry.key).toList();
  }

  /// ========================================
  /// COMPLEX FILTERING
  /// ========================================

  /// Advanced filtering with multiple criteria
  Future<List<VeiculoCar>> filter(VehicleFilter filter) async {
    _stats.recordQuery('filter');

    final cacheKey = filter.toCacheKey();
    if (_queryCache.containsKey(cacheKey)) {
      final cached = _queryCache[cacheKey]!;
      if (!cached.isExpired) {
        return cached.results.cast<VeiculoCar>();
      }
    }

    final results = await _performFilter(filter);

    // Cache results
    _queryCache[cacheKey] = QueryResult(results.cast<dynamic>());

    return results;
  }

  /// Internal filtering implementation
  Future<List<VeiculoCar>> _performFilter(VehicleFilter filter) async {
    Set<VeiculoCar>? candidates;

    // Start with the most selective filter
    if (filter.id != null) {
      final vehicle = findById(filter.id!);
      return vehicle != null ? [vehicle] : [];
    }

    if (filter.placa != null) {
      final vehicle = findByPlaca(filter.placa!);
      return vehicle != null ? [vehicle] : [];
    }

    // Use indexed lookups for single-value filters
    if (filter.marca != null) {
      candidates = _intersectCandidates(candidates, findByMarca(filter.marca!));
    }

    if (filter.modelo != null) {
      candidates =
          _intersectCandidates(candidates, findByModelo(filter.modelo!));
    }

    if (filter.ano != null) {
      candidates = _intersectCandidates(candidates, findByAno(filter.ano!));
    }

    if (filter.combustivel != null) {
      candidates = _intersectCandidates(
          candidates, findByCombustivel(filter.combustivel!));
    }

    // Apply range filters
    if (filter.anoMin != null || filter.anoMax != null) {
      final rangeResults = findByAnoRange(
        filter.anoMin ?? 1900,
        filter.anoMax ?? DateTime.now().year + 5,
      );
      candidates = _intersectCandidates(candidates, rangeResults.toSet());
    }

    if (filter.odometroMin != null || filter.odometroMax != null) {
      final rangeResults = findByOdometroRange(
        filter.odometroMin ?? 0,
        filter.odometroMax ?? double.infinity,
      );
      candidates = _intersectCandidates(candidates, rangeResults.toSet());
    }

    // Apply text search if specified
    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      final searchResults =
          await search(filter.searchText!, fuzzyMatch: filter.fuzzySearch);
      candidates = _intersectCandidates(candidates, searchResults.toSet());
    }

    // If no filters applied, return all vehicles
    candidates ??= _idIndex.values.toSet();

    // Apply additional predicates
    var results = candidates.toList();

    if (filter.vendidoFilter != null) {
      results =
          results.where((v) => v.vendido == filter.vendidoFilter).toList();
    }

    // Apply sorting
    if (filter.sortBy != null) {
      _applySorting(results, filter.sortBy!, filter.sortDescending);
    }

    return results;
  }

  /// ========================================
  /// HELPER METHODS
  /// ========================================

  /// Intersect candidate sets efficiently
  Set<VeiculoCar>? _intersectCandidates(
      Set<VeiculoCar>? existing, Set<VeiculoCar> newSet) {
    if (existing == null) return newSet;
    return existing.intersection(newSet);
  }

  /// Apply sorting to results
  void _applySorting(List<VeiculoCar> results, String sortBy, bool descending) {
    switch (sortBy.toLowerCase()) {
      case 'marca':
        results.sort((a, b) => descending
            ? b.marca.compareTo(a.marca)
            : a.marca.compareTo(b.marca));
        break;
      case 'modelo':
        results.sort((a, b) => descending
            ? b.modelo.compareTo(a.modelo)
            : a.modelo.compareTo(b.modelo));
        break;
      case 'ano':
        results.sort((a, b) =>
            descending ? b.ano.compareTo(a.ano) : a.ano.compareTo(b.ano));
        break;
      case 'odometro':
        results.sort((a, b) => descending
            ? b.odometroAtual.compareTo(a.odometroAtual)
            : a.odometroAtual.compareTo(b.odometroAtual));
        break;
      case 'placa':
        results.sort((a, b) => descending
            ? b.placa.compareTo(a.placa)
            : a.placa.compareTo(b.placa));
        break;
    }
  }

  /// Normalize string for consistent indexing
  String _normalizeString(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extract searchable text from vehicle
  String _getSearchableText(VeiculoCar veiculo) {
    return [
      veiculo.marca,
      veiculo.modelo,
      veiculo.placa,
      veiculo.cor,
      veiculo.renavan,
      veiculo.chassi,
      veiculo.ano.toString(),
    ].join(' ').toLowerCase();
  }

  /// Extract search terms from query
  Set<String> _extractSearchTerms(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 1)
        .toSet();
  }

  /// Check if two terms are fuzzy matches
  bool _isFuzzyMatch(String term1, String term2) {
    if (term1 == term2) return true;
    if ((term1.length - term2.length).abs() > 2) return false;

    return _levenshteinDistance(term1, term2) <= 2;
  }

  /// Calculate Levenshtein distance for fuzzy matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
        s1.length + 1, (i) => List.generate(s2.length + 1, (j) => 0));

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = math.min(
          math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Calculate simple data hash for change detection
  int _calculateDataHash(List<VeiculoCar> veiculos) {
    var hash = 0;
    for (final veiculo in veiculos) {
      hash ^= veiculo.id.hashCode;
      hash ^= veiculo.updatedAt.hashCode;
    }
    return hash;
  }

  /// ========================================
  /// MAINTENANCE AND MONITORING
  /// ========================================

  /// Clear all indexes
  void _clearIndexes() {
    _idIndex.clear();
    _placaIndex.clear();
    _marcaIndex.clear();
    _modeloIndex.clear();
    _anoIndex.clear();
    _combustivelIndex.clear();
    _corIndex.clear();
    _fullTextIndex.clear();
    _sortedByAno.clear();
    _sortedByOdometro.clear();
    _sortedByMarca.clear();
  }

  /// Clear query cache
  void clearCache() {
    _queryCache.clear();
  }

  /// Get index statistics
  IndexStats getStats() => _stats;

  /// Get memory usage information
  Map<String, dynamic> getMemoryUsage() {
    return {
      'total_vehicles': _idIndex.length,
      'marca_keys': _marcaIndex.length,
      'modelo_keys': _modeloIndex.length,
      'fulltext_terms': _fullTextIndex.length,
      'cache_entries': _queryCache.length,
      'last_build_time_ms': _stats.lastBuildTime,
      'total_queries': _stats.totalQueries,
    };
  }

  /// Check if indexes are built and up to date
  bool get isBuilt => _isBuilt;

  /// Get last build time
  DateTime? get lastBuildTime => _lastBuildTime;
}

/// ========================================
/// SUPPORTING CLASSES
/// ========================================

/// Vehicle filter criteria
class VehicleFilter {
  final String? id;
  final String? placa;
  final String? marca;
  final String? modelo;
  final int? ano;
  final int? anoMin;
  final int? anoMax;
  final int? combustivel;
  final double? odometroMin;
  final double? odometroMax;
  final bool? vendidoFilter;
  final String? searchText;
  final bool fuzzySearch;
  final String? sortBy;
  final bool sortDescending;

  const VehicleFilter({
    this.id,
    this.placa,
    this.marca,
    this.modelo,
    this.ano,
    this.anoMin,
    this.anoMax,
    this.combustivel,
    this.odometroMin,
    this.odometroMax,
    this.vendidoFilter,
    this.searchText,
    this.fuzzySearch = false,
    this.sortBy,
    this.sortDescending = false,
  });

  String toCacheKey() {
    return [
      id,
      placa,
      marca,
      modelo,
      ano,
      anoMin,
      anoMax,
      combustivel,
      odometroMin,
      odometroMax,
      vendidoFilter,
      searchText,
      fuzzySearch,
      sortBy,
      sortDescending,
    ].join('|');
  }
}

/// Query result with expiration
class QueryResult {
  final List<dynamic> results;
  final DateTime timestamp;
  static const Duration cacheExpiry = Duration(minutes: 5);

  QueryResult(this.results) : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > cacheExpiry;
}

/// Index performance statistics
class IndexStats {
  int totalVehicles = 0;
  int lastBuildTime = 0;
  int totalQueries = 0;
  final Map<String, int> queryTypeCount = <String, int>{};

  void recordQuery(String queryType) {
    totalQueries++;
    queryTypeCount[queryType] = (queryTypeCount[queryType] ?? 0) + 1;
  }

  @override
  String toString() =>
      'IndexStats(vehicles: $totalVehicles, queries: $totalQueries, '
      'build_time: ${lastBuildTime}ms)';
}
