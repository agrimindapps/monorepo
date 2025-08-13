// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../cache/i_cache_service.dart';

/// Refactored RouteManager with unified cache service integration
/// Maintains backward compatibility while leveraging centralized cache
class RouteManager {
  static RouteManager? _instance;
  static RouteManager get instance => _instance ??= RouteManager._internal();
  
  RouteManager._internal();

  // Cache keys for unified cache service
  static const String _routeCachePrefix = 'route_cache_';
  static const String _versionCacheKey = 'route_manager_version';
  static const String _metricsCacheKey = 'route_manager_metrics';
  static const Duration _routeCacheTtl = Duration(hours: 24);
  
  // Legacy static cache for backward compatibility and performance
  static final Set<String> _registeredRoutes = <String>{};
  static final Map<String, GetPage> _routeCache = <String, GetPage>{};
  static String _cachedVersion = '';
  
  // Unified cache service integration
  ICacheService? _cacheService;
  bool _unifiedCacheEnabled = false;
  
  // Metrics
  static int _totalRegistrationCalls = 0;
  static int _actualRegistrations = 0;
  static int _duplicatesPrevented = 0;
  
  bool _isInitialized = false;

  /// Initialize cache service integration
  void _initializeCacheService() {
    try {
      _cacheService = Get.find<ICacheService>();
      _unifiedCacheEnabled = true;
      debugPrint('🗄️ RouteManager: Unified cache service integrated');
    } catch (e) {
      _unifiedCacheEnabled = false;
      debugPrint('⚠️ RouteManager: Unified cache service not available, using legacy cache');
    }
  }

