import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';

void main() {
  group('VehicleEntity', () {
    final testVehicle = VehicleEntity(
      id: 'test-id',
      firebaseId: 'firebase-id',
      name: 'Meu Carro',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      color: 'Prata',
      licensePlate: 'ABC-1234',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline, FuelType.ethanol],
      tankCapacity: 50.0,
      engineSize: 2.0,
      currentOdometer: 15000.0,
      averageConsumption: 12.5,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should create vehicle entity with all fields', () {
      expect(testVehicle.id, 'test-id');
      expect(testVehicle.name, 'Meu Carro');
      expect(testVehicle.brand, 'Toyota');
      expect(testVehicle.model, 'Corolla');
      expect(testVehicle.year, 2020);
      expect(testVehicle.licensePlate, 'ABC-1234');
      expect(testVehicle.type, VehicleType.car);
      expect(testVehicle.supportedFuels.length, 2);
      expect(testVehicle.currentOdometer, 15000.0);
      expect(testVehicle.isActive, true);
    });

    test('should return correct display name', () {
      expect(testVehicle.displayName, 'Toyota Corolla (2020)');
    });

    test('should identify as not empty with valid data', () {
      expect(testVehicle.isEmpty, false);
    });

    test('should identify as empty with missing required fields', () {
      final emptyVehicle = testVehicle.copyWith(
        name: '',
        brand: '',
        model: '',
      );
      expect(emptyVehicle.isEmpty, true);
    });

    test('should support multiple fuels', () {
      expect(testVehicle.supportsMultipleFuels, true);
      expect(testVehicle.supportsFuelType(FuelType.gasoline), true);
      expect(testVehicle.supportsFuelType(FuelType.ethanol), true);
      expect(testVehicle.supportsFuelType(FuelType.diesel), false);
    });

    test('should return primary fuel type', () {
      expect(testVehicle.primaryFuelType, 'Gasolina');
    });

    test('should copy with new values', () {
      final updated = testVehicle.copyWith(
        name: 'Novo Nome',
        currentOdometer: 20000.0,
      );

      expect(updated.name, 'Novo Nome');
      expect(updated.currentOdometer, 20000.0);
      expect(updated.brand, 'Toyota'); // unchanged
    });

    test('should mark as dirty', () {
      final dirty = testVehicle.markAsDirty();
      
      expect(dirty.isDirty, true);
      expect(dirty.updatedAt!.isAfter(testVehicle.updatedAt!), true);
    });

    test('should mark as synced', () {
      final synced = testVehicle.markAsSynced();
      
      expect(synced.isDirty, false);
      expect(synced.lastSyncAt, isNotNull);
    });

    test('should mark as deleted', () {
      final deleted = testVehicle.markAsDeleted();
      
      expect(deleted.isDeleted, true);
      expect(deleted.isDirty, true);
    });

    test('should increment version', () {
      final incremented = testVehicle.incrementVersion();
      
      expect(incremented.version, testVehicle.version + 1);
    });

    test('should convert to Firebase map', () {
      final map = testVehicle.toFirebaseMap();
      
      expect(map['name'], 'Meu Carro');
      expect(map['brand'], 'Toyota');
      expect(map['model'], 'Corolla');
      expect(map['year'], 2020);
      expect(map['license_plate'], 'ABC-1234');
      expect(map['type'], 'car');
      expect(map['supported_fuels'], ['gasoline', 'ethanol']);
      expect(map['current_odometer'], 15000.0);
      expect(map['tank_capacity'], 50.0);
      expect(map['is_active'], true);
    });

    test('should create from Firebase map', () {
      final map = {
        'id': 'test-id',
        'name': 'Meu Carro',
        'brand': 'Toyota',
        'model': 'Corolla',
        'year': 2020,
        'color': 'Prata',
        'license_plate': 'ABC-1234',
        'type': 'car',
        'supported_fuels': ['gasoline', 'ethanol'],
        'current_odometer': 15000.0,
        'tank_capacity': 50.0,
        'engine_size': 2.0,
        'average_consumption': 12.5,
        'is_active': true,
        'user_id': 'user-001',
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final vehicle = VehicleEntity.fromFirebaseMap(map);
      
      expect(vehicle.id, 'test-id');
      expect(vehicle.name, 'Meu Carro');
      expect(vehicle.brand, 'Toyota');
      expect(vehicle.type, VehicleType.car);
      expect(vehicle.supportedFuels.length, 2);
    });

    test('should handle missing optional fields in Firebase map', () {
      final map = {
        'id': 'test-id',
        'name': 'Basic Car',
        'brand': 'Honda',
        'model': 'Civic',
        'year': 2019,
        'color': 'Preto',
        'license_plate': 'XYZ-5678',
        'type': 'car',
        'supported_fuels': ['gasoline'],
        'current_odometer': 5000.0,
        'user_id': 'user-001',
      };

      final vehicle = VehicleEntity.fromFirebaseMap(map);
      
      expect(vehicle.tankCapacity, isNull);
      expect(vehicle.engineSize, isNull);
      expect(vehicle.averageConsumption, isNull);
      expect(vehicle.photoUrl, isNull);
      expect(vehicle.isActive, true);
    });

    test('should use equality correctly', () {
      final vehicle1 = testVehicle;
      final vehicle2 = testVehicle.copyWith();
      final vehicle3 = testVehicle.copyWith(name: 'Different Name');

      expect(vehicle1, equals(vehicle2));
      expect(vehicle1, isNot(equals(vehicle3)));
    });
  });

  group('FuelType', () {
    test('should return correct display names', () {
      expect(FuelType.gasoline.displayName, 'Gasolina');
      expect(FuelType.ethanol.displayName, 'Etanol');
      expect(FuelType.diesel.displayName, 'Diesel');
      expect(FuelType.electric.displayName, 'Elétrico');
      expect(FuelType.flex.displayName, 'Flex');
    });

    test('should convert from string', () {
      expect(FuelType.fromString('gasoline'), FuelType.gasoline);
      expect(FuelType.fromString('diesel'), FuelType.diesel);
      expect(FuelType.fromString('invalid'), FuelType.gasoline); // default
    });
  });

  group('VehicleType', () {
    test('should return correct display names', () {
      expect(VehicleType.car.displayName, 'Carro');
      expect(VehicleType.motorcycle.displayName, 'Moto');
      expect(VehicleType.truck.displayName, 'Caminhão');
      expect(VehicleType.van.displayName, 'Van');
      expect(VehicleType.bus.displayName, 'Ônibus');
    });

    test('should convert from string', () {
      expect(VehicleType.fromString('car'), VehicleType.car);
      expect(VehicleType.fromString('motorcycle'), VehicleType.motorcycle);
      expect(VehicleType.fromString('invalid'), VehicleType.car); // default
    });
  });
}
