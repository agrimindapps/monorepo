import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/plants/domain/usecases/get_plants_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockPlantsRepository mockPlantsRepository;
  late GetPlantsUseCase getPlantsUseCase;

  setUpAll(() {
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
    getPlantsUseCase = GetPlantsUseCase(mockPlantsRepository);
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('GetPlantsUseCase', () {
    test('should return list of plants successfully', () async {
      // Arrange
      final plants = [
        TestFixtures.createTestPlant(id: 'plant-1', name: 'Rosa'),
        TestFixtures.createTestPlant(id: 'plant-2', name: 'Orquídea'),
        TestFixtures.createTestPlant(id: 'plant-3', name: 'Violeta'),
      ];

      when(
        () => mockPlantsRepository.getPlants(),
      ).thenAnswer((_) async => Right(plants));

      // Act
      final result = await getPlantsUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (plantList) {
        expect(plantList.length, 3);
        expect(plantList[0].name, 'Rosa');
        expect(plantList[1].name, 'Orquídea');
        expect(plantList[2].name, 'Violeta');
      });
      verify(() => mockPlantsRepository.getPlants()).called(1);
    });

    test('should return empty list when no plants exist', () async {
      // Arrange
      when(
        () => mockPlantsRepository.getPlants(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await getPlantsUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (plantList) => expect(plantList, isEmpty),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(
        () => mockPlantsRepository.getPlants(),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro no servidor')));

      // Act
      final result = await getPlantsUseCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('servidor')),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle network failures', () async {
      // Arrange
      when(
        () => mockPlantsRepository.getPlants(),
      ).thenAnswer((_) async => const Left(NetworkFailure('Sem conexão')));

      // Act
      final result = await getPlantsUseCase(const NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('conexão'));
      }, (_) => fail('Should return network failure'));
    });

    test('should return plants with all fields populated', () async {
      // Arrange
      final plants = [
        TestFixtures.createTestPlant(
          id: 'plant-1',
          name: 'Rosa Vermelha',
          species: 'Rosa gallica',
          notes: 'Precisa de sol pleno',
        ),
      ];

      when(
        () => mockPlantsRepository.getPlants(),
      ).thenAnswer((_) async => Right(plants));

      // Act
      final result = await getPlantsUseCase(const NoParams());

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return success'), (plantList) {
        expect(plantList[0].name, 'Rosa Vermelha');
        expect(plantList[0].species, 'Rosa gallica');
        expect(plantList[0].notes, 'Precisa de sol pleno');
      });
    });
  });
}
