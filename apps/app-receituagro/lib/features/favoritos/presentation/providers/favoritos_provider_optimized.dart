import 'package:flutter/foundation.dart';

import '../../data/repositories/favoritos_repository_simplified.dart';
import '../../domain/entities/favorito_entity.dart';
import '../../events/favorito_event_bus.dart';
import '../../events/favorito_events.dart';
import '../../utils/favorito_performance_manager.dart';

/// Provider otimizado para página de favoritos com lazy loading e cache inteligente
class FavoritosProviderOptimized extends ChangeNotifier with FavoritoEventListener, FavoritoPerformanceOptimized {
  final FavoritosRepositorySimplified _repository;

  // Estados por tipo - lazy loading
  final Map<String, List<FavoritoEntity>> _favoritosByType = {};
  final Map<String, bool> _loadingByType = {};
  final Map<String, String?> _errorsByType = {};
  final Map<String, bool> _initializedByType = {};
  
  // Estado global
  bool _isInitialized = false;
  String _currentTab = TipoFavorito.defensivo;
  FavoritosStats? _stats;

  // Performance tracking
  int _totalFavoritos = 0;
  final Map<String, int> _countsCache = {};

  FavoritosProviderOptimized({
    required FavoritosRepositorySimplified repository,
  }) : _repository = repository {
    _setupEventListeners();
    _initializeTypes();
  }

  // === GETTERS PÚBLICOS ===

  /// Favoritos do tipo atual
  List<FavoritoEntity> get currentFavoritos => _favoritosByType[_currentTab] ?? [];
  
  /// Favoritos por tipo específico
  List<FavoritoEntity> getFavoritosByTipo(String tipo) => _favoritosByType[tipo] ?? [];
  
  /// Loading state do tipo atual
  bool get isCurrentLoading => _loadingByType[_currentTab] ?? false;
  
  /// Loading state por tipo específico
  bool isLoadingType(String tipo) => _loadingByType[tipo] ?? false;
  
  /// Erro do tipo atual
  String? get currentError => _errorsByType[_currentTab];
  
  /// Erro por tipo específico
  String? getErrorForType(String tipo) => _errorsByType[tipo];
  
  /// Estado de inicialização
  bool get isInitialized => _isInitialized;
  bool isTypeInitialized(String tipo) => _initializedByType[tipo] ?? false;
  
  /// Tab atual
  String get currentTab => _currentTab;
  
  /// Estatísticas (cached)
  FavoritosStats? get stats => _stats;
  int get totalFavoritos => _totalFavoritos;
  
  /// Contadores rápidos (sem carregar dados)
  int getCountForType(String tipo) => _countsCache[tipo] ?? 0;
  
  /// Estados de conveniência
  bool get hasCurrentFavoritos => currentFavoritos.isNotEmpty;
  bool hasTypeWithFavoritos(String tipo) => (_countsCache[tipo] ?? 0) > 0;

  // === MÉTODOS DE CARREGAMENTO ===

  /// Inicialização lazy - só carrega contadores primeiro
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 [FavoritosOptimized] Inicializando...');
      
      // Carrega apenas estatísticas rapidamente
      await _loadStatsQuick();
      
      _isInitialized = true;
      notifyListeners();
      
