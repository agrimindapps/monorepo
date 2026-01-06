import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/fuel/domain/services/fuel_crud_service.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/add_fuel_record.dart';
import 'package:gasometer_drift/features/fuel/domain/usecases/delete_fuel_record.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_utils/test_helpers.dart';
import '../../helpers/fake_data.dart';
import '../../helpers/mock_factories.dart';

void main() {
  late FuelCrudService service;
  late MockAddFuelRecord mockAddFuelRecord;
  late MockUpdateFuelRecord mockUpdateFuelRecord;
  late MockDeleteFuelRecord mockDeleteFuelRecord;

  setUpAll(() {
    MockFactories.registerFallbackValues();
  });

  setUp(() {
    mockAddFuelRecord = MockAddFuelRecord();
    mockUpdateFuelRecord = MockUpdateFuelRecord();
    mockDeleteFuelRecord = MockDeleteFuelRecord();

    service = FuelCrudService(
      addFuelRecord: mockAddFuelRecord,
      updateFuelRecord: mockUpdateFuelRecord,
      deleteFuelRecord: mockDeleteFuelRecord,
    );
  });

  group('FuelCrudService - addFuel', () {
    test('should add fuel record successfully', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord();
      when(() => mockAddFuelRecord(any()))
          .thenAnswer((_) async => Right(fuelRecord));

      // Act
      final result = await service.addFuel(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      final addedRecord = result.expectRight();
      expect(addedRecord.id, fuelRecord.id);
      expect(addedRecord.vehicleId, fuelRecord.vehicleId);
      expect(addedRecord.liters, fuelRecord.liters);

      verify(() => mockAddFuelRecord(any())).called(1);
    });

    test('should return ValidationFailure when use case fails validation',
        () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord(liters: -1.0);
      final failure = FakeData.validationFailure('Liters must be positive');

      when(() => mockAddFuelRecord(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await service.addFuel(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<ValidationFailure>());
      expect(error.message, 'Liters must be positive');
    });

    test('should return CacheFailure when use case fails with cache error',
        () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord();
      final failure = FakeData.cacheFailure('Database not available');

      when(() => mockAddFuelRecord(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await service.addFuel(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<CacheFailure>());
      expect(error.message, contains('Database not available'));
    });

    test('should handle exception and return CacheFailure', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord();

      when(() => mockAddFuelRecord(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await service.addFuel(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<CacheFailure>());
      expect(error.message, contains('Failed to add fuel record'));
    });

    test('should pass correct parameters to use case', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord(
        id: 'fuel-123',
        vehicleId: 'vehicle-456',
        liters: 45.5,
      );

      when(() => mockAddFuelRecord(any()))
          .thenAnswer((_) async => Right(fuelRecord));

      // Act
      await service.addFuel(fuelRecord);

      // Assert
      final captured = verify(
        () => mockAddFuelRecord(captureAny()),
      ).captured;

      expect(captured.length, 1);
      final params = captured.first as AddFuelRecordParams;
      expect(params.fuelRecord.id, 'fuel-123');
      expect(params.fuelRecord.vehicleId, 'vehicle-456');
      expect(params.fuelRecord.liters, 45.5);
    });
  });

  group('FuelCrudService - updateFuel', () {
    test('should update fuel record successfully', () async {
      // Arrange
      final updatedRecord = FakeData.fuelRecord(id: 'fuel-001', liters: 42.0);

      when(() => mockUpdateFuelRecord(any()))
          .thenAnswer((_) async => Right(updatedRecord));

      // Act
      final result = await service.updateFuel(updatedRecord);

      // Assert
      expect(result.isRight(), true);
      final record = result.expectRight();
      expect(record.id, 'fuel-001');
      expect(record.liters, 42.0);

      verify(() => mockUpdateFuelRecord(any())).called(1);
    });

    test('should return ValidationFailure when record not found', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord(id: 'non-existent');
      final failure = FakeData.validationFailure('Record not found');

      when(() => mockUpdateFuelRecord(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await service.updateFuel(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<ValidationFailure>());
      expect(error.message, 'Record not found');
    });

    test('should handle exception during update', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord();

      when(() => mockUpdateFuelRecord(any()))
          .thenThrow(Exception('Database locked'));

      // Act
      final result = await service.updateFuel(fuelRecord);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<CacheFailure>());
      expect(error.message, contains('Failed to update fuel record'));
    });

    test('should preserve record ID during update', () async {
      // Arrange
      const recordId = 'fuel-preserve-id';
      final fuelRecord = FakeData.fuelRecord(id: recordId);

      when(() => mockUpdateFuelRecord(any()))
          .thenAnswer((_) async => Right(fuelRecord));

      // Act
      final result = await service.updateFuel(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      final record = result.expectRight();
      expect(record.id, recordId);
    });
  });

  group('FuelCrudService - deleteFuel', () {
    test('should delete fuel record successfully', () async {
      // Arrange
      const recordId = 'fuel-to-delete';

      when(() => mockDeleteFuelRecord(any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await service.deleteFuel(recordId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockDeleteFuelRecord(any())).called(1);
    });

    test('should return ValidationFailure when record not found', () async {
      // Arrange
      const recordId = 'non-existent';
      final failure = FakeData.validationFailure('Record not found');

      when(() => mockDeleteFuelRecord(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await service.deleteFuel(recordId);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<ValidationFailure>());
    });

    test('should handle exception during delete', () async {
      // Arrange
      const recordId = 'fuel-123';

      when(() => mockDeleteFuelRecord(any()))
          .thenThrow(Exception('Cascade delete failed'));

      // Act
      final result = await service.deleteFuel(recordId);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<CacheFailure>());
      expect(error.message, contains('Failed to delete fuel record'));
    });

    test('should pass correct ID to delete use case', () async {
      // Arrange
      const recordId = 'fuel-specific-id';

      when(() => mockDeleteFuelRecord(any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      await service.deleteFuel(recordId);

      // Assert
      final captured = verify(
        () => mockDeleteFuelRecord(captureAny()),
      ).captured;

      expect(captured.length, 1);
      final params = captured.first as DeleteFuelRecordParams;
      expect(params.id, recordId);
    });

    test('should handle empty ID gracefully', () async {
      // Arrange
      const recordId = '';
      final failure = FakeData.validationFailure('ID cannot be empty');

      when(() => mockDeleteFuelRecord(any()))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await service.deleteFuel(recordId);

      // Assert
      expect(result.isLeft(), true);
      final error = result.expectLeft();
      expect(error, isA<ValidationFailure>());
    });
  });

  group('FuelCrudService - edge cases', () {
    test('should handle null values in optional fields', () async {
      // Arrange
      final fuelRecord = FakeData.fuelRecord(
        gasStationName: null,
        notes: null,
        previousOdometer: null,
      );

      when(() => mockAddFuelRecord(any()))
          .thenAnswer((_) async => Right(fuelRecord));

      // Act
      final result = await service.addFuel(fuelRecord);

      // Assert
      expect(result.isRight(), true);
      final record = result.expectRight();
      expect(record.gasStationName, null);
      expect(record.notes, null);
      expect(record.previousOdometer, null);
    });

    test('should handle concurrent operations', () async {
      // Arrange
      final records = FakeData.fuelRecords(count: 3);

      when(() => mockAddFuelRecord(any())).thenAnswer((invocation) async {
        final params = invocation.positionalArguments[0] as AddFuelRecordParams;
        await TestHelpers.waitForAsync(milliseconds: 10);
        return Right(params.fuelRecord);
      });

      // Act
      final futures = records.map((record) => service.addFuel(record));
      final results = await Future.wait(futures);

      // Assert
      expect(results.length, 3);
      for (final result in results) {
        expect(result.isRight(), true);
      }
      verify(() => mockAddFuelRecord(any())).called(3);
    });
  });
}
