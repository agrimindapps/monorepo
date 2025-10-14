import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import 'bovines_filter_state.dart';

part 'bovines_filter_notifier.g.dart';

/// Riverpod notifier for bovines filters
///
/// Single Responsibility: Manage filters and filtering of bovines
@riverpod
class BovinesFilterNotifier extends _$BovinesFilterNotifier {
  @override
  BovinesFilterState build() {
    return const BovinesFilterState();
  }

  /// Computed properties
  List<String> get availableBreeds => state.availableBreeds.toList()..sort();
  List<String> get availableCountries =>
      state.availableCountries.toList()..sort();
  List<BovineAptitude> get availableAptitudes => BovineAptitude.values;
  List<BreedingSystem> get availableBreedingSystems => BreedingSystem.values;

  bool get hasActiveFilters =>
      state.searchQuery.isNotEmpty ||
      state.selectedBreed != null ||
      state.selectedOriginCountry != null ||
      state.selectedAptitude != null ||
      state.selectedBreedingSystem != null ||
      !state.onlyActive;

  int get activeFiltersCount {
    int count = 0;
    if (state.searchQuery.isNotEmpty) count++;
    if (state.selectedBreed != null) count++;
    if (state.selectedOriginCountry != null) count++;
    if (state.selectedAptitude != null) count++;
    if (state.selectedBreedingSystem != null) count++;
    if (!state.onlyActive) count++;
    return count;
  }

  /// Updates cache of available values based on bovines list
  void updateAvailableValues(List<BovineEntity> bovines) {
    final breeds = <String>{};
    final countries = <String>{};

    for (final bovine in bovines) {
      breeds.add(bovine.breed);
      countries.add(bovine.originCountry);
    }

    // Clear invalid selections
    String? validatedBreed = state.selectedBreed;
    String? validatedCountry = state.selectedOriginCountry;

    if (validatedBreed != null && !breeds.contains(validatedBreed)) {
      validatedBreed = null;
    }
    if (validatedCountry != null && !countries.contains(validatedCountry)) {
      validatedCountry = null;
    }

    state = state.copyWith(
      availableBreeds: breeds,
      availableCountries: countries,
      selectedBreed: validatedBreed,
      selectedOriginCountry: validatedCountry,
    );
  }

  /// Applies all filters to a bovines list
  List<BovineEntity> applyFilters(List<BovineEntity> bovines) {
    var filtered = List<BovineEntity>.from(bovines);

    if (state.onlyActive) {
      filtered = filtered.where((bovine) => bovine.isActive).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((bovine) =>
          bovine.commonName.toLowerCase().contains(query) ||
          bovine.breed.toLowerCase().contains(query) ||
          bovine.registrationId.toLowerCase().contains(query)).toList();
    }

    if (state.selectedBreed != null) {
      filtered = filtered
          .where((bovine) =>
              bovine.breed.toLowerCase().contains(state.selectedBreed!.toLowerCase()))
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

  /// Updates search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    debugPrint('BovinesFilterNotifier: Query de busca atualizada - "$query"');
  }

  /// Updates breed filter
  void updateBreedFilter(String? breed) {
    state = state.copyWith(selectedBreed: breed);
    debugPrint(
      'BovinesFilterNotifier: Filtro de raça atualizado - ${breed ?? "nenhum"}',
    );
  }

  /// Updates origin country filter
  void updateOriginCountryFilter(String? country) {
    state = state.copyWith(selectedOriginCountry: country);
    debugPrint(
      'BovinesFilterNotifier: Filtro de país atualizado - ${country ?? "nenhum"}',
    );
  }

  /// Updates aptitude filter
  void updateAptitudeFilter(BovineAptitude? aptitude) {
    state = state.copyWith(selectedAptitude: aptitude);
    debugPrint(
      'BovinesFilterNotifier: Filtro de aptidão atualizado - ${aptitude?.name ?? "nenhum"}',
    );
  }

  /// Updates breeding system filter
  void updateBreedingSystemFilter(BreedingSystem? system) {
    state = state.copyWith(selectedBreedingSystem: system);
    debugPrint(
      'BovinesFilterNotifier: Filtro de sistema atualizado - ${system?.name ?? "nenhum"}',
    );
  }

  /// Updates active filter
  void updateActiveFilter(bool onlyActive) {
    state = state.copyWith(onlyActive: onlyActive);
    debugPrint(
      'BovinesFilterNotifier: Filtro de ativos atualizado - $onlyActive',
    );
  }

  /// Clears all filters
  void clearAllFilters() {
    state = const BovinesFilterState();
    debugPrint('BovinesFilterNotifier: Todos os filtros limpos');
  }

  /// Clears only text filters
  void clearTextFilters() {
    state = state.copyWith(searchQuery: '');
    debugPrint('BovinesFilterNotifier: Filtros de texto limpos');
  }

  /// Clears only selection filters
  void clearSelectionFilters() {
    state = state.copyWith(
      selectedBreed: null,
      selectedOriginCountry: null,
      selectedAptitude: null,
      selectedBreedingSystem: null,
    );
    debugPrint('BovinesFilterNotifier: Filtros de seleção limpos');
  }

  /// Sets multiple filters at once
  void setFilters({
    String? searchQuery,
    String? breed,
    String? originCountry,
    BovineAptitude? aptitude,
    BreedingSystem? breedingSystem,
    bool? onlyActive,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      selectedBreed: breed,
      selectedOriginCountry: originCountry,
      selectedAptitude: aptitude,
      selectedBreedingSystem: breedingSystem,
      onlyActive: onlyActive ?? state.onlyActive,
    );
    debugPrint('BovinesFilterNotifier: Múltiplos filtros atualizados');
  }

  /// Gets current filters as Map
  Map<String, dynamic> getCurrentFilters() {
    return {
      'searchQuery': state.searchQuery,
      'selectedBreed': state.selectedBreed,
      'selectedOriginCountry': state.selectedOriginCountry,
      'selectedAptitude': state.selectedAptitude?.name,
      'selectedBreedingSystem': state.selectedBreedingSystem?.name,
      'onlyActive': state.onlyActive,
    };
  }

  /// Restores filters from a Map
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
