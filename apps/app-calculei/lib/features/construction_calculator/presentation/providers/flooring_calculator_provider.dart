import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

/// State for flooring calculator
class FlooringCalculatorState extends Equatable {
  const FlooringCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  final FlooringCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  FlooringCalculatorState copyWith({
    FlooringCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FlooringCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [calculation, isLoading, errorMessage];
}

/// Notifier for flooring calculator
class FlooringCalculatorNotifier
    extends StateNotifier<FlooringCalculatorState> {
  final CalculateFlooringUseCase _calculateFlooringUseCase;

  FlooringCalculatorNotifier({
    required CalculateFlooringUseCase calculateFlooringUseCase,
  })  : _calculateFlooringUseCase = calculateFlooringUseCase,
        super(const FlooringCalculatorState());

  Future<void> calculate(CalculateFlooringParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _calculateFlooringUseCase(params);

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
    state = const FlooringCalculatorState();
  }
}

/// Provider for flooring calculator
final flooringCalculatorNotifierProvider =
    StateNotifierProvider<FlooringCalculatorNotifier, FlooringCalculatorState>(
  (ref) {
    final calculateFlooringUseCase =
        ref.watch(calculateFlooringUseCaseProvider);
    return FlooringCalculatorNotifier(
      calculateFlooringUseCase: calculateFlooringUseCase,
    );
  },
);

/// Provider for calculate flooring use case
final calculateFlooringUseCaseProvider = Provider<CalculateFlooringUseCase>(
  (ref) {
    final repository = ref.watch(constructionCalculatorRepositoryProvider);
    return CalculateFlooringUseCase(repository: repository);
  },
);
