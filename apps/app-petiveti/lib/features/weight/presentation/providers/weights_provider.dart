import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';

import 'package:flutter/material.dart';


import 'weight_providers.dart';

import '../../../../core/interfaces/usecase.dart' as local;

import '../../domain/entities/weight.dart';

import '../../domain/repositories/weight_repository.dart';

import '../../domain/usecases/add_weight.dart';

import '../../domain/usecases/get_weight_statistics.dart';

import '../../domain/usecases/get_weights.dart';

import '../../domain/usecases/get_weights_by_animal_id.dart';

import '../../domain/usecases/update_weight.dart';

import '../states/weights_crud_state.dart';

import '../states/weights_filter_state.dart';

import '../states/weights_query_state.dart';

import '../states/weights_sort_state.dart';

import './notifiers/weights_crud_notifier.dart';

import './notifiers/weights_filter_notifier.dart';

import './notifiers/weights_query_notifier.dart';

import './notifiers/weights_sort_notifier.dart';

part 'weights_provider.g.dart';


// ============================================================================
// ENUMS AND EXTENSIONS - exported from weights_sort_state.dart
// ============================================================================
// WeightSortOrder is defined in states/weight_sort_order.dart and 
// re-exported through weights_sort_state.dart

// ============================================================================
// LEGACY STATE CLASS (Maintained for backward compatibility)
// ============================================================================

class WeightsState {
  final List<Weight> weights;
  final Map<String, List<Weight>> weightsByAnimal;
  final WeightStatistics? statistics;
  final bool isLoading;
  final String? error;
  final String? selectedAnimalId;
  final WeightSortOrder sortOrder;

  const WeightsState({
    this.weights = const [],
    this.weightsByAnimal = const {},
    this.statistics,
    this.isLoading = false,
    this.error,
    this.selectedAnimalId,
    this.sortOrder = WeightSortOrder.dateDesc,
  });

