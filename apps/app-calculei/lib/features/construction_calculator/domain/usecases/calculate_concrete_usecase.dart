import 'package:core/core.dart';
import '../entities/index.dart';
import '../repositories/construction_calculator_repository.dart';

/// Parameters for concrete calculation
class CalculateConcreteParams {
  final double length;
  final double width;
  final double height;
  final String concreteType;
  final double? cementPricePerBag;
  final double? sandPricePerCubicMeter;
  final double? gravelPricePerCubicMeter;

  CalculateConcreteParams({
    required this.length,
    required this.width,
    required this.height,
    required this.concreteType,
    this.cementPricePerBag,
    this.sandPricePerCubicMeter,
    this.gravelPricePerCubicMeter,
  });
}

/// Use case for calculating concrete
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for executing concrete calculation
/// - Delegates data persistence to repository
class CalculateConcreteUseCase
    extends UseCase<ConcreteCalculation, CalculateConcreteParams> {
  final ConstructionCalculatorRepository repository;

  CalculateConcreteUseCase({required this.repository});

  @override
  Future<Either<Failure, ConcreteCalculation>> call(
    CalculateConcreteParams params,
  ) async {
    return repository.calculateConcrete(
      length: params.length,
      width: params.width,
      height: params.height,
      concreteType: params.concreteType,
      cementPricePerBag: params.cementPricePerBag,
      sandPricePerCubicMeter: params.sandPricePerCubicMeter,
      gravelPricePerCubicMeter: params.gravelPricePerCubicMeter,
    );
  }
}