  /// Register routes with unified cache integration
  Future<RouteRegistrationResult> registerRoutes(
    List<GetPage> routes, {
    String? version,
    bool forceRefresh = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _totalRegistrationCalls++;
      
      // Initialize cache service if not done yet
      if (!_unifiedCacheEnabled && _cacheService == null) {
        _initializeCacheService();
      }
      
      final currentVersion = version ?? '1.0.0';
      
      // Check version cache
      if (await _shouldInvalidateCacheUnified(currentVersion) || forceRefresh) {
        await _invalidateCache();
        _cachedVersion = currentVersion;
        
        // Update version in unified cache
        if (_unifiedCacheEnabled) {
          await _cacheService!.put(_versionCacheKey, currentVersion, ttl: _routeCacheTtl);
        }
      }

      // First initialization
      if (!_isInitialized) {
        await _loadExistingRoutes();
        _isInitialized = true;
      }

      final result = await _processRoutes(routes);
      
      stopwatch.stop();
      
      // Cache metrics if unified cache is enabled
      await _updateMetricsCache();
      
      _logRegistrationMetrics(result, stopwatch.elapsedMicroseconds);
      
      return result;
      
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('❌ RouteManager: Erro durante registro de rotas: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      
      return RouteRegistrationResult.error(
        error: e.toString(),
        duration: stopwatch.elapsedMicroseconds,
      );
    }
  }

  /// Process routes with unified cache support
  Future<RouteRegistrationResult> _processRoutes(List<GetPage> routes) async {
    final newRoutes = <GetPage>[];
    final duplicates = <String>[];
    final errors = <String>[];

    for (final route in routes) {
      try {
        if (_isRouteDuplicate(route.name)) {
          duplicates.add(route.name);
          _duplicatesPrevented++;
          continue;
        }

        // Register in GetX
        Get.addPage(route);
        
        // Add to cache
        _addToCache(route);
        newRoutes.add(route);
        _actualRegistrations++;
        
      } catch (e) {
        errors.add('Erro ao registrar rota ${route.name}: $e');
      }
    }

    return RouteRegistrationResult.success(
      registeredRoutes: newRoutes,
      duplicateRoutes: duplicates,
      errors: errors,
      totalRequested: routes.length,
      totalRegistered: newRoutes.length,
      totalDuplicates: duplicates.length,
    );
  }

  /// Check for route duplication
  bool _isRouteDuplicate(String routeName) {
    return _registeredRoutes.contains(routeName);
  }

  /// Add route to both legacy and unified cache
  void _addToCache(GetPage route) {
    // Legacy cache
    _registeredRoutes.add(route.name);
    _routeCache[route.name] = route;
    
    // Unified cache (async, fire and forget for performance)
    if (_unifiedCacheEnabled && _cacheService != null) {
      _addRouteToUnifiedCache(route);
    }
  }

  /// Add route to unified cache (async)
  void _addRouteToUnifiedCache(GetPage route) {
    Future(() async {
      try {
        final cacheKey = '$_routeCachePrefix${route.name}';
        await _cacheService!.put(
          cacheKey,
          {
            'name': route.name,
            'registeredAt': DateTime.now().toIso8601String(),
            'type': 'route_metadata',
          },
          ttl: _routeCacheTtl,
        );
      } catch (e) {
        // Silent error for unified cache failures
        debugPrint('⚠️ RouteManager: Failed to cache route ${route.name} in unified cache: $e');
      }
    });
  }

  /// Load existing routes
  Future<void> _loadExistingRoutes() async {
    try {
      final existingRoutes = Get.routeTree.routes;
      
      for (final route in existingRoutes) {
        _registeredRoutes.add(route.name);
      }
      
      debugPrint('📋 RouteManager: Carregadas ${existingRoutes.length} rotas existentes do GetX');
      
    } catch (e) {
      debugPrint('⚠️ RouteManager: Erro ao carregar rotas existentes: $e');
    }
  }

  /// Check if cache should be invalidated (unified cache version)
  Future<bool> _shouldInvalidateCacheUnified(String newVersion) async {
    if (!_unifiedCacheEnabled || _cacheService == null) {
      return _cachedVersion.isEmpty || _cachedVersion != newVersion;
    }
    
    try {
      final cachedVersion = await _cacheService!.get<String>(_versionCacheKey);
      return cachedVersion == null || cachedVersion != newVersion;
    } catch (e) {
      return true; // Invalidate on error
    }
  }

  /// Invalidate cache (both legacy and unified)
  Future<void> _invalidateCache() async {
    debugPrint('🔄 RouteManager: Invalidando cache de rotas');
    
    // Clear legacy cache
    _registeredRoutes.clear();
    _routeCache.clear();
    _isInitialized = false;
    
    // Clear unified cache
    if (_unifiedCacheEnabled && _cacheService != null) {
      try {
        await _cacheService!.clearByPrefix(_routeCachePrefix);
        await _cacheService!.remove(_versionCacheKey);
      } catch (e) {
        debugPrint('⚠️ RouteManager: Failed to clear unified cache: $e');
      }
    }
  }

  /// Update metrics in unified cache
  Future<void> _updateMetricsCache() async {
    if (!_unifiedCacheEnabled || _cacheService == null) return;
    
    try {
      final metrics = {
        'totalRegistrationCalls': _totalRegistrationCalls,
        'actualRegistrations': _actualRegistrations,
        'duplicatesPrevented': _duplicatesPrevented,
        'cacheSize': _registeredRoutes.length,
        'lastUpdated': DateTime.now().toIso8601String(),
        'strategy': 'unified_cache_service',
      };
      
      await _cacheService!.put(_metricsCacheKey, metrics, ttl: _routeCacheTtl);
    } catch (e) {
      // Silent error for metrics caching
    }
  }

  /// Log registration metrics
  void _logRegistrationMetrics(RouteRegistrationResult result, int microseconds) {
    final milliseconds = (microseconds / 1000).toStringAsFixed(2);
    
    debugPrint('📊 RouteManager: Registro concluído em ${milliseconds}ms');
    debugPrint('   • Solicitadas: ${result.totalRequested}');
    debugPrint('   • Registradas: ${result.totalRegistered}');
    debugPrint('   • Duplicatas: ${result.totalDuplicates}');
    debugPrint('   • Erros: ${result.errors.length}');
    debugPrint('   • Cache size: ${_registeredRoutes.length}');
    debugPrint('   • Strategy: ${_unifiedCacheEnabled ? 'unified' : 'legacy'} cache');
  }

  /// Remove route from both caches
  void removeRoute(String routeName) {
    // Legacy cache
    _registeredRoutes.remove(routeName);
    _routeCache.remove(routeName);
    
    // Unified cache (async)
    if (_unifiedCacheEnabled && _cacheService != null) {
      Future(() async {
        try {
          final cacheKey = '$_routeCachePrefix$routeName';
          await _cacheService!.remove(cacheKey);
        } catch (e) {
          // Silent error
        }
      });
    }
  }

  /// Check if route is registered
  bool isRouteRegistered(String routeName) {
    return _registeredRoutes.contains(routeName);
  }

  /// Get cached route (try legacy first, then unified)
  GetPage? getCachedRoute(String routeName) {
    return _routeCache[routeName];
  }

  /// Get route metadata from unified cache
  Future<Map<String, dynamic>?> getRouteMetadata(String routeName) async {
    if (!_unifiedCacheEnabled || _cacheService == null) return null;
    
    try {
      final cacheKey = '$_routeCachePrefix$routeName';
      return await _cacheService!.get<Map<String, dynamic>>(cacheKey);
    } catch (e) {
      return null;
    }
  }

  /// Get metrics (enhanced with unified cache data)
  Future<Map<String, dynamic>> getMetrics() async {
    final basicMetrics = {
      'totalRegistrationCalls': _totalRegistrationCalls,
      'actualRegistrations': _actualRegistrations,
      'duplicatesPrevented': _duplicatesPrevented,
      'cacheSize': _registeredRoutes.length,
      'isInitialized': _isInitialized,
      'currentVersion': _cachedVersion,
      'unifiedCacheEnabled': _unifiedCacheEnabled,
      'strategy': _unifiedCacheEnabled ? 'unified_cache_service' : 'legacy_cache',
    };

    if (_unifiedCacheEnabled && _cacheService != null) {
      try {
        final cachedMetrics = await _cacheService!.get<Map<String, dynamic>>(_metricsCacheKey);
        if (cachedMetrics != null) {
          basicMetrics['cachedMetrics'] = cachedMetrics;
        }
        
        final cacheStats = await _cacheService!.getStats();
        basicMetrics['overallCacheStats'] = cacheStats;
      } catch (e) {
        basicMetrics['cacheError'] = e.toString();
      }
    }

    return basicMetrics;
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final stats = <String, dynamic>{
      'legacyCacheSize': _registeredRoutes.length,
      'strategy': _unifiedCacheEnabled ? 'unified' : 'legacy',
    };

    if (_unifiedCacheEnabled && _cacheService != null) {
      try {
        final keys = await _cacheService!.getKeys();
        final routeKeys = keys.where((key) => key.startsWith(_routeCachePrefix));
        
        stats['unifiedCacheRoutes'] = routeKeys.length;
        stats['overallCacheStats'] = await _cacheService!.getStats();
      } catch (e) {
        stats['unifiedCacheError'] = e.toString();
      }
    }

    return stats;
  }

  /// Clear all cache (both legacy and unified)
  Future<void> clearAllCache() async {
    // Clear legacy
    _registeredRoutes.clear();
    _routeCache.clear();
    _isInitialized = false;
    _cachedVersion = '';
    
    // Clear unified
    if (_unifiedCacheEnabled && _cacheService != null) {
      try {
        await _cacheService!.clearByPrefix(_routeCachePrefix);
        await _cacheService!.remove(_versionCacheKey);
        await _cacheService!.remove(_metricsCacheKey);
      } catch (e) {
        debugPrint('⚠️ RouteManager: Failed to clear unified cache: $e');
      }
    }
    
    debugPrint('🧹 RouteManager: All cache cleared');
  }

  /// Reset metrics
  void resetMetrics() {
    _totalRegistrationCalls = 0;
    _actualRegistrations = 0;
    _duplicatesPrevented = 0;
  }

  /// Full reset
  Future<void> reset() async {
    await clearAllCache();
    resetMetrics();
  }

  /// Lazy route registration with unified cache support
  Future<bool> registerLazyRoute(
    String routeName,
    GetPage Function() routeFactory,
  ) async {
    if (_isRouteDuplicate(routeName)) {
      return false;
    }

    try {
      final route = routeFactory();
      final result = await registerRoutes([route]);
      return result.isSuccess && result.totalRegistered > 0;
    } catch (e) {
      debugPrint('❌ RouteManager: Erro no registro lazy de $routeName: $e');
      return false;
    }
  }
}

/// Route registration result (unchanged for backward compatibility)
class RouteRegistrationResult {
  final bool isSuccess;
  final List<GetPage> registeredRoutes;
  final List<String> duplicateRoutes;
  final List<String> errors;
  final int totalRequested;
  final int totalRegistered;
  final int totalDuplicates;
  final int duration;
  final String? error;

