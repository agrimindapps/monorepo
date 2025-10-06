import 'package:core/core.dart' show Box;

import '../../../../core/storage/hive_service.dart';
import '../models/animal_model.dart';

abstract class AnimalLocalDataSource {
  Future<List<AnimalModel>> getAnimals();
  Future<AnimalModel?> getAnimalById(String id);
  Future<void> addAnimal(AnimalModel animal);
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String id);
  Stream<List<AnimalModel>> watchAnimals();
}

class AnimalLocalDataSourceImpl implements AnimalLocalDataSource {
  final HiveService _hiveService;

  AnimalLocalDataSourceImpl(this._hiveService);

  Future<Box<AnimalModel>> get _box async {
    return await _hiveService.getBox<AnimalModel>(HiveBoxNames.animals);
  }

  @override
  Future<List<AnimalModel>> getAnimals() async {
    final animalsBox = await _box;
    return animalsBox.values.where((animal) => !animal.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AnimalModel?> getAnimalById(String id) async {
    final animalsBox = await _box;
    return animalsBox.values
        .where((animal) => animal.id == id && !animal.isDeleted)
        .firstOrNull;
  }

  @override
  Future<void> addAnimal(AnimalModel animal) async {
    final animalsBox = await _box;
    await animalsBox.put(animal.id, animal);
  }

  @override
  Future<void> updateAnimal(AnimalModel animal) async {
    final animalsBox = await _box;
    await animalsBox.put(animal.id, animal);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    final animalsBox = await _box;
    final animal = animalsBox.get(id);
    if (animal != null) {
      final deletedAnimal = animal.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await animalsBox.put(id, deletedAnimal);
    }
  }

  @override
  Stream<List<AnimalModel>> watchAnimals() async* {
    final animalsBox = await _box;

    yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
      return animalsBox.values.where((animal) => !animal.isDeleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }
}
