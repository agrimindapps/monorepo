import 'package:core/core.dart';
import '../entities/index.dart';
import '../repositories/construction_calculator_repository.dart';

/// Parameters for cost per square meter calculation
class CalculateCostPerSqmParams {
  final double area;
  final double costPerSquareMeter;

  CalculateCostPerSqmParams({
    required this.area,
    required this.costPerSquareMeter,
  });
}

/// Use case for calculating cost per square meter
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for executing cost per sqm calculation
/// - Delegates data persistence to repository
class CalculateCostPerSqmUseCase
    extends UseCase<CostPerSquareMeterCalculation, CalculateCostPerSqmParams> {
  final ConstructionCalculatorRepository repository;

  CalculateCostPerSqmUseCase({required this.repository});

  @override
  Future<Either<Failure, CostPerSquareMeterCalculation>> call(
    CalculateCostPerSqmParams params,
  ) async {
    return await repository.calculateCostPerSqm(
      area: params.area,
      costPerSquareMeter: params.costPerSquareMeter,
    );
  }
}
