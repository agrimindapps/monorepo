import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';

part 'bovines_filter_provider.g.dart';

/// State class for BovinesFilter
class BovinesFilterState {
  final String searchQuery;
  final String? selectedBreed;
  final String? selectedOriginCountry;
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final bool onlyActive;
  final Set<String> availableBreeds;
  final Set<String> availableCountries;

  const BovinesFilterState({
    this.searchQuery = '',
    this.selectedBreed,
    this.selectedOriginCountry,
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.onlyActive = true,
    this.availableBreeds = const {},
    this.availableCountries = const {},
  });

  BovinesFilterState copyWith({
    String? searchQuery,
    String? selectedBreed,
    String? selectedOriginCountry,
    BovineAptitude? selectedAptitude,
    BreedingSystem? selectedBreedingSystem,
    bool? onlyActive,
    Set<String>? availableBreeds,
    Set<String>? availableCountries,
    bool clearBreed = false,
    bool clearOriginCountry = false,
    bool clearAptitude = false,
    bool clearBreedingSystem = false,
    bool clearAll = false,
  }) {
    if (clearAll) {
      return BovinesFilterState(
        availableBreeds: availableBreeds ?? this.availableBreeds,
        availableCountries: availableCountries ?? this.availableCountries,
      );
    }
    return BovinesFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBreed: clearBreed ? null : (selectedBreed ?? this.selectedBreed),
      selectedOriginCountry: clearOriginCountry ? null : (selectedOriginCountry ?? this.selectedOriginCountry),
      selectedAptitude: clearAptitude ? null : (selectedAptitude ?? this.selectedAptitude),
      selectedBreedingSystem: clearBreedingSystem ? null : (selectedBreedingSystem ?? this.selectedBreedingSystem),
      onlyActive: onlyActive ?? this.onlyActive,
      availableBreeds: availableBreeds ?? this.availableBreeds,
      availableCountries: availableCountries ?? this.availableCountries,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedBreed != null ||
      selectedOriginCountry != null ||
      selectedAptitude != null ||
      selectedBreedingSystem != null ||
      !onlyActive;

  int get activeFiltersCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (selectedBreed != null) count++;
    if (selectedOriginCountry != null) count++;
    if (selectedAptitude != null) count++;
    if (selectedBreedingSystem != null) count++;
    if (!onlyActive) count++;
    return count;
  }

  List<String> get availableBreedsList => availableBreeds.toList()..sort();
  List<String> get availableCountriesList => availableCountries.toList()..sort();
  List<BovineAptitude> get availableAptitudes => BovineAptitude.values;
  List<BreedingSystem> get availableBreedingSystems => BreedingSystem.values;

  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'selectedBreed': selectedBreed,
      'selectedOriginCountry': selectedOriginCountry,
      'selectedAptitude': selectedAptitude?.name,
      'selectedBreedingSystem': selectedBreedingSystem?.name,
      'onlyActive': onlyActive,
    };
  }
}

/// Provider especializado para filtros de bovinos
///
/// Responsabilidade única: Gerenciar filtros e filtragem de bovinos
/// Seguindo Single Responsibility Principle
@riverpod
class BovinesFilterNotifier extends _$BovinesFilterNotifier {
  @override
  BovinesFilterState build() {
    return const BovinesFilterState();
  }

  // Convenience getters for backward compatibility
  String get searchQuery => state.searchQuery;
  String? get selectedBreed => state.selectedBreed;
  String? get selectedOriginCountry => state.selectedOriginCountry;
  BovineAptitude? get selectedAptitude => state.selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => state.selectedBreedingSystem;
  bool get onlyActive => state.onlyActive;
  List<String> get availableBreeds => state.availableBreedsList;
  List<String> get availableCountries => state.availableCountriesList;
  List<BovineAptitude> get availableAptitudes => state.availableAptitudes;
  List<BreedingSystem> get availableBreedingSystems => state.availableBreedingSystems;
  bool get hasActiveFilters => state.hasActiveFilters;
  int get activeFiltersCount => state.activeFiltersCount;

  /// Atualiza cache de valores disponíveis com base na lista de bovinos
  void updateAvailableValues(List<BovineEntity> bovines) {
    final breeds = <String>{};
    final countries = <String>{};

    for (final bovine in bovines) {
      breeds.add(bovine.breed);
      countries.add(bovine.originCountry);
    }

    // Validate existing selections
    final newBreed = state.selectedBreed != null && !breeds.contains(state.selectedBreed) 
        ? null : state.selectedBreed;
    final newCountry = state.selectedOriginCountry != null && !countries.contains(state.selectedOriginCountry)
        ? null : state.selectedOriginCountry;

    state = state.copyWith(
      availableBreeds: breeds,
      availableCountries: countries,
      selectedBreed: newBreed,
      selectedOriginCountry: newCountry,
      clearBreed: newBreed == null && state.selectedBreed != null,
      clearOriginCountry: newCountry == null && state.selectedOriginCountry != null,
    );
  }

  /// Aplica todos os filtros a uma lista de bovinos
  List<BovineEntity> applyFilters(List<BovineEntity> bovines) {
    var filtered = List<BovineEntity>.from(bovines);
    
    if (state.onlyActive) {
      filtered = filtered.where((bovine) => bovine.isActive).toList();
    }
    
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((bovine) =>
              bovine.commonName.toLowerCase().contains(query) ||
              bovine.breed.toLowerCase().contains(query) ||
              bovine.registrationId.toLowerCase().contains(query))
          .toList();
    }
    
