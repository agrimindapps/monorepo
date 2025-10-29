import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import '../../domain/usecases/calculate_cost_per_sqm_usecase.dart';
import 'construction_calculator_providers.dart';

/// State for cost per square meter calculator
class CostPerSqmCalculatorState extends Equatable {
  const CostPerSqmCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  final CostPerSquareMeterCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  CostPerSqmCalculatorState copyWith({
    CostPerSquareMeterCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CostPerSqmCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [calculation, isLoading, errorMessage];
}

/// Notifier for cost per square meter calculator
class CostPerSqmCalculatorNotifier
    extends StateNotifier<CostPerSqmCalculatorState> {
  final CalculateCostPerSqmUseCase _calculateCostPerSqmUseCase;

  CostPerSqmCalculatorNotifier({
    required CalculateCostPerSqmUseCase calculateCostPerSqmUseCase,
  })  : _calculateCostPerSqmUseCase = calculateCostPerSqmUseCase,
        super(const CostPerSqmCalculatorState());

  Future<void> calculate(CalculateCostPerSqmParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _calculateCostPerSqmUseCase(params);

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
    state = const CostPerSqmCalculatorState();
  }
}

/// Provider for cost per square meter calculator
final costPerSqmCalculatorNotifierProvider = StateNotifierProvider<
    CostPerSqmCalculatorNotifier, CostPerSqmCalculatorState>(
  (ref) {
    final calculateCostPerSqmUseCase =
        ref.watch(calculateCostPerSqmUseCaseProvider);
    return CostPerSqmCalculatorNotifier(
      calculateCostPerSqmUseCase: calculateCostPerSqmUseCase,
    );
  },
);

/// Provider for calculate cost per sqm use case
final calculateCostPerSqmUseCaseProvider = Provider<CalculateCostPerSqmUseCase>(
  (ref) {
    final repository = ref.watch(constructionCalculatorRepositoryProvider);
    return CalculateCostPerSqmUseCase(repository: repository);
  },
);
