import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/models/favorito_item_hive.dart';
import '../../../core/repositories/favoritos_hive_repository.dart';
import 'favorito_retry_manager.dart';

/// Manager de performance para operações otimizadas de favoritos
/// Implementa lazy loading, batch queries e cache inteligente
class FavoritoPerformanceManager {
  final FavoritosHiveRepository _repository;
  
  // Cache em memória para evitar queries desnecessárias
  final Map<String, List<String>> _cachedIds = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, bool> _loadingStates = {};
  
  // Configurações de cache
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _batchSize = 50;

  FavoritoPerformanceManager(this._repository);

  /// Carregamento lazy por tipo - só carrega quando necessário
  Future<List<String>> loadFavoriteIdsLazy(String tipo) async {
    // Verifica cache primeiro
    if (_isCacheValid(tipo)) {
      debugPrint('📋 [Performance] Cache hit para $tipo: ${_cachedIds[tipo]?.length ?? 0} itens');
      return _cachedIds[tipo] ?? [];
    }

    // Evita carregamentos simultâneos
    if (_loadingStates[tipo] == true) {
      debugPrint('⏳ [Performance] Aguardando carregamento em andamento para $tipo');
      await _waitForLoading(tipo);
      return _cachedIds[tipo] ?? [];
    }

    // Carrega dados
    return await _loadAndCacheIds(tipo);
  }

  /// Carregamento batch otimizado para múltiplos tipos
  Future<Map<String, List<String>>> loadMultipleTypesBatch(List<String> tipos) async {
    final results = <String, List<String>>{};
    final typesToLoad = <String>[];

    // Identifica tipos que precisam ser carregados
    for (final tipo in tipos) {
      if (_isCacheValid(tipo)) {
        results[tipo] = _cachedIds[tipo] ?? [];
      } else {
        typesToLoad.add(tipo);
      }
    }

    if (typesToLoad.isEmpty) {
      debugPrint('🚀 [Performance] Todos os tipos em cache: ${tipos.join(', ')}');
      return results;
    }

    // Carrega tipos em lote
    debugPrint('🔄 [Performance] Carregando batch: ${typesToLoad.join(', ')}');
    
    final futures = typesToLoad.map((tipo) => _loadAndCacheIds(tipo));
    final loadedResults = await Future.wait(futures);

    // Combina resultados
    for (int i = 0; i < typesToLoad.length; i++) {
      results[typesToLoad[i]] = loadedResults[i];
    }

    return results;
  }

  /// Carregamento incremental - carrega apenas IDs primeiro, dados depois
  Future<List<String>> loadIncrementalIds(String tipo) async {
    final ids = await loadFavoriteIdsLazy(tipo);
    
    // Para listas grandes, carrega em chunks
    if (ids.length > _batchSize) {
      debugPrint('📦 [Performance] Lista grande ($tipo): ${ids.length} itens, carregamento incremental');
      return _loadIdsInChunks(tipo, ids);
    }

    return ids;
  }

  /// Pré-carrega dados para tabs adjacentes
  Future<void> preloadAdjacentTabs(String currentTipo, List<String> allTipos) async {
    final currentIndex = allTipos.indexOf(currentTipo);
    if (currentIndex == -1) return;

    final adjacentTipos = <String>[];
    
    // Tab anterior
    if (currentIndex > 0) {
      adjacentTipos.add(allTipos[currentIndex - 1]);
    }
    
    // Tab seguinte
    if (currentIndex < allTipos.length - 1) {
      adjacentTipos.add(allTipos[currentIndex + 1]);
    }

    if (adjacentTipos.isEmpty) return;

    debugPrint('🔮 [Performance] Pré-carregando tabs adjacentes: ${adjacentTipos.join(', ')}');
    
    // Carrega em background sem bloquear UI
    unawaited(loadMultipleTypesBatch(adjacentTipos));
  }

  /// Verificação otimizada de favorito individual
  Future<bool> checkIsFavoriteFast(String tipo, String itemId) async {
    // Tenta usar cache primeiro
    final cachedIds = _cachedIds[tipo];
    if (cachedIds != null && _isCacheValid(tipo)) {
      return cachedIds.contains(itemId);
    }

    // Fallback para query direta com retry
    return await FavoritoRetryManager.retryReadOperation<bool>(
      () => _repository.isFavoritoAsync(tipo, itemId),
      tipo,
      itemId,
    ) ?? false;
  }

  /// Operação batch para múltiplos favoritos
  Future<Map<String, bool>> checkMultipleFavoritesFast(
    String tipo, 
    List<String> itemIds,
  ) async {
    final results = <String, bool>{};
    
    // Tenta usar cache primeiro
    final cachedIds = _cachedIds[tipo];
    if (cachedIds != null && _isCacheValid(tipo)) {
      for (final itemId in itemIds) {
        results[itemId] = cachedIds.contains(itemId);
      }
      return results;
    }

    // Carrega todos de uma vez se cache inválido
    await loadFavoriteIdsLazy(tipo);
    final finalCachedIds = _cachedIds[tipo] ?? [];
    
    for (final itemId in itemIds) {
      results[itemId] = finalCachedIds.contains(itemId);
    }

    return results;
  }

