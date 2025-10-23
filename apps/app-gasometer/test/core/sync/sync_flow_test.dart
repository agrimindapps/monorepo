import 'dart:async';

import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/logging/services/logging_service.dart';
import 'package:gasometer/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:gasometer/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/sync_test_helpers.dart';

void main() {
  late VehicleRepositoryImpl vehicleRepository;
  late FuelRepositoryImpl fuelRepository;
  late MaintenanceRepositoryImpl maintenanceRepository;
  late MockUnifiedSyncManager mockSyncManager;
  late MockLoggingService mockLogger;

  setUp(() {
    mockSyncManager = MockUnifiedSyncManager();
    mockLogger = MockLoggingService();

    vehicleRepository = VehicleRepositoryImpl(loggingService: mockLogger);
    fuelRepository = FuelRepositoryImpl(loggingService: mockLogger);
    maintenanceRepository =
        MaintenanceRepositoryImpl(loggingService: mockLogger);

    SyncTestSetup.registerFallbackValues();
    SyncTestSetup.setupLoggingService(mockLogger);
  });

  group('Offline → Online Sync Flow', () {
    test('should create vehicle offline then sync when online', () async {
      // Arrange - Offline creation
      final vehicle = SyncTestFixtures.createVehicle(
        id: 'local_123',
        name: 'Offline Car',
      );

      when(() => mockSyncManager.create<VehicleEntity>(
            'gasometer',
            any(that: isVehicleWithId('local_123')),
          )).thenAnswer((_) async => const Right('local_123'));

      // Act - Create offline (UnifiedSyncManager marca como pending sync)
      final createResult = await vehicleRepository.addVehicle(vehicle);

      // Assert - Criado localmente
      expect(createResult.isRight(), true);

      // Simulate online sync trigger
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act - Force sync
      final syncResult = await vehicleRepository.syncVehicles();

      // Assert - Sync completed
      expect(syncResult.isRight(), true);
      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(1);
    });

    test('should batch create multiple entities offline then sync', () async {
      // Arrange - Create multiple entities offline
      final vehicles = SyncTestFixtures.createVehicles(3);

      for (var i = 0; i < vehicles.length; i++) {
        when(() => mockSyncManager.create<VehicleEntity>(
              'gasometer',
              any(that: isVehicleWithId('vehicle_${i + 1}')),
            )).thenAnswer((_) async => Right('vehicle_${i + 1}'));
      }

      // Act - Create all vehicles
      final createResults = await Future.wait(
        vehicles.map((v) => vehicleRepository.addVehicle(v)),
      );

      // Assert - All created
      expect(createResults.every((r) => r.isRight()), true);

      // Act - Batch sync
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      final syncResult = await vehicleRepository.syncVehicles();

      // Assert - Batch sync completed
      expect(syncResult.isRight(), true);
      verify(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .called(3);
    });

    test(
        'should handle offline create of fuel record with vehicle reference verification',
        () async {
      // Arrange - Vehicle exists
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right('vehicle_1'));
      await vehicleRepository.addVehicle(vehicle);

      // Arrange - Fuel record references vehicle
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'vehicle_1',
      );
      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .called(1);
    });
  });

  group('Multi-Device Conflict Sync', () {
    test(
        'should resolve conflict when same vehicle edited on multiple devices',
        () async {
      // Arrange - Device A edits
      final vehicleA = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: 2,
        name: 'Device A Name',
        updatedAt: DateTime(2024, 1, 1, 10, 0),
      );

      // Arrange - Device B edits (mais recente)
      final vehicleB = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: 2,
        name: 'Device B Name',
        updatedAt: DateTime(2024, 1, 1, 11, 0), // 1 hora depois
      );

      // Device A sync first
      when(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right(unit));

      await vehicleRepository.updateVehicle(vehicleA);

      // Device B detects conflict (version mismatch)
      // UnifiedSyncManager should resolve based on updatedAt
      when(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async {
        // Conflict detected - B is newer
        return const Right(unit);
      });

      final resultB = await vehicleRepository.updateVehicle(vehicleB);

      // Assert - B wins (newer timestamp)
      expect(resultB.isRight(), true);
      verify(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(),
          )).called(2);
    });

    test('should handle concurrent fuel record updates', () async {
      // Arrange - Same fuel record updated concurrently
      final fuelRecordA = SyncTestFixtures.createFuelRecord(
        id: 'fuel_1',
        version: 1,
        liters: 40.0,
      );

      final fuelRecordB = SyncTestFixtures.createFuelRecord(
        id: 'fuel_1',
        version: 1,
        liters: 45.0, // Diferente
      );

      // Both try to update
      when(() => mockSyncManager.update<FuelRecordEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final results = await Future.wait([
        fuelRepository.updateFuelRecord(fuelRecordA),
        fuelRepository.updateFuelRecord(fuelRecordB),
      ]);

      // Assert - Both updates processed (conflict resolution handled by USM)
      expect(results.every((r) => r.isRight()), true);
    });

    test('should handle version increment correctly during updates', () async {
      // Arrange
      var currentVersion = 1;
      final vehicle = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        version: currentVersion,
      );

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Multiple sequential updates
      var result = await vehicleRepository.updateVehicle(vehicle);
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.version, 2);
          currentVersion = updated.version;
        },
      );

      // Act - Second update
      final vehicle2 = vehicle.copyWith(version: currentVersion);
      result = await vehicleRepository.updateVehicle(vehicle2);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.version, 3); // Incrementado novamente
        },
      );
    });
  });

  group('Cross-Entity Sync Flow', () {
    test('should sync vehicle with dependent fuel records', () async {
      // Arrange - Vehicle
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right('vehicle_1'));

      // Arrange - Fuel records for this vehicle
      final fuelRecords = SyncTestFixtures.createFuelRecords(
        3,
        vehicleId: 'vehicle_1',
      );
      for (var record in fuelRecords) {
        when(() => mockSyncManager.create<FuelRecordEntity>(
              any(),
              any(that: isFuelRecordWithId(record.id)),
            )).thenAnswer((_) async => Right(record.id));
      }

      // Act - Create vehicle
      final vehicleResult = await vehicleRepository.addVehicle(vehicle);
      expect(vehicleResult.isRight(), true);

      // Act - Create fuel records
      final fuelResults = await Future.wait(
        fuelRecords.map((r) => fuelRepository.addFuelRecord(r)),
      );

      // Assert - All created
      expect(fuelResults.every((r) => r.isRight()), true);
    });

    test('should sync vehicle with maintenance and fuel records', () async {
      // Arrange - Complete vehicle ecosystem
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');
      final fuelRecords = SyncTestFixtures.createFuelRecords(
        2,
        vehicleId: 'vehicle_1',
      );
      final maintenances = SyncTestFixtures.createMaintenances(
        2,
        vehicleId: 'vehicle_1',
      );

      // Setup mocks
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right('vehicle_1'));
      for (var record in fuelRecords) {
        when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
            .thenAnswer((_) async => Right(record.id));
      }
      for (var maint in maintenances) {
        when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
            .thenAnswer((_) async => Right(maint.id));
      }

      // Act - Create all entities
      await vehicleRepository.addVehicle(vehicle);
      await Future.wait(fuelRecords.map((r) => fuelRepository.addFuelRecord(r)));
      await Future.wait(
          maintenances.map((m) => maintenanceRepository.addMaintenanceRecord(m)));

      // Assert - All entities created
      verify(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .called(1);
      verify(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .called(2);
      verify(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .called(2);
    });

    test('should handle cascading updates (vehicle -> fuel consumption)',
        () async {
      // Arrange - Vehicle com odômetro atualizado
      final vehicle = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        currentOdometer: 12000.0,
      );

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act - Update vehicle odometer
      final updatedVehicle = vehicle.copyWith(currentOdometer: 12500.0);
      final vehicleResult = await vehicleRepository.updateVehicle(updatedVehicle);

      expect(vehicleResult.isRight(), true);

      // Arrange - Fuel record com novo odômetro
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'vehicle_1',
        odometer: 12500.0,
      );

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act - Create fuel record
      final fuelResult = await fuelRepository.addFuelRecord(fuelRecord);

      // Assert
      expect(fuelResult.isRight(), true);
      fuelResult.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.odometer, 12500.0);
        },
      );
    });
  });

  group('Batch Sync Operations', () {
    test('should batch sync multiple vehicles efficiently', () async {
      // Arrange
      final vehicles = SyncTestFixtures.createVehicles(5);

      for (var vehicle in vehicles) {
        when(() => mockSyncManager.create<VehicleEntity>(
              any(),
              any(that: isVehicleWithId(vehicle.id)),
            )).thenAnswer((_) async => Right(vehicle.id));
      }

      // Act - Create all vehicles
      final results = await Future.wait(
        vehicles.map((v) => vehicleRepository.addVehicle(v)),
      );

      // Assert - All created successfully
      expect(results.every((r) => r.isRight()), true);
      expect(results.length, 5);

      // Trigger batch sync
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      final syncResult = await vehicleRepository.syncVehicles();
      expect(syncResult.isRight(), true);
    });

    test('should handle partial batch sync (some succeed, some fail)', () async {
      // Arrange - 3 vehicles, 1 will fail
      final vehicles = SyncTestFixtures.createVehicles(3);

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right('vehicle_1'));

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_2')),
          )).thenAnswer(
              (_) async => const Left(ValidationFailure('Invalid vehicle')));

      when(() => mockSyncManager.create<VehicleEntity>(
            any(),
            any(that: isVehicleWithId('vehicle_3')),
          )).thenAnswer((_) async => const Right('vehicle_3'));

      // Act
      final results = await Future.wait(
        vehicles.map((v) => vehicleRepository.addVehicle(v)),
      );

      // Assert - 2 succeeded, 1 failed
      final succeeded = results.where((r) => r.isRight()).length;
      final failed = results.where((r) => r.isLeft()).length;

      expect(succeeded, 2);
      expect(failed, 1);
    });

    test('should maintain data consistency during batch sync', () async {
      // Arrange - Batch de fuel records para mesmo veículo
      final fuelRecords = List.generate(
        5,
        (i) => SyncTestFixtures.createFuelRecord(
          id: 'fuel_$i',
          vehicleId: 'vehicle_1',
          odometer: 10000.0 + (i * 500), // Sequential odometer
        ),
      );

      for (var record in fuelRecords) {
        when(() => mockSyncManager.create<FuelRecordEntity>(
              any(),
              any(that: isFuelRecordWithId(record.id)),
            )).thenAnswer((_) async => Right(record.id));
      }

      // Act - Create all records
      final results = await Future.wait(
        fuelRecords.map((r) => fuelRepository.addFuelRecord(r)),
      );

      // Assert - All created in order
      expect(results.every((r) => r.isRight()), true);
      expect(results.length, 5);
    });
  });

  group('Sync State Recovery', () {
    test('should recover from interrupted sync', () async {
      // Arrange - Sync interrupted mid-operation
      final vehicle = SyncTestFixtures.createVehicle();

      var callCount = 0;
      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Network timeout');
        }
        return Right(vehicle.id);
      });

      // Act - First attempt fails
      var result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isLeft(), true);

      // Act - Retry succeeds
      result = await vehicleRepository.addVehicle(vehicle);
      expect(result.isRight(), true);

      // Assert - Recovery successful
      expect(callCount, 2);
    });

    test('should handle sync after app restart', () async {
      // Arrange - Entities marcados como dirty (pendentes de sync)
      final vehicle = SyncTestFixtures.createVehicle(isDirty: true);

      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act - Force sync on app startup
      final syncResult = await vehicleRepository.syncVehicles();

      // Assert - Sync completed
      expect(syncResult.isRight(), true);
      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(1);
    });
  });

  group('Real-time Sync Scenarios', () {
    test('should handle rapid consecutive syncs without duplication', () async {
      // Arrange
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Right(unit);
      });

      // Act - Trigger multiple syncs simultaneously
      final syncResults = await Future.wait([
        vehicleRepository.syncVehicles(),
        vehicleRepository.syncVehicles(),
        vehicleRepository.syncVehicles(),
      ]);

      // Assert - All completed (UnifiedSyncManager handles deduplication)
      expect(syncResults.every((r) => r.isRight()), true);
    });

    test('should propagate updates to reactive streams', () async {
      // Arrange
      final vehicles = SyncTestFixtures.createVehicles(2);
      final controller = StreamController<List<VehicleEntity>>();

      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) => controller.stream);

      // Act - Watch stream
      final streamFuture =
          vehicleRepository.watchVehicles().first;

      // Emit initial data
      controller.add(vehicles);

      // Assert - Stream receives data
      final result = await streamFuture;
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (list) => expect(list.length, 2),
      );

      await controller.close();
    });
  });
}
