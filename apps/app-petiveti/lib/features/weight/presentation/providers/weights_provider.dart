import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../domain/entities/weight.dart';
import '../../domain/repositories/weight_repository.dart';
import '../../domain/usecases/add_weight.dart';
import '../../domain/usecases/get_weight_statistics.dart';
import '../../domain/usecases/get_weights.dart';
import '../../domain/usecases/get_weights_by_animal_id.dart';
import '../../domain/usecases/update_weight.dart';

// State classes
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
    
    return currentWeights.reduce((a, b) => 
        a.date.isAfter(b.date) ? a : b);
  }

  double? get averageWeight {
    if (currentWeights.isEmpty) return null;
    
    final total = currentWeights.fold<double>(
      0, (sum, weight) => sum + weight.weight);
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

enum WeightSortOrder {
  dateAsc,
  dateDesc,
  weightAsc,
  weightDesc,
}

extension WeightSortOrderExtension on WeightSortOrder {
  String get displayName {
    switch (this) {
      case WeightSortOrder.dateAsc:
        return 'Data (Antiga → Recente)';
      case WeightSortOrder.dateDesc:
        return 'Data (Recente → Antiga)';
      case WeightSortOrder.weightAsc:
        return 'Peso (Menor → Maior)';
      case WeightSortOrder.weightDesc:
        return 'Peso (Maior → Menor)';
    }
  }

  IconData get icon {
    switch (this) {
      case WeightSortOrder.dateAsc:
        return Icons.arrow_upward;
      case WeightSortOrder.dateDesc:
        return Icons.arrow_downward;
      case WeightSortOrder.weightAsc:
        return Icons.arrow_upward;
      case WeightSortOrder.weightDesc:
        return Icons.arrow_downward;
    }
  }
}

// State notifier
class WeightsNotifier extends StateNotifier<WeightsState> {
  final GetWeights _getWeights;
  final GetWeightsByAnimalId _getWeightsByAnimalId;
  final GetWeightStatistics _getWeightStatistics;
  final AddWeight _addWeight;
  final UpdateWeight _updateWeight;

  WeightsNotifier({
    required GetWeights getWeights,
    required GetWeightsByAnimalId getWeightsByAnimalId,
    required GetWeightStatistics getWeightStatistics,
    required AddWeight addWeight,
    required UpdateWeight updateWeight,
  })  : _getWeights = getWeights,
        _getWeightsByAnimalId = getWeightsByAnimalId,
        _getWeightStatistics = getWeightStatistics,
        _addWeight = addWeight,
        _updateWeight = updateWeight,
        super(const WeightsState());

  Future<void> loadWeights() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWeights(const local.NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (weights) => state = state.copyWith(
        weights: weights,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> loadWeightsByAnimal(String animalId) async {
    state = state.copyWith(isLoading: true, error: null, selectedAnimalId: animalId);

    final result = await _getWeightsByAnimalId(animalId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (weights) {
        final updatedWeightsByAnimal = Map<String, List<Weight>>.from(state.weightsByAnimal);
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
      (statistics) => state = state.copyWith(
        statistics: statistics,
        error: null,
      ),
    );
  }

  Future<void> addWeight(Weight weight) async {
    final result = await _addWeight(weight);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Add weight to the global list
        final updatedWeights = [weight, ...state.weights];
        
        // Add weight to the specific animal's list if available
        final updatedWeightsByAnimal = Map<String, List<Weight>>.from(state.weightsByAnimal);
        if (updatedWeightsByAnimal.containsKey(weight.animalId)) {
          final animalWeights = List<Weight>.from(updatedWeightsByAnimal[weight.animalId]!);
          animalWeights.insert(0, weight);
          updatedWeightsByAnimal[weight.animalId] = animalWeights;
        }
        
        state = state.copyWith(
          weights: updatedWeights,
          weightsByAnimal: updatedWeightsByAnimal,
          error: null,
        );
      },
    );
  }

  Future<void> updateWeight(Weight weight) async {
    final result = await _updateWeight(weight);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update in global list
        final updatedWeights = state.weights.map((w) {
          return w.id == weight.id ? weight : w;
        }).toList();
        
        // Update in animal-specific list
        final updatedWeightsByAnimal = Map<String, List<Weight>>.from(state.weightsByAnimal);
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
      },
    );
  }

  Future<void> deleteWeight(String id) async {
    // Find the weight to get animal ID
    final weightToDelete = state.weights.firstWhere(
      (w) => w.id == id,
      orElse: () => state.currentWeights.firstWhere((w) => w.id == id),
    );

    // Remove from global list
    final updatedWeights = state.weights.where((w) => w.id != id).toList();
    
    // Remove from animal-specific list
    final updatedWeightsByAnimal = Map<String, List<Weight>>.from(state.weightsByAnimal);
    if (updatedWeightsByAnimal.containsKey(weightToDelete.animalId)) {
      final animalWeights = updatedWeightsByAnimal[weightToDelete.animalId]!
          .where((w) => w.id != id).toList();
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
    
    return weights
        .where((w) => w.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

// Providers
final weightsProvider = StateNotifierProvider<WeightsNotifier, WeightsState>((ref) {
  return WeightsNotifier(
    getWeights: di.getIt<GetWeights>(),
    getWeightsByAnimalId: di.getIt<GetWeightsByAnimalId>(),
    getWeightStatistics: di.getIt<GetWeightStatistics>(),
    addWeight: di.getIt<AddWeight>(),
    updateWeight: di.getIt<UpdateWeight>(),
  );
});

// Individual weight provider by animal
final weightsByAnimalProvider = FutureProvider.family<List<Weight>, String>((ref, animalId) async {
  final notifier = ref.read(weightsProvider.notifier);
  await notifier.loadWeightsByAnimal(animalId);
  return ref.read(weightsProvider).weightsByAnimal[animalId] ?? [];
});

// Statistics provider
final weightStatisticsProvider = FutureProvider.family<WeightStatistics, String>((ref, animalId) async {
  final useCase = di.getIt<GetWeightStatistics>();
  final result = await useCase(animalId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (statistics) => statistics,
  );
});

// Stream provider for real-time updates
final weightsStreamProvider = StreamProvider.family<List<Weight>, String?>((ref, animalId) {
  final repository = di.getIt.get<WeightRepository>();
  if (animalId != null) {
    return repository.watchWeightsByAnimalId(animalId);
  }
  return repository.watchWeights();
});

// Sort order provider
final weightSortOrderProvider = Provider<WeightSortOrder>((ref) {
  final state = ref.watch(weightsProvider);
  return state.sortOrder;
});

// Selected animal provider
final selectedAnimalForWeightProvider = StateProvider<String?>((ref) => null);

// Weight trend provider
final weightTrendProvider = Provider.family<WeightTrend?, String>((ref, animalId) {
  final weights = ref.watch(weightsProvider).weightsByAnimal[animalId] ?? [];
  
  if (weights.length < 2) return null;
  
  final sortedByDate = List<Weight>.from(weights)
    ..sort((a, b) => a.date.compareTo(b.date));
  
  final first = sortedByDate.first;
  final last = sortedByDate.last;
  
  return last.calculateDifference(first)?.trend;
});

// Latest weight provider
final latestWeightProvider = Provider.family<Weight?, String>((ref, animalId) {
  final weights = ref.watch(weightsProvider).weightsByAnimal[animalId] ?? [];
  
  if (weights.isEmpty) return null;
  
  return weights.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
});