import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lazy_loading_manager_migrated.g.dart';

/// State para gerenciamento de lazy loading
class LazyLoadingState {
  const LazyLoadingState({
    this.lazyCache = const {},
    this.loadingFutures = const {},
    this.loadedKeys = const {},
  });

  final Map<String, dynamic> lazyCache;
  final Map<String, Future<dynamic>> loadingFutures;
  final Set<String> loadedKeys;

  LazyLoadingState copyWith({
    Map<String, dynamic>? lazyCache,
    Map<String, Future<dynamic>>? loadingFutures,
    Set<String>? loadedKeys,
  }) {
    return LazyLoadingState(
      lazyCache: lazyCache ?? this.lazyCache,
      loadingFutures: loadingFutures ?? this.loadingFutures,
      loadedKeys: loadedKeys ?? this.loadedKeys,
    );
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> get cacheStats {
    return {
      'total_registered': lazyCache.length,
      'loaded': loadedKeys.length,
      'loading': loadingFutures.length,
      'memory_usage_kb': _estimateMemoryUsage(),
    };
  }

  /// Estima o uso de memória do cache
  double _estimateMemoryUsage() {
    return loadedKeys.length * 0.5; // 0.5KB por instância (estimativa)
  }
}

/// Pure Riverpod Notifier para gerenciamento de lazy loading
///
/// Implementa estratégias de carregamento preguiçoso para:
/// - Providers
/// - Datasets grandes
/// - Componentes pesados
/// - Cálculos complexos
@riverpod
class LazyLoading extends _$LazyLoading {
  @override
  LazyLoadingState build() {
    return const LazyLoadingState();
  }

  /// Registra um provider para lazy loading
  void registerProvider<T>(String key, T Function() factory) {
    if (!state.lazyCache.containsKey(key)) {
      final newCache = Map<String, dynamic>.from(state.lazyCache);
      newCache[key] = factory;
      state = state.copyWith(lazyCache: newCache);
    }
  }

  /// Obtém um provider com lazy loading
  Future<T> getProvider<T>(String key) async {
    if (state.loadedKeys.contains(key)) {
      return state.lazyCache[key] as T;
    }
    if (state.loadingFutures.containsKey(key)) {
      return await state.loadingFutures[key] as T;
    }
    final completer = Completer<T>();
    final newLoadingFutures = Map<String, Future<dynamic>>.from(
      state.loadingFutures,
    );
    newLoadingFutures[key] = completer.future;
    state = state.copyWith(loadingFutures: newLoadingFutures);

    try {
      final factory = state.lazyCache[key] as T Function();
      final instance = factory();

      final newCache = Map<String, dynamic>.from(state.lazyCache);
      newCache[key] = instance;

      final newLoadedKeys = Set<String>.from(state.loadedKeys);
      newLoadedKeys.add(key);

      final finalLoadingFutures = Map<String, Future<dynamic>>.from(
        state.loadingFutures,
      );
      finalLoadingFutures.remove(key);

      state = state.copyWith(
        lazyCache: newCache,
        loadedKeys: newLoadedKeys,
        loadingFutures: finalLoadingFutures,
      );
      completer.complete(instance);
      return instance;
    } catch (error) {
      final errorLoadingFutures = Map<String, Future<dynamic>>.from(
        state.loadingFutures,
      );
      errorLoadingFutures.remove(key);
      state = state.copyWith(loadingFutures: errorLoadingFutures);
      completer.completeError(error);
      rethrow;
    }
  }

  /// Verifica se um provider está carregado
  bool isLoaded(String key) => state.loadedKeys.contains(key);

  /// Verifica se um provider está sendo carregado
  bool isLoading(String key) => state.loadingFutures.containsKey(key);

  /// Pré-carrega providers com prioridade
  Future<void> preloadProviders(List<String> keys, {int? priority}) async {
    final List<Future<dynamic>> futuresToLoad = [];
    for (final key in keys) {
      if (!isLoaded(key)) {
        futuresToLoad.add(getProvider<dynamic>(key));
      }
    }

    if (futuresToLoad.isNotEmpty) {
      await Future.wait(futuresToLoad);
    }
  }

  /// Remove um provider do cache (para economizar memória)
  void unloadProvider(String key) {
    final newCache = Map<String, dynamic>.from(state.lazyCache);
    newCache.remove(key);

    final newLoadedKeys = Set<String>.from(state.loadedKeys);
    newLoadedKeys.remove(key);

    final newLoadingFutures = Map<String, Future<dynamic>>.from(
      state.loadingFutures,
    );
    newLoadingFutures.remove(key);

    state = state.copyWith(
      lazyCache: newCache,
      loadedKeys: newLoadedKeys,
      loadingFutures: newLoadingFutures,
    );
  }

  void clearCache() {
    state = const LazyLoadingState();
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() => state.cacheStats;
}

/// Provider derivado para estatísticas do cache
@riverpod
Map<String, dynamic> lazyLoadingStats(LazyLoadingStatsRef ref) {
  return ref.watch(lazyLoadingProvider).cacheStats;
}