  /// Atualização otimista do cache após operações
  void updateCacheOptimistically(String tipo, String itemId, bool added) {
    final cachedIds = _cachedIds[tipo];
    if (cachedIds == null) return;

    if (added && !cachedIds.contains(itemId)) {
      cachedIds.add(itemId);
      debugPrint('✅ [Performance] Cache atualizado otimisticamente: +$itemId em $tipo');
    } else if (!added && cachedIds.contains(itemId)) {
      cachedIds.remove(itemId);
      debugPrint('➖ [Performance] Cache atualizado otimisticamente: -$itemId em $tipo');
    }
    
    // Atualiza timestamp do cache
    _cacheTimestamps[tipo] = DateTime.now();
  }

  /// Limpa cache de um tipo específico
  void invalidateCache(String tipo) {
    _cachedIds.remove(tipo);
    _cacheTimestamps.remove(tipo);
    _loadingStates.remove(tipo);
    debugPrint('🗑️ [Performance] Cache invalidado para $tipo');
  }

  /// Limpa todo o cache
  void clearAllCache() {
    _cachedIds.clear();
    _cacheTimestamps.clear();
    _loadingStates.clear();
    debugPrint('🧹 [Performance] Todo cache limpo');
  }

  /// Estatísticas de cache para debug
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedTypes': _cachedIds.keys.toList(),
      'cacheSizes': _cachedIds.map((k, v) => MapEntry(k, v.length)),
      'cacheAges': _cacheTimestamps.map((k, v) => 
          MapEntry(k, DateTime.now().difference(v).inSeconds)),
      'loadingStates': Map<String, bool>.from(_loadingStates),
    };
  }

  // === MÉTODOS PRIVADOS ===

  /// Verifica se cache é válido
  bool _isCacheValid(String tipo) {
    if (!_cachedIds.containsKey(tipo)) return false;
    
    final timestamp = _cacheTimestamps[tipo];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Carrega e cacheia IDs
  Future<List<String>> _loadAndCacheIds(String tipo) async {
    _loadingStates[tipo] = true;
    
    try {
      debugPrint('🔍 [Performance] Carregando IDs para $tipo');
      
      final favoritos = await FavoritoRetryManager.retryBatchOperation(
        () => _repository.getFavoritosByTipoAsync(tipo),
        'carregar_favoritos_$tipo',
      );

      final ids = (favoritos ?? <FavoritoItemHive>[]).map((f) => f.itemId).toList();
      
      // Cacheia resultado
      _cachedIds[tipo] = ids;
      _cacheTimestamps[tipo] = DateTime.now();
      
      debugPrint('✅ [Performance] $tipo carregado: ${ids.length} itens');
      return ids;
      
    } catch (e) {
      debugPrint('❌ [Performance] Erro ao carregar $tipo: $e');
      return [];
    } finally {
      _loadingStates[tipo] = false;
    }
  }

  /// Carrega IDs em chunks para listas grandes
  List<String> _loadIdsInChunks(String tipo, List<String> ids) {
    // Por enquanto retorna todos - implementação de chunking seria para UI virtual
    return ids;
  }

  /// Aguarda carregamento em andamento
  Future<void> _waitForLoading(String tipo) async {
    var attempts = 0;
    const maxAttempts = 50; // 5 segundos máximo
    
    while (_loadingStates[tipo] == true && attempts < maxAttempts) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }
}

/// Extensão para facilitar uso sem import adicional
extension FavoritoRepositoryPerformance on FavoritosHiveRepository {
  /// Carregamento otimizado usando performance manager
  Future<List<FavoritoItemHive>> getFavoritosByTipoOptimized(
    String tipo,
    FavoritoPerformanceManager performanceManager,
  ) async {
    final ids = await performanceManager.loadFavoriteIdsLazy(tipo);
    return findByIds(ids);
  }
}

/// Mixin para providers que querem usar performance optimizations
mixin FavoritoPerformanceOptimized {
  FavoritoPerformanceManager? _performanceManager;
  
  /// Inicializa performance manager
  void initPerformanceManager(FavoritosHiveRepository repository) {
    _performanceManager = FavoritoPerformanceManager(repository);
  }
  
  /// Getter para performance manager
  FavoritoPerformanceManager get performanceManager {
    if (_performanceManager == null) {
      throw StateError('Performance manager não foi inicializado. Chame initPerformanceManager() primeiro.');
    }
    return _performanceManager!;
  }
  
  /// Cleanup do performance manager
  void disposePerformanceManager() {
    _performanceManager?.clearAllCache();
    _performanceManager = null;
  }
}