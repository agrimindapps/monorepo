import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/concrete_calculation.dart';
import '../../domain/usecases/calculate_concrete_usecase.dart';

part 'concrete_calculator_provider.g.dart';

/// Provider for CalculateConcreteUseCase
@riverpod
CalculateConcreteUseCase calculateConcreteUseCase(Ref ref) {
  return const CalculateConcreteUseCase();
}

/// State notifier for concrete calculator
@riverpod
class ConcreteCalculator extends _$ConcreteCalculator {
  @override
  ConcreteCalculation build() {
    return ConcreteCalculation.empty();
  }

  /// Calculate concrete volume and materials
  Future<void> calculate({
    required double length,
    required double width,
    required double height,
    String concreteType = 'Estrutural',
    String concreteStrength = '25 MPa',
  }) async {
    final useCase = ref.read(calculateConcreteUseCaseProvider);

    final params = CalculateConcreteParams(
      length: length,
      width: width,
      height: height,
      concreteType: concreteType,
      concreteStrength: concreteStrength,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = ConcreteCalculation.empty();
  }
}
