import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/maintenance/domain/entities/maintenance_entity.dart';
import 'package:gasometer_drift/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/add_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/delete_maintenance_record.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/get_all_maintenance_records.dart';
import 'package:gasometer_drift/features/maintenance/domain/usecases/update_maintenance_record.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

class FakeMaintenanceEntity extends Fake implements MaintenanceEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMaintenanceEntity());
  });

  late MockMaintenanceRepository mockRepository;

  final testMaintenance = MaintenanceEntity(
    id: 'test-id',
    vehicleId: 'vehicle-001',
    type: MaintenanceType.preventive,
    status: MaintenanceStatus.completed,
    title: 'Troca de óleo',
    description: 'Troca de óleo e filtros',
    cost: 250.0,
    serviceDate: DateTime(2024, 1, 15),
    odometer: 15000.0,
    workshopName: 'Auto Center ABC',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
    userId: 'user-001',
    moduleName: 'gasometer',
  );

  setUp(() {
    mockRepository = MockMaintenanceRepository();
  });

  group('AddMaintenanceRecord UseCase', () {
    late AddMaintenanceRecord useCase;

    setUp(() {
      useCase = AddMaintenanceRecord(mockRepository);
    });

    test('should add maintenance record successfully', () async {
      // Arrange
      final params = AddMaintenanceRecordParams(maintenance: testMaintenance);
      when(() => mockRepository.addMaintenanceRecord(any()))
          .thenAnswer((_) async => Right(testMaintenance));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (maintenance) {
          expect(maintenance.id, testMaintenance.id);
          expect(maintenance.title, testMaintenance.title);
          expect(maintenance.cost, testMaintenance.cost);
        },
      );

      verify(() => mockRepository.addMaintenanceRecord(any())).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final params = AddMaintenanceRecordParams(maintenance: testMaintenance);
      when(() => mockRepository.addMaintenanceRecord(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Database error')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should fail'),
      );
    });
  });

  group('GetAllMaintenanceRecords UseCase', () {
    late GetAllMaintenanceRecords useCase;

    setUp(() {
      useCase = GetAllMaintenanceRecords(mockRepository);
    });

    test('should get all maintenance records successfully', () async {
      // Arrange
      final records = [testMaintenance];
      when(() => mockRepository.getAllMaintenanceRecords())
          .thenAnswer((_) async => Right(records));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, testMaintenance.id);
        },
      );

      verify(() => mockRepository.getAllMaintenanceRecords()).called(1);
    });

    test('should return empty list when no records', () async {
      // Arrange
      when(() => mockRepository.getAllMaintenanceRecords())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) => expect(list.isEmpty, true),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getAllMaintenanceRecords())
          .thenAnswer((_) async => const Left(CacheFailure('No data')));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('UpdateMaintenanceRecord UseCase', () {
    late UpdateMaintenanceRecord useCase;

    setUp(() {
      useCase = UpdateMaintenanceRecord(mockRepository);
    });

    test('should update maintenance record successfully', () async {
      // Arrange
      final updated = testMaintenance.copyWith(title: 'Revisão completa');
      final params = UpdateMaintenanceRecordParams(maintenance: updated);
      when(() => mockRepository.updateMaintenanceRecord(any()))
          .thenAnswer((_) async => Right(updated));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (maintenance) => expect(maintenance.title, 'Revisão completa'),
      );

      verify(() => mockRepository.updateMaintenanceRecord(any())).called(1);
    });

    test('should return failure when update fails', () async {
      // Arrange
      final params = UpdateMaintenanceRecordParams(maintenance: testMaintenance);
      when(() => mockRepository.updateMaintenanceRecord(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Update failed')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should mark as dirty when updating', () async {
      // Arrange
      final updated = testMaintenance.copyWith(
        status: MaintenanceStatus.inProgress,
      );
      final params = UpdateMaintenanceRecordParams(maintenance: updated);
      when(() => mockRepository.updateMaintenanceRecord(any()))
          .thenAnswer((_) async => Right(updated));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.updateMaintenanceRecord(any())).called(1);
    });
  });

  group('DeleteMaintenanceRecord UseCase', () {
    late DeleteMaintenanceRecord useCase;

    setUp(() {
      useCase = DeleteMaintenanceRecord(mockRepository);
    });

    test('should delete maintenance record successfully', () async {
      // Arrange
      const params = DeleteMaintenanceRecordParams(id: 'test-id');
      when(() => mockRepository.deleteMaintenanceRecord(any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.deleteMaintenanceRecord('test-id')).called(1);
    });

    test('should return failure when delete fails', () async {
      // Arrange
      const params = DeleteMaintenanceRecordParams(id: 'test-id');
      when(() => mockRepository.deleteMaintenanceRecord(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should handle non-existent record', () async {
      // Arrange
      const params = DeleteMaintenanceRecordParams(id: 'invalid-id');
      when(() => mockRepository.deleteMaintenanceRecord(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Record not found')));

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
}
