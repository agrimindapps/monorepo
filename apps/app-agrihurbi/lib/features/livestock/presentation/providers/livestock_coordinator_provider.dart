import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'bovines_filter_provider.dart';
import 'bovines_management_provider.dart';
import 'equines_management_provider.dart';
import 'livestock_search_provider.dart';
import 'livestock_statistics_provider.dart';
import 'livestock_sync_provider.dart';

/// Provider coordenador que compõe funcionalidades especializadas
/// 
/// Responsabilidade única: Coordenar providers especializados seguindo SRP
/// Substitui o LivestockProvider monolítico original de 475 linhas
@singleton
class LivestockCoordinatorProvider extends ChangeNotifier {
  final BovinesManagementProvider _bovinesProvider;
  final EquinesManagementProvider _equinesProvider;
  final BovinesFilterProvider _filtersProvider;
  final LivestockSearchProvider _searchProvider;
  final LivestockStatisticsProvider _statisticsProvider;
  final LivestockSyncProvider _syncProvider;

  LivestockCoordinatorProvider({
    required BovinesManagementProvider bovinesProvider,
    required EquinesManagementProvider equinesProvider,
    required BovinesFilterProvider filtersProvider,
    required LivestockSearchProvider searchProvider,
    required LivestockStatisticsProvider statisticsProvider,
    required LivestockSyncProvider syncProvider,
  })  : _bovinesProvider = bovinesProvider,
        _equinesProvider = equinesProvider,
        _filtersProvider = filtersProvider,
        _searchProvider = searchProvider,
        _statisticsProvider = statisticsProvider,
        _syncProvider = syncProvider {
    _initializeProviders();
  }

  // === PROVIDERS ACCESS ===
  
  BovinesManagementProvider get bovinesProvider => _bovinesProvider;
  EquinesManagementProvider get equinesProvider => _equinesProvider;
  BovinesFilterProvider get filtersProvider => _filtersProvider;
  LivestockSearchProvider get searchProvider => _searchProvider;
  LivestockStatisticsProvider get statisticsProvider => _statisticsProvider;
  LivestockSyncProvider get syncProvider => _syncProvider;

  // === AGGREGATED GETTERS ===

  /// Verifica se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
    _bovinesProvider.isAnyOperationInProgress ||
    _equinesProvider.isAnyOperationInProgress ||
    _searchProvider.isSearching ||
    _statisticsProvider.isLoading ||
    _syncProvider.isSyncing;

  /// Obtém mensagem de erro consolidada
  String? get consolidatedErrorMessage {
    final errors = <String>[];
    
    if (_bovinesProvider.errorMessage != null) {
      errors.add('Bovinos: ${_bovinesProvider.errorMessage}');
    }
    if (_equinesProvider.errorMessage != null) {
      errors.add('Equinos: ${_equinesProvider.errorMessage}');
    }
    if (_searchProvider.errorMessage != null) {
      errors.add('Busca: ${_searchProvider.errorMessage}');
    }
    if (_statisticsProvider.errorMessage != null) {
      errors.add('Estatísticas: ${_statisticsProvider.errorMessage}');
    }
    if (_syncProvider.errorMessage != null) {
      errors.add('Sincronização: ${_syncProvider.errorMessage}');
    }
    
    return errors.isEmpty ? null : errors.join('\n');
  }

  /// Lista filtrada de bovinos
  List<dynamic> get filteredBovines {
    return _filtersProvider.applyFilters(_bovinesProvider.bovines);
  }

  /// Total de animais
  int get totalAnimals => 
    _bovinesProvider.totalBovines + _equinesProvider.totalEquines;

  // === COORDINATED OPERATIONS ===

