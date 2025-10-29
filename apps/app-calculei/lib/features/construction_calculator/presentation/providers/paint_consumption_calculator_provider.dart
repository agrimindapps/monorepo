import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

/// State for paint consumption calculator
class PaintConsumptionCalculatorState extends Equatable {
  const PaintConsumptionCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  final PaintConsumptionCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

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

  @override
  List<Object?> get props => [calculation, isLoading, errorMessage];
}

/// Notifier for paint consumption calculator
class PaintConsumptionCalculatorNotifier
    extends StateNotifier<PaintConsumptionCalculatorState> {
  final CalculatePaintConsumptionUseCase _calculatePaintConsumptionUseCase;

  PaintConsumptionCalculatorNotifier({
    required CalculatePaintConsumptionUseCase calculatePaintConsumptionUseCase,
  })  : _calculatePaintConsumptionUseCase = calculatePaintConsumptionUseCase,
        super(const PaintConsumptionCalculatorState());

  Future<void> calculate(CalculatePaintConsumptionParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _calculatePaintConsumptionUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (calculation) {
        state = state.copyWith(
          isLoading: false,
          calculation: calculation,
        );
      },
    );
  }

  void clearCalculation() {
    state = const PaintConsumptionCalculatorState();
  }
}

/// Provider for paint consumption calculator
final paintConsumptionCalculatorNotifierProvider = StateNotifierProvider<
    PaintConsumptionCalculatorNotifier, PaintConsumptionCalculatorState>(
  (ref) {
    final calculatePaintConsumptionUseCase =
        ref.watch(calculatePaintConsumptionUseCaseProvider);
    return PaintConsumptionCalculatorNotifier(
      calculatePaintConsumptionUseCase: calculatePaintConsumptionUseCase,
    );
  },
);

/// Provider for calculate paint consumption use case
final calculatePaintConsumptionUseCaseProvider =
    Provider<CalculatePaintConsumptionUseCase>(
  (ref) {
    final repository = ref.watch(constructionCalculatorRepositoryProvider);
    return CalculatePaintConsumptionUseCase(repository: repository);
  },
);
