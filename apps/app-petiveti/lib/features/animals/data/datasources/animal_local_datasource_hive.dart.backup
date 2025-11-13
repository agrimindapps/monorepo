import 'package:core/core.dart' show Box;

import '../../../../core/storage/hive_service.dart';
import '../models/animal_model.dart';
import 'delete_strategy.dart';

abstract class AnimalLocalDataSource {
  Future<List<AnimalModel>> getAnimals();
  Future<AnimalModel?> getAnimalById(String id);
  Future<void> addAnimal(AnimalModel animal);
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String id);
  Stream<List<AnimalModel>> watchAnimals();
}

/// Responsabilidades ÚNICAS (SRP):
/// 1. Comunicação com Hive (storage)
/// 2. Operações CRUD básicas
/// 3. Ordenação e filtragem básica de resultados
///
/// Não é responsável por:
/// - Lógica de delete (delegada para DeleteStrategy)
/// - Transformações complexas (responsabilidade da Repository)
/// - Sincronização (responsabilidade do Sync Manager)
class AnimalLocalDataSourceImpl implements AnimalLocalDataSource {
  final HiveService _hiveService;
  final DeleteStrategy _deleteStrategy;

  AnimalLocalDataSourceImpl(
    this._hiveService, {
    DeleteStrategy? deleteStrategy,
  }) : _deleteStrategy = deleteStrategy ?? SoftDeleteStrategy();

  Future<Box<AnimalModel>> get _box async {
    return await _hiveService.getBox<AnimalModel>(HiveBoxNames.animals);
  }

  @override
  Future<List<AnimalModel>> getAnimals() async {
    final animalsBox = await _box;
    return _filterAndSort(animalsBox.values.toList());
  }

  @override
  Future<AnimalModel?> getAnimalById(String id) async {
    final animalsBox = await _box;
    final animal = animalsBox.get(id);
    return animal != null && !animal.isDeleted ? animal : null;
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
      // Delegar lógica de delete para a estratégia
      final deletedAnimal = await _deleteStrategy.execute(animal);
      await animalsBox.put(id, deletedAnimal);
    }
  }

  @override
  Stream<List<AnimalModel>> watchAnimals() async* {
    final animalsBox = await _box;

    yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
      return _filterAndSort(animalsBox.values.toList());
    });
  }

  /// Filtrar ativos e ordenar por data de criação (responsabilidade comum)
  List<AnimalModel> _filterAndSort(List<AnimalModel> animals) {
    return animals.where((animal) => !animal.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
