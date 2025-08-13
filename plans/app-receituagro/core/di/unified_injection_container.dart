// Unified dependency injection container
// Replaces ServiceRegistry, LazyLoadingConfig, and multiple DI systems with a single solution

// Dart imports:
import 'dart:async';
import 'dart:developer' as developer;

// Package imports:
import 'package:get/get.dart';

/// Dependency factory function
typedef DependencyFactory<T> = T Function();

/// Async dependency factory function
typedef AsyncDependencyFactory<T> = Future<T> Function();

/// Dependency lifecycle management
enum DependencyLifecycle {
  singleton,    // Single instance for entire app lifecycle
  transient,    // New instance every time
  scoped,       // Single instance per scope (e.g., per page)
}

/// Lazy loading strategy
enum LazyLoadingStrategy {
  immediate,    // Load immediately when registered
  onDemand,     // Load when first requested
  predictive,   // Load based on usage patterns
}

/// Dependency metadata
class DependencyMetadata {
  final Type type;
  final String? tag;
  final DependencyLifecycle lifecycle;
  final LazyLoadingStrategy loadingStrategy;
  final List<Type> dependencies;
  final DateTime registeredAt;
  final int priority;

  DependencyMetadata({
    required this.type,
    this.tag,
    required this.lifecycle,
    required this.loadingStrategy,
    required this.dependencies,
    required this.registeredAt,
    this.priority = 0,
  });
}

/// Dependency registration entry
class DependencyEntry<T> {
  final DependencyFactory<T>? factory;
  final AsyncDependencyFactory<T>? asyncFactory;
  final DependencyMetadata metadata;
  final Completer<T>? _asyncCompleter;
  
  T? _instance;
  bool _isLoading = false;
  bool _isLoaded = false;
  DateTime? _lastAccessed;
  int _accessCount = 0;

  DependencyEntry({
    this.factory,
    this.asyncFactory,
    required this.metadata,
  }) : _asyncCompleter = asyncFactory != null ? Completer<T>() : null;

  bool get isAsync => asyncFactory != null;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  DateTime? get lastAccessed => _lastAccessed;
  int get accessCount => _accessCount;

  Future<T> getInstance() async {
    _lastAccessed = DateTime.now();
    _accessCount++;

    // Return cached instance for singleton
    if (metadata.lifecycle == DependencyLifecycle.singleton && _instance != null) {
      return _instance!;
    }

    // Handle async dependency
    if (isAsync) {
      if (!_isLoading && !_isLoaded) {
        _isLoading = true;
        try {
          final instance = await asyncFactory!();
          _instance = instance;
          _isLoaded = true;
          _asyncCompleter!.complete(instance);
        } catch (e) {
          _asyncCompleter!.completeError(e);
          _isLoading = false;
          rethrow;
        }
        _isLoading = false;
      }

      if (_isLoaded && metadata.lifecycle == DependencyLifecycle.singleton) {
        return _instance!;
      }

      return await _asyncCompleter!.future;
    }

    // Handle sync dependency
    if (factory != null) {
      final instance = factory!();
      
      if (metadata.lifecycle == DependencyLifecycle.singleton) {
        _instance ??= instance;
        return _instance!;
      }
      
      return instance;
    }

    throw StateError('No factory available for ${metadata.type}');
  }

  void dispose() {
    if (_instance is GetxController) {
      (_instance as GetxController).dispose();
    }
    _instance = null;
    _isLoaded = false;
    _isLoading = false;
  }
}

/// Unified dependency injection container
class UnifiedInjectionContainer {
  static UnifiedInjectionContainer? _instance;
  static UnifiedInjectionContainer get instance => _instance ??= UnifiedInjectionContainer._();

  UnifiedInjectionContainer._();

  final Map<String, DependencyEntry> _dependencies = {};
  final Map<String, List<String>> _dependencyGraph = {};
  final Map<String, DateTime> _loadingTimes = {};
  final List<String> _loadingOrder = [];

