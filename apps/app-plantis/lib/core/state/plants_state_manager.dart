import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/plants_care_calculator.dart' as care_service;
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart' as filter_service;

/// Estado das plantas para gerenciamento
class PlantsState {
  final List<Plant> allPlants;
  final List<Plant> filteredPlants;
  final Plant? selectedPlant;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String searchQuery;
  final ViewMode viewMode;
  final PlantSortOption sortBy;
  final String? filterBySpace;
  final PlantCareStatus? filterByCareStatus;
  final bool showOnlyFavorites;
  final bool showOnlyNeedingWater;

  const PlantsState({
    this.allPlants = const [],
    this.filteredPlants = const [],
    this.selectedPlant,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.viewMode = ViewMode.grid,
    this.sortBy = PlantSortOption.nameAZ,
    this.filterBySpace,
    this.filterByCareStatus,
    this.showOnlyFavorites = false,
    this.showOnlyNeedingWater = false,
  });

  PlantsState copyWith({
    List<Plant>? allPlants,
    List<Plant>? filteredPlants,
    Plant? selectedPlant,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? searchQuery,
    ViewMode? viewMode,
    PlantSortOption? sortBy,
    String? filterBySpace,
    PlantCareStatus? filterByCareStatus,
    bool? showOnlyFavorites,
    bool? showOnlyNeedingWater,
    bool clearError = false,
    bool clearSelectedPlant = false,
  }) {
    return PlantsState(
      allPlants: allPlants ?? this.allPlants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
      selectedPlant: clearSelectedPlant ? null : (selectedPlant ?? this.selectedPlant),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: filterBySpace ?? this.filterBySpace,
      filterByCareStatus: filterByCareStatus ?? this.filterByCareStatus,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      showOnlyNeedingWater: showOnlyNeedingWater ?? this.showOnlyNeedingWater,
    );
  }

  // Convenience getters
  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  bool get isGroupedBySpaces => viewMode == ViewMode.groupedBySpaces;
  int get plantsCount => allPlants.length;
  
  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final Map<String?, List<Plant>> groupedPlants = {};

    for (final plant in filteredPlants) {
      final spaceId = plant.spaceId;
      if (!groupedPlants.containsKey(spaceId)) {
        groupedPlants[spaceId] = [];
      }
      groupedPlants[spaceId]!.add(plant);
    }

    return groupedPlants;
  }
}

/// Enum para modo de visualização
enum ViewMode {
  grid,
  list,
  groupedBySpaces,
}

/// Enum para opções de ordenação (local)
enum PlantSortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
  careUrgency,
  lastWatered,
}

/// Enum para status de cuidado (local)
enum PlantCareStatus {
  critical,
  needsWater,
  soon,
  healthy,
  unknown,
}

/// Gerenciador de estado APENAS para coordenação UI
/// Resolve violação SRP - separando coordenação de lógica de negócio
class PlantsStateManager extends ChangeNotifier {
  final PlantsDataService _dataService;
  final filter_service.PlantsFilterService _filterService;
  final care_service.PlantsCareCalculator _careCalculator;
  final IAuthStateProvider _authProvider;
  
  PlantsState _state = const PlantsState();
  StreamSubscription<UserEntity?>? _authSubscription;
  Timer? _autoRefreshTimer;

  PlantsStateManager({
    required PlantsDataService dataService,
    required filter_service.PlantsFilterService filterService,
    required care_service.PlantsCareCalculator careCalculator,
    required IAuthStateProvider authProvider,
  })  : _dataService = dataService,
        _filterService = filterService,
        _careCalculator = careCalculator,
        _authProvider = authProvider {
    _initialize();
  }

  /// Estado atual
  PlantsState get state => _state;

  /// Inicializa o gerenciador
  void _initialize() {
    // Escutar mudanças no estado de autenticação
    _authSubscription = _authProvider.userStream.listen(_onAuthStateChanged);
    
    // Configurar auto-refresh a cada 15 minutos
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => refreshPlants(),
    );
    
