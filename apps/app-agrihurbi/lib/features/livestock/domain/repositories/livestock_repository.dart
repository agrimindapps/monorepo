import 'package:core/core.dart';

import '../entities/animal_base_entity.dart';
import '../entities/bovine_entity.dart';
import '../entities/equine_entity.dart';

/// Parâmetros para busca avançada de animais
class SearchAnimalsParams {
  const SearchAnimalsParams({
    query,
    breed,
    originCountry,
    tags,
    isActive,
    limit = 20,
    offset = 0,
  });

  final String? query; // Busca por nome/id/características
  final String? breed;
  final String? originCountry;
  final List<String>? tags;
  final bool? isActive;
  final int limit;
  final int offset;
}

/// Parâmetros específicos para filtros de bovinos
class BovineSearchParams extends SearchAnimalsParams {
  const BovineSearchParams({
    super.query,
    super.breed,
    super.originCountry,
    super.tags,
    super.isActive,
    super.limit,
    super.offset,
    aptitude,
    breedingSystem,
    purpose,
  });

  final BovineAptitude? aptitude;
  final BreedingSystem? breedingSystem;
  final String? purpose;
}

/// Parâmetros específicos para filtros de equinos
class EquineSearchParams extends SearchAnimalsParams {
  const EquineSearchParams({
    super.query,
    super.breed,
    super.originCountry,
    super.tags,
    super.isActive,
    super.limit,
    super.offset,
    temperament,
    coat,
    primaryUse,
  });

  final EquineTemperament? temperament;
  final CoatColor? coat;
  final EquinePrimaryUse? primaryUse;
}

/// Interface do repositório de livestock seguindo Clean Architecture
/// 
/// Define os contratos para operações com bovinos e equinos
/// Usa Either<Failure, Success> para error handling funcional
/// Baseada na análise do projeto original com Supabase + arquitetura avançada
abstract class LivestockRepository {
  // === OPERAÇÕES BOVINOS ===
  
  /// Obtém lista de todos os bovinos ativos
  Future<Either<Failure, List<BovineEntity>>> getBovines();
  
  /// Obtém um bovino específico por ID
  Future<Either<Failure, BovineEntity>> getBovineById(String id);
  
  /// Cria um novo bovino com validação
  Future<Either<Failure, BovineEntity>> createBovine(BovineEntity bovine);
  
  /// Atualiza um bovino existente
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine);
  
  /// Remove um bovino por ID (soft delete)
  Future<Either<Failure, Unit>> deleteBovine(String id);
  
  /// Busca bovinos com filtros avançados
  Future<Either<Failure, List<BovineEntity>>> searchBovines(BovineSearchParams params);
  
  // === OPERAÇÕES EQUINOS ===
  
  /// Obtém lista de todos os equinos ativos
  Future<Either<Failure, List<EquineEntity>>> getEquines();
  
  /// Obtém um equino específico por ID
  Future<Either<Failure, EquineEntity>> getEquineById(String id);
  
  /// Cria um novo equino com validação
  Future<Either<Failure, EquineEntity>> createEquine(EquineEntity equine);
  
  /// Atualiza um equino existente
  Future<Either<Failure, EquineEntity>> updateEquine(EquineEntity equine);
  
  /// Remove um equino por ID (soft delete)
  Future<Either<Failure, Unit>> deleteEquine(String id);
  
  /// Busca equinos com filtros avançados
  Future<Either<Failure, List<EquineEntity>>> searchEquines(EquineSearchParams params);
  
  // === OPERAÇÕES UNIFICADAS ===
  
  /// Busca unificada em bovinos e equinos
  Future<Either<Failure, List<AnimalBaseEntity>>> searchAllAnimals(SearchAnimalsParams params);
  
  /// Upload de imagens para animais
  Future<Either<Failure, List<String>>> uploadAnimalImages(String animalId, List<String> imagePaths);
  
  /// Remove imagens de animais
  Future<Either<Failure, Unit>> deleteAnimalImages(String animalId, List<String> imageUrls);
  
  // === OPERAÇÕES DE SINCRONIZAÇÃO ===
  
  /// Sincroniza dados locais com servidor remoto
  Future<Either<Failure, Unit>> syncLivestockData();
  
  /// Obtém estatísticas gerais do rebanho
  Future<Either<Failure, Map<String, dynamic>>> getLivestockStatistics();
  
  /// Exporta dados para backup (JSON/CSV)
  Future<Either<Failure, String>> exportLivestockData({String format = 'json'});
  
  /// Importa dados de backup com validação
  Future<Either<Failure, Unit>> importLivestockData(String backupData, {String format = 'json'});
}