  // Statistics
  int _totalRegistrations = 0;
  int _totalResolutions = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Register a synchronous dependency
  void register<T>(
    DependencyFactory<T> factory, {
    String? tag,
    DependencyLifecycle lifecycle = DependencyLifecycle.singleton,
    LazyLoadingStrategy loadingStrategy = LazyLoadingStrategy.onDemand,
    List<Type> dependencies = const [],
    int priority = 0,
  }) {
    final key = _generateKey<T>(tag);
    
    if (_dependencies.containsKey(key)) {
      developer.log('⚠️ Overriding existing dependency: $key');
    }

    final metadata = DependencyMetadata(
      type: T,
      tag: tag,
      lifecycle: lifecycle,
      loadingStrategy: loadingStrategy,
      dependencies: dependencies,
      registeredAt: DateTime.now(),
      priority: priority,
    );

    _dependencies[key] = DependencyEntry<T>(
      factory: factory,
      metadata: metadata,
    );

    _updateDependencyGraph<T>(dependencies);
    _totalRegistrations++;

    // Immediate loading if required
    if (loadingStrategy == LazyLoadingStrategy.immediate) {
      _preloadDependency<T>(tag);
    }

    developer.log('📦 Registered: $key (${lifecycle.name}, ${loadingStrategy.name})');
  }

  /// Register an asynchronous dependency
  void registerAsync<T>(
    AsyncDependencyFactory<T> asyncFactory, {
    String? tag,
    DependencyLifecycle lifecycle = DependencyLifecycle.singleton,
    LazyLoadingStrategy loadingStrategy = LazyLoadingStrategy.onDemand,
    List<Type> dependencies = const [],
    int priority = 0,
  }) {
    final key = _generateKey<T>(tag);
    
    if (_dependencies.containsKey(key)) {
      developer.log('⚠️ Overriding existing async dependency: $key');
    }

    final metadata = DependencyMetadata(
      type: T,
      tag: tag,
      lifecycle: lifecycle,
      loadingStrategy: loadingStrategy,
      dependencies: dependencies,
      registeredAt: DateTime.now(),
      priority: priority,
    );

    _dependencies[key] = DependencyEntry<T>(
      asyncFactory: asyncFactory,
      metadata: metadata,
    );

    _updateDependencyGraph<T>(dependencies);
    _totalRegistrations++;

    // Immediate loading if required
    if (loadingStrategy == LazyLoadingStrategy.immediate) {
      _preloadDependencyAsync<T>(tag);
    }

    developer.log('📦 Registered async: $key (${lifecycle.name}, ${loadingStrategy.name})');
  }

  /// Get a dependency instance
  Future<T> get<T>({String? tag}) async {
    final key = _generateKey<T>(tag);
    final entry = _dependencies[key];

    if (entry == null) {
      _cacheMisses++;
      throw StateError('Dependency not registered: $key');
    }

    _totalResolutions++;
    
    if (entry.isLoaded && entry.metadata.lifecycle == DependencyLifecycle.singleton) {
      _cacheHits++;
    } else {
      _cacheMisses++;
    }

    final startTime = DateTime.now();
    
    try {
      final instance = await entry.getInstance();
      
      final loadTime = DateTime.now().difference(startTime);
      _loadingTimes[key] = startTime;
      
      if (!_loadingOrder.contains(key)) {
        _loadingOrder.add(key);
      }

      developer.log('✅ Resolved: $key in ${loadTime.inMilliseconds}ms');
      return instance as T;
    } catch (e) {
      developer.log('❌ Failed to resolve: $key - $e');
      rethrow;
    }
  }

  /// Check if dependency is registered
  bool isRegistered<T>({String? tag}) {
    final key = _generateKey<T>(tag);
    return _dependencies.containsKey(key);
  }

  /// Remove a dependency
  void remove<T>({String? tag}) {
    final key = _generateKey<T>(tag);
    final entry = _dependencies[key];
    
    if (entry != null) {
      entry.dispose();
      _dependencies.remove(key);
      _dependencyGraph.remove(key);
      developer.log('🗑️ Removed: $key');
    }
  }

  /// Clear all non-permanent dependencies
  void clearTransient() {
    final keysToRemove = <String>[];
    
    for (final entry in _dependencies.entries) {
      if (entry.value.metadata.lifecycle == DependencyLifecycle.transient) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _dependencies[key]?.dispose();
      _dependencies.remove(key);
    }

    developer.log('🧹 Cleared ${keysToRemove.length} transient dependencies');
  }

  /// Clear all dependencies
  void clearAll() {
    for (final entry in _dependencies.values) {
      entry.dispose();
    }
    
    _dependencies.clear();
    _dependencyGraph.clear();
    _loadingTimes.clear();
    _loadingOrder.clear();
    
    _totalRegistrations = 0;
    _totalResolutions = 0;
    _cacheHits = 0;
    _cacheMisses = 0;

    developer.log('🧹 Cleared all dependencies');
  }

