import 'package:gasometer_drift/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:core/core.dart';

/// Factory methods for creating fake/test data
class FakeData {
  /// Creates a test FuelRecordEntity with default values
  static FuelRecordEntity fuelRecord({
    String? id,
    String? vehicleId,
    FuelType? fuelType,
    double? liters,
    double? pricePerLiter,
    double? totalPrice,
    double? odometer,
    DateTime? date,
    String? gasStationName,
    bool? fullTank,
    String? notes,
    double? previousOdometer,
    double? distanceTraveled,
    double? consumption,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
    String? userId,
  }) {
    return FuelRecordEntity(
      id: id ?? 'fuel-test-001',
      vehicleId: vehicleId ?? 'vehicle-test-001',
      fuelType: fuelType ?? FuelType.gasoline,
      liters: liters ?? 40.0,
      pricePerLiter: pricePerLiter ?? 5.50,
      totalPrice: totalPrice ?? 220.0,
      odometer: odometer ?? 10000.0,
      date: date ?? DateTime(2024, 1, 15),
      gasStationName: gasStationName,
      fullTank: fullTank ?? true,
      notes: notes,
      previousOdometer: previousOdometer,
      distanceTraveled: distanceTraveled,
      consumption: consumption,
      createdAt: createdAt ?? DateTime(2024, 1, 15),
      updatedAt: updatedAt ?? DateTime(2024, 1, 15),
      isDirty: isDirty ?? false,
      isDeleted: isDeleted ?? false,
      userId: userId ?? 'user-test-001',
      moduleName: 'gasometer',
    );
  }

  /// Creates a list of test fuel records
  static List<FuelRecordEntity> fuelRecords({
    int count = 3,
    String? vehicleId,
  }) {
    return List.generate(
      count,
      (index) => fuelRecord(
        id: 'fuel-test-${index.toString().padLeft(3, '0')}',
        vehicleId: vehicleId ?? 'vehicle-test-001',
        odometer: 10000.0 + (index * 500.0),
        date: DateTime(2024, 1, 1).add(Duration(days: index * 7)),
        liters: 40.0 + (index * 2.0),
        totalPrice: 220.0 + (index * 10.0),
      ),
    );
  }

  /// Creates a test VehicleEntity with default values
  static VehicleEntity vehicle({
    String? id,
    String? name,
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    double? currentOdometer,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
    String? userId,
  }) {
    return VehicleEntity(
      id: id ?? 'vehicle-test-001',
      name: name ?? 'Carro de Teste',
      brand: brand ?? 'Toyota',
      model: model ?? 'Corolla',
      year: year ?? 2020,
      color: 'Preto',
      licensePlate: licensePlate ?? 'ABC-1234',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: currentOdometer ?? 0.0,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
      updatedAt: updatedAt ?? DateTime(2024, 1, 1),
      isDirty: isDirty ?? false,
      isDeleted: isDeleted ?? false,
      userId: userId ?? 'user-test-001',
      moduleName: 'gasometer',
    );
  }

  /// Creates a list of test vehicles
  static List<VehicleEntity> vehicles({int count = 3}) {
    return List.generate(
      count,
      (index) => vehicle(
        id: 'vehicle-test-${index.toString().padLeft(3, '0')}',
        name: 'Carro ${index + 1}',
        licensePlate: 'ABC-${(1234 + index).toString()}',
      ),
    );
  }

  /// Creates a validation failure for testing
  static ValidationFailure validationFailure([String message = 'Validation error']) {
    return ValidationFailure(message);
  }

  /// Creates a cache failure for testing
  static CacheFailure cacheFailure([String message = 'Cache error']) {
    return CacheFailure(message);
  }

  /// Creates a server failure for testing
  static ServerFailure serverFailure([String message = 'Server error']) {
    return ServerFailure(message);
  }

  /// Creates a network failure for testing
  static NetworkFailure networkFailure([String message = 'Network error']) {
    return NetworkFailure(message);
  }

  /// Creates test fuel consumption data
  static Map<String, double> fuelConsumptionData() {
    return {
      'averageConsumption': 12.5,
      'bestConsumption': 14.2,
      'worstConsumption': 10.8,
      'totalDistance': 1500.0,
      'totalLiters': 120.0,
    };
  }

  /// Creates test financial data
  static Map<String, double> financialData() {
    return {
      'totalCost': 660.0,
      'averagePricePerLiter': 5.50,
      'costPerKm': 0.44,
      'totalDistance': 1500.0,
    };
  }
}
