import 'package:core/core.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/construction_calculator_repository.dart';
import '../datasources/construction_local_datasource.dart';

/// Implementation of ConstructionCalculatorRepository
///
/// Follows Interface Segregation Principle (ISP):
/// - Implements only necessary methods
/// - Uses datasource for data operations
class ConstructionCalculatorRepositoryImpl
    implements ConstructionCalculatorRepository {
  final ConstructionLocalDataSource localDataSource;

  ConstructionCalculatorRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, MaterialsQuantityCalculation>>
      calculateMaterialsQuantity({
    required double area,
    required String buildingType,
  }) async {
    try {
      final calculation = await localDataSource.calculateMaterialsQuantity(
        area: area,
        buildingType: buildingType,
      );
      return Right(calculation);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Erro ao calcular quantidades de materiais: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CostPerSquareMeterCalculation>> calculateCostPerSqm({
    required double area,
    required double costPerSquareMeter,
  }) async {
    try {
      final calculation = await localDataSource.calculateCostPerSqm(
        area: area,
        costPerSquareMeter: costPerSquareMeter,
      );
      return Right(calculation);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Erro ao calcular custo por m²: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, PaintConsumptionCalculation>>
      calculatePaintConsumption({
    required double area,
    required double surfacePreparation,
    required double coats,
  }) async {
    try {
      final calculation = await localDataSource.calculatePaintConsumption(
        area: area,
        surfacePreparation: surfacePreparation,
        coats: coats,
      );
      return Right(calculation);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Erro ao calcular consumo de tinta: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, FlooringCalculation>> calculateFlooring({
    required double area,
    required double tileWidth,
    required double tileLength,
    double? pricePerTile,
    double wastePercentage = 10.0,
  }) async {
    try {
      final calculation = await localDataSource.calculateFlooring(
        area: area,
        tileWidth: tileWidth,
        tileLength: tileLength,
        pricePerTile: pricePerTile,
        wastePercentage: wastePercentage,
      );
      return Right(calculation);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Erro ao calcular piso/revestimento: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ConcreteCalculation>> calculateConcrete({
    required double length,
    required double width,
    required double height,
    required String concreteType,
    double? cementPricePerBag,
    double? sandPricePerCubicMeter,
    double? gravelPricePerCubicMeter,
  }) async {
    try {
      final calculation = await localDataSource.calculateConcrete(
        length: length,
        width: width,
        height: height,
        concreteType: concreteType,
        cementPricePerBag: cementPricePerBag,
        sandPricePerCubicMeter: sandPricePerCubicMeter,
        gravelPricePerCubicMeter: gravelPricePerCubicMeter,
      );
      return Right(calculation);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Erro ao calcular concreto: $e'),
      );
    }
  }
}