      debugPrint('✅ [FavoritosOptimized] Inicializado com $_totalFavoritos favoritos totais');
    } catch (e) {
      debugPrint('❌ [FavoritosOptimized] Erro na inicialização: $e');
      _setGlobalError('Erro na inicialização: $e');
    }
  }

  /// Carrega favoritos de um tipo específico (lazy)
  Future<void> loadFavoritosByTipo(String tipo) async {
    if (isLoadingType(tipo)) {
      debugPrint('⏳ [FavoritosOptimized] $tipo já carregando, ignorando...');
      return;
    }

    if (isTypeInitialized(tipo)) {
      debugPrint('📋 [FavoritosOptimized] $tipo já carregado');
      return;
    }

    try {
      _setLoading(tipo, true);
      _clearError(tipo);
      
      debugPrint('🔄 [FavoritosOptimized] Carregando $tipo...');
      
      // Usa performance manager para carregamento otimizado
      final ids = await performanceManager.loadFavoriteIdsLazy(tipo);
      final favoritos = await _loadFavoritosFromIds(tipo, ids);
      
      _favoritosByType[tipo] = favoritos;
      _initializedByType[tipo] = true;
      _countsCache[tipo] = favoritos.length;
      
      debugPrint('✅ [FavoritosOptimized] $tipo carregado: ${favoritos.length} itens');
      
    } catch (e) {
      debugPrint('❌ [FavoritosOptimized] Erro ao carregar $tipo: $e');
      _setError(tipo, 'Erro ao carregar favoritos: $e');
    } finally {
      _setLoading(tipo, false);
    }
  }

  /// Muda tab atual e carrega dados se necessário
  Future<void> changeTab(String newTab) async {
    if (_currentTab == newTab) return;

    final oldTab = _currentTab;
    _currentTab = newTab;
    notifyListeners();

    debugPrint('📑 [FavoritosOptimized] Mudança de tab: $oldTab → $newTab');

    // Carrega dados da nova tab se necessário
    if (!isTypeInitialized(newTab)) {
      await loadFavoritosByTipo(newTab);
    }

    // Pré-carrega tabs adjacentes em background
    await _preloadAdjacentTabs();
  }

  /// Força recarregamento de um tipo
  Future<void> reloadType(String tipo) async {
    debugPrint('🔄 [FavoritosOptimized] Forçando reload de $tipo');
    
    _initializedByType[tipo] = false;
    _favoritosByType.remove(tipo);
    performanceManager.invalidateCache(tipo);
    
    await loadFavoritosByTipo(tipo);
  }

  /// Recarrega todos os dados
  Future<void> reloadAll() async {
    debugPrint('🔄 [FavoritosOptimized] Recarregando todos os tipos');
    
    _initializedByType.clear();
    _favoritosByType.clear();
    _countsCache.clear();
    performanceManager.clearAllCache();
    
    _isInitialized = false;
    await initialize();
    
    // Recarrega tab atual
    await loadFavoritosByTipo(_currentTab);
  }

  /// Verificação rápida se item é favorito
  Future<bool> isFavorito(String tipo, String itemId) async {
    return await performanceManager.checkIsFavoriteFast(tipo, itemId);
  }

  /// Verificação batch para múltiplos itens
  Future<Map<String, bool>> checkMultipleFavoritos(String tipo, List<String> itemIds) async {
    return await performanceManager.checkMultipleFavoritesFast(tipo, itemIds);
  }

  // === MÉTODOS DE MANIPULAÇÃO ===

  /// Adiciona favorito com atualização otimística
  Future<bool> addFavorito(String tipo, String itemId) async {
    final success = await _repository.addFavorito(tipo, itemId);
    
    if (success) {
      _updateCacheOptimistically(tipo, itemId, true);
    }
    
    return success;
  }

  /// Remove favorito com atualização otimística
  Future<bool> removeFavorito(String tipo, String itemId) async {
    final success = await _repository.removeFavorito(tipo, itemId);
    
    if (success) {
      _updateCacheOptimistically(tipo, itemId, false);
    }
    
    return success;
  }

  /// Toggle favorito com atualização otimística
  Future<bool> toggleFavorito(String tipo, String itemId) async {
    final isFav = await isFavorito(tipo, itemId);
    
    return isFav 
        ? await removeFavorito(tipo, itemId)
        : await addFavorito(tipo, itemId);
  }

  // === EVENT LISTENERS ===

  void _setupEventListeners() {
    // Escuta mudanças globais de favoritos
    listenToFavoritoEvents<FavoritoAdded>((event) {
      _handleFavoritoAdded(event);
    });

    listenToFavoritoEvents<FavoritoRemoved>((event) {
      _handleFavoritoRemoved(event);
    });

    listenToFavoritoEvents<FavoritosCleared>((event) {
      _handleFavoritosCleared(event);
    });
  }

  void _handleFavoritoAdded(FavoritoAdded event) {
    _updateCacheOptimistically(event.tipo, event.itemId, true);
  }

  void _handleFavoritoRemoved(FavoritoRemoved event) {
    _updateCacheOptimistically(event.tipo, event.itemId, false);
  }

  void _handleFavoritosCleared(FavoritosCleared event) {
    _favoritosByType[event.tipo] = [];
    _countsCache[event.tipo] = 0;
    _totalFavoritos = _countsCache.values.fold(0, (sum, count) => sum + count);
    performanceManager.invalidateCache(event.tipo);
    notifyListeners();
  }

  // === MÉTODOS PRIVADOS ===

  void _initializeTypes() {
    for (final tipo in [TipoFavorito.defensivo, TipoFavorito.praga, TipoFavorito.diagnostico]) {
      _loadingByType[tipo] = false;
      _errorsByType[tipo] = null;
      _initializedByType[tipo] = false;
      _countsCache[tipo] = 0;
    }
  }

  Future<void> _loadStatsQuick() async {
    try {
      _stats = await _repository.getStats();
      
      // Atualiza contadores cache rapidamente
      if (_stats != null) {
        _countsCache[TipoFavorito.defensivo] = _stats!.totalDefensivos;
        _countsCache[TipoFavorito.praga] = _stats!.totalPragas;
        _countsCache[TipoFavorito.diagnostico] = _stats!.totalDiagnosticos;
        _totalFavoritos = _stats!.total;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [FavoritosOptimized] Erro ao carregar stats: $e');
    }
  }

  Future<List<FavoritoEntity>> _loadFavoritosFromIds(String tipo, List<String> ids) async {
    if (ids.isEmpty) return [];
    
    // Aqui você converteria os IDs para FavoritoEntity usando o repository
    return await _repository.getByTipo(tipo);
  }

  Future<void> _preloadAdjacentTabs() async {
    const allTabs = [TipoFavorito.defensivo, TipoFavorito.praga, TipoFavorito.diagnostico];
    await performanceManager.preloadAdjacentTabs(_currentTab, allTabs);
  }

  void _updateCacheOptimistically(String tipo, String itemId, bool added) {
    // Atualiza cache de performance
    performanceManager.updateCacheOptimistically(tipo, itemId, added);
    
    // Atualiza lista local se carregada
    final currentList = _favoritosByType[tipo];
    if (currentList != null) {
      // Nota: implementação completa removeria/adicionaria o item real da lista
      _countsCache[tipo] = ((_countsCache[tipo] ?? 0) + (added ? 1 : -1)).clamp(0, double.infinity).toInt();
      _totalFavoritos = _countsCache.values.fold(0, (sum, count) => sum + count);
      notifyListeners();
    }
  }

  void _setLoading(String tipo, bool loading) {
    if (_loadingByType[tipo] != loading) {
      _loadingByType[tipo] = loading;
      notifyListeners();
    }
  }

  void _setError(String tipo, String error) {
    _errorsByType[tipo] = error;
    notifyListeners();
  }

  void _clearError(String tipo) {
    if (_errorsByType[tipo] != null) {
      _errorsByType[tipo] = null;
      notifyListeners();
    }
  }

  void _setGlobalError(String error) {
    for (final tipo in _errorsByType.keys) {
      _errorsByType[tipo] = error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    disposeEventListeners();
    disposePerformanceManager();
    super.dispose();
  }

  // === DEBUG ===
  
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _isInitialized,
      'currentTab': _currentTab,
      'totalFavoritos': _totalFavoritos,
      'countsCache': Map<String, int>.from(_countsCache),
      'loadingStates': Map<String, bool>.from(_loadingByType),
      'initializedTypes': Map<String, bool>.from(_initializedByType),
      'cacheStats': performanceManager.getCacheStats(),
    };
  }
}