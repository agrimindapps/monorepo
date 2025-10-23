import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/logging/services/logging_service.dart';
import 'package:gasometer/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/sync_test_helpers.dart';

void main() {
  late FuelRepositoryImpl repository;
  late MockUnifiedSyncManager mockSyncManager;
  late MockLoggingService mockLogger;

  setUp(() {
    mockSyncManager = MockUnifiedSyncManager();
    mockLogger = MockLoggingService();

    repository = FuelRepositoryImpl(
      loggingService: mockLogger,
    );

    SyncTestSetup.registerFallbackValues();
    SyncTestSetup.setupLoggingService(mockLogger);
  });

  group('FuelRepository - Create with Sync', () {
    test('should create fuel record and sync successfully', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        id: 'fuel_1',
        vehicleId: 'vehicle_1',
        liters: 40.0,
        pricePerLiter: 5.5,
      );

      when(() => mockSyncManager.create<FuelRecordEntity>(
            'gasometer',
            any(that: isFuelRecordWithId('fuel_1')),
          )).thenAnswer((_) async => const Right('fuel_1'));

      // Act
      final result = await repository.addFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (created) {
          expect(created.id, 'fuel_1');
          expect(created.liters, 40.0);
          expect(created.totalPrice, 220.0); // 40 * 5.5
        },
      );

      verify(() => mockSyncManager.create<FuelRecordEntity>(
            'gasometer',
            any(that: isFuelRecordWithId('fuel_1')),
          )).called(1);
    });

    test('should log detailed metadata for financial audit', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'vehicle_1',
        fuelType: FuelType.diesel,
        liters: 50.0,
        pricePerLiter: 6.0,
        odometer: 12000.0,
      );

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      await repository.addFuelRecord(fuelRecord);

      // Assert - Verificar logging de auditoria
      verify(() => mockLogger.logOperationStart(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message', that: predicate<String>((m) => m.contains('vehicle_1'))),
            metadata: any(
              named: 'metadata',
              that: predicate<Map<String, dynamic>>((m) =>
                  m['vehicle_id'] == 'vehicle_1' &&
                  m['liters'] == '50.0' &&
                  m['cost'] == '300.0' &&
                  m['odometer_reading'] == '12000.0'),
            ),
          )).called(1);
    });

    test('should handle validation failure on create', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord();
      const failure = ValidationFailure('Invalid fuel data');

      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.addFuelRecord(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, 'Invalid fuel data');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle orphaned fuel records (vehicle not found)', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        vehicleId: 'nonexistent_vehicle',
      );

      // Este teste simula que o UnifiedSyncManager permitiria a criação
      // (data integrity será verificado posteriormente)
      when(() => mockSyncManager.create<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => Right(fuelRecord.id));

      // Act
      final result = await repository.addFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      // Data integrity check deve detectar este orphan record posteriormente
    });
  });

  group('FuelRepository - Update with Sync', () {
    test('should update fuel record and increment version', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        id: 'fuel_1',
        version: 1,
        liters: 30.0,
      );

      when(() => mockSyncManager.update<FuelRecordEntity>(
            'gasometer',
            'fuel_1',
            any(that: isFuelRecordWithId('fuel_1')),
          )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.isDirty, true);
          expect(updated.version, 2);
          expect(updated.liters, 30.0);
        },
      );

      verify(() => mockSyncManager.update<FuelRecordEntity>(
            'gasometer',
            'fuel_1',
            any(that: isDirtyEntity()),
          )).called(1);
    });

    test('should preserve calculated fields during update', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        liters: 40.0,
        pricePerLiter: 5.0,
        odometer: 10500.0,
      );

      when(() => mockSyncManager.update<FuelRecordEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateFuelRecord(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.liters, 40.0);
          expect(updated.odometer, 10500.0);
        },
      );
    });

    test('should handle concurrent update conflict', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(
        id: 'fuel_1',
        version: 1,
      );

      // Simular conflito de versão (já foi atualizado por outro device)
      const failure =
          ValidationFailure('Version conflict: record was updated elsewhere');

      when(() => mockSyncManager.update<FuelRecordEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.updateFuelRecord(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, contains('Version conflict'));
        },
        (_) => fail('Should detect conflict'),
      );
    });
  });

  group('FuelRepository - Delete with Sync', () {
    test('should delete fuel record and propagate to remote', () async {
      // Arrange
      const fuelId = 'fuel_1';

      when(() => mockSyncManager.delete<FuelRecordEntity>('gasometer', fuelId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.deleteFuelRecord(fuelId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockSyncManager.delete<FuelRecordEntity>(
            'gasometer',
            fuelId,
          )).called(1);

      verify(() => mockLogger.logOperationSuccess(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message', that: predicate<String>((m) => m.contains('deletion completed'))),
            metadata: any(named: 'metadata'),
          )).called(1);
    });

    test('should handle delete of non-existent record', () async {
      // Arrange
      const fuelId = 'nonexistent';
      const failure = CacheFailure('Fuel record not found');

      when(() => mockSyncManager.delete<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.deleteFuelRecord(fuelId);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('FuelRepository - Read Operations with Sync', () {
    test('should get all fuel records with background sync', () async {
      // Arrange
      final fuelRecords = SyncTestFixtures.createFuelRecords(5);

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(fuelRecords));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAllFuelRecords();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (records) {
          expect(records.length, 5);
        },
      );

      verify(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .called(1);
      verify(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .called(1);
    });

    test('should get fuel records by vehicle with proper filtering', () async {
      // Arrange
      final allRecords = [
        SyncTestFixtures.createFuelRecord(
          id: 'f1',
          vehicleId: 'v1',
          date: DateTime(2024, 1, 3),
        ),
        SyncTestFixtures.createFuelRecord(
          id: 'f2',
          vehicleId: 'v2',
          date: DateTime(2024, 1, 2),
        ),
        SyncTestFixtures.createFuelRecord(
          id: 'f3',
          vehicleId: 'v1',
          date: DateTime(2024, 1, 1),
        ),
      final allRecords = [

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(allRecords));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getFuelRecordsByVehicle('v1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (filtered) {
          expect(filtered.length, 2);
          expect(filtered.every((r) => r.vehicleId == 'v1'), true);
          // Deve estar ordenado por data (mais recente primeiro)
          expect(filtered[0].id, 'f1'); // 2024-01-03
          expect(filtered[1].id, 'f3'); // 2024-01-01
        },
      );
    });

    test('should get fuel record by id', () async {
      // Arrange
      final fuelRecord = SyncTestFixtures.createFuelRecord(id: 'fuel_1');

      when(() => mockSyncManager.findById<FuelRecordEntity>(
            'gasometer',
            'fuel_1',
          )).thenAnswer((_) async => Right(fuelRecord));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getFuelRecordById('fuel_1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (found) {
          expect(found?.id, 'fuel_1');
        },
      );
    });

    test('should return null when record not found', () async {
      // Arrange
      when(() => mockSyncManager.findById<FuelRecordEntity>(any(), any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getFuelRecordById('nonexistent');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (found) {
          expect(found, isNull);
        },
      );
    });
  });

  group('FuelRepository - Search Operations', () {
    test('should search fuel records by fuel type', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createFuelRecord(
          id: 'f1',
          fuelType: FuelType.gasoline,
        ),
        SyncTestFixtures.createFuelRecord(
          id: 'f2',
          fuelType: FuelType.diesel,
        ),
        SyncTestFixtures.createFuelRecord(
          id: 'f3',
          fuelType: FuelType.gasoline,
        ),
      final records = [

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.searchFuelRecords('gasoline');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (searchResults) {
          expect(searchResults.length, 2);
          expect(
            searchResults.every((r) => r.fuelType == FuelType.gasoline),
            true,
          );
        },
      );
    });

    test('should search by numeric values (liters, price)', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createFuelRecord(id: 'f1', liters: 40.0),
        SyncTestFixtures.createFuelRecord(id: 'f3', liters: 45.0),
      ];

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.searchFuelRecords('40');

      // Assert
      expect(result.isRight(), true);),
      result.fold(
        (_) => fail('Should not fail'),
        (searchResults) {
          expect(searchResults.length, 1);
          expect(searchResults[0].liters, 40.0);
        },
      );
    });
  });

  group('FuelRepository - Analytics Operations', () {
    test('should calculate average consumption correctly', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createFuelRecord(
          vehicleId: 'v1',
        ),
      final records = [

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAverageConsumption('v1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (average) {
          expect(average, closeTo(12.5, 0.01)); // (12.5 + 13.0 + 12.0) / 3
        },
      );
    });

    test('should return zero when insufficient data for average', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createFuelRecord(vehicleId: 'v1')),
      ];

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAverageConsumption('v1');

      // Assert
      expect(result.isRight(), true);),
      result.fold(
        (_) => fail('Should not fail'),
        (average) {
          expect(average, 0.0);
        },
      );
    });

    test('should calculate total spent with date filters', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createFuelRecord(
          vehicleId: 'v1',
          date: DateTime(2024, 1, 1),
          liters: 40.0,
          pricePerLiter: 5.0,
        ), // 200.0
        SyncTestFixtures.createFuelRecord(
          vehicleId: 'v1',
          date: DateTime(2024, 1, 15),
          liters: 50.0,
          pricePerLiter: 5.0,
        ), // 250.0
        SyncTestFixtures.createFuelRecord(
          vehicleId: 'v1',
          date: DateTime(2024, 2, 1),
          liters: 30.0,
          pricePerLiter: 5.0,
        ), // 150.0
      final records = [

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act - Only January 2024
      final result = await repository.getTotalSpent(
        'v1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (total) {
          expect(total, 450.0); // 200 + 250
        },
      );
    });

    test('should get recent fuel records with limit', () async {
      // Arrange
      final records = List.generate(
        15,
        (i) => SyncTestFixtures.createFuelRecord(
          id: 'fuel_$i',
          vehicleId: 'v1',
          date: DateTime(2024, 1, 15 - i),
      );

      when(() => mockSyncManager.findAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getRecentFuelRecords('v1', limit: 5);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (recent) {
          expect(recent.length, 5);
          // Deve retornar os 5 mais recentes
          expect(recent[0].id, 'fuel_0');
          expect(recent[4].id, 'fuel_4');
        },
      );
    });
  });

  group('FuelRepository - Watch Streams', () {
    test('should provide reactive stream of all fuel records', () async {
      // Arrange
      final records = SyncTestFixtures.createFuelRecords(3);
      final stream = Stream.value(records);

      when(() => mockSyncManager.streamAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) => stream);

      // Act
      final resultStream = repository.watchFuelRecords();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<FuelRecordEntity>>>(
            (result) =>
                result.isRight() && result.getOrElse(() => []).length == 3,
          )),
        )),
      );
    });

    test('should provide filtered stream by vehicle', () async {
      // Arrange
      final allRecords = [
        SyncTestFixtures.createFuelRecord(id: 'f1', vehicleId: 'v1'),
        SyncTestFixtures.createFuelRecord(id: 'f3', vehicleId: 'v1',
      ];
      final stream = Stream.value(allRecords);

      when(() => mockSyncManager.streamAll<FuelRecordEntity>('gasometer'))
          .thenAnswer((_) => stream);

      // Act
      final resultStream = repository.watchFuelRecordsByVehicle('v1');

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<FuelRecordEntity>>>(
            (result) {
              final records = result.getOrElse(() => []);
              return result.isRight() &&
                  records.length == 2 &&
                  records.every((r) => r.vehicleId == 'v1');
            },
          )),
        )),
      );
    });

    test('should handle stream not available error', () async {
      // Arrange
      when(() => mockSyncManager.streamAll<FuelRecordEntity>('gasometer'))
          .thenReturn(null);

      // Act
      final resultStream = repository.watchFuelRecords();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<FuelRecordEntity>>>(
            (result) => result.isLeft()),
          )),
        )),
      );
    });
  });
}
      final allRecords = [
