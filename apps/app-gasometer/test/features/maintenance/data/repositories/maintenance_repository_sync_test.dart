import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../lib/core/logging/services/logging_service.dart';
import '../../../../../lib/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../../../../../lib/features/maintenance/domain/entities/maintenance_entity.dart';
import '../../../../helpers/sync_test_helpers.dart';

void main() {
  late MaintenanceRepositoryImpl repository;
  late MockUnifiedSyncManager mockSyncManager;
  late MockLoggingService mockLogger;

  setUp(() {
    mockSyncManager = MockUnifiedSyncManager();
    mockLogger = MockLoggingService();

    repository = MaintenanceRepositoryImpl(
      loggingService: mockLogger,
    );

    SyncTestSetup.registerFallbackValues();
    SyncTestSetup.setupLoggingService(mockLogger);
  });

  group('MaintenanceRepository - Create with Sync', () {
    test('should create maintenance record and sync successfully', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        id: 'maint_1',
        vehicleId: 'vehicle_1',
        type: MaintenanceType.preventive,
        cost: 500.0,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(
            'gasometer',
            any(that: isMaintenanceWithId('maint_1')),
          )).thenAnswer((_) async => const Right('maint_1'));

      // Act
      final result = await repository.addMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (created) {
          expect(created.id, 'maint_1');
          expect(created.type, MaintenanceType.preventive);
          expect(created.cost, 500.0);
        },
      );

      verify(() => mockSyncManager.create<MaintenanceEntity>(
            'gasometer',
            any(that: isMaintenanceWithId('maint_1')),
          )).called(1);
    });

    test('should log comprehensive metadata for maintenance audit trail',
        () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        vehicleId: 'vehicle_1',
        type: MaintenanceType.corrective,
        status: MaintenanceStatus.completed,
        cost: 1200.0,
        odometer: 15000.0,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      await repository.addMaintenanceRecord(maintenance);

      // Assert - Verificar logging detalhado
      verify(() => mockLogger.logOperationStart(
            category: any(named: 'category'),
            operation: any(named: 'operation'),
            message: contains('vehicle_1'),
            metadata: any(
              named: 'metadata',
              that: predicate<Map<String, dynamic>>((m) =>
                  m['vehicle_id'] == 'vehicle_1' &&
                  m['maintenance_type'] == 'Corretiva' &&
                  m['cost'] == '1200.0' &&
                  m['odometer_reading'] == '15000.0' &&
                  m['status'] == 'Concluída'),
            ),
          )).called(1);
    });

    test('should handle high-cost maintenance creation', () async {
      // Arrange - Manutenção de alto custo (>= 1000)
      final maintenance = SyncTestFixtures.createMaintenance(
        cost: 2500.0,
        type: MaintenanceType.emergency,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await repository.addMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.isHighCost, true);
          expect(created.type, MaintenanceType.emergency);
        },
      );
    });

    test('should handle recurring maintenance scheduling', () async {
      // Arrange - Preventive maintenance com próxima data agendada
      final now = DateTime.now();
      final nextService = now.add(const Duration(days: 90));
      final maintenance = SyncTestFixtures.createMaintenance(
        type: MaintenanceType.preventive,
        serviceDate: now,
      ).copyWith(
        nextServiceDate: nextService,
        nextServiceOdometer: 18000.0,
      );

      when(() => mockSyncManager.create<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => Right(maintenance.id));

      // Act
      final result = await repository.addMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (created) {
          expect(created.hasNextService, true);
          expect(created.nextServiceDate, nextService);
          expect(created.nextServiceOdometer, 18000.0);
        },
      );
    });
  });

  group('MaintenanceRepository - Update with Sync', () {
    test('should update maintenance and increment version', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        id: 'maint_1',
        version: 1,
        status: MaintenanceStatus.pending,
      );

      when(() => mockSyncManager.update<MaintenanceEntity>(
            'gasometer',
            'maint_1',
            any(that: isMaintenanceWithId('maint_1')),
          )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.isDirty, true);
          expect(updated.version, 2);
        },
      );

      verify(() => mockSyncManager.update<MaintenanceEntity>(
            'gasometer',
            'maint_1',
            any(that: isDirtyEntity()),
          )).called(1);
    });

    test('should update maintenance status (pending -> completed)', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        id: 'maint_1',
        status: MaintenanceStatus.pending,
      ).copyWith(status: MaintenanceStatus.completed);

      when(() => mockSyncManager.update<MaintenanceEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.isCompleted, true);
          expect(updated.isPending, false);
        },
      );
    });

    test('should preserve workshop info during update', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        workshopName: 'Auto Service Center',
        workshopPhone: '+55 11 1234-5678',
        workshopAddress: 'Rua Example, 123',
      );

      when(() => mockSyncManager.update<MaintenanceEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.hasWorkshopInfo, true);
          expect(updated.workshopName, 'Auto Service Center');
        },
      );
    });

    test('should preserve parts list during update', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        parts: {
          'Oil Filter': 'OF-12345',
          'Air Filter': 'AF-67890',
          'Engine Oil': '5W-30 Synthetic',
        },
      );

      when(() => mockSyncManager.update<MaintenanceEntity>(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.updateMaintenanceRecord(maintenance);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (updated) {
          expect(updated.hasParts, true);
          expect(updated.parts.length, 3);
          expect(updated.parts['Oil Filter'], 'OF-12345');
        },
      );
    });
  });

  group('MaintenanceRepository - Delete with Sync', () {
    test('should delete maintenance and propagate to remote', () async {
      // Arrange
      const maintenanceId = 'maint_1';

      when(() => mockSyncManager.delete<MaintenanceEntity>(
            'gasometer',
            maintenanceId,
          )).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.deleteMaintenanceRecord(maintenanceId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockSyncManager.delete<MaintenanceEntity>(
            'gasometer',
            maintenanceId,
          )).called(1);
    });

    test('should handle delete of non-existent record', () async {
      // Arrange
      const maintenanceId = 'nonexistent';
      const failure = CacheFailure('Maintenance record not found');

      when(() => mockSyncManager.delete<MaintenanceEntity>(any(), any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await repository.deleteMaintenanceRecord(maintenanceId);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('MaintenanceRepository - Read Operations with Sync', () {
    test('should get all maintenance records with background sync', () async {
      // Arrange
      final maintenances = SyncTestFixtures.createMaintenances(4);

      when(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => Right(maintenances));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAllMaintenanceRecords();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (records) {
          expect(records.length, 4);
        },
      );

      verify(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .called(1);
      verify(() =>
              mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .called(1);
    });

    test('should get maintenance records by vehicle with proper sorting',
        () async {
      // Arrange
      final allRecords = [
        SyncTestFixtures.createMaintenance(
          id: 'm1',
          vehicleId: 'v1',
          serviceDate: DateTime(2024, 1, 15),
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm2',
          vehicleId: 'v2',
          serviceDate: DateTime(2024, 1, 10),
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm3',
          vehicleId: 'v1',
          serviceDate: DateTime(2024, 1, 20),
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm4',
          vehicleId: 'v1',
          serviceDate: DateTime(2024, 1, 5),
        ),
      ];

      when(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => Right(allRecords));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getMaintenanceRecordsByVehicle('v1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (filtered) {
          expect(filtered.length, 3);
          expect(filtered.every((r) => r.vehicleId == 'v1'), true);
          // Deve estar ordenado por data (mais recente primeiro)
          expect(filtered[0].id, 'm3'); // 2024-01-20
          expect(filtered[1].id, 'm1'); // 2024-01-15
          expect(filtered[2].id, 'm4'); // 2024-01-05
        },
      );
    });

    test('should get maintenance record by id', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(id: 'maint_1');

      when(() => mockSyncManager.findById<MaintenanceEntity>(
            'gasometer',
            'maint_1',
          )).thenAnswer((_) async => Right(maintenance));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getMaintenanceRecordById('maint_1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (found) {
          expect(found?.id, 'maint_1');
        },
      );
    });
  });

  group('MaintenanceRepository - Upcoming/Overdue Tracking', () {
    test('should identify overdue maintenance', () async {
      // Arrange
      final now = DateTime.now();
      final overdue = SyncTestFixtures.createMaintenance(
        id: 'm1',
        vehicleId: 'v1',
      ).copyWith(
        nextServiceDate: now.subtract(const Duration(days: 10)),
      );

      final upToDate = SyncTestFixtures.createMaintenance(
        id: 'm2',
        vehicleId: 'v1',
      ).copyWith(
        nextServiceDate: now.add(const Duration(days: 30)),
      );

      when(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => Right([overdue, upToDate]));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getMaintenanceRecordsByVehicle('v1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (records) {
          expect(records[0].urgencyLevel, 'overdue');
          expect(records[1].urgencyLevel, 'normal');
        },
      );
    });

    test('should identify urgent maintenance (within 7 days)', () async {
      // Arrange
      final now = DateTime.now();
      final maintenance = SyncTestFixtures.createMaintenance().copyWith(
        nextServiceDate: now.add(const Duration(days: 5)),
      );

      // Assert
      expect(maintenance.urgencyLevel, 'urgent');
      expect(maintenance.urgencyDisplayName, 'Urgente');
    });

    test('should calculate service progress by odometer', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        odometer: 10000.0,
      ).copyWith(
        nextServiceOdometer: 15000.0,
      );

      // Current odometer: 12500 (halfway)
      final progress = maintenance.nextServiceProgress(12500.0);

      // Assert
      expect(progress, closeTo(0.5, 0.01));
    });

    test('should detect service due by odometer', () async {
      // Arrange
      final maintenance = SyncTestFixtures.createMaintenance(
        odometer: 10000.0,
      ).copyWith(
        nextServiceOdometer: 15000.0,
      );

      // Assert
      expect(maintenance.isNextServiceDue(16000.0), true);
      expect(maintenance.isNextServiceDue(14000.0), false);
    });
  });

  group('MaintenanceRepository - Complex Filters', () {
    test('should filter by maintenance type', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createMaintenance(
          id: 'm1',
          type: MaintenanceType.preventive,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm2',
          type: MaintenanceType.corrective,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm3',
          type: MaintenanceType.preventive,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm4',
          type: MaintenanceType.inspection,
        ),
      ];

      when(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAllMaintenanceRecords();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (allRecords) {
          final preventives =
              allRecords.where((r) => r.isPreventive).toList();
          expect(preventives.length, 2);
        },
      );
    });

    test('should filter by maintenance status', () async {
      // Arrange
      final records = [
        SyncTestFixtures.createMaintenance(
          id: 'm1',
          status: MaintenanceStatus.completed,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm2',
          status: MaintenanceStatus.pending,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm3',
          status: MaintenanceStatus.inProgress,
        ),
        SyncTestFixtures.createMaintenance(
          id: 'm4',
          status: MaintenanceStatus.completed,
        ),
      ];

      when(() => mockSyncManager.findAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => Right(records));
      when(() => mockSyncManager.forceSyncEntity<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await repository.getAllMaintenanceRecords();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not fail'),
        (allRecords) {
          final completed = allRecords.where((r) => r.isCompleted).toList();
          expect(completed.length, 2);

          final pending = allRecords.where((r) => r.isPending).toList();
          expect(pending.length, 1);
        },
      );
    });
  });

  group('MaintenanceRepository - Watch Streams', () {
    test('should provide reactive stream of maintenance records', () async {
      // Arrange
      final records = SyncTestFixtures.createMaintenances(3);
      final stream = Stream.value(records);

      when(() => mockSyncManager.streamAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) => stream);

      // Act
      final resultStream = repository.watchMaintenanceRecords();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<MaintenanceEntity>>>(
            (result) =>
                result.isRight() && result.getOrElse(() => []).length == 3,
          ),
        ),
      );
    });

    test('should provide filtered stream by vehicle', () async {
      // Arrange
      final allRecords = [
        SyncTestFixtures.createMaintenance(id: 'm1', vehicleId: 'v1'),
        SyncTestFixtures.createMaintenance(id: 'm2', vehicleId: 'v2'),
        SyncTestFixtures.createMaintenance(id: 'm3', vehicleId: 'v1'),
      ];
      final stream = Stream.value(allRecords);

      when(() => mockSyncManager.streamAll<MaintenanceEntity>('gasometer'))
          .thenAnswer((_) => stream);

      // Act
      final resultStream =
          repository.watchMaintenanceRecordsByVehicle('v1');

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<MaintenanceEntity>>>(
            (result) {
              final records = result.getOrElse(() => []);
              return result.isRight() &&
                  records.length == 2 &&
                  records.every((r) => r.vehicleId == 'v1');
            },
          ),
        ),
      );
    });

    test('should handle stream not available error', () async {
      // Arrange
      when(() => mockSyncManager.streamAll<MaintenanceEntity>('gasometer'))
          .thenReturn(null);

      // Act
      final resultStream = repository.watchMaintenanceRecords();

      // Assert
      await expectLater(
        resultStream,
        emits(
          predicate<Either<Failure, List<MaintenanceEntity>>>(
            (result) => result.isLeft(),
          ),
        ),
      );
    });
  });
}
