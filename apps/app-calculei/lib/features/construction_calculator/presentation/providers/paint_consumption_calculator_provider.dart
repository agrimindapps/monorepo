import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'paint_consumption_calculator_provider.g.dart';

/// State for paint consumption calculator
class PaintConsumptionCalculatorState {
  final PaintConsumptionCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  const PaintConsumptionCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  PaintConsumptionCalculatorState copyWith({
    PaintConsumptionCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PaintConsumptionCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for calculate paint consumption use case
@riverpod
CalculatePaintConsumptionUseCase calculatePaintConsumptionUseCase(
  Ref ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculatePaintConsumptionUseCase(repository: repository);
}

/// State notifier for paint consumption calculator
@riverpod
class PaintConsumptionCalculator extends _$PaintConsumptionCalculator {
  @override
  PaintConsumptionCalculatorState build() {
    return const PaintConsumptionCalculatorState(); // Initial empty state
  }

  /// Calculate paint consumption
  Future<void> calculate(CalculatePaintConsumptionParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculatePaintConsumptionUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (calculation) {
        state = state.copyWith(
          isLoading: false,
          calculation: calculation,
          errorMessage: null,
        );
      },
    );
  }

  /// Clear calculation
  void clearCalculation() {
    state = const PaintConsumptionCalculatorState();
  }
}