  /// Get dependency statistics
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    
    return {
      'totalRegistrations': _totalRegistrations,
      'totalResolutions': _totalResolutions,
      'activeDependencies': _dependencies.length,
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRatio': _totalResolutions > 0 ? _cacheHits / _totalResolutions : 0.0,
      'dependencyGraph': Map<String, List<String>>.from(_dependencyGraph),
      'loadingOrder': List<String>.from(_loadingOrder),
      'dependenciesByType': _groupDependenciesByType(),
      'dependenciesByLifecycle': _groupDependenciesByLifecycle(),
      'dependenciesByLoadingStrategy': _groupDependenciesByLoadingStrategy(),
      'averageLoadTime': _calculateAverageLoadTime(),
      'generatedAt': now.toIso8601String(),
    };
  }

  /// Get detailed dependency information
  Map<String, dynamic> getDependencyDetails() {
    final details = <String, dynamic>{};
    
    for (final entry in _dependencies.entries) {
      final dep = entry.value;
      details[entry.key] = {
        'type': dep.metadata.type.toString(),
        'tag': dep.metadata.tag,
        'lifecycle': dep.metadata.lifecycle.name,
        'loadingStrategy': dep.metadata.loadingStrategy.name,
        'isAsync': dep.isAsync,
        'isLoaded': dep.isLoaded,
        'isLoading': dep.isLoading,
        'accessCount': dep.accessCount,
        'lastAccessed': dep.lastAccessed?.toIso8601String(),
        'registeredAt': dep.metadata.registeredAt.toIso8601String(),
        'priority': dep.metadata.priority,
        'dependencies': dep.metadata.dependencies.map((t) => t.toString()).toList(),
      };
    }
    
    return details;
  }

  /// Preload dependencies with predictive loading
  Future<void> preloadPredictiveDependencies() async {
    final predictiveDeps = _dependencies.entries
        .where((e) => e.value.metadata.loadingStrategy == LazyLoadingStrategy.predictive)
        .toList();

    // Sort by priority and access patterns
    predictiveDeps.sort((a, b) {
      final priorityDiff = b.value.metadata.priority - a.value.metadata.priority;
      if (priorityDiff != 0) return priorityDiff;
      
      return b.value.accessCount - a.value.accessCount;
    });

    developer.log('🔮 Preloading ${predictiveDeps.length} predictive dependencies');

    for (final entry in predictiveDeps.take(5)) { // Limit to top 5
      try {
        await entry.value.getInstance();
      } catch (e) {
        developer.log('⚠️ Failed to preload ${entry.key}: $e');
      }
    }
  }

  // Private helper methods

  String _generateKey<T>(String? tag) {
    return tag != null ? '${T.toString()}#$tag' : T.toString();
  }

  void _updateDependencyGraph<T>(List<Type> dependencies) {
    final key = T.toString();
    _dependencyGraph[key] = dependencies.map((t) => t.toString()).toList();
  }

  void _preloadDependency<T>(String? tag) {
    Future.microtask(() async {
      try {
        await get<T>(tag: tag);
      } catch (e) {
        developer.log('⚠️ Failed to preload $T: $e');
      }
    });
  }

  void _preloadDependencyAsync<T>(String? tag) {
    Future.delayed(Duration.zero, () async {
      try {
        await get<T>(tag: tag);
      } catch (e) {
        developer.log('⚠️ Failed to preload async $T: $e');
      }
    });
  }

  Map<String, int> _groupDependenciesByType() {
    final groups = <String, int>{};
    
    for (final entry in _dependencies.values) {
      final typeName = entry.metadata.type.toString();
      groups[typeName] = (groups[typeName] ?? 0) + 1;
    }
    
    return groups;
  }

  Map<String, int> _groupDependenciesByLifecycle() {
    final groups = <String, int>{};
    
    for (final entry in _dependencies.values) {
      final lifecycle = entry.metadata.lifecycle.name;
      groups[lifecycle] = (groups[lifecycle] ?? 0) + 1;
    }
    
    return groups;
  }

  Map<String, int> _groupDependenciesByLoadingStrategy() {
    final groups = <String, int>{};
    
    for (final entry in _dependencies.values) {
      final strategy = entry.metadata.loadingStrategy.name;
      groups[strategy] = (groups[strategy] ?? 0) + 1;
    }
    
    return groups;
  }

  double _calculateAverageLoadTime() {
    if (_loadingTimes.isEmpty) return 0.0;
    
    final now = DateTime.now();
    var totalMs = 0;
    
    for (final loadTime in _loadingTimes.values) {
      totalMs += now.difference(loadTime).inMilliseconds;
    }
    
    return totalMs / _loadingTimes.length;
  }
}