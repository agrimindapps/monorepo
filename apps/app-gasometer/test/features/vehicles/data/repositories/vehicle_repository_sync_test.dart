import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../lib/core/logging/services/logging_service.dart';
import '../../../../../lib/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import '../../../../../lib/features/vehicles/domain/entities/vehicle_entity.dart';
import '../../../../helpers/sync_test_helpers.dart';

void main() {
  late VehicleRepositoryImpl repository;
  late MockUnifiedSyncManager mockSyncManager;
  late MockLoggingService mockLogger;

  setUp(() {
    mockSyncManager = MockUnifiedSyncManager();
    mockLogger = MockLoggingService();

    repository = VehicleRepositoryImpl(
      loggingService: mockLogger,
    );

    // Registrar fallback values
    SyncTestSetup.registerFallbackValues();

    // Setup padrão de logging
    SyncTestSetup.setupLoggingService(mockLogger);
  });

  group('VehicleRepository - Create with Sync', () {
    test('should create vehicle and sync successfully (online)', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        name: 'My Car',
      );

      when(() => mockSyncManager.create<VehicleEntity>(
            'gasometer',
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right('vehicle_1'));

      // Act
      final result = await repository.addVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (createdVehicle) {
          expect(createdVehicle.id, 'vehicle_1');
          expect(createdVehicle.name, 'My Car');
        },
      );

      verify(() => mockSyncManager.create<VehicleEntity>(
            'gasometer',
            any(that: isVehicleWithId('vehicle_1')),
          )).called(1);

      verify(() => mockLogger.logOperationSuccess(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message'),
            metadata: any(named: 'metadata'),
          )).called(1);
    });

    test('should handle sync failure and return error', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();
      const failure = CacheFailure('Network error');

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.addVehicle(vehicle);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, 'Network error');
        },
        (_) => fail('Should return failure'),
      );

      verify(() => mockLogger.logOperationError(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(named: 'message'),
            error: any(named: 'error'),
            metadata: any(named: 'metadata'),
          )).called(1);
    });

    test('should handle unexpected exceptions during create', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.addVehicle(vehicle);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<UnexpectedFailure>());
          expect(error.message, contains('Unexpected error'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should log operation metadata on successful create', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(
        name: 'Tesla Model 3',
        brand: 'Tesla',
        model: 'Model 3',
      );

      when(() => mockSyncManager.create<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => Right(vehicle.id));

      // Act
      await repository.addVehicle(vehicle);

      // Assert
      verify(() => mockLogger.logOperationStart(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(
              named: 'message',
              that: predicate<String>((m) => m.contains('Tesla Model 3')),
            ),
            metadata: any(
              named: 'metadata',
              that: predicate<Map<String, dynamic>>((m) =>
                  m['vehicle_name'] == 'Tesla Model 3' &&
                  m['vehicle_brand'] == 'Tesla' &&
                  m['vehicle_model'] == 'Model 3'),
            ),
          )).called(1);
    });
  });

  group('VehicleRepository - Update with Sync', () {
    test('should update vehicle and sync changes', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(
        id: 'vehicle_1',
        name: 'Updated Name',
        version: 1,
      );

      when(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(that: isVehicleWithId('vehicle_1')),
          )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (updatedVehicle) {
          expect(updatedVehicle.name, 'Updated Name');
          expect(updatedVehicle.isDirty, true); // Marcado como dirty
          expect(updatedVehicle.version, 2); // Version incrementada
        },
      );

      verify(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(that: isDirtyEntity()),
          )).called(1);

      verify(() => mockSyncManager.update<VehicleEntity>(
            'gasometer',
            'vehicle_1',
            any(that: isEntityWithVersion(2)),
          )).called(1);
    });

    test('should handle update failure gracefully', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle();
      const failure = ValidationFailure('Invalid vehicle data');

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.updateVehicle(vehicle);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, 'Invalid vehicle data');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should preserve vehicle metadata during update', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(
        metadata: {'customField': 'customValue'},
      );

      when(() => mockSyncManager.update<VehicleEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateVehicle(vehicle);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.metadata['customField'], 'customValue');
        },
      );
    });
  });

  group('VehicleRepository - Delete with Sync', () {
    test('should delete vehicle and propagate deletion', () async {
      // Arrange
      const vehicleId = 'vehicle_1';

      when(() => mockSyncManager.delete<VehicleEntity>('gasometer', vehicleId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.deleteVehicle(vehicleId);

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => throw Exception()), unit);

      verify(() => mockSyncManager.delete<VehicleEntity>(
            'gasometer',
            vehicleId,
          )).called(1);

      verify(() => mockLogger.logOperationSuccess(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(
              named: 'message',
              that: predicate<String>((m) => m.contains('deletion completed')),
            ),
            metadata: any(named: 'metadata'),
          )).called(1);
    });

    test('should handle delete failure', () async {
      // Arrange
      const vehicleId = 'vehicle_1';
      const failure = CacheFailure('Vehicle not found');

      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.deleteVehicle(vehicleId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<CacheFailure>());
          expect(error.message, 'Vehicle not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should log deletion metadata', () async {
      // Arrange
      const vehicleId = 'vehicle_123';

      when(() => mockSyncManager.delete<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      await repository.deleteVehicle(vehicleId);

      // Assert
      verify(() => mockLogger.logOperationStart(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: any(
              named: 'message',
              that: predicate<String>((m) => m.contains('vehicle_123')),
            ),
            metadata: any(
              named: 'metadata',
              that: predicate<Map<String, dynamic>>(
                (m) => m['vehicle_id'] == 'vehicle_123',
              ),
            ),
          )).called(1);
    });
  });

  group('VehicleRepository - Read Operations with Sync', () {
    test('should get all vehicles and trigger background sync', () async {
      // Arrange
      final vehicles = SyncTestFixtures.createVehicles(3);

      when(() => mockSyncManager.findAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => Right(vehicles));

      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAllVehicles();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (vehicleList) {
          expect(vehicleList.length, 3);
          expect(vehicleList[0].id, 'vehicle_1');
          expect(vehicleList[1].id, 'vehicle_2');
          expect(vehicleList[2].id, 'vehicle_3');
        },
      );

      verify(() => mockSyncManager.findAll<VehicleEntity>('gasometer'))
          .called(1);
      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(1);
    });

    test('should get vehicle by id and trigger background sync', () async {
      // Arrange
      final vehicle = SyncTestFixtures.createVehicle(id: 'vehicle_1');

      when(() => mockSyncManager.findById<VehicleEntity>(
            'gasometer',
            'vehicle_1',
          )).thenAnswer((_) async => Right(vehicle));

      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getVehicleById('vehicle_1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (foundVehicle) {
          expect(foundVehicle.id, 'vehicle_1');
        },
      );

      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(1);
    });

    test('should return validation failure when vehicle not found', () async {
      // Arrange
      when(() => mockSyncManager.findById<VehicleEntity>(any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await repository.getVehicleById('nonexistent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<ValidationFailure>());
          expect(error.message, 'Vehicle not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle read errors gracefully', () async {
      // Arrange
      const failure = CacheFailure('Database error');

      when(() => mockSyncManager.findAll<VehicleEntity>(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.getAllVehicles();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('VehicleRepository - Manual Sync', () {
    test('should force sync vehicles successfully', () async {
      // Arrange
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result.isRight(), true);
      expect(result.getOrElse(() => throw Exception()), unit);

      verify(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .called(1);
    });

    test('should handle sync failure', () async {
      // Arrange
      const failure = CacheFailure('Sync failed');

      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('VehicleRepository - Search with Sync', () {
    test('should search vehicles locally', () async {
      // Arrange
      final vehicles = [
        SyncTestFixtures.createVehicle(
          id: 'v1',
          name: 'Tesla Model 3',
          brand: 'Tesla',
        ),
        SyncTestFixtures.createVehicle(
          id: 'v2',
          name: 'Ford Mustang',
          brand: 'Ford',
        ),
        SyncTestFixtures.createVehicle(
          id: 'v3',
          name: 'Tesla Model S',
          brand: 'Tesla',
        ),
      ];

      when(() => mockSyncManager.findAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => Right(vehicles));
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.searchVehicles('tesla');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (searchResults) {
          expect(searchResults.length, 2);
          expect(searchResults.every((v) => v.brand == 'Tesla'), true);
        },
      );
    });

    test('should search by multiple fields', () async {
      // Arrange
      final vehicles = [
        SyncTestFixtures.createVehicle(
          id: 'v1',
          name: 'My Car',
          brand: 'Tesla',
          year: 2020,
        ),
        SyncTestFixtures.createVehicle(
          id: 'v2',
          name: 'Work Car',
          brand: 'Ford',
          year: 2020,
        ),
      ];

      when(() => mockSyncManager.findAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => Right(vehicles));
      when(() => mockSyncManager.forceSyncEntity<VehicleEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act - Search by year
      final result = await repository.searchVehicles('2020');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (searchResults) {
          expect(searchResults.length, 2);
        },
      );
    });
  });

  group('VehicleRepository - Watch Stream', () {
    test('should provide reactive stream of vehicles', () async {
      // Arrange
      final vehicles = SyncTestFixtures.createVehicles(2);
      final stream = Stream.value(vehicles);

      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenAnswer((_) => stream);

      // Act
      final resultStream = repository.watchVehicles();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<VehicleEntity>>>(
            (result) =>
                result.isRight() &&
                result.getOrElse(() => []).length == 2,
          ),
        ),
      );
    });

    test('should handle stream errors', () async {
      // Arrange
      when(() => mockSyncManager.streamAll<VehicleEntity>('gasometer'))
          .thenReturn(null);

      // Act
      final resultStream = repository.watchVehicles();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<VehicleEntity>>>(
            (result) => result.isLeft(),
          ),
        ),
      );
    });
  });
}
