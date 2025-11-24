import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/fuel/domain/services/fuel_supply_id_reconciliation_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageRepository extends Mock
    implements ILocalStorageRepository {}

void main() {
  late FuelSupplyIdReconciliationService service;
  late MockLocalStorageRepository mockLocalStorage;

  setUp(() {
    mockLocalStorage = MockLocalStorageRepository();
    service = FuelSupplyIdReconciliationService(mockLocalStorage);
  });

  group('FuelSupplyIdReconciliationService', () {
    const localId = 'local_fuel_123';
    const remoteId = 'firebase_fuel_789';

    final testFuelMap = {
      'id': localId,
      'vehicleId': 'vehicle-001',
      'liters': 40.0,
      'totalPrice': 220.0,
      'odometer': 10000.0,
      'date': DateTime(2024, 1, 15).millisecondsSinceEpoch,
      'updatedAt': DateTime(2024, 1, 15).millisecondsSinceEpoch,
      'userId': 'user-001',
      'isDirty': true,
      'isDeleted': false,
    };

    group('reconcileId', () {
      test('should return Right when localId equals remoteId', () async {
        // Act
        final result = await service.reconcileId(localId, localId);

        // Assert
        expect(result.isRight(), true);
        verifyNever(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: any(named: 'key'),
              box: any(named: 'box'),
            ));
      });

      test(
          'should successfully reconcile when local record exists and no duplicate',
          () async {
        // Arrange
        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(testFuelMap));

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Not found')));

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
        final result = await service.reconcileId(localId, remoteId);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).called(1);
        verify(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).called(1);
        verify(() => mockLocalStorage.save<Map<String, dynamic>>(
              key: remoteId,
              data: any(named: 'data'),
              box: 'fuel_records',
            )).called(1);
        verify(() => mockLocalStorage.remove(
              key: localId,
              box: 'fuel_records',
            )).called(1);
      });

      test('should handle case when local record not found', () async {
        // Arrange
        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Not found')));

        // Act
        final result = await service.reconcileId(localId, remoteId);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).called(1);
        verifyNever(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            ));
      });

      test('should merge duplicates keeping most recent updatedAt', () async {
        // Arrange
        final olderFuelMap = Map<String, dynamic>.from(testFuelMap)
          ..['updatedAt'] = DateTime(2024, 1, 10).millisecondsSinceEpoch;

        final newerFuelMap = Map<String, dynamic>.from(testFuelMap)
          ..['id'] = remoteId
          ..['updatedAt'] = DateTime(2024, 1, 20).millisecondsSinceEpoch
          ..['liters'] = 50.0;

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(olderFuelMap));

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(newerFuelMap));

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
        final result = await service.reconcileId(localId, remoteId);

        // Assert
        expect(result.isRight(), true);

        // Verify that newer record was saved
        final captured =
            verify(() => mockLocalStorage.save<Map<String, dynamic>>(
                  key: remoteId,
                  data: captureAny(named: 'data'),
                  box: 'fuel_records',
                )).captured;

        expect(captured.length, 1);
        final savedMap = captured.first as Map<String, dynamic>;
        expect(savedMap['liters'], 50.0); // Newer value preserved
        expect(savedMap['updatedAt'],
            DateTime(2024, 1, 20).millisecondsSinceEpoch);
      });

      test('should handle error when saving reconciled record fails', () async {
        // Arrange
        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(testFuelMap));

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Not found')));

        when(() => mockLocalStorage.save<Map<String, dynamic>>(
              key: remoteId,
              data: any(named: 'data'),
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Save failed')));

        // Act
        final result = await service.reconcileId(localId, remoteId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.message, contains('Save failed')),
          (_) => fail('Should return failure'),
        );
      });

      test('should handle error when deleting old record fails', () async {
        // Arrange
        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(testFuelMap));

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Not found')));

        when(() => mockLocalStorage.save<Map<String, dynamic>>(
              key: remoteId,
              data: any(named: 'data'),
              box: 'fuel_records',
            )).thenAnswer((_) async => const Right(null));

        when(() => mockLocalStorage.remove(
                  key: localId,
                  box: 'fuel_records',
                ))
            .thenAnswer((_) async => const Left(CacheFailure('Delete failed')));

        // Act
        final result = await service.reconcileId(localId, remoteId);

        // Assert - Should still succeed as old record deletion is not critical
        expect(result.isRight(), true);
      });

      test('should preserve all fuel data during reconciliation', () async {
        // Arrange
        final detailedFuelMap = {
          'id': localId,
          'vehicleId': 'vehicle-001',
          'liters': 42.5,
          'totalPrice': 233.75,
          'odometer': 10543.7,
          'date': DateTime(2024, 1, 15).millisecondsSinceEpoch,
          'fuelType': 0,
          'gasStationName': 'Shell',
          'notes': 'Full tank',
          'fullTank': true,
          'updatedAt': DateTime(2024, 1, 15).millisecondsSinceEpoch,
          'userId': 'user-001',
          'isDirty': true,
        };

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenAnswer((_) async => Right(detailedFuelMap));

        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: remoteId,
              box: 'fuel_records',
            )).thenAnswer((_) async => const Left(CacheFailure('Not found')));

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
        await service.reconcileId(localId, remoteId);

        // Assert - Verify all data preserved
        final captured =
            verify(() => mockLocalStorage.save<Map<String, dynamic>>(
                  key: remoteId,
                  data: captureAny(named: 'data'),
                  box: 'fuel_records',
                )).captured;

        final savedMap = captured.first as Map<String, dynamic>;
        expect(savedMap['liters'], 42.5);
        expect(savedMap['totalPrice'], 233.75);
        expect(savedMap['odometer'], 10543.7);
        expect(savedMap['gasStationName'], 'Shell');
        expect(savedMap['notes'], 'Full tank');
        expect(savedMap['fullTank'], true);
        expect(savedMap['id'], remoteId); // ID updated
      });

      test('should handle exception during reconciliation', () async {
        // Arrange
        when(() => mockLocalStorage.get<Map<String, dynamic>>(
              key: localId,
              box: 'fuel_records',
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await service.reconcileId(localId, remoteId);

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('getPendingCount', () {
      test('should return 0 as reconciliation is automatic during sync',
          () async {
        // Act
        final result = await service.getPendingCount();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should return success'),
          (count) => expect(count, 0),
        );
      });
    });
  });
}
