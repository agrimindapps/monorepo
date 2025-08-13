// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Serviço de Performance
// DESCRIÇÃO: Otimiza carregamento de dados com execução paralela e cache
// RESPONSABILIDADES: Cache, loading paralelo, timeouts, fallbacks
// DEPENDÊNCIAS: Interfaces de repositórios e serviços
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Performance optimization service for parallel data loading and caching

// Dart imports:
import 'dart:async';

// Project imports:
import '../../../core/cache/i_cache_service.dart';
import '../../../services/premium_service.dart';
import '../constants/diagnostico_performance_constants.dart';
import '../interfaces/i_database_repository.dart';
import '../interfaces/i_local_storage_service.dart';
import '../models/diagnostic_data.dart';

/// Refactored service for optimizing data loading with unified cache service
class DiagnosticoPerformanceService {
  final IDatabaseRepository _databaseRepository;
  final ILocalStorageService _localStorageService;
  final PremiumService _premiumService;
  final ICacheService _cacheService;

  DiagnosticoPerformanceService({
    required IDatabaseRepository databaseRepository,
    required ILocalStorageService localStorageService,
    required PremiumService premiumService,
    required ICacheService cacheService,
  })  : _databaseRepository = databaseRepository,
        _localStorageService = localStorageService,
        _premiumService = premiumService,
        _cacheService = cacheService;

  /// Loads all diagnostic data in parallel with caching and fallbacks
  Future<DiagnosticoLoadResult> loadDiagnosticoDataParallel(
      String diagnosticoId) async {
    final completer = Completer<DiagnosticoLoadResult>();

    // Start all operations in parallel with unified cache
    final futures = <String, Future<dynamic>>{
      'diagnostic': _loadDiagnosticDataWithUnifiedCache(diagnosticoId),
      'favorite': _loadFavoriteStatusWithUnifiedCache(diagnosticoId),
      'premium': _loadPremiumStatusWithUnifiedCache(),
    };

    // Track completion status
    final results = <String, dynamic>{};
    final errors = <String, dynamic>{};
    int completedCount = 0;

    // Process each future with individual timeouts and fallbacks
    futures.forEach((key, future) {
      future
          .timeout(
        _getTimeoutForOperation(key),
        onTimeout: _getTimeoutFallback(key),
      )
          .then((result) {
        results[key] = result;
        completedCount++;

        // Complete when all operations are done
        if (completedCount == futures.length) {
          _completeWithResults(completer, results, errors);
        }
      }).catchError((error) {
        errors[key] = error;
        // Use fallback data for failed operations
        results[key] = _getFallbackData(key);
        completedCount++;

        if (completedCount == futures.length) {
          _completeWithResults(completer, results, errors);
        }
      });
    });

    // Global timeout for all operations
    Timer(DiagnosticoPerformanceConstants.parallelLoadingTimeout, () {
      if (!completer.isCompleted) {
        // Complete with partial results
        _completeWithResults(completer, results, errors, isPartial: true);
      }
    });

    return completer.future;
  }

  /// Loads diagnostic data with unified cache
  Future<DiagnosticData?> _loadDiagnosticDataWithUnifiedCache(
      String diagnosticoId) async {
    final cacheKey =
        '${DiagnosticoPerformanceConstants.diagnosticoCacheKey}_$diagnosticoId';

    try {
      // Check unified cache first
      final cachedData = await _cacheService.get<DiagnosticData>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // Load from database
      final data = await _fetchDiagnosticDataOptimized(diagnosticoId);

      // Cache the result in unified cache
      if (data != null) {
        await _cacheService.put(
          cacheKey,
          data,
          ttl: DiagnosticoPerformanceConstants.cacheExpiration,
        );
      }

      return data;
    } catch (e) {
      // Fallback to direct database load on cache error
      return await _fetchDiagnosticDataOptimized(diagnosticoId);
    }
  }

  /// Loads favorite status with unified cache
  Future<bool> _loadFavoriteStatusWithUnifiedCache(String diagnosticoId) async {
    final cacheKey =
        '${DiagnosticoPerformanceConstants.favoriteCacheKey}_$diagnosticoId';

    try {
      // Check unified cache first
      final cachedStatus = await _cacheService.get<bool>(cacheKey);
      if (cachedStatus != null) {
        return cachedStatus;
      }

      // Load from storage
      final isFavorite =
          await _localStorageService.isFavorite('favDiagnosticos', diagnosticoId);

      // Cache the result in unified cache
      await _cacheService.put(
        cacheKey,
        isFavorite,
        ttl: DiagnosticoPerformanceConstants.cacheExpiration,
      );

      return isFavorite;
    } catch (e) {
      // Fallback to direct storage access on cache error
      return await _localStorageService.isFavorite('favDiagnosticos', diagnosticoId);
    }
  }