  WeightsState copyWith({
    List<Weight>? weights,
    Map<String, List<Weight>>? weightsByAnimal,
    WeightStatistics? statistics,
    bool? isLoading,
    String? error,
    String? selectedAnimalId,
    WeightSortOrder? sortOrder,
  }) {
    return WeightsState(
      weights: weights ?? this.weights,
      weightsByAnimal: weightsByAnimal ?? this.weightsByAnimal,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  List<Weight> get currentWeights {
    if (selectedAnimalId != null) {
      return weightsByAnimal[selectedAnimalId] ?? [];
    }
    return weights;
  }

  List<Weight> get sortedWeights {
    final weightList = List<Weight>.from(currentWeights);

    switch (sortOrder) {
      case WeightSortOrder.dateAsc:
        weightList.sort((a, b) => a.date.compareTo(b.date));
        break;
      case WeightSortOrder.dateDesc:
        weightList.sort((a, b) => b.date.compareTo(a.date));
        break;
      case WeightSortOrder.weightAsc:
        weightList.sort((a, b) => a.weight.compareTo(b.weight));
        break;
      case WeightSortOrder.weightDesc:
        weightList.sort((a, b) => b.weight.compareTo(a.weight));
        break;
    }

    return weightList;
  }

  Weight? get latestWeight {
    if (currentWeights.isEmpty) return null;

    return currentWeights.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  double? get averageWeight {
    if (currentWeights.isEmpty) return null;

    final total = currentWeights.fold<double>(
      0,
      (total, weight) => total + weight.weight,
    );
    return total / currentWeights.length;
  }

  WeightTrend? get overallTrend {
    if (currentWeights.length < 2) return null;

    final sortedByDate = List<Weight>.from(currentWeights)
      ..sort((a, b) => a.date.compareTo(b.date));

    final first = sortedByDate.first;
    final last = sortedByDate.last;

    return last.calculateDifference(first)?.trend;
  }

  List<Weight> get recentWeights {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return currentWeights.where((w) => w.date.isAfter(thirtyDaysAgo)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int get totalRecords => currentWeights.length;
}

// ============================================================================
// LEGACY NOTIFIER (Maintained for backward compatibility)
// ============================================================================

// NOTE: The old WeightsNotifier has been split into specialized notifiers:
// - WeightsCrudNotifier: Handles ADD, UPDATE, DELETE operations
// - WeightsQueryNotifier: Handles READ, LIST, SEARCH operations
// - WeightsSortNotifier: Handles SORTING operations
// - WeightsFilterNotifier: Handles FILTERING operations
//
// This provides better SRP (Single Responsibility Principle) compliance.
// The monolithic WeightsNotifier class has been DEPRECATED but is kept here
// as a legacy fallback for backward compatibility during the migration phase.

@riverpod
class WeightsNotifier extends _$WeightsNotifier {
  late final GetWeights _getWeights;
  late final GetWeightsByAnimalId _getWeightsByAnimalId;
  late final GetWeightStatistics _getWeightStatistics;
  late final AddWeight _addWeight;
  late final UpdateWeight _updateWeight;

  @override
  WeightsState build() {
    _getWeights = ref.watch(getWeightsProvider);
    _getWeightsByAnimalId = ref.watch(getWeightsByAnimalIdProvider);
    _getWeightStatistics = ref.watch(getWeightStatisticsProvider);
    _addWeight = ref.watch(addWeightProvider);
    _updateWeight = ref.watch(updateWeightProvider);
    return const WeightsState();
  }

  Future<void> loadWeights() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWeights(const local.NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (weights) => state = state.copyWith(
        weights: weights,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> loadWeightsByAnimal(String animalId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedAnimalId: animalId,
    );

    final result = await _getWeightsByAnimalId(animalId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (weights) {
        final updatedWeightsByAnimal = Map<String, List<Weight>>.from(
          state.weightsByAnimal,
        );
        updatedWeightsByAnimal[animalId] = weights;

        state = state.copyWith(
          weightsByAnimal: updatedWeightsByAnimal,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> loadStatistics(String animalId) async {
    final result = await _getWeightStatistics(animalId);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (statistics) =>
          state = state.copyWith(statistics: statistics, error: null),
    );
  }

  Future<void> addWeight(Weight weight) async {
    final result = await _addWeight(weight);

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      final updatedWeights = [weight, ...state.weights];
      final updatedWeightsByAnimal = Map<String, List<Weight>>.from(
        state.weightsByAnimal,
      );
      if (updatedWeightsByAnimal.containsKey(weight.animalId)) {
        final animalWeights = List<Weight>.from(
          updatedWeightsByAnimal[weight.animalId]!,
        );
        animalWeights.insert(0, weight);
        updatedWeightsByAnimal[weight.animalId] = animalWeights;
      }

      state = state.copyWith(
        weights: updatedWeights,
        weightsByAnimal: updatedWeightsByAnimal,
        error: null,
      );
    });
  }

  Future<void> updateWeight(Weight weight) async {
    final result = await _updateWeight(weight);

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      final updatedWeights = state.weights.map((w) {
        return w.id == weight.id ? weight : w;
      }).toList();
      final updatedWeightsByAnimal = Map<String, List<Weight>>.from(
        state.weightsByAnimal,
      );
      if (updatedWeightsByAnimal.containsKey(weight.animalId)) {
        final animalWeights = updatedWeightsByAnimal[weight.animalId]!.map((w) {
          return w.id == weight.id ? weight : w;
        }).toList();
        updatedWeightsByAnimal[weight.animalId] = animalWeights;
      }

      state = state.copyWith(
        weights: updatedWeights,
        weightsByAnimal: updatedWeightsByAnimal,
        error: null,
      );
    });
  }

  Future<void> deleteWeight(String id) async {
    final weightToDelete = state.weights.firstWhere(
      (w) => w.id == id,
      orElse: () => state.currentWeights.firstWhere((w) => w.id == id),
    );
    final updatedWeights = state.weights.where((w) => w.id != id).toList();
    final updatedWeightsByAnimal = Map<String, List<Weight>>.from(
      state.weightsByAnimal,
    );
    if (updatedWeightsByAnimal.containsKey(weightToDelete.animalId)) {
      final animalWeights = updatedWeightsByAnimal[weightToDelete.animalId]!
          .where((w) => w.id != id)
          .toList();
      updatedWeightsByAnimal[weightToDelete.animalId] = animalWeights;
    }

    state = state.copyWith(
      weights: updatedWeights,
      weightsByAnimal: updatedWeightsByAnimal,
      error: null,
    );
  }

  void setSelectedAnimal(String? animalId) {
    state = state.copyWith(selectedAnimalId: animalId);
  }

  void setSortOrder(WeightSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedAnimal() {
    state = state.copyWith(selectedAnimalId: null);
  }

  List<Weight> getWeightHistory(String animalId, {int? limit}) {
    final weights = state.weightsByAnimal[animalId] ?? [];
    final sorted = List<Weight>.from(weights)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit > 0) {
      return sorted.take(limit).toList();
    }

    return sorted;
  }

  WeightDifference? getWeightProgress(String animalId) {
    final weights = getWeightHistory(animalId, limit: 2);
    if (weights.length < 2) return null;

    return weights.first.calculateDifference(weights[1]);
  }

  List<Weight> getRecentWeights(String animalId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final weights = state.weightsByAnimal[animalId] ?? [];

    return weights.where((w) => w.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

// NOTE: The old WeightsNotifier has been split into specialized notifiers:
// - WeightsCrudNotifier: Handles ADD, UPDATE, DELETE operations
// - WeightsQueryNotifier: Handles READ, LIST, SEARCH operations
// - WeightsSortNotifier: Handles SORTING operations
// - WeightsFilterNotifier: Handles FILTERING operations
//
// This provides better SRP (Single Responsibility Principle) compliance.
// The monolithic WeightsNotifier class has been DEPRECATED but is kept here
// as a legacy fallback for backward compatibility during the migration phase.
// ============================================================================
// NEW SPECIALIZED PROVIDERS (Phase 1 SOLID Refactoring)
// ============================================================================

/// Provider for CRUD operations (Add, Update, Delete)
/// Single Responsibility: Weight creation, modification, and deletion
/// NOTE: Use weightsCrudNotifierProvider from weights_crud_notifier.dart instead
@riverpod
class WeightsCrud extends _$WeightsCrud {
  @override
  WeightsCrudState build() {
    // Initialize with use cases
    return const WeightsCrudState();
  }
  
  Future<void> addWeight(Weight weight) async {
    final addWeightUseCase = ref.read(addWeightProvider);
    state = state.copyWith(isLoading: true, error: null);
    final result = await addWeightUseCase(weight);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, error: null),
    );
  }
  
  Future<void> updateWeight(Weight weight) async {
    final updateWeightUseCase = ref.read(updateWeightProvider);
    state = state.copyWith(isLoading: true, error: null);
    final result = await updateWeightUseCase(weight);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, error: null),
    );
  }
}

/// Provider for READ and QUERY operations (Fetch, List, Search)
/// Single Responsibility: Weight retrieval and loading
@riverpod
class WeightsQuery extends _$WeightsQuery {
  @override
  WeightsQueryState build() {
    return const WeightsQueryState();
  }
  
  Future<void> getWeights() async {
    final getWeightsUseCase = ref.read(getWeightsProvider);
    state = state.copyWith(isLoading: true, error: null);
    final result = await getWeightsUseCase(const local.NoParams());
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (weights) => state = state.copyWith(isLoading: false, weights: weights),
    );
  }
  
  Future<void> getWeightsByAnimalId(String animalId) async {
    final getWeightsByAnimalIdUseCase = ref.read(getWeightsByAnimalIdProvider);
    state = state.copyWith(isLoading: true, error: null);
    final result = await getWeightsByAnimalIdUseCase(animalId);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (weights) {
        final newMap = Map<String, List<Weight>>.from(state.weightsByAnimal);
        newMap[animalId] = weights;
        state = state.copyWith(isLoading: false, weightsByAnimal: newMap);
      },
    );
  }
}

/// Provider for SORTING operations
/// Single Responsibility: Weight list sorting
@riverpod
class WeightsSort extends _$WeightsSort {
  @override
  WeightsSortState build() {
    return const WeightsSortState();
  }
  
  void setSortOrder(WeightSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }
  
  List<Weight> sortWeights(List<Weight> weights) {
    final sorted = List<Weight>.from(weights);
    switch (state.sortOrder) {
      case WeightSortOrder.dateAsc:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case WeightSortOrder.dateDesc:
        sorted.sort((a, b) => b.date.compareTo(a.date));
      case WeightSortOrder.weightAsc:
        sorted.sort((a, b) => a.weight.compareTo(b.weight));
      case WeightSortOrder.weightDesc:
        sorted.sort((a, b) => b.weight.compareTo(a.weight));
    }
    return sorted;
  }
}

/// Provider for FILTERING operations
/// Single Responsibility: Weight filtering by animal and criteria
@riverpod
class WeightsFilter extends _$WeightsFilter {
  @override
  WeightsFilterState build() {
    return const WeightsFilterState();
  }
}

/// Composed provider for sorted and filtered weights
/// Combines sort and filter operations for UI consumption
@riverpod
List<Weight> sortedAndFilteredWeights(Ref ref) {
  final queryState = ref.watch(weightsQueryProvider);
  final filterState = ref.watch(weightsFilterProvider);
  final sortNotifier = ref.watch(weightsSortProvider.notifier);

  final filtered = filterState.selectedAnimalId != null
      ? queryState.weightsByAnimal[filterState.selectedAnimalId] ?? []
      : queryState.weights;

  return sortNotifier.sortWeights(filtered);
}

// ============================================================================
// LEGACY PROVIDERS (Maintained for backward compatibility)
// ============================================================================

// NOTE: These legacy providers are kept for backward compatibility during migration.
// New code should use the specialized providers above instead.

// Provider generated by @riverpod
@riverpod
Future<List<Weight>> weightsByAnimal(Ref ref, String animalId) async {
  final notifier = ref.read(weightsProvider.notifier);
  await notifier.loadWeightsByAnimal(animalId);
  return ref.read(weightsProvider).weightsByAnimal[animalId] ?? [];
}

@riverpod
Future<WeightStatistics> weightStatistics(Ref ref, String animalId) async {
  final useCase = ref.watch(getWeightStatisticsProvider);
  final result = await useCase(animalId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (statistics) => statistics,
  );
}

@riverpod
Stream<List<Weight>> weightsStream(Ref ref, String? animalId) {
  final repository = ref.watch(weightRepositoryProvider);
  if (animalId != null) {
    return repository.watchWeightsByAnimalId(animalId);
  }
  return repository.watchWeights();
}

@riverpod
WeightSortOrder weightSortOrder(Ref ref) {
  final state = ref.watch(weightsProvider);
  return state.sortOrder;
}

@riverpod
class SelectedAnimalForWeight extends _$SelectedAnimalForWeight {
  @override
  String? build() => null;

  void set(String? animalId) => state = animalId;
  void clear() => state = null;
}

@riverpod
WeightTrend? weightTrend(Ref ref, String animalId) {
  final weights = ref.watch(weightsProvider).weightsByAnimal[animalId] ?? [];

  if (weights.length < 2) return null;

  final sortedByDate = List<Weight>.from(weights)
    ..sort((a, b) => a.date.compareTo(b.date));

  final first = sortedByDate.first;
  final last = sortedByDate.last;

  return last.calculateDifference(first)?.trend;
}

@riverpod
Weight? latestWeight(Ref ref, String animalId) {
  final weights = ref.watch(weightsProvider).weightsByAnimal[animalId] ?? [];

  if (weights.isEmpty) return null;

  return weights.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
}