  const RouteRegistrationResult._({
    required this.isSuccess,
    required this.registeredRoutes,
    required this.duplicateRoutes,
    required this.errors,
    required this.totalRequested,
    required this.totalRegistered,
    required this.totalDuplicates,
    required this.duration,
    this.error,
  });

  factory RouteRegistrationResult.success({
    required List<GetPage> registeredRoutes,
    required List<String> duplicateRoutes,
    required List<String> errors,
    required int totalRequested,
    required int totalRegistered,
    required int totalDuplicates,
    int duration = 0,
  }) {
    return RouteRegistrationResult._(
      isSuccess: true,
      registeredRoutes: registeredRoutes,
      duplicateRoutes: duplicateRoutes,
      errors: errors,
      totalRequested: totalRequested,
      totalRegistered: totalRegistered,
      totalDuplicates: totalDuplicates,
      duration: duration,
    );
  }

  factory RouteRegistrationResult.error({
    required String error,
    int duration = 0,
  }) {
    return RouteRegistrationResult._(
      isSuccess: false,
      registeredRoutes: [],
      duplicateRoutes: [],
      errors: [error],
      totalRequested: 0,
      totalRegistered: 0,
      totalDuplicates: 0,
      duration: duration,
      error: error,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasDuplicates => totalDuplicates > 0;
  double get successRate => totalRequested > 0 
      ? (totalRegistered / totalRequested) 
      : 0.0;
}

/// Route manager metrics (unchanged for backward compatibility)
class RouteManagerMetrics {
  final int totalRegistrationCalls;
  final int actualRegistrations;
  final int duplicatesPrevented;
  final int cacheSize;
  final bool isInitialized;
  final String currentVersion;

  const RouteManagerMetrics({
    required this.totalRegistrationCalls,
    required this.actualRegistrations,
    required this.duplicatesPrevented,
    required this.cacheSize,
    required this.isInitialized,
    required this.currentVersion,
  });

  double get efficiencyRate => totalRegistrationCalls > 0
      ? (duplicatesPrevented / totalRegistrationCalls)
      : 0.0;

  @override
  String toString() {
    return 'RouteManagerMetrics('
        'calls: $totalRegistrationCalls, '
        'registered: $actualRegistrations, '
        'duplicates: $duplicatesPrevented, '
        'cache: $cacheSize, '
        'efficiency: ${(efficiencyRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}