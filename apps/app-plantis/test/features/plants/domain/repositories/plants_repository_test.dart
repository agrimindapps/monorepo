import 'package:app_plantis/features/plants/domain/entities/plant.dart';
import 'package:app_plantis/features/plants/domain/repositories/plants_repository.dart';
import 'package:core/core.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_fixtures.dart';

/// Concrete implementation for testing abstract PlantsRepository
class _TestPlantsRepository implements PlantsRepository {
  final List<Plant> _plants = [];

  @override
  Future<Either<Failure, List<Plant>>> getPlants() async {
    return Right(_plants);
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    try {
      final plant = _plants.firstWhere((p) => p.id == id);
      return Right(plant);
    } catch (e) {
      return Left(NotFoundFailure('Plant with id $id not found'));
    }
  }

  @override
  Future<Either<Failure, Plant>> addPlant(Plant plant) async {
    _plants.add(plant);
    return Right(plant);
  }

  @override
  Future<Either<Failure, Plant>> updatePlant(Plant plant) async {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index == -1) {
      return const Left(NotFoundFailure('Plant not found'));
    }
    _plants[index] = plant;
    return Right(plant);
  }

  @override
  Future<Either<Failure, void>> deletePlant(String id) async {
    _plants.removeWhere((p) => p.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Plant>>> searchPlants(String query) async {
    final results = _plants
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              (p.species?.toLowerCase().contains(query.toLowerCase()) ?? false),
        )
        .toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId) async {
    final results = _plants.where((p) => p.spaceId == spaceId).toList();
    return Right(results);
  }

  @override
  Future<Either<Failure, int>> getPlantsCount() async {
    return Right(_plants.length);
  }

  @override
  Stream<List<Plant>> watchPlants() {
    return Stream.value(_plants);
  }

  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    return const Right(null);
  }
}

void main() {
  late _TestPlantsRepository repository;

  setUp(() {
    repository = _TestPlantsRepository();
  });

  group('PlantsRepository', () {
    test('should add plant and retrieve it', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant();

      // Act
      final addResult = await repository.addPlant(plant);
      final getResult = await repository.getPlantById(plant.id);

      // Assert
      expect(addResult.isRight(), true);
      expect(getResult.isRight(), true);
      getResult.fold((_) => fail('Should return plant'), (retrievedPlant) {
        expect(retrievedPlant.id, equals(plant.id));
        expect(retrievedPlant.name, equals(plant.name));
      });
    });

    test('should return NotFoundFailure when plant does not exist', () async {
      // Act
      final result = await repository.getPlantById('non-existent-id');

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
      }, (_) => fail('Should return failure'));
    });

    test('should get all plants', () async {
      // Arrange
      final plants = TestFixtures.createTestPlants(count: 3);

      // Act
      for (var plant in plants) {
        await repository.addPlant(plant);
      }
      final result = await repository.getPlants();

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return plants'), (retrievedPlants) {
        expect(retrievedPlants.length, equals(3));
        expect(retrievedPlants[0].id, equals('plant-0'));
        expect(retrievedPlants[1].id, equals('plant-1'));
        expect(retrievedPlants[2].id, equals('plant-2'));
      });
    });

    test('should update existing plant', () async {
      // Arrange
      final originalPlant = TestFixtures.createTestPlant(name: 'Original Name');
      await repository.addPlant(originalPlant);

      final updatedPlant = originalPlant.copyWith(name: 'Updated Name');

      // Act
      final result = await repository.updatePlant(updatedPlant);

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return updated plant'), (plant) {
        expect(plant.name, equals('Updated Name'));
      });
    });

    test('should return Left when updating non-existent plant', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant(id: 'non-existent');

      // Act
      final result = await repository.updatePlant(plant);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
      }, (_) => fail('Should return failure'));
    });

    test('should delete plant by id', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant();
      await repository.addPlant(plant);

      // Act
      await repository.deletePlant(plant.id);
      final getResult = await repository.getPlantById(plant.id);

      // Assert
      expect(getResult.isLeft(), true);
    });

    test('should search plants by name', () async {
      // Arrange
      final plant1 = TestFixtures.createTestPlant(
        id: 'plant-1',
        name: 'Monstera Deliciosa',
      );
      final plant2 = TestFixtures.createTestPlant(
        id: 'plant-2',
        name: 'Succulent Plant',
      );
      await repository.addPlant(plant1);
      await repository.addPlant(plant2);

      // Act
      final result = await repository.searchPlants('Monstera');

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return plants'), (plants) {
        expect(plants.length, equals(1));
        expect(plants[0].name, equals('Monstera Deliciosa'));
      });
    });

    test('should search plants by species', () async {
      // Arrange
      final plant1 = TestFixtures.createTestPlant(
        id: 'plant-1',
        species: 'Monstera Deliciosa',
      );
      final plant2 = TestFixtures.createTestPlant(
        id: 'plant-2',
        species: 'Cactus Cereus',
      );
      await repository.addPlant(plant1);
      await repository.addPlant(plant2);

      // Act
      final result = await repository.searchPlants('Cactus');

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return plants'), (plants) {
        expect(plants.length, equals(1));
        expect(plants[0].species, equals('Cactus Cereus'));
      });
    });

    test('should get plants by space', () async {
      // Arrange
      final plant1 = TestFixtures.createTestPlant(
        id: 'plant-1',
        spaceId: 'living-room',
      );
      final plant2 = TestFixtures.createTestPlant(
        id: 'plant-2',
        spaceId: 'bedroom',
      );
      await repository.addPlant(plant1);
      await repository.addPlant(plant2);

      // Act
      final result = await repository.getPlantsBySpace('living-room');

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return plants'), (plants) {
        expect(plants.length, equals(1));
        expect(plants[0].spaceId, equals('living-room'));
      });
    });

    test('should get plants count', () async {
      // Arrange
      final plants = TestFixtures.createTestPlants(count: 5);

      // Act
      for (var plant in plants) {
        await repository.addPlant(plant);
      }
      final result = await repository.getPlantsCount();

      // Assert
      expect(result.isRight(), true);
      result.fold((_) => fail('Should return count'), (count) {
        expect(count, equals(5));
      });
    });

    test('should sync pending changes', () async {
      // Act
      final result = await repository.syncPendingChanges();

      // Assert
      expect(result.isRight(), true);
    });

    test('should watch plants stream', () async {
      // Arrange
      final plant = TestFixtures.createTestPlant();
      await repository.addPlant(plant);

      // Act
      final stream = repository.watchPlants();

      // Assert
      expect(stream, emits(isA<List<Plant>>()));
    });
  });
}
