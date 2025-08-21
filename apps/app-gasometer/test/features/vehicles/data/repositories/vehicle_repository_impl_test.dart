import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:gasometer/core/error/exceptions.dart';
import 'package:gasometer/core/error/failures.dart';
import 'package:gasometer/features/vehicles/data/datasources/vehicle_local_data_source.dart';
import 'package:gasometer/features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import 'package:gasometer/features/vehicles/data/models/vehicle_model.dart';
import 'package:gasometer/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:gasometer/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:gasometer/features/auth/domain/entities/user_entity.dart';
import 'package:gasometer/features/auth/domain/repositories/auth_repository.dart';

// Mock classes
class MockVehicleLocalDataSource extends Mock implements VehicleLocalDataSource {}
class MockVehicleRemoteDataSource extends Mock implements VehicleRemoteDataSource {}
class MockConnectivity extends Mock implements Connectivity {}
class MockAuthRepository extends Mock implements AuthRepository {}

// Helper function for asserting successful vehicle lists
void expectVehicleListResult(Either<Failure, List<VehicleEntity>> result, List<VehicleEntity> expectedVehicles) {
  expect(result, isA<Right<Failure, List<VehicleEntity>>>());
  result.fold(
    (failure) => fail('Should not return failure: $failure'),
    (vehicles) {
      expect(vehicles.length, equals(expectedVehicles.length));
      for (int i = 0; i < vehicles.length; i++) {
        expect(vehicles[i].id, equals(expectedVehicles[i].id));
        expect(vehicles[i].brand, equals(expectedVehicles[i].brand));
        expect(vehicles[i].model, equals(expectedVehicles[i].model));
      }
    },
  );
}

// Helper function for asserting successful vehicle results
void expectVehicleResult(Either<Failure, VehicleEntity> result, VehicleEntity expectedVehicle) {
  expect(result, isA<Right<Failure, VehicleEntity>>());
  result.fold(
    (failure) => fail('Should not return failure: $failure'),
    (vehicle) {
      expect(vehicle.id, equals(expectedVehicle.id));
      expect(vehicle.brand, equals(expectedVehicle.brand));
      expect(vehicle.model, equals(expectedVehicle.model));
    },
  );
}

