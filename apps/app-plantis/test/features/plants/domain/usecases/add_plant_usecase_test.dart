import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/plants/domain/usecases/add_plant_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockPlantsRepository mockPlantsRepository;
  late MockGenerateInitialTasksUseCase mockGenerateInitialTasksUseCase;
  late MockPlantTaskGenerator mockPlantTaskGenerator;
  late MockPlantTasksRepository mockPlantTasksRepository;
  late AddPlantUseCase addPlantUseCase;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(AddPlantParams(name: 'Test'));
    registerFallbackValue(TestFixtures.createTestPlant());

    // Setup authenticated user for tests
    final testUser = UserEntity(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );
    AuthStateNotifier.instance.updateUser(testUser);
  });

  setUp(() {
    mockPlantsRepository = MockPlantsRepository();
    mockGenerateInitialTasksUseCase = MockGenerateInitialTasksUseCase();
    mockPlantTaskGenerator = MockPlantTaskGenerator();
    mockPlantTasksRepository = MockPlantTasksRepository();

    addPlantUseCase = AddPlantUseCase(
      mockPlantsRepository,
      mockGenerateInitialTasksUseCase,
      mockPlantTaskGenerator,
      mockPlantTasksRepository,
    );
  });

  tearDownAll(() {
    // Clean up auth state
    AuthStateNotifier.instance.updateUser(null);
  });

  group('AddPlantUseCase', () {
    test(
      'should return Left with ValidationFailure when plant name is empty',
      () async {
        // Arrange
        final params = AddPlantParams(name: '');

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('obrigatório'));
        }, (_) => fail('Should return failure'));
      },
    );

    test(
      'should return Left with ValidationFailure when plant name is less than 2 characters',
      () async {
        // Arrange
        final params = AddPlantParams(name: 'A');

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('2 caracteres'));
        }, (_) => fail('Should return failure'));
      },
    );

    test(
      'should return Left with ValidationFailure when plant name exceeds 50 characters',
      () async {
        // Arrange
        final longName = 'A' * 51;
        final params = AddPlantParams(name: longName);

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('50 caracteres'));
        }, (_) => fail('Should return failure'));
      },
    );

    test(
      'should return Left with ValidationFailure when species exceeds 100 characters',
      () async {
        // Arrange
        final longSpecies = 'A' * 101;
        final params = AddPlantParams(
          name: 'Valid Plant Name',
          species: longSpecies,
        );

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('100 caracteres'));
        }, (_) => fail('Should return failure'));
      },
    );

    test(
      'should return Left with ValidationFailure when notes exceed 500 characters',
      () async {
        // Arrange
        final longNotes = 'A' * 501;
        final params = AddPlantParams(
          name: 'Valid Plant Name',
          notes: longNotes,
        );

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('500 caracteres'));
        }, (_) => fail('Should return failure'));
      },
    );

    test(
      'should return Right with Plant when repository returns success',
      () async {
        // Arrange
        final testPlant = TestFixtures.createTestPlant(
          name: 'Monstera',
          species: 'Monstera Deliciosa',
        );

        when(
          () => mockPlantsRepository.addPlant(any()),
        ).thenAnswer((_) async => Right(testPlant));

        when(
          () => mockPlantTaskGenerator.generateTasksForPlant(any()),
        ).thenReturn([]);

        final params = AddPlantParams(
          name: 'Monstera',
          species: 'Monstera Deliciosa',
        );

        // Act
        final result = await addPlantUseCase(params);

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should return success'), (plant) {
          expect(plant.name, equals('Monstera'));
          expect(plant.species, equals('Monstera Deliciosa'));
        });

        verify(() => mockPlantsRepository.addPlant(any())).called(1);
      },
    );

    test('should return Left when repository fails', () async {
      // Arrange
      when(
        () => mockPlantsRepository.addPlant(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Database error')));

      final params = AddPlantParams(name: 'Test Plant');

      // Act
      final result = await addPlantUseCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('Database error'));
      }, (_) => fail('Should return failure'));

      verify(() => mockPlantsRepository.addPlant(any())).called(1);
    });

    test('should trim whitespace from plant name', () async {
      // Arrange
      final testPlant = TestFixtures.createTestPlant(name: 'Trimmed Plant');

      when(
        () => mockPlantsRepository.addPlant(any()),
      ).thenAnswer((_) async => Right(testPlant));

      when(
        () => mockPlantTaskGenerator.generateTasksForPlant(any()),
      ).thenReturn([]);

      final params = AddPlantParams(name: '  Test Plant  ');

      // Act
      final result = await addPlantUseCase(params);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockPlantsRepository.addPlant(any())).called(1);
    });
  });
}