    // Carregar plantas inicial
    loadPlants();
  }

  /// Callback para mudanças no estado de auth
  void _onAuthStateChanged(UserEntity? user) {
    if (user != null) {
      // Usuário logou - carregar plantas
      loadPlants();
    } else {
      // Usuário deslogou - limpar estado
      _updateState(_state.copyWith(
        allPlants: [],
        filteredPlants: [],
        clearSelectedPlant: true,
        clearError: true,
      ));
    }
  }

  /// Atualiza o estado e notifica listeners
  void _updateState(PlantsState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Carrega todas as plantas
  Future<void> loadPlants() async {
    if (_state.isLoading) return;

    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _dataService.loadPlants();
      
      await result.fold(
        (failure) async {
          _updateState(_state.copyWith(
            isLoading: false,
            error: failure.message,
          ));
        },
        (plants) async {
          _updateState(_state.copyWith(
            allPlants: plants,
            isLoading: false,
            clearError: true,
          ));
          
          // Aplicar filtros aos dados carregados
          await _applyCurrentFilters();
        },
      );
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: $e',
      ));
    }
  }

  /// Atualiza plantas (pull-to-refresh)
  Future<void> refreshPlants() async {
    await loadPlants();
  }

  /// Adiciona uma nova planta
  Future<bool> addPlant(AddPlantParams params) async {
    final result = await _dataService.addPlant(params);
    
    return result.fold(
      (failure) {
        _updateState(_state.copyWith(error: failure.message));
        return false;
      },
      (plant) {
        final updatedPlants = [..._state.allPlants, plant];
        _updateState(_state.copyWith(allPlants: updatedPlants));
        _applyCurrentFilters();
        return true;
      },
    );
  }

  /// Atualiza uma planta existente
  Future<bool> updatePlant(UpdatePlantParams params) async {
    final result = await _dataService.updatePlant(params);
    
    return result.fold(
      (failure) {
        _updateState(_state.copyWith(error: failure.message));
        return false;
      },
      (updatedPlant) {
        final updatedPlants = _state.allPlants.map((plant) {
          return plant.id == updatedPlant.id ? updatedPlant : plant;
        }).toList();
        
        _updateState(_state.copyWith(allPlants: updatedPlants));
        _applyCurrentFilters();
        return true;
      },
    );
  }

  /// Remove uma planta
  Future<bool> deletePlant(String plantId) async {
    final result = await _dataService.deletePlant(plantId);
    
    return result.fold(
      (failure) {
        _updateState(_state.copyWith(error: failure.message));
        return false;
      },
      (_) {
        final updatedPlants = _state.allPlants.where((plant) => plant.id != plantId).toList();
        _updateState(_state.copyWith(
          allPlants: updatedPlants,
          clearSelectedPlant: _state.selectedPlant?.id == plantId,
        ));
        _applyCurrentFilters();
        return true;
      },
    );
  }

  /// Seleciona uma planta
  void selectPlant(Plant? plant) {
    _updateState(_state.copyWith(selectedPlant: plant));
  }

  /// Busca plantas por termo
  Future<void> searchPlants(String query) async {
    _updateState(_state.copyWith(
      searchQuery: query,
      isSearching: query.isNotEmpty,
    ));
    
    await _applyCurrentFilters();
  }

  /// Define filtro por espaço
  Future<void> setSpaceFilter(String? spaceId) async {
    _updateState(_state.copyWith(filterBySpace: spaceId));
    await _applyCurrentFilters();
  }

  /// Define filtro por status de cuidado
  Future<void> setCareStatusFilter(PlantCareStatus? status) async {
    _updateState(_state.copyWith(filterByCareStatus: status));
    await _applyCurrentFilters();
  }

  /// Define filtro de favoritos
  Future<void> setFavoritesFilter(bool showOnlyFavorites) async {
    _updateState(_state.copyWith(showOnlyFavorites: showOnlyFavorites));
    await _applyCurrentFilters();
  }

  /// Define filtro de plantas que precisam de água
  Future<void> setNeedingWaterFilter(bool showOnlyNeedingWater) async {
    _updateState(_state.copyWith(showOnlyNeedingWater: showOnlyNeedingWater));
    await _applyCurrentFilters();
  }

  /// Define ordenação
  Future<void> setSortBy(PlantSortOption sortBy) async {
    _updateState(_state.copyWith(sortBy: sortBy));
    await _applyCurrentFilters();
  }

  /// Define modo de visualização
  void setViewMode(ViewMode viewMode) {
    _updateState(_state.copyWith(viewMode: viewMode));
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    _updateState(_state.copyWith(
      searchQuery: '',
      filterBySpace: null,
      filterByCareStatus: null,
      showOnlyFavorites: false,
      showOnlyNeedingWater: false,
      isSearching: false,
    ));
    
    await _applyCurrentFilters();
  }

  /// Aplica filtros atuais aos dados
  Future<void> _applyCurrentFilters() async {
    final filtered = _filterService.searchWithFilters(
      plants: _state.allPlants,
      searchTerm: _state.searchQuery.isNotEmpty ? _state.searchQuery : null,
      spaceId: _state.filterBySpace,
      careStatus: _mapToServiceCareStatus(_state.filterByCareStatus),
      onlyFavorites: _state.showOnlyFavorites,
      onlyNeedingWater: _state.showOnlyNeedingWater,
      sortOption: _mapToServiceSortOption(_state.sortBy),
    );

    _updateState(_state.copyWith(filteredPlants: filtered));
  }

  /// Obtém estatísticas de cuidado
  care_service.PlantCareStatistics getCareStatistics() {
    return _careCalculator.calculateCareStatistics(_state.allPlants);
  }

  /// Obtém plantas que precisam de água em breve
  List<Plant> getPlantsNeedingWaterSoon(int days) {
    return _careCalculator.getPlantsNeedingWaterSoon(_state.allPlants, days);
  }

  /// Calcula status de cuidado de uma planta específica
  PlantCareStatus getPlantCareStatus(Plant plant) {
    final serviceStatus = _careCalculator.calculateCareStatus(plant);
    return _mapFromServiceCareStatus(serviceStatus);
  }

  /// Mapeia enum local para enum do service (sort)
  filter_service.PlantSortOption _mapToServiceSortOption(PlantSortOption option) {
    switch (option) {
      case PlantSortOption.nameAZ:
        return filter_service.PlantSortOption.nameAZ;
      case PlantSortOption.nameZA:
        return filter_service.PlantSortOption.nameZA;
      case PlantSortOption.dateNewest:
        return filter_service.PlantSortOption.dateNewest;
      case PlantSortOption.dateOldest:
        return filter_service.PlantSortOption.dateOldest;
      case PlantSortOption.careUrgency:
        return filter_service.PlantSortOption.careUrgency;
      case PlantSortOption.lastWatered:
        return filter_service.PlantSortOption.lastWatered;
    }
  }

  /// Mapeia enum local para enum do service (care status)
  filter_service.PlantCareStatus? _mapToServiceCareStatus(PlantCareStatus? status) {
    if (status == null) return null;
    switch (status) {
      case PlantCareStatus.critical:
        return filter_service.PlantCareStatus.critical;
      case PlantCareStatus.needsWater:
        return filter_service.PlantCareStatus.needsWater;
      case PlantCareStatus.soon:
        return filter_service.PlantCareStatus.soon;
      case PlantCareStatus.healthy:
        return filter_service.PlantCareStatus.healthy;
      case PlantCareStatus.unknown:
        return filter_service.PlantCareStatus.unknown;
    }
  }

  /// Mapeia enum do service para enum local (care status)
  PlantCareStatus _mapFromServiceCareStatus(care_service.PlantCareStatus serviceStatus) {
    switch (serviceStatus) {
      case care_service.PlantCareStatus.critical:
        return PlantCareStatus.critical;
      case care_service.PlantCareStatus.needsWater:
        return PlantCareStatus.needsWater;
      case care_service.PlantCareStatus.soon:
        return PlantCareStatus.soon;
      case care_service.PlantCareStatus.healthy:
        return PlantCareStatus.healthy;
      case care_service.PlantCareStatus.unknown:
        return PlantCareStatus.unknown;
    }
  }

  /// Limpa erros
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}