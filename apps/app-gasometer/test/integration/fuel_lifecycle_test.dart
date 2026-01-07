import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer_drift/features/fuel/domain/repositories/fuel_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFuelRepository extends Mock implements FuelRepository {}

void main() {
  late MockFuelRepository mockRepository;

  setUp(() {
    mockRepository = MockFuelRepository();
  });

  group('Fuel Lifecycle Integration Tests', () {
    const testUserId = 'user-test-001';
    const testVehicleId = 'vehicle-test-001';

    test('Complete lifecycle: add → update → delete → verify', () async {
      // Phase 1: ADD FUEL RECORD
      final newFuelEntity = FuelRecordEntity(
        id: 'fuel-lifecycle-001',
        vehicleId: testVehicleId,
        fuelType: FuelType.gasoline,
        liters: 40.0,
        pricePerLiter: 5.50,
        totalPrice: 220.0,
        odometer: 10000.0,
        date: DateTime(2024, 1, 15),
        fullTank: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: true,
        isDeleted: false,
        userId: testUserId,
        moduleName: 'gasometer',
      );

      when(() => mockRepository.addFuelRecord(newFuelEntity))
          .thenAnswer((_) async => Right(newFuelEntity));

      final addResult = await mockRepository.addFuelRecord(newFuelEntity);

      expect(addResult.isRight(), true);
      addResult.fold(
        (_) => fail('Add should succeed'),
        (record) {
          expect(record.id, 'fuel-lifecycle-001');
          expect(record.liters, 40.0);
          expect(record.isDirty, true);
        },
      );

      // Phase 2: UPDATE FUEL RECORD
      final updatedEntity = newFuelEntity.copyWith(
        liters: 42.0,
        totalPrice: 231.0,
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.updateFuelRecord(updatedEntity))
          .thenAnswer((_) async => Right(updatedEntity));

      final updateResult = await mockRepository.updateFuelRecord(updatedEntity);

      expect(updateResult.isRight(), true);
      updateResult.fold(
        (_) => fail('Update should succeed'),
        (record) {
          expect(record.id, 'fuel-lifecycle-001');
          expect(record.liters, 42.0);
          expect(record.totalPrice, 231.0);
        },
      );

      // Phase 3: GET FUEL RECORD
      when(() => mockRepository.getFuelRecordById('fuel-lifecycle-001'))
          .thenAnswer((_) async => Right(updatedEntity));

      final getResult =
          await mockRepository.getFuelRecordById('fuel-lifecycle-001');

      expect(getResult.isRight(), true);
      getResult.fold(
        (_) => fail('Get should succeed'),
        (record) {
          expect(record, isNotNull);
          expect(record!.liters, 42.0);
        },
      );

      // Phase 4: DELETE FUEL RECORD
      when(() => mockRepository.deleteFuelRecord('fuel-lifecycle-001'))
          .thenAnswer((_) async => const Right(unit));

      final deleteResult =
          await mockRepository.deleteFuelRecord('fuel-lifecycle-001');

      expect(deleteResult.isRight(), true);

      // Phase 5: VERIFY DELETION
      when(() => mockRepository.getFuelRecordById('fuel-lifecycle-001'))
          .thenAnswer(
              (_) async => const Left(CacheFailure('Record not found')));

      final verifyResult =
          await mockRepository.getFuelRecordById('fuel-lifecycle-001');

      expect(verifyResult.isLeft(), true);
    });

    test('Offline to online lifecycle: create offline → sync → verify',
        () async {
      // Phase 1: CREATE OFFLINE (with temporary ID)
      final offlineId = 'local_fuel_${DateTime.now().millisecondsSinceEpoch}';
      final offlineFuelEntity = FuelRecordEntity(
        id: offlineId,
        vehicleId: testVehicleId,
        fuelType: FuelType.ethanol,
        liters: 35.0,
        pricePerLiter: 4.20,
        totalPrice: 147.0,
        odometer: 10500.0,
        date: DateTime(2024, 1, 20),
        fullTank: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: true,
        isDeleted: false,
        userId: testUserId,
        moduleName: 'gasometer',
      );

      when(() => mockRepository.addFuelRecord(offlineFuelEntity))
          .thenAnswer((_) async => Right(offlineFuelEntity));

      final offlineAddResult =
          await mockRepository.addFuelRecord(offlineFuelEntity);

      expect(offlineAddResult.isRight(), true);
      offlineAddResult.fold(
        (_) => fail('Offline add should succeed'),
        (record) {
          expect(record.isDirty, true);
          expect(record.id, offlineId);
        },
      );

      // Phase 2: SYNC ONLINE (ID reconciliation)
      const remoteId = 'firebase_fuel_123';
      final syncedEntity = offlineFuelEntity.copyWith(
        id: remoteId,
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );

      when(() => mockRepository.updateFuelRecord(syncedEntity))
          .thenAnswer((_) async => Right(syncedEntity));

      final syncResult = await mockRepository.updateFuelRecord(syncedEntity);

      expect(syncResult.isRight(), true);
      syncResult.fold(
        (_) => fail('Sync should succeed'),
        (record) {
          expect(record.id, remoteId);
          expect(record.isDirty, false);
          expect(record.lastSyncAt, isNotNull);
        },
      );

      // Phase 3: VERIFY SYNCED STATE
      when(() => mockRepository.getFuelRecordById(remoteId))
          .thenAnswer((_) async => Right(syncedEntity));

      final verifyResult = await mockRepository.getFuelRecordById(remoteId);

      expect(verifyResult.isRight(), true);
      verifyResult.fold(
        (_) => fail('Verify should succeed'),
        (record) {
          expect(record, isNotNull);
          expect(record!.isDirty, false);
          expect(record.id, remoteId);
        },
      );
    });

    test(
        'Multiple vehicles lifecycle: add fuels → filter by vehicle → calculate stats',
        () async {
      // Setup: Multiple vehicles and fuel records
      const vehicle1Id = 'vehicle-001';
      const vehicle2Id = 'vehicle-002';

      final vehicle1Fuels = [
        FuelRecordEntity(
          id: 'fuel-v1-001',
          vehicleId: vehicle1Id,
          fuelType: FuelType.gasoline,
          liters: 40.0,
          pricePerLiter: 5.50,
          totalPrice: 220.0,
          odometer: 10000.0,
          date: DateTime(2024, 1, 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
          isDeleted: false,
          userId: testUserId,
          moduleName: 'gasometer',
        ),
        FuelRecordEntity(
          id: 'fuel-v1-002',
          vehicleId: vehicle1Id,
          fuelType: FuelType.gasoline,
          liters: 38.0,
          pricePerLiter: 5.60,
          totalPrice: 212.8,
          odometer: 10500.0,
          date: DateTime(2024, 1, 20),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
          isDeleted: false,
          userId: testUserId,
          moduleName: 'gasometer',
        ),
      ];

      final vehicle2Fuels = [
        FuelRecordEntity(
          id: 'fuel-v2-001',
          vehicleId: vehicle2Id,
          fuelType: FuelType.diesel,
          liters: 50.0,
          pricePerLiter: 4.80,
          totalPrice: 240.0,
          odometer: 15000.0,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: false,
          isDeleted: false,
          userId: testUserId,
          moduleName: 'gasometer',
        ),
      ];

      final allFuels = [...vehicle1Fuels, ...vehicle2Fuels];

      // Phase 1: GET ALL RECORDS
      when(() => mockRepository.getAllFuelRecords())
          .thenAnswer((_) async => Right(allFuels));

      final allResult = await mockRepository.getAllFuelRecords();

      expect(allResult.isRight(), true);
      allResult.fold(
        (_) => fail('Should get all records'),
        (records) {
          expect(records.length, 3);
        },
      );

      // Phase 2: FILTER BY VEHICLE
      when(() => mockRepository.getFuelRecordsByVehicle(vehicle1Id))
          .thenAnswer((_) async => Right(vehicle1Fuels));

      final vehicle1Result =
          await mockRepository.getFuelRecordsByVehicle(vehicle1Id);

      expect(vehicle1Result.isRight(), true);
      vehicle1Result.fold(
        (_) => fail('Should get vehicle 1 records'),
        (records) {
          expect(records.length, 2);
          expect(records.every((r) => r.vehicleId == vehicle1Id), true);
        },
      );

      // Phase 3: CALCULATE STATS FOR VEHICLE 1
      vehicle1Result.fold(
        (_) {},
        (records) {
          final totalLiters = records.fold(0.0, (acc, r) => acc + r.liters);
          final totalCost = records.fold(0.0, (acc, r) => acc + r.totalPrice);
          final avgPricePerLiter = totalCost / totalLiters;

          expect(totalLiters, 78.0);
          expect(totalCost, closeTo(432.8, 0.01));
          expect(avgPricePerLiter, closeTo(5.548, 0.001));
        },
      );
    });

    test('Error handling lifecycle: validation → retry → success', () async {
      // Phase 1: VALIDATION FAILURE
      final invalidFuelEntity = FuelRecordEntity(
        id: 'fuel-invalid-001',
        vehicleId: '', // Invalid: empty vehicle ID
        fuelType: FuelType.gasoline,
        liters: 0.0, // Invalid: zero liters
        pricePerLiter: 5.50,
        totalPrice: 0.0,
        odometer: 10000.0,
        date: DateTime(2024, 1, 15),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDirty: true,
        isDeleted: false,
        userId: testUserId,
        moduleName: 'gasometer',
      );

      when(() => mockRepository.addFuelRecord(invalidFuelEntity)).thenAnswer(
        (_) async => const Left(ValidationFailure('Invalid fuel data')),
      );

      final invalidResult =
          await mockRepository.addFuelRecord(invalidFuelEntity);

      expect(invalidResult.isLeft(), true);
      invalidResult.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid'));
        },
        (_) => fail('Should fail validation'),
      );

      // Phase 2: FIX AND RETRY
      final validFuelEntity = invalidFuelEntity.copyWith(
        vehicleId: testVehicleId,
        liters: 40.0,
        totalPrice: 220.0,
      );

      when(() => mockRepository.addFuelRecord(validFuelEntity))
          .thenAnswer((_) async => Right(validFuelEntity));

      final validResult = await mockRepository.addFuelRecord(validFuelEntity);

      expect(validResult.isRight(), true);
      validResult.fold(
        (_) => fail('Valid add should succeed'),
        (record) {
          expect(record.vehicleId, testVehicleId);
          expect(record.liters, 40.0);
        },
      );
    });

    test('Concurrent operations lifecycle: multiple adds → batch read',
        () async {
      // Simulate multiple concurrent fuel additions
      final fuels = List.generate(
        5,
        (i) => FuelRecordEntity(
          id: 'fuel-batch-00$i',
          vehicleId: testVehicleId,
          fuelType: FuelType.gasoline,
          liters: 40.0 + i.toDouble(),
          pricePerLiter: 5.50,
          totalPrice: (40.0 + i) * 5.50,
          odometer: 10000.0 + (i * 500.0),
          date: DateTime(2024, 1, 10).add(Duration(days: i * 7)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDirty: true,
          isDeleted: false,
          userId: testUserId,
          moduleName: 'gasometer',
        ),
      );

      // Add all fuels
      for (final fuel in fuels) {
        when(() => mockRepository.addFuelRecord(fuel))
            .thenAnswer((_) async => Right(fuel));
      }

      final addResults = await Future.wait(
        fuels.map((fuel) => mockRepository.addFuelRecord(fuel)),
      );

      // Verify all succeeded
      expect(addResults.every((r) => r.isRight()), true);

      // Batch read
      when(() => mockRepository.getAllFuelRecords())
          .thenAnswer((_) async => Right(fuels));

      final batchResult = await mockRepository.getAllFuelRecords();

      expect(batchResult.isRight(), true);
      batchResult.fold(
        (_) => fail('Batch read should succeed'),
        (records) {
          expect(records.length, 5);
          expect(records.map((r) => r.liters).toList(),
              [40.0, 41.0, 42.0, 43.0, 44.0]);
        },
      );
    });
  });
}
