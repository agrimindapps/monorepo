import 'package:app_plantis/core/auth/auth_state_notifier.dart';
import 'package:app_plantis/features/plants/domain/usecases/delete_plant_usecase.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPlantsRepository mockPlantsRepository;
  late DeletePlantUseCase deletePlantUseCase;

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
    deletePlantUseCase = DeletePlantUseCase(mockPlantsRepository);
  });

  tearDownAll(() {
    AuthStateNotifier.instance.updateUser(null);
  });

  group('DeletePlantUseCase', () {
    test('should delete plant successfully', () async {
      // Arrange
      const plantId = 'plant-1';

      when(
        () => mockPlantsRepository.deletePlant(plantId),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await deletePlantUseCase(
        const DeletePlantParams(plantId: plantId),
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockPlantsRepository.deletePlant(plantId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const plantId = 'plant-1';

      when(
        () => mockPlantsRepository.deletePlant(plantId),
      ).thenAnswer((_) async => const Left(ServerFailure('Erro ao deletar')));

      // Act
      final result = await deletePlantUseCase(
        const DeletePlantParams(plantId: plantId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('deletar')),
        (_) => fail('Should return failure'),
      );
    });

    test('should validate plant ID not empty', () async {
      // Act
      final result = await deletePlantUseCase(
        const DeletePlantParams(plantId: ''),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('ID'));
      }, (_) => fail('Should return validation failure'));
      verifyNever(() => mockPlantsRepository.deletePlant(any()));
    });

    test('should handle network failures', () async {
      // Arrange
      const plantId = 'plant-1';

      when(
        () => mockPlantsRepository.deletePlant(plantId),
      ).thenAnswer((_) async => const Left(NetworkFailure('Sem conexão')));

      // Act
      final result = await deletePlantUseCase(
        const DeletePlantParams(plantId: plantId),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('conexão'));
      }, (_) => fail('Should return network failure'));
    });
  });
}
