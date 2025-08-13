// Unified bindings system replacing the chaotic injection system
// Single source of truth for all dependency management

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/logging_service.dart';
import 'dependency_providers.dart';
import 'unified_injection_container.dart';

/// Unified bindings for the Receituagro module
/// Replaces ServiceRegistry, LazyLoadingConfig, and GetX bindings with a single system
class UnifiedReceituagroBindings extends Bindings {
  static final UnifiedInjectionContainer _container = UnifiedInjectionContainer.instance;
  
  // Initialization state management
  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static final Object _initializationLock = Object();

  @override
  void dependencies() {
    if (_isInitialized) {
      LoggingService.info('Dependencies already initialized', tag: 'UnifiedBindings');
      return;
    }

    if (_isInitializing) {
      LoggingService.info('Initialization already in progress', tag: 'UnifiedBindings');
      return;
    }

    _isInitializing = true;

    try {
      LoggingService.info('Starting unified dependency initialization', tag: 'UnifiedBindings');
      
      // Initialize all providers in correct order
      DependencyUtils.initializeAllProviders();
      
      // Register this bindings instance for access
      _container.register<UnifiedReceituagroBindings>(
        () => this,
        lifecycle: DependencyLifecycle.singleton,
        loadingStrategy: LazyLoadingStrategy.immediate,
      );

      _isInitialized = true;
      LoggingService.info('Unified dependencies initialized successfully', tag: 'UnifiedBindings');

    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to initialize unified dependencies',
        tag: 'UnifiedBindings',
        error: e,
        stackTrace: stackTrace,
      );
      _isInitialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// Initialize dependencies with proper error handling and retries
  static Future<void> initializeDependencies({int maxRetries = 3}) async {
    if (_isInitialized) {
      LoggingService.info('Dependencies already initialized', tag: 'UnifiedBindings');
      return;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        LoggingService.info('Dependency initialization attempt $attempt/$maxRetries', tag: 'UnifiedBindings');
        
        // Synchronous initialization
        final bindings = UnifiedReceituagroBindings();
        bindings.dependencies();

        // Asynchronous preloading of critical dependencies
        await DependencyUtils.preloadCriticalDependencies();

        // Predictive preloading
        await _container.preloadPredictiveDependencies();

        LoggingService.info('All dependencies initialized and preloaded', tag: 'UnifiedBindings');
        return; // Success

      } catch (e, stackTrace) {
        LoggingService.error(
          'Initialization attempt $attempt failed',
          tag: 'UnifiedBindings',
          error: e,
          stackTrace: stackTrace,
        );

        if (attempt == maxRetries) {
          LoggingService.error(
            'All initialization attempts failed, trying fallback',
            tag: 'UnifiedBindings',
            error: e,
          );
          
          // Fallback initialization with minimal dependencies
          await _initializeFallback();
          return;
        }

        // Wait before retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  /// Fallback initialization with minimal dependencies
  static Future<void> _initializeFallback() async {
    try {
      LoggingService.warning('Using fallback initialization', tag: 'UnifiedBindings');

      // Register minimal essential services
      _container.register<LoggingService>(
        () => LoggingService(),
        lifecycle: DependencyLifecycle.singleton,
        loadingStrategy: LazyLoadingStrategy.immediate,
      );

      _isInitialized = true;
      LoggingService.info('Fallback initialization completed', tag: 'UnifiedBindings');

    } catch (e, stackTrace) {
      LoggingService.error(
        'Fallback initialization also failed',
        tag: 'UnifiedBindings',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if dependencies are initialized
  static bool get isInitialized => _isInitialized;

  /// Force reinitialize all dependencies (use with caution)
  static Future<void> reinitialize() async {
    LoggingService.warning('Forcing reinitialization of all dependencies', tag: 'UnifiedBindings');
    
    // Clear all dependencies
    _container.clearAll();
    
    // Reset state
    _isInitialized = false;
    _isInitializing = false;
    
    // Reinitialize
    await initializeDependencies();
  }

  /// Get system statistics
  static Map<String, dynamic> getSystemStats() {
    final containerStats = _container.getStats();
    final healthCheck = DependencyUtils.checkHealth();
    
    return {
      'initialized': _isInitialized,
      'initializing': _isInitializing,
      'container': containerStats,
      'health': healthCheck,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get detailed system information
  static Map<String, dynamic> getDetailedSystemInfo() {
    return {
      'dependencies': _container.getDependencyDetails(),
      'stats': getSystemStats(),
      'providers': {
        'services': 'ServiceProvider - Core application services',
        'repositories': 'RepositoryProvider - Data access layer',
        'controllers': 'ControllerProvider - UI controllers',
        'factories': 'FactoryProvider - Factory functions',
      },
    };
  }

  /// Perform system health check
  static bool performHealthCheck() {
    try {
      final healthInfo = DependencyUtils.checkHealth();
      final isHealthy = healthInfo['isHealthy'] as bool;
      
      if (!isHealthy) {
        LoggingService.warning(
          'System health check failed',
          tag: 'UnifiedBindings',
        );
        
        final recommendations = healthInfo['recommendations'] as List<String>;
        for (final recommendation in recommendations) {
          LoggingService.info('Recommendation: $recommendation', tag: 'UnifiedBindings');
        }
      }
      
      return isHealthy;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Health check failed with error',
        tag: 'UnifiedBindings',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Cleanup system resources
  static void cleanup() {
    try {
      DependencyUtils.cleanup();
      LoggingService.info('System cleanup completed', tag: 'UnifiedBindings');
    } catch (e, stackTrace) {
      LoggingService.error(
        'System cleanup failed',
        tag: 'UnifiedBindings',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generate performance report
  static String generatePerformanceReport({bool detailed = false}) {
    final stats = getSystemStats();
    final containerStats = stats['container'] as Map<String, dynamic>;
    final healthStats = stats['health'] as Map<String, dynamic>;

    final buffer = StringBuffer();
    
    buffer.writeln('=== Unified Dependency System Report ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Initialized: ${stats['initialized']}');
    buffer.writeln();
    
    buffer.writeln('=== Performance Metrics ===');
    buffer.writeln('Total Registrations: ${containerStats['totalRegistrations']}');
    buffer.writeln('Total Resolutions: ${containerStats['totalResolutions']}');
    buffer.writeln('Active Dependencies: ${containerStats['activeDependencies']}');
    buffer.writeln('Cache Hit Ratio: ${(containerStats['hitRatio'] * 100).toStringAsFixed(1)}%');
    buffer.writeln('Average Load Time: ${containerStats['averageLoadTime'].toStringAsFixed(2)}ms');
    buffer.writeln();

    buffer.writeln('=== Health Status ===');
    buffer.writeln('System Healthy: ${healthStats['isHealthy']}');
    buffer.writeln('Total Dependencies: ${healthStats['totalDependencies']}');
    
    final recommendations = healthStats['recommendations'] as List<String>;
    if (recommendations.isNotEmpty) {
      buffer.writeln('\n=== Recommendations ===');
      for (int i = 0; i < recommendations.length; i++) {
        buffer.writeln('${i + 1}. ${recommendations[i]}');
      }
    }

    if (detailed) {
      buffer.writeln('\n=== Dependency Breakdown ===');
      final byLifecycle = containerStats['dependenciesByLifecycle'] as Map<String, dynamic>;
      for (final entry in byLifecycle.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }

      buffer.writeln('\n=== Loading Strategies ===');
      final byStrategy = containerStats['dependenciesByLoadingStrategy'] as Map<String, dynamic>;
      for (final entry in byStrategy.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
    }

    return buffer.toString();
  }
}