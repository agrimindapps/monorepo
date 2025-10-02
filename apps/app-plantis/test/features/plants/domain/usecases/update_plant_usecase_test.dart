import 'package:app_plantis/features/plants/domain/entities/plant.dart';
import 'package:app_plantis/features/plants/domain/repositories/plants_repository.dart';
import 'package:app_plantis/features/plants/domain/usecases/update_plant_usecase.dart';
import 'package:core/core.dart' hide test;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

void main() {
  late UpdatePlantUseCase useCase;
  late MockPlantsRepository mockRepository;

  setUp(() {
    mockRepository = MockPlantsRepository();
    useCase = UpdatePlantUseCase(mockRepository);

    // Register fallback values
    registerFallbackValue(_FakePlant());
  });

  group('UpdatePlantUseCase', () {
    final existingPlant = Plant(
      id: 'plant-123',
      name: 'Rosa Antiga',
      species: 'Rosa chinensis',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      isDirty: false,
      userId: 'user-123',
      moduleName: 'plantis',
    );

    test('should update plant successfully with valid data', () async {
      // Arrange
      const params = UpdatePlantParams(
        id: 'plant-123',
        name: 'Rosa Nova',
        species: 'Rosa damascena',
      );

      when(() => mockRepository.getPlantById('plant-123'))
          .thenAnswer((_) async => Right(existingPlant));

      when(() => mockRepository.updatePlant(any()))
          .thenAnswer((_) async => Right(existingPlant.copyWith(
                name: 'Rosa Nova',
                species: 'Rosa damascena',
                updatedAt: DateTime.now(),
              )));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (plant) {
          expect(plant.name, 'Rosa Nova');
          expect(plant.species, 'Rosa damascena');
        },
      );

      verify(() => mockRepository.getPlantById('plant-123')).called(1);
      verify(() => mockRepository.updatePlant(any())).called(1);
    });

    test('should return ValidationFailure when id is empty', () async {
      // Arrange
      const params = UpdatePlantParams(id: '', name: 'Rosa');

      // Act
      final result = await useCase(params);

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

    test('should return ValidationFailure when name is empty', () async {
      // Arrange
      const params = UpdatePlantParams(id: 'plant-123', name: '');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome da planta é obrigatório');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when name is too short', () async {
      // Arrange
      const params = UpdatePlantParams(id: 'plant-123', name: 'R');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome deve ter pelo menos 2 caracteres');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should propagate repository failure when plant not found', () async {
      // Arrange
      const params = UpdatePlantParams(id: 'plant-999', name: 'Rosa');
      const failure = CacheFailure('Plant not found');

      when(() => mockRepository.getPlantById('plant-999'))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Plant not found');
        },
        (_) => fail('Should not return success'),
      );

      verifyNever(() => mockRepository.updatePlant(any()));
    });

    test('should trim whitespace from plant name and species', () async {
      // Arrange
      const params = UpdatePlantParams(
        id: 'plant-123',
        name: '  Rosa  ',
        species: '  Rosa damascena  ',
      );

      when(() => mockRepository.getPlantById('plant-123'))
          .thenAnswer((_) async => Right(existingPlant));

      when(() => mockRepository.updatePlant(any())).thenAnswer(
        (_) async => Right(existingPlant.copyWith(
          name: 'Rosa',
          species: 'Rosa damascena',
          updatedAt: DateTime.now(),
        )),
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (plant) {
          expect(plant.name, 'Rosa');
          expect(plant.species, 'Rosa damascena');
        },
      );
    });

    test('should update updatedAt timestamp', () async {
      // Arrange
      const params = UpdatePlantParams(id: 'plant-123', name: 'Rosa');

      when(() => mockRepository.getPlantById('plant-123'))
          .thenAnswer((_) async => Right(existingPlant));

      final capturedPlant = <Plant>[];
      when(() => mockRepository.updatePlant(any())).thenAnswer((invocation) {
        final plant = invocation.positionalArguments[0] as Plant;
        capturedPlant.add(plant);
        return Future.value(Right(plant));
      });

      // Act
      await useCase(params);

      // Assert
      expect(capturedPlant.length, 1);
      expect(capturedPlant.first.isDirty, true);
      expect(
        capturedPlant.first.updatedAt!.isAfter(existingPlant.updatedAt!),
        true,
      );
    });
  });
}

// Fake class for fallback registration
class _FakePlant extends Fake implements Plant {}
