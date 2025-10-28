import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/space.dart';
import '../../domain/entities/plant.dart';

part 'spaces_state.freezed.dart';

/// View states for spaces feature
enum SpacesViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// State imutável para gerenciamento de espaços
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
class SpacesState with _$SpacesState {
  const SpacesState._();

  const factory SpacesState({
    /// Lista de espaços
    @Default([]) List<Space> spaces,

    /// Espaço selecionado
    Space? selectedSpace,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Filtro de busca
    @Default('') String searchQuery,

    /// Ordenação (name, plantCount)
    @Default('name') String sortBy,

    /// Ordem ascendente
    @Default(true) bool isAscending,

    /// Plantas por espaço (cache)
    @Default({}) Map<String, List<Plant>> plantsBySpace,
  }) = _SpacesState;

  /// Factory para estado inicial
  factory SpacesState.initial() => const SpacesState();

  // ========== Computed Properties ==========

  /// Espaços filtrados
  List<Space> get filteredSpaces {
    var filtered = spaces;

    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(query) ||
            (s.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Ordenar
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'plantCount':
          final aCount = plantsBySpace[a.id]?.length ?? 0;
          final bCount = plantsBySpace[b.id]?.length ?? 0;
          comparison = aCount.compareTo(bCount);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Conta total de espaços
  int get totalSpaces => spaces.length;

  /// Conta de espaços filtrados
  int get filteredCount => filteredSpaces.length;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se lista está vazia
  bool get isEmpty => spaces.isEmpty;

  /// Verifica se há espaços filtrados
  bool get hasFilteredSpaces => filteredSpaces.isNotEmpty;

  /// Verifica se há busca ativa
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Estado da view baseado nos dados
  SpacesViewState get viewState {
    if (isLoading) return SpacesViewState.loading;
    if (hasError) return SpacesViewState.error;
    if (isEmpty) return SpacesViewState.empty;
    if (hasFilteredSpaces) return SpacesViewState.loaded;
    return SpacesViewState.initial;
  }

  /// Verifica se há espaço selecionado
  bool get hasSelectedSpace => selectedSpace != null;

  /// Obtém plantas do espaço selecionado
  List<Plant> get selectedSpacePlants {
    if (selectedSpace == null) return [];
    return plantsBySpace[selectedSpace!.id] ?? [];
  }

  /// Conta de plantas no espaço selecionado
  int get selectedSpacePlantCount => selectedSpacePlants.length;

  /// Espaços com plantas
  List<Space> get spacesWithPlants {
    return spaces.where((s) {
      final plants = plantsBySpace[s.id] ?? [];
      return plants.isNotEmpty;
    }).toList();
  }

  /// Espaços vazios
  List<Space> get emptySpaces {
    return spaces.where((s) {
      final plants = plantsBySpace[s.id] ?? [];
      return plants.isEmpty;
    }).toList();
  }

  /// Total de plantas em todos os espaços
  int get totalPlantsCount {
    int total = 0;
    for (final plants in plantsBySpace.values) {
      total += plants.length;
    }
    return total;
  }

  /// Espaço com mais plantas
  Space? get spaceMostPlants {
    if (spaces.isEmpty) return null;

    Space? result;
    int maxCount = 0;

    for (final space in spaces) {
      final count = plantsBySpace[space.id]?.length ?? 0;
      if (count > maxCount) {
        maxCount = count;
        result = space;
      }
    }

    return result;
  }

  /// Média de plantas por espaço
  double get averagePlantsPerSpace {
    if (spaces.isEmpty) return 0.0;
    return totalPlantsCount / spaces.length;
  }
}

/// Extension para métodos de transformação do state
extension SpacesStateX on SpacesState {
  /// Limpa mensagem de erro
  SpacesState clearError() => copyWith(error: null);

  /// Limpa busca
  SpacesState clearSearch() => copyWith(searchQuery: '');

  /// Limpa seleção
  SpacesState clearSelection() => copyWith(selectedSpace: null);

  /// Reseta filtros
  SpacesState resetFilters() => copyWith(
        searchQuery: '',
        sortBy: 'name',
        isAscending: true,
      );

  /// Atualiza cache de plantas por espaço
  SpacesState updatePlantsBySpace(Map<String, List<Plant>> newPlantsBySpace) =>
      copyWith(plantsBySpace: newPlantsBySpace);
}
