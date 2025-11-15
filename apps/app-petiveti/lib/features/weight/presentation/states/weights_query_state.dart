import '../../domain/entities/weight.dart';

class WeightsQueryState {
  final List<Weight> weights;
  final Map<String, List<Weight>> weightsByAnimal;
  final bool isLoading;
  final String? error;

  const WeightsQueryState({
    this.weights = const [],
    this.weightsByAnimal = const {},
    this.isLoading = false,
    this.error,
  });

  WeightsQueryState copyWith({
    List<Weight>? weights,
    Map<String, List<Weight>>? weightsByAnimal,
    bool? isLoading,
    String? error,
  }) {
    return WeightsQueryState(
      weights: weights ?? this.weights,
      weightsByAnimal: weightsByAnimal ?? this.weightsByAnimal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
