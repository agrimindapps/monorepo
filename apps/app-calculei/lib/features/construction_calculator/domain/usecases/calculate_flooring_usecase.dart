import 'package:core/core.dart';
import '../entities/index.dart';
import '../repositories/construction_calculator_repository.dart';

/// Parameters for flooring calculation
class CalculateFlooringParams {
  final double area;
  final double tileWidth;
  final double tileLength;
  final double? pricePerTile;
  final double wastePercentage;

  CalculateFlooringParams({
    required this.area,
    required this.tileWidth,
    required this.tileLength,
    this.pricePerTile,
    this.wastePercentage = 10.0,
  });
}

/// Use case for calculating flooring
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for executing flooring calculation
/// - Delegates data persistence to repository
class CalculateFlooringUseCase
    extends UseCase<FlooringCalculation, CalculateFlooringParams> {
  final ConstructionCalculatorRepository repository;

  CalculateFlooringUseCase({required this.repository});

  @override
  Future<Either<Failure, FlooringCalculation>> call(
    CalculateFlooringParams params,
  ) async {
    return repository.calculateFlooring(
      area: params.area,
      tileWidth: params.tileWidth,
      tileLength: params.tileLength,
      pricePerTile: params.pricePerTile,
      wastePercentage: params.wastePercentage,
    );
  }
}