void main() {
  late VehicleRepositoryImpl repository;
  late MockVehicleLocalDataSource mockLocalDataSource;
  late MockVehicleRemoteDataSource mockRemoteDataSource;
  late MockConnectivity mockConnectivity;
  late MockAuthRepository mockAuthRepository;

  // Test data
  const testUserId = 'test-user-id';
  const testVehicleId = 'test-vehicle-id';

  final testUserEntity = UserEntity(
    id: testUserId,
    email: 'test@example.com',
    displayName: 'Test User',
    type: UserType.registered,
    isEmailVerified: true,
    createdAt: DateTime.now(),
  );

  final testVehicleModel = VehicleModel.create(
    id: testVehicleId,
    userId: testUserId,
    marca: 'Honda',
    modelo: 'Civic',
    ano: 2020,
    placa: 'ABC-1234',
    odometroInicial: 0.0,
    combustivel: 0,
    cor: 'Preto',
    odometroAtual: 10000.0,
  );

  final testVehicleEntity = testVehicleModel.toEntity();

  final testVehiclesList = [testVehicleModel];
  final testVehiclesEntitiesList = [testVehicleEntity];

  setUp(() {
    mockLocalDataSource = MockVehicleLocalDataSource();
    mockRemoteDataSource = MockVehicleRemoteDataSource();
    mockConnectivity = MockConnectivity();
    mockAuthRepository = MockAuthRepository();

    repository = VehicleRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      authRepository: mockAuthRepository,
    );

    // Set up fallbacks for mocktail
    registerFallbackValue(testVehicleModel);
  });

  group('getAllVehicles', () {
    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should return vehicles from remote when successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllVehicles(testUserId))
            .thenAnswer((_) async => testVehiclesList);
        when(() => mockLocalDataSource.clearAllVehicles())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveVehicle(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expectVehicleListResult(result, testVehiclesEntitiesList);
        verify(() => mockRemoteDataSource.getAllVehicles(testUserId)).called(1);
        verify(() => mockLocalDataSource.clearAllVehicles()).called(1);
        verify(() => mockLocalDataSource.saveVehicle(testVehicleModel)).called(1);
      });

      test('should fallback to local when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllVehicles(testUserId))
            .thenThrow(const ServerException('Remote error'));
        when(() => mockLocalDataSource.getAllVehicles())
            .thenAnswer((_) async => testVehiclesList);

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expectVehicleListResult(result, testVehiclesEntitiesList);
        verify(() => mockRemoteDataSource.getAllVehicles(testUserId)).called(1);
        verify(() => mockLocalDataSource.getAllVehicles()).called(1);
      });

      test('should fallback to local when user is null', () async {
        // Arrange
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        when(() => mockLocalDataSource.getAllVehicles())
            .thenAnswer((_) async => testVehiclesList);

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expectVehicleListResult(result, testVehiclesEntitiesList);
        verify(() => mockLocalDataSource.getAllVehicles()).called(1);
        verifyNever(() => mockRemoteDataSource.getAllVehicles(any()));
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
      });

      test('should return vehicles from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllVehicles())
            .thenAnswer((_) async => testVehiclesList);

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expectVehicleListResult(result, testVehiclesEntitiesList);
        verify(() => mockLocalDataSource.getAllVehicles()).called(1);
        verifyNever(() => mockRemoteDataSource.getAllVehicles(any()));
      });
    });

    group('error handling', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
      });

      test('should return CacheFailure when CacheException is thrown', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllVehicles())
            .thenThrow(const CacheException('Cache error'));

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expect(result, equals(const Left(CacheFailure('Cache error'))));
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
        when(() => mockRemoteDataSource.getAllVehicles(testUserId))
            .thenThrow(const ServerException('Server error'));
        when(() => mockLocalDataSource.getAllVehicles())
            .thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expect(result, equals(const Left(ServerFailure('Server error'))));
      });

      test('should return NetworkFailure when NetworkException is thrown', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllVehicles())
            .thenThrow(const NetworkException('Network error'));

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expect(result, equals(const Left(NetworkFailure('Network error'))));
      });

      test('should return UnexpectedFailure when unexpected error occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllVehicles())
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.getAllVehicles();

        // Assert
        expect(result, isA<Left<Failure, List<VehicleEntity>>>());
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (vehicles) => fail('Should not return vehicles'),
        );
      });
    });
  });

  group('getVehicleById', () {
    group('when connected', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
      });

      test('should return vehicle from remote and cache it', () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId))
            .thenAnswer((_) async => testVehicleModel);
        when(() => mockLocalDataSource.saveVehicle(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getVehicleById(testVehicleId);

        // Assert
        expectVehicleResult(result, testVehicleEntity);
        verify(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId)).called(1);
        verify(() => mockLocalDataSource.saveVehicle(testVehicleModel)).called(1);
      });

      test('should fallback to local when remote returns null', () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getVehicleById(testVehicleId))
            .thenAnswer((_) async => testVehicleModel);

        // Act
        final result = await repository.getVehicleById(testVehicleId);

        // Assert
        expectVehicleResult(result, testVehicleEntity);
        verify(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId)).called(1);
        verify(() => mockLocalDataSource.getVehicleById(testVehicleId)).called(1);
      });

      test('should fallback to local when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId))
            .thenThrow(const ServerException('Remote error'));
        when(() => mockLocalDataSource.getVehicleById(testVehicleId))
            .thenAnswer((_) async => testVehicleModel);

        // Act
        final result = await repository.getVehicleById(testVehicleId);

        // Assert
        expectVehicleResult(result, testVehicleEntity);
        verify(() => mockRemoteDataSource.getVehicleById(testUserId, testVehicleId)).called(1);
        verify(() => mockLocalDataSource.getVehicleById(testVehicleId)).called(1);
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
      });

      test('should return vehicle from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getVehicleById(testVehicleId))
            .thenAnswer((_) async => testVehicleModel);

        // Act
        final result = await repository.getVehicleById(testVehicleId);

        // Assert
        expectVehicleResult(result, testVehicleEntity);
        verify(() => mockLocalDataSource.getVehicleById(testVehicleId)).called(1);
        verifyNever(() => mockRemoteDataSource.getVehicleById(any(), any()));
      });

      test('should return VehicleNotFoundFailure when vehicle not found', () async {
        // Arrange
        when(() => mockLocalDataSource.getVehicleById(testVehicleId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getVehicleById(testVehicleId);

        // Assert
        expect(result, equals(const Left(VehicleNotFoundFailure('Vehicle not found'))));
      });
    });
  });

  group('addVehicle', () {
    test('should save vehicle locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.saveVehicle(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.saveVehicle(testUserId, any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.addVehicle(testVehicleEntity);

      // Assert
      expect(result, isA<Right<Failure, VehicleEntity>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (vehicle) => expect(vehicle.id, equals(testVehicleEntity.id)),
      );
      verify(() => mockLocalDataSource.saveVehicle(any())).called(1);
      verify(() => mockRemoteDataSource.saveVehicle(testUserId, any())).called(1);
    });

    test('should save vehicle locally only when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.saveVehicle(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.addVehicle(testVehicleEntity);

      // Assert
      expect(result, isA<Right<Failure, VehicleEntity>>());
      verify(() => mockLocalDataSource.saveVehicle(any())).called(1);
      verifyNever(() => mockRemoteDataSource.saveVehicle(any(), any()));
    });

    test('should continue if remote save fails but local succeeds', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.saveVehicle(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.saveVehicle(testUserId, any()))
          .thenThrow(const ServerException('Remote save failed'));

      // Act
      final result = await repository.addVehicle(testVehicleEntity);

      // Assert
      expect(result, isA<Right<Failure, VehicleEntity>>());
      verify(() => mockLocalDataSource.saveVehicle(any())).called(1);
      verify(() => mockRemoteDataSource.saveVehicle(testUserId, any())).called(1);
    });

    test('should return ValidationFailure when ValidationException is thrown', () async {
      // Arrange
      when(() => mockLocalDataSource.saveVehicle(any()))
          .thenThrow(const ValidationException('Validation error'));

      // Act
      final result = await repository.addVehicle(testVehicleEntity);

      // Assert
      expect(result, equals(const Left(ValidationFailure('Validation error'))));
    });
  });

  group('updateVehicle', () {
    test('should update vehicle locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.updateVehicle(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.updateVehicle(testUserId, any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateVehicle(testVehicleEntity);

      // Assert
      expect(result, isA<Right<Failure, VehicleEntity>>());
      verify(() => mockLocalDataSource.updateVehicle(any())).called(1);
      verify(() => mockRemoteDataSource.updateVehicle(testUserId, any())).called(1);
    });

    test('should return VehicleNotFoundFailure when VehicleNotFoundException is thrown', () async {
      // Arrange
      when(() => mockLocalDataSource.updateVehicle(any()))
          .thenThrow(const VehicleNotFoundException('Vehicle not found'));

      // Act
      final result = await repository.updateVehicle(testVehicleEntity);

      // Assert
      expect(result, equals(const Left(VehicleNotFoundFailure('Vehicle not found'))));
    });
  });

  group('deleteVehicle', () {
    test('should delete vehicle locally and remotely when connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.deleteVehicle(testVehicleId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.deleteVehicle(testUserId, testVehicleId))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteVehicle(testVehicleId);

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.deleteVehicle(testVehicleId)).called(1);
      verify(() => mockRemoteDataSource.deleteVehicle(testUserId, testVehicleId)).called(1);
    });

    test('should delete vehicle locally only when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.deleteVehicle(testVehicleId))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteVehicle(testVehicleId);

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.deleteVehicle(testVehicleId)).called(1);
      verifyNever(() => mockRemoteDataSource.deleteVehicle(any(), any()));
    });
  });

  group('syncVehicles', () {
    test('should sync vehicles when connected and authenticated', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);
      when(() => mockRemoteDataSource.syncVehicles(testUserId, testVehiclesList))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result, equals(const Right(unit)));
      verify(() => mockLocalDataSource.getAllVehicles()).called(1);
      verify(() => mockRemoteDataSource.syncVehicles(testUserId, testVehiclesList)).called(1);
    });

    test('should return NetworkFailure when offline', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result, equals(const Left(NetworkFailure('No internet connection'))));
      verifyNever(() => mockLocalDataSource.getAllVehicles());
      verifyNever(() => mockRemoteDataSource.syncVehicles(any(), any()));
    });

    test('should return AuthenticationFailure when user not authenticated', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result, equals(const Left(AuthenticationFailure('User not authenticated'))));
    });

    test('should return SyncFailure when SyncException is thrown', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);
      when(() => mockRemoteDataSource.syncVehicles(testUserId, testVehiclesList))
          .thenThrow(const SyncException('Sync failed'));

      // Act
      final result = await repository.syncVehicles();

      // Assert
      expect(result, equals(const Left(SyncFailure('Sync failed'))));
    });
  });

  group('searchVehicles', () {
    final testSearchResults = [testVehicleEntity];

    test('should search vehicles by name', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('honda');

      // Assert
      expectVehicleListResult(result, testSearchResults);
    });

    test('should search vehicles by brand', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('Honda');

      // Assert
      expectVehicleListResult(result, testSearchResults);
    });

    test('should search vehicles by model', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('civic');

      // Assert
      expectVehicleListResult(result, testSearchResults);
    });

    test('should search vehicles by year', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('2020');

      // Assert
      expectVehicleListResult(result, testSearchResults);
    });

    test('should return empty list when no vehicles match search', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('toyota');

      // Assert
      expectVehicleListResult(result, const []);
    });

    test('should return failure when getAllVehicles fails', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenThrow(const CacheException('Cache error'));

      // Act
      final result = await repository.searchVehicles('honda');

      // Assert
      expect(result, equals(const Left(CacheFailure('Cache error'))));
    });

    test('should handle case insensitive search', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('HONDA');

      // Assert
      expectVehicleListResult(result, testSearchResults);
    });

    test('should return UnexpectedFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Mock getAllVehicles to simulate the private method behavior
      // Since we can't directly test private methods, we'll simulate an error 
      // in the searchVehicles method itself
      
      // This will test the catch-all exception handler in searchVehicles
      final repositoryWithMockFailure = VehicleRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
        connectivity: mockConnectivity,
        authRepository: mockAuthRepository,
      );

      // Force an error by returning a malformed response that will cause
      // an exception during the search processing
      when(() => mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repositoryWithMockFailure.searchVehicles('honda');

      // Assert
      expect(result, isA<Left<Failure, List<VehicleEntity>>>());
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (vehicles) => fail('Should not return vehicles'),
      );
    });
  });

  group('private helper methods', () {
    group('_isConnected', () {
      test('should return true when connected to wifi', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        await repository.getAllVehicles();

        // Assert - We test this indirectly by verifying remote calls are made
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should return false when no connection', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);
        when(() => mockLocalDataSource.getAllVehicles())
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllVehicles();

        // Assert - We test this indirectly by verifying no auth calls are made
        verifyNever(() => mockAuthRepository.getCurrentUser());
      });
    });

    group('_getCurrentUserId', () {
      test('should return user id when user is authenticated', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUserEntity));
        when(() => mockRemoteDataSource.getAllVehicles(testUserId))
            .thenAnswer((_) async => []);
        when(() => mockLocalDataSource.clearAllVehicles())
            .thenAnswer((_) async {});

        // Act
        await repository.getAllVehicles();

        // Assert - We test this indirectly by verifying the correct userId is used
        verify(() => mockRemoteDataSource.getAllVehicles(testUserId)).called(1);
      });

      test('should return null when user is not authenticated', () async {
        // Arrange
        when(() => mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(AuthenticationFailure('Not authenticated')));
        when(() => mockLocalDataSource.getAllVehicles())
            .thenAnswer((_) async => []);

        // Act
        await repository.getAllVehicles();

        // Assert - We test this indirectly by verifying no remote calls are made
        verifyNever(() => mockRemoteDataSource.getAllVehicles(any()));
      });
    });
  });

  group('edge cases', () {
    test('should handle empty vehicle list', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getAllVehicles();

      // Assert
      expectVehicleListResult(result, const []);
    });

    test('should handle null values gracefully in search', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalDataSource.getAllVehicles())
          .thenAnswer((_) async => testVehiclesList);

      // Act
      final result = await repository.searchVehicles('');

      // Assert - Empty search should return all vehicles
      expectVehicleListResult(result, testVehiclesEntitiesList);
    });

    test('should handle multiple connectivity results', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(testUserEntity));
      when(() => mockRemoteDataSource.getAllVehicles(testUserId))
          .thenAnswer((_) async => testVehiclesList);
      when(() => mockLocalDataSource.clearAllVehicles())
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveVehicle(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.getAllVehicles();

      // Assert
      expectVehicleListResult(result, testVehiclesEntitiesList);
      verify(() => mockRemoteDataSource.getAllVehicles(testUserId)).called(1);
    });
  });
}