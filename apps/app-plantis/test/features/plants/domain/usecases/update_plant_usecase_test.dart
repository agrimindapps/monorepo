import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/plants/domain/usecases/update_plant_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockPlantsRepository mockPlantsRepository;
  late MockGenerateInitialTasksUseCase mockGenerateTasksUseCase;
  late UpdatePlantUseCase updatePlantUseCase;

  setUpAll(() {
    registerFallbackValue(TestFixtures.createTestPlant());

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
    mockGenerateTasksUseCase = MockGenerateInitialTasksUseCase();
    updatePlantUseCase = UpdatePlantUseCase(
      mockPlantsRepository,
      mockGenerateTasksUseCase,
    );
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('UpdatePlantUseCase', () {
    test('should update plant successfully', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1', name: 'Rosa');
      final updatedPlant = plant.copyWith(
        name: 'Rosa Vermelha',
        notes: 'Flores bonitas',
      );

      when(
        () => mockPlantsRepository.updatePlant(any()),
      ).thenAnswer((_) async => Right(updatedPlant));

      // Act
      final result = await updatePlantUseCase(
        UpdatePlantParams(
          id: updatedPlant.id,
          name: updatedPlant.name,
          notes: updatedPlant.notes,
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (plant) {
        expect(plant.name, 'Rosa Vermelha');
        expect(plant.notes, 'Flores bonitas');
      });
      verify(() => mockPlantsRepository.updatePlant(updatedPlant)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1');

      when(
        () => mockPlantsRepository.updatePlant(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro no servidor')));

      // Act
      final result = await updatePlantUseCase(
        UpdatePlantParams(id: plant.id, name: plant.name),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('servidor')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate plant name not empty', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1', name: '');

      // Act
      final result = await updatePlantUseCase(
        UpdatePlantParams(id: plant.id, name: plant.name),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('obrigatório'));
      }, (_) => fail('Should return validation failure'));
      verifyNever(() => mockPlantsRepository.updatePlant(any()));
    });

    test('should validate plant name minimum length', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1', name: 'A');

      // Act
      final result = await updatePlantUseCase(
        UpdatePlantParams(id: plant.id, name: plant.name),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('2 caracteres'));
      }, (_) => fail('Should return validation failure'));
    });

    test('should update plant with optional fields', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(
        id: 'plant-1',
        name: 'Orquídea',
        species: 'Phalaenopsis',
        notes: 'Precisa de luz indireta',
      );

      when(
        () => mockPlantsRepository.updatePlant(any()),
      ).thenAnswer((_) async => Right(plant));

      // Act
      final result = await updatePlantUseCase(
        UpdatePlantParams(
          id: plant.id,
          name: plant.name,
          species: plant.species,
          notes: plant.notes,
        ),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (updatedPlant) {
        expect(updatedPlant.species, 'Phalaenopsis');
        expect(updatedPlant.notes, 'Precisa de luz indireta');
      });
    });
  });
}