  /// Loads premium status with unified cache for consistency
  Future<bool> _loadPremiumStatusWithUnifiedCache() async {
    const cacheKey = DiagnosticoPerformanceConstants.premiumCacheKey;

    try {
      // Check unified cache first for consistency
      final cachedStatus = await _cacheService.get<bool>(cacheKey);
      if (cachedStatus != null) {
        return cachedStatus;
      }

      // Get from PremiumService
      final isPremium = _premiumService.isPremium;

      // Cache the result with shorter TTL for premium status
      await _cacheService.put(
        cacheKey,
        isPremium,
        ttl: DiagnosticoPerformanceConstants.premiumTimeout,
      );

      return isPremium;
    } catch (e) {
      // Fallback to direct service access on cache error
      return _premiumService.isPremium;
    }
  }

  /// Optimized diagnostic data fetching
  Future<DiagnosticData?> _fetchDiagnosticDataOptimized(String id) async {
    try {
      // Find diagnostic with early return if not found
      final diagList = _databaseRepository.gDiagnosticos
          .where((d) => d.toJson()['idReg'] == id)
          .toList();

      if (diagList.isEmpty) {
        return null;
      }

      final diag = diagList.first.toJson();
      final String? defensivoId = diag['fkIdDefensivo'] as String?;
      final String? pragaId = diag['fkIdPraga'] as String?;
      final String? culturaId = diag['fkIdCultura'] as String?;

      if (defensivoId == null || defensivoId.isEmpty) {
        return null;
      }

      // Parallel lookup of related data
      final futures = [
        _findItemById(_databaseRepository.gFitossanitarios, defensivoId),
        _findItemById(_databaseRepository.gPragas, pragaId),
        _findItemById(_databaseRepository.gCulturas, culturaId),
        _findFitossanitarioInfo(defensivoId),
      ];

      final results = await Future.wait(futures);

      return DiagnosticData(
        diag: diag,
        fito: results[0],
        praga: results[1],
        cultura: results[2],
        info: results[3],
      );
    } catch (e) {
      throw Exception('Error fetching diagnostic data: $e');
    }
  }

  /// Helper method to find item by ID
  Future<Map<String, dynamic>> _findItemById(
      List<dynamic> collection, String? id) async {
    if (id == null || id.isEmpty) return <String, dynamic>{};

    final items =
        collection.where((item) => item.toJson()['idReg'] == id).toList();

    return items.isNotEmpty ? items.first.toJson() : <String, dynamic>{};
  }

  /// Helper method to find fitossanitario info
  Future<Map<String, dynamic>> _findFitossanitarioInfo(
      String defensivoId) async {
    final infoList = _databaseRepository.gFitossanitariosInfo
        .where((info) => info.toJson()['fkIdDefensivo'] == defensivoId)
        .toList();

    return infoList.isNotEmpty ? infoList.first.toJson() : <String, dynamic>{};
  }

  /// Gets timeout for specific operation
  Duration _getTimeoutForOperation(String operation) {
    switch (operation) {
      case 'diagnostic':
        return DiagnosticoPerformanceConstants.dataLoadingTimeout;
      case 'favorite':
        return DiagnosticoPerformanceConstants.favoriteTimeout;
      case 'premium':
        return DiagnosticoPerformanceConstants.premiumTimeout;
      default:
        return DiagnosticoPerformanceConstants.dataLoadingTimeout;
    }
  }

  /// Gets timeout fallback function
  dynamic Function() _getTimeoutFallback(String operation) {
    switch (operation) {
      case 'diagnostic':
        return () => null;
      case 'favorite':
        return () => false;
      case 'premium':
        return () => false;
      default:
        return () => null;
    }
  }

  /// Gets fallback data for failed operations
  dynamic _getFallbackData(String operation) {
    switch (operation) {
      case 'diagnostic':
        return null;
      case 'favorite':
        return false;
      case 'premium':
        return false;
      default:
        return null;
    }
  }

  /// Completes the future with results
  void _completeWithResults(
    Completer<DiagnosticoLoadResult> completer,
    Map<String, dynamic> results,
    Map<String, dynamic> errors, {
    bool isPartial = false,
  }) {
    if (!completer.isCompleted) {
      completer.complete(DiagnosticoLoadResult(
        diagnosticData: results['diagnostic'] as DiagnosticData?,
        isFavorite: results['favorite'] as bool? ?? false,
        isPremium: results['premium'] as bool? ?? false,
        errors: errors,
        isPartial: isPartial,
      ));
    }
  }

  /// Clears cache for a specific diagnostic using unified cache
  Future<void> clearDiagnosticoCache(String diagnosticoId) async {
    final keys = [
      '${DiagnosticoPerformanceConstants.diagnosticoCacheKey}_$diagnosticoId',
      '${DiagnosticoPerformanceConstants.favoriteCacheKey}_$diagnosticoId',
    ];

    try {
      for (final key in keys) {
        await _cacheService.remove(key);
      }
    } catch (e) {
      // Silent error for cache clearing
    }
  }

