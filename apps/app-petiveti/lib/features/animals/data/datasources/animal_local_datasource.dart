import 'package:drift/drift.dart';

import '../../../../database/petiveti_database.dart';
import '../../domain/entities/animal_enums.dart';
import '../models/animal_model.dart';

abstract class AnimalLocalDataSource {
  Future<List<AnimalModel>> getAnimals(String userId);
  Future<AnimalModel?> getAnimalById(int id);
  Future<int> addAnimal(AnimalModel animal);
  Future<bool> updateAnimal(AnimalModel animal);
  Future<bool> deleteAnimal(int id);
  Stream<List<AnimalModel>> watchAnimals(String userId);
  Future<int> getAnimalsCount(String userId);
  Future<List<AnimalModel>> searchAnimals(String userId, String query);
}

/// Drift-based implementation of AnimalLocalDataSource
///
/// Responsibilities (SRP):
/// 1. Communication with Drift database
/// 2. CRUD operations
/// 3. Data transformation (Drift entities ↔ Domain models)
///
/// Not responsible for:
/// - Business logic (delegated to Repository/Use Cases)
/// - Complex transformations (Repository responsibility)
/// - Sync logic (Sync Manager responsibility)
class AnimalLocalDataSourceImpl implements AnimalLocalDataSource {
  final PetivetiDatabase _database;

  AnimalLocalDataSourceImpl(this._database);

  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    final animals = await _database.animalDao.getAllAnimals(userId);
    return animals.map(_toModel).toList();
  }

  @override
  Future<AnimalModel?> getAnimalById(int id) async {
    final animal = await _database.animalDao.getAnimalById(id);
    return animal != null ? _toModel(animal) : null;
  }

  @override
  Future<int> addAnimal(AnimalModel animal) async {
    final companion = _toCompanion(animal);
    return await _database.animalDao.createAnimal(companion);
  }

  @override
  Future<bool> updateAnimal(AnimalModel animal) async {
    if (animal.id == null) return false;
    final companion = _toCompanion(animal, forUpdate: true);
    return await _database.animalDao.updateAnimal(animal.id!, companion);
  }

  @override
  Future<bool> deleteAnimal(int id) async {
    return await _database.animalDao.deleteAnimal(id);
  }

  @override
  Stream<List<AnimalModel>> watchAnimals(String userId) {
    return _database.animalDao
        .watchAllAnimals(userId)
        .map((animals) => animals.map(_toModel).toList());
  }

  @override
  Future<int> getAnimalsCount(String userId) async {
    return await _database.animalDao.getActiveAnimalsCount(userId);
  }

  @override
  Future<List<AnimalModel>> searchAnimals(String userId, String query) async {
    final animals = await _database.animalDao.searchAnimals(userId, query);
    return animals.map(_toModel).toList();
  }

  /// Convert Drift Animal entity to domain AnimalModel
  AnimalModel _toModel(Animal animal) {
    // Parse species and gender from stored strings
    final species = AnimalSpeciesExtension.fromString(animal.species);
    final gender = AnimalGenderExtension.fromString(animal.gender);

    return AnimalModel(
      id: animal.id,
      name: animal.name,
      species: species,
      breed: animal.breed,
      birthDate: animal.birthDate,
      gender: gender,
      weight: animal.weight,
      photoUrl: animal.photo,
      color: animal.color,
      microchipNumber: animal.microchipNumber,
      notes: animal.notes,
      userId: animal.userId,
      isActive: animal.isActive,
      isDeleted: animal.isDeleted,
      createdAt: animal.createdAt,
      updatedAt: animal.updatedAt,
    );
  }

  /// Convert domain AnimalModel to Drift AnimalsCompanion
  AnimalsCompanion _toCompanion(AnimalModel model, {bool forUpdate = false}) {
    if (forUpdate) {
      return AnimalsCompanion(
        id: model.id != null ? Value(model.id!) : const Value.absent(),
        name: Value(model.name),
        species: Value(model.species.name),
        breed: Value.absentIfNull(model.breed),
        birthDate: Value.absentIfNull(model.birthDate),
        gender: Value(model.gender.name),
        weight: Value.absentIfNull(model.weight),
        photo: Value.absentIfNull(model.photoUrl),
        color: Value.absentIfNull(model.color),
        microchipNumber: Value.absentIfNull(model.microchipNumber),
        notes: Value.absentIfNull(model.notes),
        userId: Value(model.userId),
        isActive: Value(model.isActive),
        updatedAt: Value(DateTime.now()),
      );
    }

    return AnimalsCompanion.insert(
      name: model.name,
      species: model.species.name,
      breed: Value.absentIfNull(model.breed),
      birthDate: Value.absentIfNull(model.birthDate),
      gender: model.gender.name,
      weight: Value.absentIfNull(model.weight),
      photo: Value.absentIfNull(model.photoUrl),
      color: Value.absentIfNull(model.color),
      microchipNumber: Value.absentIfNull(model.microchipNumber),
      notes: Value.absentIfNull(model.notes),
      userId: model.userId,
      isActive: Value(model.isActive),
      createdAt: Value(model.createdAt),
    );
  }
}