  /// Inicialização completa do sistema livestock
  Future<void> initializeSystem() async {
    debugPrint('LivestockCoordinatorProvider: Inicializando sistema livestock');
    
    await Future.wait([
      _bovinesProvider.loadBovines(),
      _equinesProvider.loadEquines(),
      _statisticsProvider.loadStatistics(),
    ]);

    // Atualiza filtros com dados carregados
    _filtersProvider.updateAvailableValues(_bovinesProvider.bovines);
    
    debugPrint('LivestockCoordinatorProvider: Sistema livestock inicializado');
  }

  /// Refresh completo de todos os dados
  Future<void> refreshAllData() async {
    debugPrint('LivestockCoordinatorProvider: Atualizando todos os dados');
    
    await Future.wait([
      _bovinesProvider.refreshBovines(),
      _equinesProvider.refreshEquines(),
      _statisticsProvider.refreshStatistics(),
    ]);

    // Atualiza filtros
    _filtersProvider.updateAvailableValues(_bovinesProvider.bovines);
    
    debugPrint('LivestockCoordinatorProvider: Todos os dados atualizados');
  }

  /// Sincronização completa com callback de progresso
  Future<bool> performCompleteSync({Function(double)? onProgress}) async {
    debugPrint('LivestockCoordinatorProvider: Iniciando sincronização completa');
    
    // Executa sincronização
    final syncSuccess = await _syncProvider.forceSyncNow(onProgress: onProgress);
    
    if (syncSuccess) {
      // Recarrega dados após sync bem-sucedido
      await refreshAllData();
      debugPrint('LivestockCoordinatorProvider: Sincronização completa realizada com sucesso');
    }
    
    return syncSuccess;
  }

  /// Limpa todos os erros dos providers especializados
  void clearAllErrors() {
    _bovinesProvider.clearError();
    _equinesProvider.clearError();
    _searchProvider.clearError();
    _statisticsProvider.clearError();
    _syncProvider.clearError();
    
    debugPrint('LivestockCoordinatorProvider: Todos os erros limpos');
  }

  /// Reset completo do sistema
  void resetSystem() {
    _bovinesProvider.resetState();
    _equinesProvider.resetState();
    _filtersProvider.clearAllFilters();
    _searchProvider.clearSearchResults();
    _statisticsProvider.clearStatistics();
    _syncProvider.resetSyncState();
    
    debugPrint('LivestockCoordinatorProvider: Sistema resetado');
  }

  // === PRIVATE METHODS ===

  void _initializeProviders() {
    // Escuta mudanças de todos os providers especializados
    _bovinesProvider.addListener(_onProviderChanged);
    _equinesProvider.addListener(_onProviderChanged);
    _filtersProvider.addListener(_onProviderChanged);
    _searchProvider.addListener(_onProviderChanged);
    _statisticsProvider.addListener(_onProviderChanged);
    _syncProvider.addListener(_onProviderChanged);
    
    debugPrint('LivestockCoordinatorProvider: Providers especializados inicializados');
  }

  void _onProviderChanged() {
    // Propaga mudanças para listeners do coordenador
    notifyListeners();
  }

  @override
  void dispose() {
    // Remove listeners dos providers especializados
    _bovinesProvider.removeListener(_onProviderChanged);
    _equinesProvider.removeListener(_onProviderChanged);
    _filtersProvider.removeListener(_onProviderChanged);
    _searchProvider.removeListener(_onProviderChanged);
    _statisticsProvider.removeListener(_onProviderChanged);
    _syncProvider.removeListener(_onProviderChanged);
    
    debugPrint('LivestockCoordinatorProvider: Disposed - listeners removidos');
    super.dispose();
  }
}

/// Extensão para facilitar acesso aos providers especializados
extension LivestockCoordinatorProviderExtension on LivestockCoordinatorProvider {
  /// Atalho para buscar animais
  Future<void> searchAnimals(String query) => searchProvider.searchAllAnimals(query);
  
  /// Atalho para sincronização rápida
  Future<bool> quickSync() => syncProvider.backgroundSync();
  
  /// Atalho para aplicar filtros
  void applyBovineFilters() {
    filtersProvider.updateAvailableValues(bovinesProvider.bovines);
  }
}