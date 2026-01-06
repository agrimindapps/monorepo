import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/plant.dart';
import '../../domain/entities/space.dart';

part 'plants_state.freezed.dart';

/// View states for plants feature
enum PlantsViewState { initial, loading, loaded, error, empty }

/// Filtro de visualização
enum PlantsViewFilter {
  all('Todas'),
  favorites('Favoritas'),
  needsWater('Precisa Água'),
  bySpace('Por Espaço');

  const PlantsViewFilter(this.displayName);
  final String displayName;
}

/// State imutável para gerenciamento de plantas
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class PlantsState with _$PlantsState {
  const factory PlantsState({
    /// Lista de plantas
    @Default([]) List<Plant> plants,

    /// Planta selecionada
    Plant? selectedPlant,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro de visualização
    @Default(PlantsViewFilter.all) PlantsViewFilter viewFilter,

    /// Filtro por espaço
    String? selectedSpaceId,

    /// Filtro de busca
    @Default('') String searchQuery,

    /// Ordenação (name, age, lastWatered)
    @Default('name') String sortBy,

    /// Ordem ascendente
    @Default(true) bool isAscending,

    /// Lista de espaços (para filtros)
    @Default([]) List<Space> spaces,
  }) = _PlantsState;
}

/// Extension para métodos de transformação e computed properties do PlantsState
extension PlantsStateX on PlantsState {
  /// Factory para estado inicial
  static PlantsState initial() => const PlantsState();

  // ========== Computed Properties ==========

  /// Plantas filtradas
  List<Plant> get filteredPlants {
    var filtered = plants.toList();

    // Filtrar por tipo de visualização
    switch (viewFilter) {
      case PlantsViewFilter.favorites:
        filtered = filtered.where((p) => p.isFavorited).toList();
        break;
      case PlantsViewFilter.needsWater:
        filtered = filtered.where((p) {
          if (p.lastWatered == null || p.wateringFrequency == null) {
            return false;
          }
          final daysSinceWatered = DateTime.now()
              .difference(p.lastWatered!)
              .inDays;
          return daysSinceWatered >= p.wateringFrequency!;
        }).toList();
        break;
      case PlantsViewFilter.bySpace:
        if (selectedSpaceId != null) {
          filtered = filtered
              .where((p) => p.spaceId == selectedSpaceId)
              .toList();
        }
        break;
      case PlantsViewFilter.all:
        break;
    }

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.species?.toLowerCase().contains(query) ?? false) ||
            (p.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'age':
          comparison = a.ageInDays.compareTo(b.ageInDays);
          break;
        case 'lastWatered':
          final aDate = a.lastWatered ?? DateTime(1900);
          final bDate = b.lastWatered ?? DateTime(1900);
          comparison = aDate.compareTo(bDate);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Plantas favoritas
  List<Plant> get favoritePlants => plants.where((p) => p.isFavorited).toList();

  /// Plantas que precisam de água
  List<Plant> get plantsNeedingWater => plants.where((p) {
    if (p.lastWatered == null || p.wateringFrequency == null) return false;
    final daysSinceWatered = DateTime.now().difference(p.lastWatered!).inDays;
    return daysSinceWatered >= p.wateringFrequency!;
  }).toList();

  /// Conta total de plantas
  int get totalPlants => plants.length;

  /// Conta de plantas filtradas
  int get filteredCount => filteredPlants.length;

  /// Conta de favoritas
  int get favoritesCount => favoritePlants.length;

  /// Conta de plantas que precisam água
  int get needsWaterCount => plantsNeedingWater.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => plants.isEmpty;

  /// Verifica se há plantas filtradas
  bool get hasFilteredPlants => filteredPlants.isNotEmpty;

  /// Verifica se há busca ativa
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Verifica se há filtros ativos
  bool get hasActiveFilters =>
      viewFilter != PlantsViewFilter.all ||
      selectedSpaceId != null ||
      hasSearchQuery;

  /// Estado da view baseado nos dados
  PlantsViewState get viewState {
    if (isLoading) return PlantsViewState.loading;
    if (hasError) return PlantsViewState.error;
    if (isEmpty) return PlantsViewState.empty;
    if (hasFilteredPlants) return PlantsViewState.loaded;
    return PlantsViewState.initial;
  }

  /// Verifica se há planta selecionada
  bool get hasSelectedPlant => selectedPlant != null;

  /// Verifica se há alertas (plantas que precisam água)
  bool get hasAlerts => needsWaterCount > 0;

  /// Plantas por espaço
  Map<String, List<Plant>> get plantsBySpace {
    final map = <String, List<Plant>>{};
    for (final plant in plants) {
      final spaceId = plant.spaceId ?? 'sem_espaco';
      map.putIfAbsent(spaceId, () => []).add(plant);
    }
    return map;
  }

  /// Limpa mensagem de erro
  PlantsState clearError() => copyWith(error: null);

  /// Limpa busca
  PlantsState clearSearch() => copyWith(searchQuery: '');

  /// Limpa seleção
  PlantsState clearSelection() => copyWith(selectedPlant: null);

  /// Reseta filtros
  PlantsState resetFilters() => copyWith(
    viewFilter: PlantsViewFilter.all,
    selectedSpaceId: null,
    searchQuery: '',
    sortBy: 'name',
    isAscending: true,
  );
}
