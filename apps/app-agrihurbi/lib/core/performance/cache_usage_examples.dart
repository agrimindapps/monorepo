/// ========================================
/// EXEMPLO 1: Uso básico em um Notifier
/// ========================================

/// Exemplo de notifier que usa cache
// @riverpod
// class UserDataNotifier extends _$UserDataNotifier {
//   @override
//   Future<UserData> build(String userId) async {
//     // Usa cache automático com configuração de layer
//     return ref.cached(
//       CacheLayers.user,
//       'user_$userId',
//       () => _fetchUserFromApi(userId),
//     );
//   }
//
//   Future<UserData> _fetchUserFromApi(String userId) async {
//     // Simulação de chamada API
//     await Future.delayed(Duration(seconds: 1));
//     return UserData(id: userId, name: 'João');
//   }
// }

/// ========================================
/// EXEMPLO 2: Cache manual
/// ========================================

/// Provider que gerencia cache manualmente
// @riverpod
// class ProductsNotifier extends _$ProductsNotifier {
//   @override
//   List<Product> build() {
//     // Tenta obter do cache primeiro
//     final cached = ref.getCache<List<Product>>(
//       CacheLayers.api,
//       'products_list',
//     );
//     return cached ?? [];
//   }
//
//   Future<void> loadProducts() async {
//     final products = await _fetchProducts();
//
//     // Salva no cache
//     ref.putCache(CacheLayers.api, 'products_list', products);
//
//     state = products;
//   }
//
//   Future<List<Product>> _fetchProducts() async {
//     // Implementação...
//     return [];
//   }
//
//   void clearCache() {
//     ref.clearCacheLayer(CacheLayers.api);
//   }
// }

/// ========================================
/// EXEMPLO 3: Uso direto do CacheManager
/// ========================================

/// Widget que usa cache diretamente
// class CacheStatsWidget extends ConsumerWidget {
//   const CacheStatsWidget({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final cacheManager = ref.watch(cacheManagerProvider.notifier);
//     final stats = cacheManager.getGlobalStats();
//
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Cache Statistics'),
//             SizedBox(height: 8),
//             Text('Total Layers: ${stats['total_layers']}'),
//             Text('Total Entries: ${stats['total_entries']}'),
//             Text('Hit Rate: ${(stats['global_hit_rate'] * 100).toStringAsFixed(1)}%'),
//             Text('Total Size: ${stats['total_size_kb'].toStringAsFixed(2)} KB'),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 cacheManager.optimize();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Cache otimizado!')),
//                 );
//               },
//               child: Text('Otimizar Cache'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// ========================================
/// EXEMPLO 4: Cache com TTL customizado
/// ========================================

/// Cache com configuração customizada
// Future<WeatherData> getWeatherWithCache(WidgetRef ref, String city) async {
//   final cache = ref.read(cacheManagerProvider.notifier);
//
//   return await cache.getOrPut(
//     'weather',
//     'weather_$city',
//     () => fetchWeatherFromApi(city),
//     config: CacheConfig(
//       maxSize: 50,
//       ttl: Duration(minutes: 15), // Cache por 15 minutos
//       priority: 2,
//     ),
//   );
// }

/// ========================================
/// EXEMPLO 5: Limpeza de cache
/// ========================================

/// Limpa cache de forma seletiva
// void clearSpecificCache(WidgetRef ref) {
//   final cache = ref.read(cacheManagerProvider.notifier);
//
//   // Limpar uma camada específica
//   cache.clearLayer(CacheLayers.api);
//
//   // Limpar uma entrada específica
//   cache.remove(CacheLayers.user, 'user_123');
//
//   // Limpar entradas expiradas
//   cache.cleanupExpired();
//
//   // Limpar tudo
//   cache.clearAll();
// }

/// ========================================
/// Camadas de cache disponíveis
/// ========================================
///
/// - CacheLayers.calculators - Cache de calculadoras (2h TTL)
/// - CacheLayers.livestock - Cache de bovinos/equinos (6h TTL)
/// - CacheLayers.weather - Cache de clima (15min TTL)
/// - CacheLayers.news - Cache de notícias (1h TTL)
/// - CacheLayers.user - Cache de usuários (24h TTL)
/// - CacheLayers.settings - Cache de configurações (7 dias TTL)
/// - CacheLayers.images - Cache de imagens (4h TTL)
/// - CacheLayers.api - Cache geral de API (10min TTL)
