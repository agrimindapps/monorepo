import 'package:core/core.dart';
import '../entities/index.dart';
import '../repositories/construction_calculator_repository.dart';

/// Parameters for paint consumption calculation
class CalculatePaintConsumptionParams {
  final double area;
  final double surfacePreparation; // 0-3 (roughness factor)
  final double coats;

  CalculatePaintConsumptionParams({
    required this.area,
    required this.surfacePreparation,
    required this.coats,
  });
}

/// Use case for calculating paint consumption
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for executing paint consumption calculation
/// - Delegates data persistence to repository
class CalculatePaintConsumptionUseCase extends UseCase<
    PaintConsumptionCalculation, CalculatePaintConsumptionParams> {
  final ConstructionCalculatorRepository repository;

  CalculatePaintConsumptionUseCase({required this.repository});

  @override
  Future<Either<Failure, PaintConsumptionCalculation>> call(
    CalculatePaintConsumptionParams params,
  ) async {
    return repository.calculatePaintConsumption(
      area: params.area,
      surfacePreparation: params.surfacePreparation,
      coats: params.coats,
    );
  }
}
