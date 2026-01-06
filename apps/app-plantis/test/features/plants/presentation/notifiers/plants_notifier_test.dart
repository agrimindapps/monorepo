import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/core/providers/repository_providers.dart';
import 'package:app_plantis/features/plants/domain/usecases/add_plant_usecase.dart';
import 'package:app_plantis/features/plants/domain/usecases/update_plant_usecase.dart';
import 'package:app_plantis/features/plants/presentation/providers/plants_notifier.dart';
import 'package:app_plantis/features/plants/presentation/providers/plants_providers.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockPlantsRepository mockRepository;
  late MockGenerateInitialTasksUseCase mockGenerateTasksUseCase;
  late ProviderContainer container;

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
    mockRepository = MockPlantsRepository();
    mockGenerateTasksUseCase = MockGenerateInitialTasksUseCase();

    container = ProviderContainer(
      overrides: [
        plantsRepositoryProvider.overrideWithValue(mockRepository),
        generateInitialTasksUseCaseProvider.overrideWithValue(
          mockGenerateTasksUseCase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('PlantsNotifier - Load Plants', () {
    test('should load plants successfully', () async {
      // Arrange
      final plants = [
        TestFixtures.createTestPlant(id: 'plant-1', name: 'Rosa'),
        TestFixtures.createTestPlant(id: 'plant-2', name: 'Orquídea'),
      ];

      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => Right(plants));

      // Act
      await container.read(plantsNotifierProvider.notifier).loadPlants();

      // Assert
      final state = container.read(plantsNotifierProvider);
      expect(state.plants.length, 2);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('should handle error when loading plants fails', () async {
      // Arrange
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro')));

      // Act
      await container.read(plantsNotifierProvider.notifier).loadPlants();

      // Assert
      final state = container.read(plantsNotifierProvider);
      expect(state.plants, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNotNull);
    });
  });

  group('PlantsNotifier - Add Plant', () {
    test('should add plant successfully', () async {
      // Arrange
      final newPlant = TestFixtures.createTestPlant(
        id: 'plant-1',
        name: 'Rosa',
      );

      when(
        () => mockRepository.addPlant(any()),
      ).thenAnswer((_) async => Right(newPlant));
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => Right([newPlant]));
      when(
        () => mockGenerateTasksUseCase(any()),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .addPlant(const AddPlantParams(name: 'Rosa', species: 'Rosa gallica'));

      // Assert
      expect(result, true);
      verify(() => mockRepository.addPlant(any())).called(1);
      verify(() => mockGenerateTasksUseCase(any())).called(1);
    });

    test('should validate plant name before adding', () async {
      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .addPlant(const AddPlantParams(name: ''));

      // Assert
      expect(result, false);
      verifyNever(() => mockRepository.addPlant(any()));
    });

    test('should add plant with optional fields', () async {
      // Arrange
      final newPlant = TestFixtures.createTestPlant(
        id: 'plant-1',
        name: 'Orquídea',
        species: 'Phalaenopsis',
        notes: 'Luz indireta',
      );

      when(
        () => mockRepository.addPlant(any()),
      ).thenAnswer((_) async => Right(newPlant));
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => Right([newPlant]));
      when(
        () => mockGenerateTasksUseCase(any()),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .addPlant(
            const AddPlantParams(
              name: 'Orquídea',
              species: 'Phalaenopsis',
              notes: 'Luz indireta',
            ),
          );

      // Assert
      expect(result, true);
    });
  });

  group('PlantsNotifier - Update Plant', () {
    test('should update plant successfully', () async {
      // Arrange
      final originalPlant = TestFixtures.createTestPlant(
        id: 'plant-1',
        name: 'Rosa',
      );
      final updatedPlant = originalPlant.copyWith(name: 'Rosa Vermelha');

      when(
        () => mockRepository.updatePlant(any()),
      ).thenAnswer((_) async => Right(updatedPlant));
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => Right([updatedPlant]));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .updatePlant(
            UpdatePlantParams(
              id: updatedPlant.id,
              name: updatedPlant.name,
              notes: updatedPlant.notes,
            ),
          );

      // Assert
      expect(result, true);
      verify(() => mockRepository.updatePlant(any())).called(1);
    });

    test('should handle update failure', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1');

      when(
        () => mockRepository.updatePlant(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro')));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .updatePlant(UpdatePlantParams(id: plant.id, name: plant.name));

      // Assert
      expect(result, false);
    });
  });

  group('PlantsNotifier - Delete Plant', () {
    test('should delete plant successfully', () async {
      // Arrange
      const plantId = 'plant-1';

      when(
        () => mockRepository.deletePlant(plantId),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .deletePlant(plantId);

      // Assert
      expect(result, true);
      verify(() => mockRepository.deletePlant(plantId)).called(1);
    });

    test('should handle delete failure', () async {
      // Arrange
      const plantId = 'plant-1';

      when(
        () => mockRepository.deletePlant(plantId),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro ao deletar')));

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .deletePlant(plantId);

      // Assert
      expect(result, false);
    });
  });

  group('PlantsNotifier - Get Plant by ID', () {
    test('should return plant when found', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'plant-1', name: 'Rosa');

      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => Right([plant]));

      await container.read(plantsNotifierProvider.notifier).loadPlants();

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .getPlantById('plant-1');

      // Assert
      expect(result, isNotNull);
      expect(result?.name, 'Rosa');
    });

    test('should return null when plant not found', () async {
      // Arrange
      when(
        () => mockRepository.getPlants(),
      ).thenAnswer((_) async => const Right([]));

      await container.read(plantsNotifierProvider.notifier).loadPlants();

      // Act
      final result = await container
          .read(plantsNotifierProvider.notifier)
          .getPlantById('non-existent');

      // Assert
      expect(result, isNull);
    });
  });
}
