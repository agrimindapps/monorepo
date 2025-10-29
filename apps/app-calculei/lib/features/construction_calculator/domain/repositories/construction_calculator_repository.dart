import 'package:core/core.dart';
import '../entities/index.dart';

/// Abstract repository for construction calculations
///
/// Follows Dependency Inversion Principle (DIP):
/// - High-level modules depend on abstractions
/// - Low-level modules implement abstractions
abstract class ConstructionCalculatorRepository {
  /// Calculate material quantities for construction
  Future<Either<Failure, MaterialsQuantityCalculation>>
      calculateMaterialsQuantity({
    required double area,
    required String buildingType,
  });

  /// Calculate cost per square meter
  Future<Either<Failure, CostPerSquareMeterCalculation>> calculateCostPerSqm({
    required double area,
    required double costPerSquareMeter,
  });

  /// Calculate paint consumption
  Future<Either<Failure, PaintConsumptionCalculation>>
      calculatePaintConsumption({
    required double area,
    required double surfacePreparation,
    required double coats,
  });

  /// Calculate flooring materials
  Future<Either<Failure, FlooringCalculation>> calculateFlooring({
    required double area,
    required double tileWidth,
    required double tileLength,
    double? pricePerTile,
    double wastePercentage = 10.0,
  });

  /// Calculate concrete materials
  Future<Either<Failure, ConcreteCalculation>> calculateConcrete({
    required double length,
    required double width,
    required double height,
    required String concreteType,
    double? cementPricePerBag,
    double? sandPricePerCubicMeter,
    double? gravelPricePerCubicMeter,
  });
}
