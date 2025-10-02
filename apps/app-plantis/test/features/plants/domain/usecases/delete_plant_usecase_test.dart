import 'package:app_plantis/features/plants/domain/entities/plant.dart';
import 'package:app_plantis/features/plants/domain/repositories/plants_repository.dart';
import 'package:app_plantis/features/plants/domain/usecases/delete_plant_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

void main() {
  late DeletePlantUseCase useCase;
  late MockPlantsRepository mockRepository;

  setUp(() {
    mockRepository = MockPlantsRepository();
    useCase = DeletePlantUseCase(mockRepository);
  });

  group('DeletePlantUseCase', () {
    final existingPlant = Plant(
      id: 'plant-123',
      name: 'Rosa',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      isDirty: false,
      userId: 'user-123',
      moduleName: 'plantis',
    );

    test('should delete plant successfully with valid id', () async {
      // Arrange
      const plantId = 'plant-123';

      when(() => mockRepository.getPlantById(plantId))
          .thenAnswer((_) async => Right(existingPlant));

      when(() => mockRepository.deletePlant(plantId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(plantId);

      // Assert
      expect(result.isRight(), true);

      verify(() => mockRepository.getPlantById(plantId)).called(1);
      verify(() => mockRepository.deletePlant(plantId)).called(1);
    });

    test('should return ValidationFailure when id is empty', () async {
      // Arrange
      const plantId = '';

      // Act
      final result = await useCase(plantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'ID da planta é obrigatório');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.getPlantById(any()));
      verifyNever(() => mockRepository.deletePlant(any()));
    });

    test('should return ValidationFailure when id is only whitespace', () async {
      // Arrange
      const plantId = '   ';

      // Act
      final result = await useCase(plantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'ID da planta é obrigatório');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.getPlantById(any()));
    });

    test('should return failure when plant does not exist', () async {
      // Arrange
      const plantId = 'plant-999';
      const failure = CacheFailure('Plant not found');

      when(() => mockRepository.getPlantById(plantId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(plantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Plant not found');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.getPlantById(plantId)).called(1);
      verifyNever(() => mockRepository.deletePlant(any()));
    });

    test('should propagate repository failure on delete', () async {
      // Arrange
      const plantId = 'plant-123';
      const deleteFailure = CacheFailure('Delete failed');

      when(() => mockRepository.getPlantById(plantId))
          .thenAnswer((_) async => Right(existingPlant));

      when(() => mockRepository.deletePlant(plantId))
          .thenAnswer((_) async => const Left(deleteFailure));

      // Act
      final result = await useCase(plantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Delete failed');
        },
        (_) => fail('Should not return success'),
      );

      verify(() => mockRepository.getPlantById(plantId)).called(1);
      verify(() => mockRepository.deletePlant(plantId)).called(1);
    });

    test('should check plant existence before deletion', () async {
      // Arrange
      const plantId = 'plant-123';

      when(() => mockRepository.getPlantById(plantId))
          .thenAnswer((_) async => Right(existingPlant));

      when(() => mockRepository.deletePlant(plantId))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(plantId);

      // Assert - Verify order of calls
      verifyInOrder([
        () => mockRepository.getPlantById(plantId),
        () => mockRepository.deletePlant(plantId),
      ]);
    });
  });
}
