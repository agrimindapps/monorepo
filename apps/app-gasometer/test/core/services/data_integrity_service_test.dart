import 'package:core/core.dart' hide test;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer/core/services/data_integrity_service.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageRepository extends Mock implements ILocalStorageRepository {}

void main() {
  late DataIntegrityService service;
  late MockLocalStorageRepository mockLocalStorage;

  setUp(() {
    mockLocalStorage = MockLocalStorageRepository();
    service = DataIntegrityService(mockLocalStorage);
  });

  group('DataIntegrityService - Vehicle ID Reconciliation', () {
    final vehicleMap = {
      'id': 'local_123',
      'name': 'Civic',
      'brand': 'Honda',
      'model': 'Civic',
      'year': 2020,
      'color': 'Preto',
      'license_plate': 'ABC-1234',
      'type': 'car',
      'supported_fuels': ['gasoline'],
      'current_odometer': 50000.0,
      'is_active': true,
      'metadata': <String, dynamic>{},
      'created_at': DateTime(2024, 1, 1).toIso8601String(),
      'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      'is_dirty': false,
      'is_deleted': false,
      'version': 1,
    };

    test('should skip reconciliation when IDs are equal', () async {
      // Arrange
      const localId = 'same_id';
      const remoteId = 'same_id';

      // Act
      final result = await service.reconcileVehicleId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);
      verifyNever(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: any(named: 'key'),
            box: any(named: 'box'),
          ));
    });

    test('should reconcile vehicle ID successfully when local exists', () async {
      // Arrange
      const localId = 'local_123';
      const remoteId = 'remote_456';

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicleMap));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'vehicles',
          )).thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      when(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data'),
            box: 'vehicles',
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.remove(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => const Right(null));

      // Mock dependent entities (empty)
      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right([]));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await service.reconcileVehicleId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'vehicles',
          )).called(1);

      verify(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data', that: predicate<Map<String, dynamic>>(
              (data) => data['id'] == remoteId,
            )),
            box: 'vehicles',
          )).called(1);

      verify(() => mockLocalStorage.remove(
            key: localId,
            box: 'vehicles',
          )).called(1);
    });

    test('should handle duplicate detection (remote already exists)', () async {
      // Arrange
      const localId = 'local_123';
      const remoteId = 'remote_456';

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicleMap));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicleMap));

      when(() => mockLocalStorage.remove(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await service.reconcileVehicleId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      // Should delete local (keep remote)
      verify(() => mockLocalStorage.remove(
            key: localId,
            box: 'vehicles',
          )).called(1);

      // Should NOT save remote again
      verifyNever(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: any(named: 'key'),
            data: any(named: 'data'),
            box: any(named: 'box'),
          ));
    });

    test('should update dependent FuelRecords when vehicle ID changes', () async {
      // Arrange
      const localId = 'local_123';
      const remoteId = 'remote_456';

      final fuelRecord = {
        'id': 'fuel_1',
        'vehicle_id': localId,
        'fuel_type': 0,
        'liters': 40.0,
        'price_per_liter': 5.5,
        'total_price': 220.0,
        'odometer': 50000.0,
        'date': DateTime(2024, 1, 15).toIso8601String(),
        'full_tank': true,
      };

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicleMap));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'vehicles',
          )).thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      when(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: any(named: 'key'),
            data: any(named: 'data'),
            box: any(named: 'box'),
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.remove(
            key: any(named: 'key'),
            box: any(named: 'box'),
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'fuel_records',
          )).thenAnswer((_) async => Right([fuelRecord]));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await service.reconcileVehicleId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      // Verify FuelRecord was updated
      verify(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: 'fuel_1',
            data: any(named: 'data', that: predicate<Map<String, dynamic>>(
              (data) => data['vehicle_id'] == remoteId,
            )),
            box: 'fuel_records',
          )).called(1);
    });

    test('should handle error when local vehicle not found', () async {
      // Arrange
      const localId = 'local_999';
      const remoteId = 'remote_456';

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'vehicles',
          )).thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      // Act
      final result = await service.reconcileVehicleId(localId, remoteId);

      // Assert
      expect(result.isRight(), true); // Not a critical error - vehicle already removed

      verifyNever(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: any(named: 'key'),
            data: any(named: 'data'),
            box: any(named: 'box'),
          ));
    });
  });

  group('DataIntegrityService - FuelRecord ID Reconciliation', () {
    final fuelRecordMap = {
      'id': 'local_fuel_123',
      'vehicle_id': 'vehicle_1',
      'fuel_type': 0,
      'liters': 45.0,
      'price_per_liter': 5.5,
      'total_price': 247.5,
      'odometer': 55000.0,
      'date': DateTime(2024, 1, 20).toIso8601String(),
      'full_tank': true,
      'created_at': DateTime(2024, 1, 20).toIso8601String(),
      'updated_at': DateTime(2024, 1, 20).toIso8601String(),
      'is_dirty': false,
      'is_deleted': false,
      'version': 1,
    };

    test('should reconcile fuel record ID successfully', () async {
      // Arrange
      const localId = 'local_fuel_123';
      const remoteId = 'remote_fuel_456';

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'fuel_records',
          )).thenAnswer((_) async => Right(fuelRecordMap));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'fuel_records',
          )).thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      when(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data'),
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.remove(
            key: localId,
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await service.reconcileFuelRecordId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data', that: predicate<Map<String, dynamic>>(
              (data) => data['id'] == remoteId && data['total_price'] == 247.5,
            )),
            box: 'fuel_records',
          )).called(1);

      verify(() => mockLocalStorage.remove(
            key: localId,
            box: 'fuel_records',
          )).called(1);
    });

    test('should merge duplicate fuel records (keep most recent)', () async {
      // Arrange
      const localId = 'local_fuel_123';
      const remoteId = 'remote_fuel_456';

      final localRecord = Map<String, dynamic>.from(fuelRecordMap);
      localRecord['updated_at'] = DateTime(2024, 1, 20, 10, 0).toIso8601String();

      final remoteRecord = Map<String, dynamic>.from(fuelRecordMap);
      remoteRecord['id'] = remoteId;
      remoteRecord['updated_at'] = DateTime(2024, 1, 20, 12, 0).toIso8601String(); // Newer

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'fuel_records',
          )).thenAnswer((_) async => Right(localRecord));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'fuel_records',
          )).thenAnswer((_) async => Right(remoteRecord));

      when(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data'),
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.remove(
            key: localId,
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await service.reconcileFuelRecordId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      // Should keep remote (newer) and delete local
      verify(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data', that: predicate<Map<String, dynamic>>(
              (data) {
                final updatedAt = DateTime.parse(data['updated_at'] as String);
                return updatedAt.isAfter(DateTime(2024, 1, 20, 11, 0));
              },
            )),
            box: 'fuel_records',
          )).called(1);

      verify(() => mockLocalStorage.remove(
            key: localId,
            box: 'fuel_records',
          )).called(1);
    });
  });

  group('DataIntegrityService - Maintenance ID Reconciliation', () {
    final maintenanceMap = {
      'id': 'local_maint_123',
      'vehicle_id': 'vehicle_1',
      'type': 'preventive',
      'status': 'completed',
      'title': 'Troca de óleo',
      'description': 'Troca de óleo preventiva',
      'cost': 150.0,
      'service_date': DateTime(2024, 1, 10).toIso8601String(),
      'odometer': 50000.0,
      'photos_paths': <String>[],
      'invoices_paths': <String>[],
      'parts': <String, String>{},
      'metadata': <String, dynamic>{},
      'created_at': DateTime(2024, 1, 10).toIso8601String(),
      'updated_at': DateTime(2024, 1, 10).toIso8601String(),
      'is_dirty': false,
      'is_deleted': false,
      'version': 1,
    };

    test('should reconcile maintenance ID successfully', () async {
      // Arrange
      const localId = 'local_maint_123';
      const remoteId = 'remote_maint_456';

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: localId,
            box: 'maintenance_records',
          )).thenAnswer((_) async => Right(maintenanceMap));

      when(() => mockLocalStorage.get<Map<String, dynamic>>(
            key: remoteId,
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      when(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data'),
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Right(null));

      when(() => mockLocalStorage.remove(
            key: localId,
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await service.reconcileMaintenanceId(localId, remoteId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockLocalStorage.save<Map<String, dynamic>>(
            key: remoteId,
            data: any(named: 'data', that: predicate<Map<String, dynamic>>(
              (data) => data['id'] == remoteId && data['cost'] == 150.0,
            )),
            box: 'maintenance_records',
          )).called(1);

      verify(() => mockLocalStorage.remove(
            key: localId,
            box: 'maintenance_records',
          )).called(1);
    });
  });

  group('DataIntegrityService - Data Integrity Verification', () {
    test('should detect orphaned fuel records', () async {
      // Arrange
      final vehicles = [
        {'id': 'vehicle_1', 'name': 'Civic'},
      ];

      final fuelRecords = [
        {'id': 'fuel_1', 'vehicle_id': 'vehicle_1'}, // OK
        {'id': 'fuel_2', 'vehicle_id': 'vehicle_999'}, // Orphaned!
      ];

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicles));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'fuel_records',
          )).thenAnswer((_) async => Right(fuelRecords));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'maintenance_records',
          )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await service.verifyDataIntegrity();

      // Assert
      expect(result.isRight(), true);

      result.fold(
        (failure) => fail('Should not return failure'),
        (issues) {
          final orphanedFuel = issues['orphaned_fuel_records'] as List;
          expect(orphanedFuel.length, 1);
          expect(orphanedFuel.first, 'fuel_2');
        },
      );
    });

    test('should detect orphaned maintenance records', () async {
      // Arrange
      final vehicles = [
        {'id': 'vehicle_1', 'name': 'Civic'},
      ];

      final maintenances = [
        {'id': 'maint_1', 'vehicle_id': 'vehicle_1'}, // OK
        {'id': 'maint_2', 'vehicle_id': 'vehicle_999'}, // Orphaned!
        {'id': 'maint_3', 'vehicle_id': 'vehicle_888'}, // Orphaned!
      ];

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicles));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'fuel_records',
          )).thenAnswer((_) async => const Right([]));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'maintenance_records',
          )).thenAnswer((_) async => Right(maintenances));

      // Act
      final result = await service.verifyDataIntegrity();

      // Assert
      expect(result.isRight(), true);

      result.fold(
        (failure) => fail('Should not return failure'),
        (issues) {
          final orphanedMaintenances = issues['orphaned_maintenances'] as List;
          expect(orphanedMaintenances.length, 2);
          expect(orphanedMaintenances, containsAll(['maint_2', 'maint_3']));
        },
      );
    });

    test('should pass verification when no issues found', () async {
      // Arrange
      final vehicles = [
        {'id': 'vehicle_1', 'name': 'Civic'},
      ];

      final fuelRecords = [
        {'id': 'fuel_1', 'vehicle_id': 'vehicle_1'},
      ];

      final maintenances = [
        {'id': 'maint_1', 'vehicle_id': 'vehicle_1'},
      ];

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'vehicles',
          )).thenAnswer((_) async => Right(vehicles));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'fuel_records',
          )).thenAnswer((_) async => Right(fuelRecords));

      when(() => mockLocalStorage.getValues<Map<String, dynamic>>(
            box: 'maintenance_records',
          )).thenAnswer((_) async => Right(maintenances));

      // Act
      final result = await service.verifyDataIntegrity();

      // Assert
      expect(result.isRight(), true);

      result.fold(
        (failure) => fail('Should not return failure'),
        (issues) {
          final orphanedFuel = issues['orphaned_fuel_records'] as List;
          final orphanedMaintenances = issues['orphaned_maintenances'] as List;

          expect(orphanedFuel.length, 0);
          expect(orphanedMaintenances.length, 0);
        },
      );
    });
  });
}
