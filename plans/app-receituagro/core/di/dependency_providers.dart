// Specialized dependency providers for different types of dependencies
// Provides type-safe registration and retrieval with proper lifecycle management

// Package imports:
import 'package:get/get.dart';

import '../../../core/services/localstorage_service.dart';
import '../../../core/services/logging_service.dart';
// Project imports:
import '../../core/navigation/enhanced_navigation_controller.dart';
import '../../repository/culturas_repository.dart';
import '../../repository/database_repository.dart';
import '../../repository/defensivos_repository.dart';
import '../../repository/diagnostico_repository.dart';
import '../../repository/favoritos_repository.dart';
import '../../repository/pragas_repository.dart';
import '../../services/mock_admob_service.dart';
import '../../services/premium_service.dart';
import '../cache/enhanced_unified_cache_service.dart';
import '../cache/i_cache_service.dart';
import 'unified_injection_container.dart';

/// Service provider for core application services
class ServiceProvider {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;

  /// Register all core services
  static void registerAll() {
    registerCacheServices();
    registerStorageServices();
    registerNavigationServices();
    registerBusinessServices();
  }

  /// Register cache-related services
  static void registerCacheServices() {
    // Enhanced cache service as singleton with immediate loading
    _container.register<ICacheService>(
      () => EnhancedUnifiedCacheService(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.immediate,
      priority: 100, // High priority for cache
    );

    // Direct access to enhanced cache if needed
    _container.register<EnhancedUnifiedCacheService>(
      () => Get.find<ICacheService>() as EnhancedUnifiedCacheService,
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
      dependencies: [ICacheService],
    );
  }

  /// Register storage services
  static void registerStorageServices() {
    _container.register<LocalStorageService>(
      () => LocalStorageService(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.immediate,
      priority: 90,
    );
  }

  /// Register navigation services
  static void registerNavigationServices() {
    _container.register<EnhancedNavigationController>(
      () => EnhancedNavigationController(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.immediate,
      priority: 85,
    );
  }

  /// Register business services
  static void registerBusinessServices() {
    // Premium service with async initialization
    _container.registerAsync<PremiumService>(
      () async => await PremiumService().init(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
      dependencies: [LocalStorageService],
    );

    // Mock AdMob service
    _container.register<MockAdmobService>(
      () => MockAdmobService(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
    );
  }

  /// Get cache service
  static Future<ICacheService> getCacheService() async {
    return await _container.get<ICacheService>();
  }

  /// Get storage service
  static Future<LocalStorageService> getStorageService() async {
    return await _container.get<LocalStorageService>();
  }

  /// Get navigation service
  static Future<EnhancedNavigationController> getNavigationService() async {
    return await _container.get<EnhancedNavigationController>();
  }

  /// Get premium service
  static Future<PremiumService> getPremiumService() async {
    return await _container.get<PremiumService>();
  }
}

/// Repository provider for data access layer
class RepositoryProvider {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;

  /// Register all repositories
  static void registerAll() {
    // Database repository first (others depend on it)
    _container.register<DatabaseRepository>(
      () => DatabaseRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.immediate,
      priority: 95,
    );

    // Core repositories
    _container.register<DefensivosRepository>(
      () => DefensivosRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.predictive,
      dependencies: [DatabaseRepository],
      priority: 80,
    );

    _container.register<PragasRepository>(
      () => PragasRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.predictive,
      dependencies: [DatabaseRepository],
      priority: 80,
    );

    _container.register<DiagnosticoRepository>(
      () => DiagnosticoRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
      dependencies: [DatabaseRepository],
      priority: 70,
    );

    _container.register<CulturaRepository>(
      () => CulturaRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
      dependencies: [DatabaseRepository],
      priority: 60,
    );

    _container.register<FavoritosRepository>(
      () => FavoritosRepository(),
      lifecycle: DependencyLifecycle.singleton,
      loadingStrategy: LazyLoadingStrategy.onDemand,
      dependencies: [LocalStorageService],
      priority: 50,
    );
  }

  /// Get database repository
  static Future<DatabaseRepository> getDatabaseRepository() async {
    return await _container.get<DatabaseRepository>();
  }

  /// Get defensivos repository
  static Future<DefensivosRepository> getDefensivosRepository() async {
    return await _container.get<DefensivosRepository>();
  }

  /// Get pragas repository
  static Future<PragasRepository> getPragasRepository() async {
    return await _container.get<PragasRepository>();
  }

  /// Get diagnostico repository
  static Future<DiagnosticoRepository> getDiagnosticoRepository() async {
    return await _container.get<DiagnosticoRepository>();
  }

  /// Get cultura repository
  static Future<CulturaRepository> getCulturaRepository() async {
    return await _container.get<CulturaRepository>();
  }

  /// Get favoritos repository
  static Future<FavoritosRepository> getFavoritosRepository() async {
    return await _container.get<FavoritosRepository>();
  }
}

/// Controller provider for UI controllers with proper lifecycle
class ControllerProvider {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;

  /// Register controller factory (controllers are created per page)
  static void registerControllerFactory<T extends GetxController>(
    T Function() factory, {
    String? tag,
    LazyLoadingStrategy loadingStrategy = LazyLoadingStrategy.onDemand,
    List<Type> dependencies = const [],
  }) {
    _container.register<T>(
      factory,
      tag: tag,
      lifecycle: DependencyLifecycle.transient, // Controllers are transient
      loadingStrategy: loadingStrategy,
      dependencies: dependencies,
    );
  }

  /// Get controller instance
  static Future<T> getController<T extends GetxController>({String? tag}) async {
    return await _container.get<T>(tag: tag);
  }

  /// Check if controller is registered
  static bool isControllerRegistered<T extends GetxController>({String? tag}) {
    return _container.isRegistered<T>(tag: tag);
  }
}

/// Factory provider for creating various factory functions
class FactoryProvider {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;

  /// Register a factory function
  static void registerFactory<T>(
    T Function() factory, {
    String? tag,
    LazyLoadingStrategy loadingStrategy = LazyLoadingStrategy.onDemand,
    List<Type> dependencies = const [],
  }) {
    _container.register<T>(
      factory,
      tag: tag,
      lifecycle: DependencyLifecycle.transient,
      loadingStrategy: loadingStrategy,
      dependencies: dependencies,
    );
  }

  /// Register an async factory function
  static void registerAsyncFactory<T>(
    Future<T> Function() asyncFactory, {
    String? tag,
    LazyLoadingStrategy loadingStrategy = LazyLoadingStrategy.onDemand,
    List<Type> dependencies = const [],
  }) {
    _container.registerAsync<T>(
      asyncFactory,
      tag: tag,
      lifecycle: DependencyLifecycle.transient,
      loadingStrategy: loadingStrategy,
      dependencies: dependencies,
    );
  }

  /// Create instance from factory
  static Future<T> create<T>({String? tag}) async {
    return await _container.get<T>(tag: tag);
  }
}

/// Utility provider for dependency management utilities
class DependencyUtils {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;

  /// Initialize all providers
  static void initializeAllProviders() {
    try {
      ServiceProvider.registerAll();
      RepositoryProvider.registerAll();
      
      LoggingService.info(
        'All dependency providers initialized successfully',
        tag: 'DependencyUtils',
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize dependency providers',
        tag: 'DependencyUtils',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Preload critical dependencies
  static Future<void> preloadCriticalDependencies() async {
    try {
      // Preload in order of priority
      await ServiceProvider.getCacheService();
      await ServiceProvider.getStorageService();
      await ServiceProvider.getNavigationService();
      await RepositoryProvider.getDatabaseRepository();
      
      LoggingService.info(
        'Critical dependencies preloaded successfully',
        tag: 'DependencyUtils',
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to preload critical dependencies',
        tag: 'DependencyUtils',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get dependency statistics
  static Map<String, dynamic> getStats() {
    return _container.getStats();
  }

  /// Get detailed dependency information
  static Map<String, dynamic> getDetailedInfo() {
    return _container.getDependencyDetails();
  }

  /// Cleanup transient dependencies
  static void cleanup() {
    _container.clearTransient();
    LoggingService.info('Cleaned up transient dependencies', tag: 'DependencyUtils');
  }

  /// Check system health
  static Map<String, dynamic> checkHealth() {
    final stats = _container.getStats();
    
    return {
      'isHealthy': stats['totalRegistrations'] > 0 && stats['hitRatio'] > 0.5,
      'totalDependencies': stats['activeDependencies'],
      'hitRatio': stats['hitRatio'],
      'averageLoadTime': stats['averageLoadTime'],
      'recommendations': _generateRecommendations(stats),
    };
  }

  static List<String> _generateRecommendations(Map<String, dynamic> stats) {
    final recommendations = <String>[];
    
    final hitRatio = stats['hitRatio'] as double;
    if (hitRatio < 0.7) {
      recommendations.add('Consider using more singleton dependencies to improve cache hit ratio');
    }
    
    final averageLoadTime = stats['averageLoadTime'] as double;
    if (averageLoadTime > 10.0) {
      recommendations.add('Some dependencies have slow loading times, consider preloading');
    }
    
    final activeDeps = stats['activeDependencies'] as int;
    if (activeDeps > 50) {
      recommendations.add('High number of active dependencies, consider cleanup strategies');
    }
    
    return recommendations;
  }
}