  /// Clears premium status cache using unified cache
  Future<void> clearPremiumCache() async {
    try {
      await _cacheService.remove(DiagnosticoPerformanceConstants.premiumCacheKey);
    } catch (e) {
      // Silent error for cache clearing
    }
  }

  /// Clears cache entries by pattern using unified cache
  Future<void> clearCacheByPattern(String pattern) async {
    try {
      await _cacheService.clearByPattern(pattern);
    } catch (e) {
      // Silent error for cache clearing
    }
  }

  /// Gets cache statistics from unified cache service
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final overallStats = await _cacheService.getStats();
      final keys = await _cacheService.getKeys();
      
      final diagnosticoKeys = keys.where((key) => 
        key.contains(DiagnosticoPerformanceConstants.diagnosticoCacheKey) ||
        key.contains(DiagnosticoPerformanceConstants.favoriteCacheKey) ||
        key.contains(DiagnosticoPerformanceConstants.premiumCacheKey)
      ).toList();
      
      return {
        'strategy': 'unified_cache_service',
        'diagnosticoRelatedEntries': diagnosticoKeys.length,
        'diagnosticoKeys': diagnosticoKeys,
        'overallCacheStats': overallStats,
        'cacheService': 'UnifiedCacheService',
      };
    } catch (e) {
      return {
        'strategy': 'unified_cache_service',
        'error': e.toString(),
        'diagnosticoRelatedEntries': 0,
      };
    }
  }

  /// Clears all diagnostic-related cache using unified cache
  Future<void> clearAllCache() async {
    try {
      // Clear diagnostic-related entries by pattern
      await _cacheService.clearByPattern(DiagnosticoPerformanceConstants.diagnosticoCacheKey);
      await _cacheService.clearByPattern(DiagnosticoPerformanceConstants.favoriteCacheKey);
      await _cacheService.remove(DiagnosticoPerformanceConstants.premiumCacheKey);
    } catch (e) {
      // Silent error for cache clearing
    }
  }
  
  /// Preload diagnostic data with unified cache
  Future<void> preloadDiagnosticoData(String diagnosticoId) async {
    try {
      // Preload in background for better user experience
      final futures = [
        _loadDiagnosticDataWithUnifiedCache(diagnosticoId),
        _loadFavoriteStatusWithUnifiedCache(diagnosticoId),
        _loadPremiumStatusWithUnifiedCache(),
      ];
      
      await Future.wait(futures);
    } catch (e) {
      // Silent error for preload failures
    }
  }
  
  /// Batch preload multiple diagnosticos
  Future<void> batchPreloadDiagnosticos(List<String> diagnosticoIds) async {
    try {
      final futures = diagnosticoIds
          .map((id) => preloadDiagnosticoData(id))
          .toList();
      
      await Future.wait(futures);
    } catch (e) {
      // Silent error for batch preload failures
    }
  }
  
  /// Get cache health metrics
  Future<Map<String, dynamic>> getCacheHealthMetrics() async {
    try {
      final stats = await getCacheStats();
      final keys = await _cacheService.getKeys();
      
      final diagnosticoKeys = keys.where((key) => 
        key.contains(DiagnosticoPerformanceConstants.diagnosticoCacheKey)
      ).length;
      
      final favoriteKeys = keys.where((key) => 
        key.contains(DiagnosticoPerformanceConstants.favoriteCacheKey)
      ).length;
      
      final hasPremiumCache = await _cacheService.has(
        DiagnosticoPerformanceConstants.premiumCacheKey
      );
      
      return {
        'healthy': true,
        'diagnosticoCachedCount': diagnosticoKeys,
        'favoriteCachedCount': favoriteKeys,
        'premiumCached': hasPremiumCache,
        'totalDiagnosticoEntries': diagnosticoKeys + favoriteKeys + (hasPremiumCache ? 1 : 0),
        'cacheStrategy': 'unified_cache_service',
        'overallHealth': stats,
      };
    } catch (e) {
      return {
        'healthy': false,
        'error': e.toString(),
        'cacheStrategy': 'unified_cache_service',
      };
    }
  }
}

/// Result model for parallel diagnostic loading
class DiagnosticoLoadResult {
  final DiagnosticData? diagnosticData;
  final bool isFavorite;
  final bool isPremium;
  final Map<String, dynamic> errors;
  final bool isPartial;

  DiagnosticoLoadResult({
    required this.diagnosticData,
    required this.isFavorite,
    required this.isPremium,
    required this.errors,
    this.isPartial = false,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccessful => diagnosticData != null && !hasErrors;
}
