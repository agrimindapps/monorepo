import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart' as local;
import '../../domain/entities/weight.dart';
import '../../domain/repositories/weight_repository.dart';
import 'weight_providers.dart';

part 'weights_notifiers.g.dart';

// ============================================================================
// WEIGHTS STATE
// ============================================================================

class WeightsState {
  final List<Weight> weights;
  final Map<String, List<Weight>> weightsByAnimal;
  final bool isLoading;
  final String? error;
  final String? selectedAnimalId;

  const WeightsState({
    this.weights = const [],
    this.weightsByAnimal = const {},
    this.isLoading = false,
    this.error,
    this.selectedAnimalId,
  });

  WeightsState copyWith({
    List<Weight>? weights,
    Map<String, List<Weight>>? weightsByAnimal,
    bool? isLoading,
    String? error,
    String? selectedAnimalId,
  }) {
    return WeightsState(
      weights: weights ?? this.weights,
      weightsByAnimal: weightsByAnimal ?? this.weightsByAnimal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAnimalId: selectedAnimalId ?? this.selectedAnimalId,
    );
  }

  List<Weight> get currentWeights {
    if (selectedAnimalId != null) {
      return weightsByAnimal[selectedAnimalId] ?? [];
    }
    return weights;
  }
}

// ============================================================================
// WEIGHTS NOTIFIER
// ============================================================================

@riverpod
class WeightsNotifier extends _$WeightsNotifier {
  @override
  WeightsState build() {
    return const WeightsState();
  }

  /// Carregar todos os pesos
  Future<void> loadWeights() async {
    state = state.copyWith(isLoading: true, error: null);

    final getWeights = ref.read(getWeightsProvider);
    final result = await getWeights(const local.NoParams());

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

  /// Carregar pesos de um animal específico
  Future<void> loadWeightsByAnimal(String animalId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedAnimalId: animalId,
    );

    final getWeightsByAnimalId = ref.read(getWeightsByAnimalIdProvider);
    final result = await getWeightsByAnimalId(animalId);

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

  /// Adicionar peso
  Future<void> addWeight(Weight weight) async {
    final addWeight = ref.read(addWeightProvider);
    final result = await addWeight(weight);

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

  /// Atualizar peso
  Future<void> updateWeight(Weight weight) async {
    final updateWeight = ref.read(updateWeightProvider);
    final result = await updateWeight(weight);

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

  /// Deletar peso
  Future<void> deleteWeight(String id) async {
    final deleteWeight = ref.read(deleteWeightProvider);
    final result = await deleteWeight(id);

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      final weightToDelete = state.currentWeights.firstWhere((w) => w.id == id);
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
    });
  }

  void setSelectedAnimal(String? animalId) {
    state = state.copyWith(selectedAnimalId: animalId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedAnimal() {
    state = state.copyWith(selectedAnimalId: null);
  }
}

// ============================================================================
// STREAM PROVIDERS
// ============================================================================

@riverpod
Stream<List<Weight>> weightsStream(WeightsStreamRef ref, String? animalId) {
  final repository = ref.watch(weightRepositoryProvider);
  if (animalId != null) {
    return repository.watchWeightsByAnimalId(animalId);
  }
  return repository.watchWeights();
}

@riverpod
Future<WeightStatistics> weightStatistics(
  WeightStatisticsRef ref,
  String animalId,
) async {
  final getWeightStatistics = ref.watch(getWeightStatisticsProvider);
  final result = await getWeightStatistics(animalId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (statistics) => statistics,
  );
}
