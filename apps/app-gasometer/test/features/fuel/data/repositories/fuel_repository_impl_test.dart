import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:gasometer/core/error/exceptions.dart';
import 'package:gasometer/core/error/failures.dart';
import 'package:gasometer/features/fuel/data/repositories/fuel_repository_impl.dart';
import 'package:gasometer/features/fuel/data/datasources/fuel_local_data_source.dart';
import 'package:gasometer/features/fuel/data/datasources/fuel_remote_data_source.dart';
import 'package:gasometer/features/fuel/domain/entities/fuel_record_entity.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer/features/auth/domain/repositories/auth_repository.dart';

// Mock classes
class MockFuelLocalDataSource extends Mock implements FuelLocalDataSource {}
class MockFuelRemoteDataSource extends Mock implements FuelRemoteDataSource {}
class MockConnectivity extends Mock implements Connectivity {}
class MockAuthRepository extends Mock implements AuthRepository {}

// Helper function for asserting successful fuel record lists
void expectFuelRecordListResult(Either<Failure, List<FuelRecordEntity>> result, List<FuelRecordEntity> expectedRecords) {
  expect(result, isA<Right<Failure, List<FuelRecordEntity>>>());
  result.fold(
    (failure) => fail('Should not return failure: $failure'),
    (records) {
      expect(records.length, equals(expectedRecords.length));
      for (int i = 0; i < records.length; i++) {
        expect(records[i].id, equals(expectedRecords[i].id));
        expect(records[i].vehicleId, equals(expectedRecords[i].vehicleId));
        expect(records[i].liters, equals(expectedRecords[i].liters));
        expect(records[i].totalPrice, equals(expectedRecords[i].totalPrice));
      }
    },
  );
}

// Helper function for asserting successful fuel record results
void expectFuelRecordResult(Either<Failure, FuelRecordEntity> result, FuelRecordEntity expectedRecord) {
  expect(result, isA<Right<Failure, FuelRecordEntity>>());
  result.fold(
    (failure) => fail('Should not return failure: $failure'),
    (record) {
      expect(record.id, equals(expectedRecord.id));
      expect(record.vehicleId, equals(expectedRecord.vehicleId));
      expect(record.liters, equals(expectedRecord.liters));
      expect(record.totalPrice, equals(expectedRecord.totalPrice));
    },
  );
}

