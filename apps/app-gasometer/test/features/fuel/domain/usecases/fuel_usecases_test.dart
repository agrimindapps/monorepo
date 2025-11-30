import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer_drift/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/add_fuel_record.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/delete_fuel_record.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/get_all_fuel_records.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/update_fuel_record.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFuelRepository extends Mock implements FuelRepository {}

class FakeFuelRecordEntity extends Fake implements FuelRecordEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFuelRecordEntity());
  });

  group('AddFuelRecord Use Case', () {
    late AddFuelRecord useCase;
    late MockFuelRepository mockRepository;

    setUp(() {
      mockRepository = MockFuelRepository();
      useCase = AddFuelRecord(mockRepository);
    });

    final validFuelRecord = FuelRecordEntity(
      id: 'test-id',
      vehicleId: 'vehicle-001',
      fuelType: FuelType.gasoline,
      liters: 40.0,
      pricePerLiter: 5.50,
      totalPrice: 220.0,
      odometer: 10000.0,
      date: DateTime(2024, 1, 15),
      fullTank: true,
      gasStationName: 'Shell',
      notes: 'Full tank',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should add fuel record successfully with valid data', () async {
      // Arrange
      final params = AddFuelRecordParams(fuelRecord: validFuelRecord);

      when(() => mockRepository.addFuelRecord(any()))
          .thenAnswer((_) async => Right(validFuelRecord));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (entity) {
          expect(entity.vehicleId, validFuelRecord.vehicleId);
          expect(entity.liters, validFuelRecord.liters);
        },
      );

      verify(() => mockRepository.addFuelRecord(any())).called(1);
    });

    test('should return ValidationFailure for empty vehicle ID', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(vehicleId: '');
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('veículo'));
        },
        (_) => fail('Should fail'),
      );

      verifyNever(() => mockRepository.addFuelRecord(any()));
    });

    test('should return ValidationFailure for zero liters', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(liters: 0.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('litros')),
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for negative liters', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(liters: -10.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for zero price per liter', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(pricePerLiter: 0.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message.toLowerCase(), contains('preço')),
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for zero total price', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(totalPrice: 0.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for zero odometer', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(odometer: 0.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Odômetro')),
        (_) => fail('Should fail'),
      );
    });

    test('should return ValidationFailure for mismatched total price',
        () async {
      // Arrange
      // liters: 40, price: 5.50 = 220.0, but total is 300.0 (way off)
      final invalidRecord = validFuelRecord.copyWith(totalPrice: 300.0);
      final params = AddFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('não confere')),
        (_) => fail('Should fail'),
      );
    });

    test('should accept total price within 5% tolerance', () async {
      // Arrange
      // liters: 40, price: 5.50 = 220.0, tolerance = 11.0
      // 224.0 is within tolerance
      final slightlyOffRecord = validFuelRecord.copyWith(totalPrice: 224.0);
      final params = AddFuelRecordParams(fuelRecord: slightlyOffRecord);

      when(() => mockRepository.addFuelRecord(any()))
          .thenAnswer((_) async => Right(slightlyOffRecord));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle CacheFailure from repository', () async {
      // Arrange
      final params = AddFuelRecordParams(fuelRecord: validFuelRecord);

      when(() => mockRepository.addFuelRecord(any())).thenAnswer(
        (_) async => const Left(CacheFailure('Database error')),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should fail'),
      );
    });
  });

  group('UpdateFuelRecord Use Case', () {
    late UpdateFuelRecord useCase;
    late MockFuelRepository mockRepository;

    setUp(() {
      mockRepository = MockFuelRepository();
      useCase = UpdateFuelRecord(mockRepository);
    });

    final validFuelRecord = FuelRecordEntity(
      id: 'fuel-001',
      vehicleId: 'vehicle-001',
      fuelType: FuelType.gasoline,
      liters: 42.0,
      pricePerLiter: 5.60,
      totalPrice: 235.2,
      odometer: 10500.0,
      date: DateTime(2024, 1, 20),
      fullTank: true,
      gasStationName: 'Shell',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
      userId: 'user-001',
      moduleName: 'gasometer',
    );

    test('should update fuel record successfully', () async {
      // Arrange
      final params = UpdateFuelRecordParams(fuelRecord: validFuelRecord);

      when(() => mockRepository.updateFuelRecord(any()))
          .thenAnswer((_) async => Right(validFuelRecord));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (entity) {
          expect(entity.id, validFuelRecord.id);
          expect(entity.liters, validFuelRecord.liters);
        },
      );

      verify(() => mockRepository.updateFuelRecord(any())).called(1);
    });

    test('should return ValidationFailure for empty ID', () async {
      // Arrange
      final invalidRecord = validFuelRecord.copyWith(id: '');
      final params = UpdateFuelRecordParams(fuelRecord: invalidRecord);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('DeleteFuelRecord Use Case', () {
    late DeleteFuelRecord useCase;
    late MockFuelRepository mockRepository;

    setUp(() {
      mockRepository = MockFuelRepository();
      useCase = DeleteFuelRecord(mockRepository);
    });

    test('should delete fuel record successfully', () async {
      // Arrange
      const params = DeleteFuelRecordParams(id: 'fuel-001');

      when(() => mockRepository.deleteFuelRecord(any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.deleteFuelRecord('fuel-001')).called(1);
    });

    test('should return ValidationFailure for empty ID', () async {
      // Arrange
      const params = DeleteFuelRecordParams(id: '');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetAllFuelRecords Use Case', () {
    late GetAllFuelRecords useCase;
    late MockFuelRepository mockRepository;

    setUp(() {
      mockRepository = MockFuelRepository();
      useCase = GetAllFuelRecords(mockRepository);
    });

    test('should return all fuel records successfully', () async {
      // Arrange
      final testRecords = [
        FuelRecordEntity(
          id: 'fuel-001',
          vehicleId: 'vehicle-001',
          fuelType: FuelType.gasoline,
          liters: 40.0,
          pricePerLiter: 5.50,
          totalPrice: 220.0,
          odometer: 10000.0,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
          isDeleted: false,
          userId: 'user-001',
          moduleName: 'gasometer',
        ),
      ];

      when(() => mockRepository.getAllFuelRecords())
          .thenAnswer((_) async => Right(testRecords));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (records) => expect(records.length, 1),
      );
    });

    test('should return empty list when no records exist', () async {
      // Arrange
      when(() => mockRepository.getAllFuelRecords())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (records) => expect(records.isEmpty, true),
      );
    });
  });

  group('GetFuelRecordsByVehicle Use Case', () {
    late GetFuelRecordsByVehicle useCase;
    late MockFuelRepository mockRepository;

    setUp(() {
      mockRepository = MockFuelRepository();
      useCase = GetFuelRecordsByVehicle(mockRepository);
    });

    test('should return fuel records for specific vehicle', () async {
      // Arrange
      const vehicleId = 'vehicle-001';
      const params = GetFuelRecordsByVehicleParams(vehicleId: vehicleId);

      final testRecords = [
        FuelRecordEntity(
          id: 'fuel-001',
          vehicleId: vehicleId,
          fuelType: FuelType.gasoline,
          liters: 40.0,
          pricePerLiter: 5.50,
          totalPrice: 220.0,
          odometer: 10000.0,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
          isDeleted: false,
          userId: 'user-001',
          moduleName: 'gasometer',
        ),
      ];

      when(() => mockRepository.getFuelRecordsByVehicle(vehicleId))
          .thenAnswer((_) async => Right(testRecords));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (records) {
          expect(records.length, 1);
          expect(records[0].vehicleId, vehicleId);
        },
      );

      verify(() => mockRepository.getFuelRecordsByVehicle(vehicleId)).called(1);
    });

    test('should return empty list for vehicle with no records', () async {
      // Arrange
      const vehicleId = 'vehicle-without-records';
      const params = GetFuelRecordsByVehicleParams(vehicleId: vehicleId);

      when(() => mockRepository.getFuelRecordsByVehicle(vehicleId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (records) => expect(records.isEmpty, true),
      );
    });

    test('should return ValidationFailure for empty vehicle ID', () async {
      // Arrange
      const params = GetFuelRecordsByVehicleParams(vehicleId: '');

      // No mock needed - use case validates before calling repository

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('veículo'));
        },
        (_) => fail('Should fail'),
      );

      // Repository should not be called for validation errors
      verifyNever(() => mockRepository.getFuelRecordsByVehicle(any()));
    });
  });
}
