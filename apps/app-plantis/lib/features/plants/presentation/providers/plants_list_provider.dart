import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/error_adapter.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';

part 'plants_list_provider.freezed.dart';
part 'plants_list_provider.g.dart';

@freezed
class PlantsListState with _$PlantsListState {
  const factory PlantsListState({
    @Default([]) List<Plant> plants,
    @Default([]) List<Plant> filteredPlants,
    @Default(false) bool isLoading,
    @Default('') String searchQuery,
    String? errorMessage,
  }) = _PlantsListState;

  const PlantsListState._();

  List<Plant> get displayPlants =>
      filteredPlants.isEmpty && searchQuery.isEmpty ? plants : filteredPlants;

  bool get hasPlants => plants.isNotEmpty;
  bool get isEmpty => plants.isEmpty && !isLoading;
  int get plantsCount => plants.length;
}

@riverpod
class PlantsListNotifier extends _$PlantsListNotifier {
  late final PlantsRepository _plantsRepository;

  @override
  PlantsListState build(PlantsRepository plantsRepository) {
    _plantsRepository = plantsRepository;
    return const PlantsListState();
  }

  Future<void> loadPlants() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _plantsRepository.getPlants();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (plants) {
          state = state.copyWith(
            plants: plants,
            isLoading: false,
            errorMessage: null,
          );
          _applySearch();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  Future<void> addPlant(Plant plant) async {
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _plantsRepository.addPlant(plant);

      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (addedPlant) {
          state = state.copyWith(
            plants: [...state.plants, addedPlant],
            errorMessage: null,
          );
          _applySearch();
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao adicionar planta: $e');
    }
  }

  Future<void> updatePlant(Plant plant) async {
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _plantsRepository.updatePlant(plant);

      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (updatedPlant) {
          final updatedPlants = state.plants.map((p) {
            return p.id == updatedPlant.id ? updatedPlant : p;
          }).toList();

          state = state.copyWith(
            plants: updatedPlants,
            errorMessage: null,
          );
          _applySearch();
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar planta: $e');
    }
  }

  Future<void> deletePlant(String id) async {
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _plantsRepository.deletePlant(id);

      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (_) {
          state = state.copyWith(
            plants: state.plants.where((plant) => plant.id != id).toList(),
            filteredPlants:
                state.filteredPlants.where((plant) => plant.id != id).toList(),
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao deletar planta: $e');
    }
  }

  void searchPlants(String query) {
    state = state.copyWith(searchQuery: query.trim().toLowerCase());
    _applySearch();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', filteredPlants: []);
  }

  Future<void> performRemoteSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _plantsRepository.searchPlants(query);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (searchResults) {
          state = state.copyWith(
            searchQuery: query.trim().toLowerCase(),
            filteredPlants: searchResults,
            isLoading: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na busca: $e',
      );
    }
  }

  List<Plant> getPlantsBySpace(String spaceId) {
    return state.displayPlants
        .where((plant) => plant.spaceId == spaceId)
        .toList();
  }

  List<Plant> getPlantsWithImages() {
    return state.displayPlants.where((plant) => plant.hasImage).toList();
  }

  List<Plant> getRecentPlants({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return state.displayPlants
        .where((plant) => plant.createdAt?.isAfter(cutoffDate) ?? false)
        .toList();
  }

  Plant? getPlantById(String id) {
    try {
      return state.plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  void refresh() {
    loadPlants();
  }

  void _applySearch() {
    if (state.searchQuery.isEmpty) {
      state = state.copyWith(filteredPlants: []);
    } else {
      final filtered = state.plants.where((plant) {
        final name = plant.name.toLowerCase();
        final species = plant.species?.toLowerCase() ?? '';
        final notes = plant.notes?.toLowerCase() ?? '';

        return name.contains(state.searchQuery) ||
            species.contains(state.searchQuery) ||
            notes.contains(state.searchQuery);
      }).toList();

      state = state.copyWith(filteredPlants: filtered);
    }
  }
}
