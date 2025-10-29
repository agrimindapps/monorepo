import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

/// State for concrete calculator
class ConcreteCalculatorState extends Equatable {
  const ConcreteCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  final ConcreteCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  ConcreteCalculatorState copyWith({
    ConcreteCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConcreteCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [calculation, isLoading, errorMessage];
}

/// Notifier for concrete calculator
class ConcreteCalculatorNotifier
    extends StateNotifier<ConcreteCalculatorState> {
  final CalculateConcreteUseCase _calculateConcreteUseCase;

  ConcreteCalculatorNotifier({
    required CalculateConcreteUseCase calculateConcreteUseCase,
  })  : _calculateConcreteUseCase = calculateConcreteUseCase,
        super(const ConcreteCalculatorState());

  Future<void> calculate(CalculateConcreteParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _calculateConcreteUseCase(params);

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
    state = const ConcreteCalculatorState();
  }
}

/// Provider for concrete calculator state
final concreteCalculatorNotifierProvider =
    StateNotifierProvider<ConcreteCalculatorNotifier, ConcreteCalculatorState>(
  (ref) {
    final useCase = ref.watch(calculateConcreteUseCaseProvider);
    return ConcreteCalculatorNotifier(
      calculateConcreteUseCase: useCase,
    );
  },
);
