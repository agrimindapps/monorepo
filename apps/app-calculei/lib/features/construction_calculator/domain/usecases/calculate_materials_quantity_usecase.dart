import 'package:core/core.dart';
import '../entities/index.dart';
import '../repositories/construction_calculator_repository.dart';

/// Parameters for material quantity calculation
class CalculateMaterialsQuantityParams {
  final double area;
  final String buildingType; // 'alvenaria', 'concreto', etc

  CalculateMaterialsQuantityParams({
    required this.area,
    required this.buildingType,
  });
}

/// Use case for calculating material quantities
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for executing material quantity calculation
/// - Delegates data persistence to repository
class CalculateMaterialsQuantityUseCase extends UseCase<
    MaterialsQuantityCalculation, CalculateMaterialsQuantityParams> {
  final ConstructionCalculatorRepository repository;

  CalculateMaterialsQuantityUseCase({required this.repository});

  @override
  Future<Either<Failure, MaterialsQuantityCalculation>> call(
    CalculateMaterialsQuantityParams params,
  ) async {
    return repository.calculateMaterialsQuantity(
      area: params.area,
      buildingType: params.buildingType,
    );
  }
}
