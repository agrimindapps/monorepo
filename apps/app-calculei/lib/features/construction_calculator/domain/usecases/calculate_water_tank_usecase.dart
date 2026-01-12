import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../entities/water_tank_calculation.dart';

/// Parameters for water tank calculation
class CalculateWaterTankParams {
  final int numberOfPeople;
  final double dailyConsumption;
  final int reserveDays;
  final String tankType;

  const CalculateWaterTankParams({
    required this.numberOfPeople,
    this.dailyConsumption = 150.0,
    this.reserveDays = 2,
    this.tankType = 'Polietileno',
  });
}

/// Use case for calculating water tank capacity
///
/// Handles all business logic for water tank calculation including:
/// - Input validation
/// - Capacity calculation based on consumption patterns
/// - Recommendation of standard tank sizes
class CalculateWaterTankUseCase {
  const CalculateWaterTankUseCase();

  // Standard tank sizes available in the market (in liters)
  static const List<int> standardTankSizes = [
    250,
    310,
    500,
    750,
    1000,
    1500,
    2000,
    2500,
    3000,
    5000,
    10000,
    15000,
    20000,
  ];

  Future<Either<Failure, WaterTankCalculation>> call(
    CalculateWaterTankParams params,
  ) async {
    // 1. VALIDATION
    final validationError = _validate(params);
    if (validationError != null) {
      return Left(validationError);
    }

    try {
      // 2. CALCULATION
      final calculation = _performCalculation(params);

      return Right(calculation);
    } catch (e) {
      return Left(ValidationFailure('Erro no cálculo: $e'));
    }
  }

  /// Validate input parameters
  ValidationFailure? _validate(CalculateWaterTankParams params) {
    if (params.numberOfPeople <= 0) {
      return const ValidationFailure(
        'Número de pessoas deve ser maior que zero',
      );
    }

    if (params.numberOfPeople > 1000) {
      return const ValidationFailure(
        'Número de pessoas não pode ser maior que 1000',
      );
    }

    if (params.dailyConsumption <= 0) {
      return const ValidationFailure(
        'Consumo diário deve ser maior que zero',
      );
    }

    if (params.dailyConsumption > 500) {
      return const ValidationFailure(
        'Consumo diário não pode ser maior que 500 litros por pessoa',
      );
    }

    if (params.reserveDays <= 0) {
      return const ValidationFailure(
        'Dias de reserva deve ser maior que zero',
      );
    }

    if (params.reserveDays > 10) {
      return const ValidationFailure(
        'Dias de reserva não pode ser maior que 10 dias',
      );
    }

    return null;
  }

  /// Perform the actual water tank calculation
  WaterTankCalculation _performCalculation(CalculateWaterTankParams params) {
    // Calculate total capacity needed
    // Formula: numberOfPeople × dailyConsumption × reserveDays
    final totalCapacity = params.numberOfPeople *
        params.dailyConsumption *
        params.reserveDays;

    // Find the recommended tank size (next standard size above needed capacity)
    final recommendedTankSize = _findRecommendedTankSize(totalCapacity);

    return WaterTankCalculation(
      id: const Uuid().v4(),
      numberOfPeople: params.numberOfPeople,
      dailyConsumption: params.dailyConsumption,
      reserveDays: params.reserveDays,
      totalCapacity: totalCapacity,
      recommendedTankSize: recommendedTankSize,
      tankType: params.tankType,
      calculatedAt: DateTime.now(),
    );
  }

  /// Find the recommended tank size from standard sizes
  /// Returns the next available size equal to or greater than needed capacity
  int _findRecommendedTankSize(double neededCapacity) {
    // Find the first tank size that is >= needed capacity
    for (final size in standardTankSizes) {
      if (size >= neededCapacity) {
        return size;
      }
    }

    // If needed capacity exceeds all standard sizes,
    // return the largest available size
    return standardTankSizes.last;
  }
}
