import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/plant.dart';

abstract class PlantsRepository {
  /// Obtém todas as plantas do usuário
  Future<Either<Failure, List<Plant>>> getPlants();
  
  /// Obtém uma planta específica por ID
  Future<Either<Failure, Plant>> getPlantById(String id);
  
  /// Adiciona uma nova planta
  Future<Either<Failure, Plant>> addPlant(Plant plant);
  
  /// Atualiza uma planta existente
  Future<Either<Failure, Plant>> updatePlant(Plant plant);
  
  /// Remove uma planta
  Future<Either<Failure, void>> deletePlant(String id);
  
  /// Busca plantas por nome ou espécie
  Future<Either<Failure, List<Plant>>> searchPlants(String query);
  
  /// Obtém plantas filtradas por espaço
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId);
  
  /// Obtém contagem total de plantas
  Future<Either<Failure, int>> getPlantsCount();
  
  /// Stream para observar mudanças nas plantas
  Stream<List<Plant>> watchPlants();
  
  /// Sincroniza mudanças pendentes com o servidor
  Future<Either<Failure, void>> syncPendingChanges();
}