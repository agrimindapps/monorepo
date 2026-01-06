import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasometer_drift/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer_drift/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/add_vehicle.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/delete_vehicle.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_all_vehicles.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/search_vehicles.dart';
import 'package:gasometer_drift/features/vehicles/domain/usecases/update_vehicle.dart';
import 'package:mocktail/mocktail.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicleEntity extends Fake implements VehicleEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVehicleEntity());
  });

  late MockVehicleRepository mockRepository;

  final testVehicle = VehicleEntity(
    id: 'test-id',
    name: 'Meu Carro',
    brand: 'Toyota',
    model: 'Corolla',
    year: 2020,
    color: 'Prata',
    licensePlate: 'ABC-1234',
    type: VehicleType.car,
    supportedFuels: const [FuelType.gasoline],
    currentOdometer: 15000.0,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    userId: 'user-001',
    moduleName: 'gasometer',
  );

  setUp(() {
    mockRepository = MockVehicleRepository();
  });

  group('AddVehicle UseCase', () {
    late AddVehicle useCase;

    setUp(() {
      useCase = AddVehicle(mockRepository);
    });

    test('should add vehicle successfully', () async {
      // Arrange
      final params = AddVehicleParams(vehicle: testVehicle);
      when(() => mockRepository.addVehicle(any()))
          .thenAnswer((_) async => Right(testVehicle));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (vehicle) {
          expect(vehicle.id, testVehicle.id);
          expect(vehicle.name, testVehicle.name);
          expect(vehicle.brand, testVehicle.brand);
        },
      );

      verify(() => mockRepository.addVehicle(any())).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final params = AddVehicleParams(vehicle: testVehicle);
      when(() => mockRepository.addVehicle(any()))
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

  group('GetAllVehicles UseCase', () {
    late GetAllVehicles useCase;

    setUp(() {
      useCase = GetAllVehicles(mockRepository);
    });

    test('should get all vehicles successfully', () async {
      // Arrange
      final vehicles = [testVehicle];
      when(() => mockRepository.getAllVehicles())
          .thenAnswer((_) async => Right(vehicles));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list.length, 1);
          expect(list.first.id, testVehicle.id);
        },
      );

      verify(() => mockRepository.getAllVehicles()).called(1);
    });

    test('should return empty list when no vehicles', () async {
      // Arrange
      when(() => mockRepository.getAllVehicles())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) => expect(list.isEmpty, true),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getAllVehicles())
          .thenAnswer((_) async => const Left(CacheFailure('No data')));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('GetVehicleById UseCase', () {
    late GetVehicleById useCase;

    setUp(() {
      useCase = GetVehicleById(mockRepository);
    });

    test('should get vehicle by id successfully', () async {
      // Arrange
      const params = GetVehicleByIdParams(vehicleId: 'test-id');
      when(() => mockRepository.getVehicleById(any()))
          .thenAnswer((_) async => Right(testVehicle));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (vehicle) => expect(vehicle.id, 'test-id'),
      );

      verify(() => mockRepository.getVehicleById('test-id')).called(1);
    });

    test('should return failure when vehicle not found', () async {
      // Arrange
      const params = GetVehicleByIdParams(vehicleId: 'invalid-id');
      when(() => mockRepository.getVehicleById(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Vehicle not found')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('UpdateVehicle UseCase', () {
    late UpdateVehicle useCase;

    setUp(() {
      useCase = UpdateVehicle(mockRepository);
    });

    test('should update vehicle successfully', () async {
      // Arrange
      final updatedVehicle = testVehicle.copyWith(name: 'Nome Atualizado');
      final params = UpdateVehicleParams(vehicle: updatedVehicle);
      when(() => mockRepository.updateVehicle(any()))
          .thenAnswer((_) async => Right(updatedVehicle));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (vehicle) => expect(vehicle.name, 'Nome Atualizado'),
      );

      verify(() => mockRepository.updateVehicle(any())).called(1);
    });

    test('should return failure when update fails', () async {
      // Arrange
      final params = UpdateVehicleParams(vehicle: testVehicle);
      when(() => mockRepository.updateVehicle(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Update failed')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('DeleteVehicle UseCase', () {
    late DeleteVehicle useCase;

    setUp(() {
      useCase = DeleteVehicle(mockRepository);
    });

    test('should delete vehicle successfully', () async {
      // Arrange
      const params = DeleteVehicleParams(vehicleId: 'test-id');
      when(() => mockRepository.deleteVehicle(any()))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.deleteVehicle('test-id')).called(1);
    });

    test('should return failure when delete fails', () async {
      // Arrange
      const params = DeleteVehicleParams(vehicleId: 'test-id');
      when(() => mockRepository.deleteVehicle(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('SearchVehicles UseCase', () {
    late SearchVehicles useCase;

    setUp(() {
      useCase = SearchVehicles(mockRepository);
    });

    test('should search vehicles successfully', () async {
      // Arrange
      const params = SearchVehiclesParams(query: 'Toyota');
      final vehicles = [testVehicle];
      when(() => mockRepository.searchVehicles(any()))
          .thenAnswer((_) async => Right(vehicles));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) {
          expect(list.length, 1);
          expect(list.first.brand, 'Toyota');
        },
      );

      verify(() => mockRepository.searchVehicles('Toyota')).called(1);
    });

    test('should return empty list when no matches', () async {
      // Arrange
      const params = SearchVehiclesParams(query: 'NonExistent');
      when(() => mockRepository.searchVehicles(any()))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should succeed'),
        (list) => expect(list.isEmpty, true),
      );
    });

    test('should return failure when search fails', () async {
      // Arrange
      const params = SearchVehiclesParams(query: 'Test');
      when(() => mockRepository.searchVehicles(any()))
          .thenAnswer((_) async => const Left(CacheFailure('Search error')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