void main() {
  late FuelRepositoryImpl repository;
  late MockFuelLocalDataSource mockLocalDataSource;
  late MockFuelRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;
  late MockAuthRepository mockAuthRepository;

  // Test data
  const testUserId = 'test-user-id';
  const testVehicleId = 'test-vehicle-id';
  const testFuelRecordId = 'test-fuel-record-id';

  final testUserEntity = UserEntity(
    id: testUserId,
    email: 'test@example.com',
    displayName: 'Test User',
    type: UserType.registered,
    isEmailVerified: true,
    createdAt: DateTime.now(),
  );

  final testFuelRecordEntity = FuelRecordEntity(
    id: testFuelRecordId,
    userId: testUserId,
    vehicleId: testVehicleId,
    fuelType: FuelType.gasoline,
    liters: 50.0,
    pricePerLiter: 5.50,
    totalPrice: 275.0,
    odometer: 45000.0,
    date: DateTime(2025, 8, 20),
    gasStationName: 'Posto Shell',
    fullTank: true,
    notes: 'Abastecimento completo',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testFuelRecordsList = [testFuelRecordEntity];

  final testFuelRecordWithConsumption = testFuelRecordEntity.copyWith(
    previousOdometer: 44500.0,
    distanceTraveled: 500.0,
    consumption: 10.0, // 500km / 50L = 10 km/l
  );

  setUp(() {
    mockLocalDataSource = MockFuelLocalDataSource();
    mockRemoteDataSource = MockFuelRemoteDataSource();
    mockConnectivity = MockConnectivity();
    mockAuthRepository = MockAuthRepository();

    repository = FuelRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      authRepository: mockAuthRepository,
    );

    // Set up fallbacks for mocktail
    registerFallbackValue(testFuelRecordEntity);
  });

  group('getAllFuelRecords', () {
    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should return fuel records from remote when successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllFuelRecords(testUserId))
            .thenAnswer((_) async => testFuelRecordsList);
        when(() => mockLocalDataSource.addFuelRecord(any()))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockRemoteDataSource.getAllFuelRecords(testUserId)).called(1);
        verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      });

      test('should fallback to local when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllFuelRecords(testUserId))
            .thenThrow(const ServerException('Remote error'));
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => testFuelRecordsList);

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockRemoteDataSource.getAllFuelRecords(testUserId)).called(1);
        verify(() => mockLocalDataSource.getAllFuelRecords()).called(1);
      });

      test('should fallback to local when user is null', () async {
        // Arrange
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => testFuelRecordsList);

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockLocalDataSource.getAllFuelRecords()).called(1);
        verifyNever(() => mockRemoteDataSource.getAllFuelRecords(any()));
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        // Mock auth repository for offline scenarios - not called but prevents null errors
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
      });

      test('should return fuel records from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => testFuelRecordsList);

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockLocalDataSource.getAllFuelRecords()).called(1);
        verifyNever(() => mockRemoteDataSource.getAllFuelRecords(any()));
      });
    });

    group('error handling', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
      });

      test('should return CacheFailure when CacheException is thrown', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenThrow(const CacheException('Cache error'));

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expect(result, equals(const Left(CacheFailure('Cache error'))));
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
        when(() => mockRemoteDataSource.getAllFuelRecords(testUserId))
            .thenThrow(const ServerException('Server error'));
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getAllFuelRecords();

        // Assert
        expect(result, isA<Left<Failure, List<FuelRecordEntity>>>());
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (records) => fail('Should not return records'),
        );
      });
    });
  });

  group('getFuelRecordsByVehicle', () {
    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should return fuel records from remote and cache them', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFuelRecordsByVehicle(testUserId, testVehicleId))
            .thenAnswer((_) async => testFuelRecordsList);
        when(() => mockLocalDataSource.addFuelRecord(any()))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        final result = await repository.getFuelRecordsByVehicle(testVehicleId);

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockRemoteDataSource.getFuelRecordsByVehicle(testUserId, testVehicleId)).called(1);
        verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      });

      test('should fallback to local when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFuelRecordsByVehicle(testUserId, testVehicleId))
            .thenThrow(const ServerException('Remote error'));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => testFuelRecordsList);

        // Act
        final result = await repository.getFuelRecordsByVehicle(testVehicleId);

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockRemoteDataSource.getFuelRecordsByVehicle(testUserId, testVehicleId)).called(1);
        verify(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId)).called(1);
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
      });

      test('should return fuel records from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => testFuelRecordsList);

        // Act
        final result = await repository.getFuelRecordsByVehicle(testVehicleId);

        // Assert
        expectFuelRecordListResult(result, testFuelRecordsList);
        verify(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId)).called(1);
        verifyNever(() => mockRemoteDataSource.getFuelRecordsByVehicle(any(), any()));
      });
    });
  });

  group('getFuelRecordById', () {
    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should return fuel record from remote and cache it', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFuelRecordById(testUserId, testFuelRecordId))
            .thenAnswer((_) async => testFuelRecordEntity);
        when(() => mockLocalDataSource.addFuelRecord(any()))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        final result = await repository.getFuelRecordById(testFuelRecordId);

        // Assert
        expect(result, isA<Right<Failure, FuelRecordEntity?>>());
        result.fold(
          (failure) => fail('Should not return failure: $failure'),
          (record) {
            expect(record, isNotNull);
            expect(record!.id, equals(testFuelRecordId));
          },
        );
        verify(() => mockRemoteDataSource.getFuelRecordById(testUserId, testFuelRecordId)).called(1);
        verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      });

      test('should return null when record not found remotely and locally', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFuelRecordById(testUserId, testFuelRecordId))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getFuelRecordById(testFuelRecordId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getFuelRecordById(testFuelRecordId);

        // Assert
        expect(result, isA<Right<Failure, FuelRecordEntity?>>());
        result.fold(
          (failure) => fail('Should not return failure: $failure'),
          (record) => expect(record, isNull),
        );
      });

      test('should fallback to local when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFuelRecordById(testUserId, testFuelRecordId))
            .thenThrow(const ServerException('Remote error'));
        when(() => mockLocalDataSource.getFuelRecordById(testFuelRecordId))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        final result = await repository.getFuelRecordById(testFuelRecordId);

        // Assert
        expect(result, isA<Right<Failure, FuelRecordEntity?>>());
        result.fold(
          (failure) => fail('Should not return failure: $failure'),
          (record) {
            expect(record, isNotNull);
            expect(record!.id, equals(testFuelRecordId));
          },
        );
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
      });

      test('should return fuel record from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getFuelRecordById(testFuelRecordId))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        final result = await repository.getFuelRecordById(testFuelRecordId);

        // Assert
        expect(result, isA<Right<Failure, FuelRecordEntity?>>());
        result.fold(
          (failure) => fail('Should not return failure: $failure'),
          (record) {
            expect(record, isNotNull);
            expect(record!.id, equals(testFuelRecordId));
          },
        );
        verify(() => mockLocalDataSource.getFuelRecordById(testFuelRecordId)).called(1);
        verifyNever(() => mockRemoteDataSource.getFuelRecordById(any(), any()));
      });
    });
  });

  group('addFuelRecord', () {
    test('should save fuel record locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.addFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);
      when(() => mockRemoteDataSource.addFuelRecord(testUserId, any()))
          .thenAnswer((_) async => testFuelRecordEntity);

      // Act
      final result = await repository.addFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      verify(() => mockRemoteDataSource.addFuelRecord(testUserId, testFuelRecordEntity)).called(1);
    });

    test('should save fuel record locally only when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.addFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);

      // Act
      final result = await repository.addFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      verifyNever(() => mockRemoteDataSource.addFuelRecord(any(), any()));
    });

    test('should continue if remote save fails but local succeeds', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.addFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);
      when(() => mockRemoteDataSource.addFuelRecord(testUserId, any()))
          .thenThrow(const ServerException('Remote save failed'));

      // Act
      final result = await repository.addFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.addFuelRecord(testFuelRecordEntity)).called(1);
      verify(() => mockRemoteDataSource.addFuelRecord(testUserId, testFuelRecordEntity)).called(1);
    });

    test('should return CacheFailure when local save fails', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.addFuelRecord(any()))
          .thenThrow(const CacheException('Local save error'));

      // Act
      final result = await repository.addFuelRecord(testFuelRecordEntity);

      // Assert
      expect(result, equals(const Left(CacheFailure('Local save error'))));
    });
  });

  group('updateFuelRecord', () {
    test('should update fuel record locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.updateFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);
      when(() => mockRemoteDataSource.updateFuelRecord(testUserId, any()))
          .thenAnswer((_) async => testFuelRecordEntity);

      // Act
      final result = await repository.updateFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.updateFuelRecord(testFuelRecordEntity)).called(1);
      verify(() => mockRemoteDataSource.updateFuelRecord(testUserId, testFuelRecordEntity)).called(1);
    });

    test('should update fuel record locally only when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.updateFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);

      // Act
      final result = await repository.updateFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.updateFuelRecord(testFuelRecordEntity)).called(1);
      verifyNever(() => mockRemoteDataSource.updateFuelRecord(any(), any()));
    });

    test('should continue if remote update fails but local succeeds', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.updateFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);
      when(() => mockRemoteDataSource.updateFuelRecord(testUserId, any()))
          .thenThrow(const ServerException('Remote update failed'));

      // Act
      final result = await repository.updateFuelRecord(testFuelRecordEntity);

      // Assert
      expectFuelRecordResult(result, testFuelRecordEntity);
      verify(() => mockLocalDataSource.updateFuelRecord(testFuelRecordEntity)).called(1);
      verify(() => mockRemoteDataSource.updateFuelRecord(testUserId, testFuelRecordEntity)).called(1);
    });
  });

  group('deleteFuelRecord', () {
    test('should delete fuel record locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.deleteFuelRecord(testUserId, testFuelRecordId))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteFuelRecord(testFuelRecordId);

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId)).called(1);
      verify(() => mockRemoteDataSource.deleteFuelRecord(testUserId, testFuelRecordId)).called(1);
    });

    test('should delete fuel record locally only when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteFuelRecord(testFuelRecordId);

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId)).called(1);
      verifyNever(() => mockRemoteDataSource.deleteFuelRecord(any(), any()));
    });

    test('should continue if remote delete fails but local succeeds', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.deleteFuelRecord(testUserId, testFuelRecordId))
          .thenThrow(const ServerException('Remote delete failed'));

      // Act
      final result = await repository.deleteFuelRecord(testFuelRecordId);

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.deleteFuelRecord(testFuelRecordId)).called(1);
      verify(() => mockRemoteDataSource.deleteFuelRecord(testUserId, testFuelRecordId)).called(1);
    });
  });

  group('searchFuelRecords', () {
    const testQuery = 'Shell';
    final testSearchResults = [testFuelRecordEntity];

    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should search fuel records from remote when connected', () async {
        // Arrange
        when(() => mockRemoteDataSource.searchFuelRecords(testUserId, testQuery))
            .thenAnswer((_) async => testSearchResults);

        // Act
        final result = await repository.searchFuelRecords(testQuery);

        // Assert
        expectFuelRecordListResult(result, testSearchResults);
        verify(() => mockRemoteDataSource.searchFuelRecords(testUserId, testQuery)).called(1);
      });

      test('should fallback to local search when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.searchFuelRecords(testUserId, testQuery))
            .thenThrow(const ServerException('Remote search error'));
        when(() => mockLocalDataSource.searchFuelRecords(testQuery))
            .thenAnswer((_) async => testSearchResults);

        // Act
        final result = await repository.searchFuelRecords(testQuery);

        // Assert
        expectFuelRecordListResult(result, testSearchResults);
        verify(() => mockRemoteDataSource.searchFuelRecords(testUserId, testQuery)).called(1);
        verify(() => mockLocalDataSource.searchFuelRecords(testQuery)).called(1);
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
      });

      test('should search fuel records from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.searchFuelRecords(testQuery))
            .thenAnswer((_) async => testSearchResults);

        // Act
        final result = await repository.searchFuelRecords(testQuery);

        // Assert
        expectFuelRecordListResult(result, testSearchResults);
        verify(() => mockLocalDataSource.searchFuelRecords(testQuery)).called(1);
        verifyNever(() => mockRemoteDataSource.searchFuelRecords(any(), any()));
      });

      test('should return empty list when no records match search', () async {
        // Arrange
        when(() => mockLocalDataSource.searchFuelRecords(testQuery))
            .thenAnswer((_) async => const []);

        // Act
        final result = await repository.searchFuelRecords(testQuery);

        // Assert
        expectFuelRecordListResult(result, const []);
      });
    });
  });

  group('watchFuelRecords', () {
    test('should return stream of fuel records when connected', () async {
      // Arrange
      final streamController = StreamController<List<FuelRecordEntity>>();
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockRemoteDataSource.watchFuelRecords(testUserId))
          .thenAnswer((_) => streamController.stream);

      // Act
      final stream = repository.watchFuelRecords();
      streamController.add(testFuelRecordsList);

      // Assert
      await expectLater(
        stream,
        emits(isA<Right<Failure, List<FuelRecordEntity>>>()),
      );

      streamController.close();
    });

    test('should return stream of fuel records from local when offline', () async {
      // Arrange
      final streamController = StreamController<List<FuelRecordEntity>>();
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.watchFuelRecords())
          .thenAnswer((_) => streamController.stream);

      // Act
      final stream = repository.watchFuelRecords();
      streamController.add(testFuelRecordsList);

      // Assert
      await expectLater(
        stream,
        emits(isA<Right<Failure, List<FuelRecordEntity>>>()),
      );

      streamController.close();
    });
  });

  group('watchFuelRecordsByVehicle', () {
    test('should return stream of fuel records for specific vehicle when connected', () async {
      // Arrange
      final streamController = StreamController<List<FuelRecordEntity>>();
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockRemoteDataSource.watchFuelRecordsByVehicle(testUserId, testVehicleId))
          .thenAnswer((_) => streamController.stream);

      // Act
      final stream = repository.watchFuelRecordsByVehicle(testVehicleId);
      streamController.add(testFuelRecordsList);

      // Assert
      await expectLater(
        stream,
        emits(isA<Right<Failure, List<FuelRecordEntity>>>()),
      );

      streamController.close();
    });

    test('should return stream of fuel records from local when offline', () async {
      // Arrange
      final streamController = StreamController<List<FuelRecordEntity>>();
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.watchFuelRecordsByVehicle(testVehicleId))
          .thenAnswer((_) => streamController.stream);

      // Act
      final stream = repository.watchFuelRecordsByVehicle(testVehicleId);
      streamController.add(testFuelRecordsList);

      // Assert
      await expectLater(
        stream,
        emits(isA<Right<Failure, List<FuelRecordEntity>>>()),
      );

      streamController.close();
    });
  });

  group('analytics methods', () {
    group('getAverageConsumption', () {
      test('should return 0.0 when there are less than 2 records', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => [testFuelRecordEntity]);

        // Act
        final result = await repository.getAverageConsumption(testVehicleId);

        // Assert
        expect(result, equals(const Right(0.0)));
      });

      test('should return 0.0 when no records have consumption data', () async {
        // Arrange
        final recordsWithoutConsumption = [
          testFuelRecordEntity,
          testFuelRecordEntity.copyWith(id: 'id2'),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithoutConsumption);

        // Act
        final result = await repository.getAverageConsumption(testVehicleId);

        // Assert
        expect(result, equals(const Right(0.0)));
      });

      test('should calculate average consumption correctly', () async {
        // Arrange
        final recordsWithConsumption = [
          testFuelRecordWithConsumption.copyWith(consumption: 10.0),
          testFuelRecordWithConsumption.copyWith(id: 'id2', consumption: 12.0),
          testFuelRecordWithConsumption.copyWith(id: 'id3', consumption: 8.0),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithConsumption);

        // Act
        final result = await repository.getAverageConsumption(testVehicleId);

        // Assert
        expect(result, equals(const Right(10.0))); // (10 + 12 + 8) / 3 = 10
      });

      test('should return failure when getFuelRecordsByVehicle fails', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenThrow(const CacheException('Cache error'));

        // Act
        final result = await repository.getAverageConsumption(testVehicleId);

        // Assert
        expect(result, equals(const Left(CacheFailure('Cache error'))));
      });

      test('should handle unexpected errors in calculation', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getAverageConsumption(testVehicleId);

        // Assert
        expect(result, isA<Left<Failure, double>>());
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (consumption) => fail('Should not return consumption'),
        );
      });
    });

    group('getTotalSpent', () {
      test('should calculate total spent correctly', () async {
        // Arrange
        final recordsWithDifferentPrices = [
          testFuelRecordEntity.copyWith(totalPrice: 100.0),
          testFuelRecordEntity.copyWith(id: 'id2', totalPrice: 150.0),
          testFuelRecordEntity.copyWith(id: 'id3', totalPrice: 75.0),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithDifferentPrices);

        // Act
        final result = await repository.getTotalSpent(testVehicleId);

        // Assert
        expect(result, equals(const Right(325.0))); // 100 + 150 + 75
      });

      test('should filter by start date correctly', () async {
        // Arrange
        final startDate = DateTime(2025, 8, 15);
        final recordsWithDifferentDates = [
          testFuelRecordEntity.copyWith(
            date: DateTime(2025, 8, 10), // Before start date
            totalPrice: 100.0,
          ),
          testFuelRecordEntity.copyWith(
            id: 'id2',
            date: DateTime(2025, 8, 20), // After start date
            totalPrice: 150.0,
          ),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithDifferentDates);

        // Act
        final result = await repository.getTotalSpent(testVehicleId, startDate: startDate);

        // Assert
        expect(result, equals(const Right(150.0))); // Only second record
      });

      test('should filter by end date correctly', () async {
        // Arrange
        final endDate = DateTime(2025, 8, 15);
        final recordsWithDifferentDates = [
          testFuelRecordEntity.copyWith(
            date: DateTime(2025, 8, 10), // Before end date
            totalPrice: 100.0,
          ),
          testFuelRecordEntity.copyWith(
            id: 'id2',
            date: DateTime(2025, 8, 20), // After end date
            totalPrice: 150.0,
          ),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithDifferentDates);

        // Act
        final result = await repository.getTotalSpent(testVehicleId, endDate: endDate);

        // Assert
        expect(result, equals(const Right(100.0))); // Only first record
      });

      test('should filter by date range correctly', () async {
        // Arrange
        final startDate = DateTime(2025, 8, 15);
        final endDate = DateTime(2025, 8, 25);
        final recordsWithDifferentDates = [
          testFuelRecordEntity.copyWith(
            date: DateTime(2025, 8, 10), // Before start date
            totalPrice: 100.0,
          ),
          testFuelRecordEntity.copyWith(
            id: 'id2',
            date: DateTime(2025, 8, 20), // Within range
            totalPrice: 150.0,
          ),
          testFuelRecordEntity.copyWith(
            id: 'id3',
            date: DateTime(2025, 8, 30), // After end date
            totalPrice: 75.0,
          ),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithDifferentDates);

        // Act
        final result = await repository.getTotalSpent(testVehicleId, 
            startDate: startDate, endDate: endDate);

        // Assert
        expect(result, equals(const Right(150.0))); // Only middle record
      });

      test('should return 0.0 when no records in date range', () async {
        // Arrange
        final startDate = DateTime(2025, 9, 1);
        final endDate = DateTime(2025, 9, 30);
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => [testFuelRecordEntity]);

        // Act
        final result = await repository.getTotalSpent(testVehicleId, 
            startDate: startDate, endDate: endDate);

        // Assert
        expect(result, equals(const Right(0.0)));
      });
    });

    group('getRecentFuelRecords', () {
      test('should return recent fuel records sorted by date', () async {
        // Arrange
        final recordsWithDifferentDates = [
          testFuelRecordEntity.copyWith(
            id: 'old',
            date: DateTime(2025, 8, 10),
          ),
          testFuelRecordEntity.copyWith(
            id: 'newest',
            date: DateTime(2025, 8, 25),
          ),
          testFuelRecordEntity.copyWith(
            id: 'middle',
            date: DateTime(2025, 8, 20),
          ),
        ];
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => recordsWithDifferentDates);

        // Act
        final result = await repository.getRecentFuelRecords(testVehicleId);

        // Assert
        expect(result, isA<Right<Failure, List<FuelRecordEntity>>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (records) {
            expect(records.length, equals(3));
            expect(records.first.id, equals('newest')); // Most recent first
            expect(records[1].id, equals('middle'));
            expect(records.last.id, equals('old'));
          },
        );
      });

      test('should limit results to specified limit', () async {
        // Arrange
        final manyRecords = List.generate(15, (index) => 
          testFuelRecordEntity.copyWith(
            id: 'record_$index',
            date: DateTime(2025, 8, index + 1),
          ),
        );
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => manyRecords);

        // Act
        final result = await repository.getRecentFuelRecords(testVehicleId, limit: 5);

        // Assert
        expect(result, isA<Right<Failure, List<FuelRecordEntity>>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (records) {
            expect(records.length, equals(5));
            expect(records.first.id, equals('record_14')); // Most recent
          },
        );
      });

      test('should use default limit of 10', () async {
        // Arrange
        final manyRecords = List.generate(15, (index) => 
          testFuelRecordEntity.copyWith(
            id: 'record_$index',
            date: DateTime(2025, 8, index + 1),
          ),
        );
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getFuelRecordsByVehicle(testVehicleId))
            .thenAnswer((_) async => manyRecords);

        // Act
        final result = await repository.getRecentFuelRecords(testVehicleId);

        // Assert
        expect(result, isA<Right<Failure, List<FuelRecordEntity>>>());
        result.fold(
          (failure) => fail('Should not return failure'),
          (records) => expect(records.length, equals(10)),
        );
      });
    });
  });

  group('private helper methods', () {
    group('_isConnected', () {
      test('should return true when connected to wifi', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => []);

        // Act - Test indirectly through getAllFuelRecords behavior
        await repository.getAllFuelRecords();

        // Assert - Verify auth repository is called (only when connected)
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should return false when no connection', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllFuelRecords();

        // Assert - Verify no remote calls are made when offline
        verifyNever(() => mockRemoteDataSource.getAllFuelRecords(any()));
      });
    });

    group('_getCurrentUserId', () {
      test('should return user id when user is authenticated', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
        when(() => mockRemoteDataSource.getAllFuelRecords(testUserId))
            .thenAnswer((_) async => []);
        when(() => mockLocalDataSource.addFuelRecord(any()))
            .thenAnswer((_) async => testFuelRecordEntity);

        // Act
        await repository.getAllFuelRecords();

        // Assert - Test indirectly by verifying correct userId is used
        verify(() => mockRemoteDataSource.getAllFuelRecords(testUserId)).called(1);
      });

      test('should return null when user is not authenticated', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(AuthenticationFailure('Not authenticated')));
        when(() => mockLocalDataSource.getAllFuelRecords())
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllFuelRecords();

        // Assert - Verify no remote calls are made
        verifyNever(() => mockRemoteDataSource.getAllFuelRecords(any()));
      });
    });
  });

  group('edge cases', () {
    test('should handle empty fuel record list', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.getAllFuelRecords())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getAllFuelRecords();

      // Assert
      expectFuelRecordListResult(result, const []);
    });

    test('should handle null values gracefully in search', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.searchFuelRecords(''))
          .thenAnswer((_) async => testFuelRecordsList);

      // Act
      final result = await repository.searchFuelRecords('');

      // Assert
      expectFuelRecordListResult(result, testFuelRecordsList);
    });

    test('should handle multiple connectivity results', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockRemoteDataSource.getAllFuelRecords(testUserId))
          .thenAnswer((_) async => testFuelRecordsList);
      when(() => mockLocalDataSource.addFuelRecord(any()))
          .thenAnswer((_) async => testFuelRecordEntity);

      // Act
      final result = await repository.getAllFuelRecords();

      // Assert
      expectFuelRecordListResult(result, testFuelRecordsList);
      verify(() => mockRemoteDataSource.getAllFuelRecords(testUserId)).called(1);
    });

    test('should handle large datasets efficiently', () async {
      // Arrange
      final largeFuelRecordsList = List.generate(1000, (index) => 
        testFuelRecordEntity.copyWith(id: 'record_$index'),
      );
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));
      when(() => mockLocalDataSource.getAllFuelRecords())
          .thenAnswer((_) async => largeFuelRecordsList);

      // Act
      final result = await repository.getAllFuelRecords();

      // Assert
      expect(result, isA<Right<Failure, List<FuelRecordEntity>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (records) => expect(records.length, equals(1000)),
      );
    });
  });
}