    if (state.selectedBreed != null) {
      filtered = filtered
          .where((bovine) => bovine.breed
              .toLowerCase()
              .contains(state.selectedBreed!.toLowerCase()))
          .toList();
    }
    
    if (state.selectedOriginCountry != null) {
      filtered = filtered
          .where((bovine) => bovine.originCountry
              .toLowerCase()
              .contains(state.selectedOriginCountry!.toLowerCase()))
          .toList();
    }
    
    if (state.selectedAptitude != null) {
      filtered = filtered
          .where((bovine) => bovine.aptitude == state.selectedAptitude)
          .toList();
    }
    
    if (state.selectedBreedingSystem != null) {
      filtered = filtered
          .where((bovine) => bovine.breedingSystem == state.selectedBreedingSystem)
          .toList();
    }

    return filtered;
  }

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    debugPrint('BovinesFilterNotifier: Query de busca atualizada - "$query"');
  }

  /// Atualiza filtro de raça
  void updateBreedFilter(String? breed) {
    state = state.copyWith(
      selectedBreed: breed,
      clearBreed: breed == null,
    );
    debugPrint('BovinesFilterNotifier: Filtro de raça atualizado - ${breed ?? "nenhum"}');
  }

  /// Atualiza filtro de país de origem
  void updateOriginCountryFilter(String? country) {
    state = state.copyWith(
      selectedOriginCountry: country,
      clearOriginCountry: country == null,
    );
    debugPrint('BovinesFilterNotifier: Filtro de país atualizado - ${country ?? "nenhum"}');
  }

  /// Atualiza filtro de aptidão
  void updateAptitudeFilter(BovineAptitude? aptitude) {
    state = state.copyWith(
      selectedAptitude: aptitude,
      clearAptitude: aptitude == null,
    );
    debugPrint('BovinesFilterNotifier: Filtro de aptidão atualizado - ${aptitude?.name ?? "nenhum"}');
  }

  /// Atualiza filtro de sistema de criação
  void updateBreedingSystemFilter(BreedingSystem? system) {
    state = state.copyWith(
      selectedBreedingSystem: system,
      clearBreedingSystem: system == null,
    );
    debugPrint('BovinesFilterNotifier: Filtro de sistema atualizado - ${system?.name ?? "nenhum"}');
  }

  /// Atualiza filtro de status ativo
  void updateActiveFilter(bool onlyActive) {
    state = state.copyWith(onlyActive: onlyActive);
    debugPrint('BovinesFilterNotifier: Filtro de ativos atualizado - $onlyActive');
  }

  /// Limpa todos os filtros
  void clearAllFilters() {
    state = state.copyWith(clearAll: true);
    debugPrint('BovinesFilterNotifier: Todos os filtros limpos');
  }

  /// Limpa apenas filtros de texto
  void clearTextFilters() {
    state = state.copyWith(searchQuery: '');
    debugPrint('BovinesFilterNotifier: Filtros de texto limpos');
  }

  /// Limpa apenas filtros de seleção
  void clearSelectionFilters() {
    state = state.copyWith(
      clearBreed: true,
      clearOriginCountry: true,
      clearAptitude: true,
      clearBreedingSystem: true,
    );
    debugPrint('BovinesFilterNotifier: Filtros de seleção limpos');
  }

  /// Define múltiplos filtros de uma vez
  void setFilters({
    String? searchQuery,
    String? breed,
    String? originCountry,
    BovineAptitude? aptitude,
    BreedingSystem? breedingSystem,
    bool? onlyActive,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      selectedBreed: breed,
      selectedOriginCountry: originCountry,
      selectedAptitude: aptitude,
      selectedBreedingSystem: breedingSystem,
      onlyActive: onlyActive,
    );
    debugPrint('BovinesFilterNotifier: Múltiplos filtros atualizados');
  }

  /// Obtém estado atual dos filtros como Map
  Map<String, dynamic> getCurrentFilters() {
    return state.toMap();
  }

  /// Restaura filtros de um Map
  void restoreFilters(Map<String, dynamic> filters) {
    BovineAptitude? aptitude;
    if (filters['selectedAptitude'] != null) {
      aptitude = BovineAptitude.values.firstWhere(
        (apt) => apt.name == filters['selectedAptitude'],
        orElse: () => BovineAptitude.values.first,
      );
    }

    BreedingSystem? breedingSystem;
    if (filters['selectedBreedingSystem'] != null) {
      breedingSystem = BreedingSystem.values.firstWhere(
        (system) => system.name == filters['selectedBreedingSystem'],
        orElse: () => BreedingSystem.values.first,
      );
    }

    state = state.copyWith(
      searchQuery: (filters['searchQuery'] as String?) ?? '',
      selectedBreed: filters['selectedBreed'] as String?,
      selectedOriginCountry: filters['selectedOriginCountry'] as String?,
      selectedAptitude: aptitude,
      selectedBreedingSystem: breedingSystem,
      onlyActive: (filters['onlyActive'] as bool?) ?? true,
    );
    debugPrint('BovinesFilterNotifier: Filtros restaurados');
  }
}
