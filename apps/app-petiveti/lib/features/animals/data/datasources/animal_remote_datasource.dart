import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../models/animal_model.dart';

abstract class AnimalRemoteDataSource {
  Future<List<AnimalModel>> getAnimals(String userId);
  Future<AnimalModel?> getAnimalById(String id);
  Future<String> addAnimal(AnimalModel animal, String userId);
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String id);
  Stream<List<AnimalModel>> streamAnimals(String userId);
  Stream<AnimalModel?> streamAnimal(String id);
}

class AnimalRemoteDataSourceImpl implements AnimalRemoteDataSource {
  final FirebaseService _firebaseService;

  AnimalRemoteDataSourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    try {
      final animals = await _firebaseService.getCollection<AnimalModel>(
        FirebaseCollections.animals,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('name'),
        ],
        fromMap: AnimalModel.fromMap,
      );
      
      return animals;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar animais do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<AnimalModel?> getAnimalById(String id) async {
    try {
      final animal = await _firebaseService.getDocument<AnimalModel>(
        FirebaseCollections.animals,
        id,
        AnimalModel.fromMap,
      );
      
      return animal;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar animal do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> addAnimal(AnimalModel animal, String userId) async {
    try {
      final animalData = animal.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final id = await _firebaseService.addDocument<AnimalModel>(
        FirebaseCollections.animals,
        animalData,
        (animal) => animal.toMap(),
      );
      
      return id;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao adicionar animal no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateAnimal(AnimalModel animal) async {
    try {
      final updatedAnimal = animal.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.setDocument<AnimalModel>(
        FirebaseCollections.animals,
        animal.id,
        updatedAnimal,
        (animal) => animal.toMap(),
        merge: true,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar animal no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteAnimal(String id) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.animals,
        id,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao deletar animal do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<AnimalModel>> streamAnimals(String userId) {
    try {
      return _firebaseService.streamCollection<AnimalModel>(
        FirebaseCollections.animals,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('name'),
        ],
        fromMap: AnimalModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar animais do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<AnimalModel?> streamAnimal(String id) {
    try {
      return _firebaseService.streamDocument<AnimalModel>(
        FirebaseCollections.animals,
        id,
        AnimalModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar animal do servidor: ${e.toString()}',
      );
    }
  }
}