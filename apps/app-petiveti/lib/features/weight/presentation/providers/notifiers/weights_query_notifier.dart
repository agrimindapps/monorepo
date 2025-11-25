import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/interfaces/usecase.dart' as local;

import '../../../domain/entities/weight.dart';

import '../../../domain/usecases/get_weights.dart';

import '../../../domain/usecases/get_weights_by_animal_id.dart';

import '../../states/weights_query_state.dart';

part 'weights_query_notifier.g.dart';


/// Notifier specialized for READ and LIST operations (Query, Search, Fetch)
/// Single Responsibility: Handles weight retrieval and loading
/// 
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class WeightsQueryNotifier extends _$WeightsQueryNotifier {
  late final GetWeights _getWeights;
  late final GetWeightsByAnimalId _getWeightsByAnimalId;

  @override
  WeightsQueryState build() {
    return const WeightsQueryState();
  }

  void setUseCases(GetWeights getWeights, GetWeightsByAnimalId getWeightsByAnimalId) {
    _getWeights = getWeights;
    _getWeightsByAnimalId = getWeightsByAnimalId;
  }

  /// Loads all weights globally
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

  /// Loads weights for a specific animal
  Future<void> loadWeightsByAnimal(String animalId) async {
    state = state.copyWith(isLoading: true, error: null);

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

  /// Gets weight history for a specific animal
  List<Weight> getWeightHistory(String animalId, {int? limit}) {
    final weights = state.weightsByAnimal[animalId] ?? [];
    final sorted = List<Weight>.from(weights)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && limit > 0) {
      return sorted.take(limit).toList();
    }

    return sorted;
  }

  /// Gets recent weights for a specific animal (default 30 days)
  List<Weight> getRecentWeights(String animalId, {int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final weights = state.weightsByAnimal[animalId] ?? [];

    return weights.where((w) => w.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
