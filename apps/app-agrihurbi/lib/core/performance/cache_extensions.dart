import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_manager_provider.dart';

/// Extension para facilitar uso do cache em Notifiers
///
/// Adiciona métodos de conveniência para cache
extension CacheAwareNotifier on Ref {
  /// Obtém a instância do cache manager
  CacheManager get cache => read(cacheManagerProvider.notifier);

  /// Cache com configuração automática por layer
  Future<T> cached<T>(
    String layer,
    String key,
    Future<T> Function() factory,
  ) async {
    final config = CacheLayers.configs[layer] ?? const CacheConfig();
    return await cache.getOrPut(layer, key, factory, config: config);
  }

  /// Cache simples - put
  void putCache<T>(String layer, String key, T value) {
    final config = CacheLayers.configs[layer] ?? const CacheConfig();
    cache.put(layer, key, value, config: config);
  }

  /// Cache simples - get
  T? getCache<T>(String layer, String key) {
    return cache.get<T>(layer, key);
  }

  /// Remove do cache
  void removeCache(String layer, String key) {
    cache.remove(layer, key);
  }

  /// Limpa uma camada
  void clearCacheLayer(String layer) {
    cache.clearLayer(layer);
  }
}

/// Exemplo de uso em um Notifier
///
/// ```dart
/// @riverpod
/// class MyDataNotifier extends _$MyDataNotifier {
///   @override
///   Future<List<Item>> build() async {
///     // Usa cache automático
///     return ref.cached(
///       CacheLayers.api,
///       'my_items',
///       () => _fetchItemsFromApi(),
///     );
///   }
///
///   Future<List<Item>> _fetchItemsFromApi() async {
///     // Implementação...
///   }
/// }
/// ```
