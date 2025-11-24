import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:core/core.dart' hide Failure, ValidationFailure;

import '../entities/animal_base_entity.dart';
import '../entities/bovine_entity.dart';
import '../entities/equine_entity.dart';
import '../repositories/livestock_repository.dart' as repo;

/// Use case para busca unificada de animais (bovinos + equinos)
/// 
/// Permite busca combinada em bovinos e equinos com filtros avançados
/// Inclui full-text search e filtros específicos por tipo
class SearchAnimalsUseCase implements UseCase<SearchAnimalsResult, SearchAnimalsParams> {
  final repo.LivestockRepository repository;
  
  const SearchAnimalsUseCase(this.repository);
  
  @override
  Future<Either<Failure, SearchAnimalsResult>> call(SearchAnimalsParams params) async {
    final validation = _validateSearchParams(params);
    if (validation != null) {
      return Left(ValidationFailure(message: validation));
    }
    if (params.animalType != null) {
      switch (params.animalType!) {
        case AnimalType.bovine:
          return await _searchBovinesOnly(params);
        case AnimalType.equine:
          return await _searchEquinesOnly(params);
      }
    }
    return await _searchAllAnimals(params);
  }
  
  /// Busca apenas bovinos
  Future<Either<Failure, SearchAnimalsResult>> _searchBovinesOnly(SearchAnimalsParams params) async {
    final bovineParams = repo.BovineSearchParams(
      query: params.query,
      breed: params.breed,
      originCountry: params.originCountry,
      tags: params.tags,
      isActive: params.isActive,
      limit: params.limit,
      offset: params.offset,
      aptitude: params.aptitude,
      breedingSystem: params.breedingSystem,
      purpose: params.purpose,
    );
    
    final result = await repository.searchBovines(bovineParams);
    
    return result.fold(
      (failure) => Left(failure),
      (bovines) => Right(SearchAnimalsResult(
        bovines: bovines,
        equines: const [],
        totalCount: bovines.length,
        searchParams: params,
      )),
    );
  }
  
  /// Busca apenas equinos
  Future<Either<Failure, SearchAnimalsResult>> _searchEquinesOnly(SearchAnimalsParams params) async {
    final equineParams = repo.EquineSearchParams(
      query: params.query,
      breed: params.breed,
      originCountry: params.originCountry,
      tags: params.tags,
      isActive: params.isActive,
      limit: params.limit,
      offset: params.offset,
      temperament: params.temperament,
      coat: params.coat,
      primaryUse: params.primaryUse,
    );
    
    final result = await repository.searchEquines(equineParams);
    
    return result.fold(
      (failure) => Left(failure),
      (equines) => Right(SearchAnimalsResult(
        bovines: const [],
        equines: equines,
        totalCount: equines.length,
        searchParams: params,
      )),
    );
  }
  
  /// Busca unificada em todos os animais
  Future<Either<Failure, SearchAnimalsResult>> _searchAllAnimals(SearchAnimalsParams params) async {
    final repoParams = repo.SearchAnimalsParams(
      query: params.query,
      breed: params.breed,
      originCountry: params.originCountry,
      tags: params.tags,
      isActive: params.isActive,
      limit: params.limit,
      offset: params.offset,
    );
    final unifiedResult = await repository.searchAllAnimals(repoParams);
    
    return unifiedResult.fold(
      (failure) => Left(failure),
      (animals) {
        final bovines = animals.whereType<BovineEntity>().toList();
        final equines = animals.whereType<EquineEntity>().toList();
        
        return Right(SearchAnimalsResult(
          bovines: bovines,
          equines: equines,
          totalCount: animals.length,
          searchParams: params,
        ));
      },
    );
  }
  
  /// Valida os parâmetros de busca
  String? _validateSearchParams(SearchAnimalsParams params) {
    if (params.query != null && params.query!.trim().length < 2) {
      return 'Termo de busca deve ter pelo menos 2 caracteres';
    }
    if (params.limit > 100) {
      return 'Limite máximo de resultados é 100';
    }
    if (params.offset < 0) {
      return 'Offset deve ser maior ou igual a zero';
    }
    
    return null;
  }
}

/// Use case para busca rápida por nome/ID
class QuickSearchAnimalsUseCase implements UseCase<SearchAnimalsResult, String> {
  final SearchAnimalsUseCase _searchUseCase;
  
  const QuickSearchAnimalsUseCase(this._searchUseCase);
  
  @override
  Future<Either<Failure, SearchAnimalsResult>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Termo de busca é obrigatório'));
    }
    
    return await _searchUseCase.call(
      SearchAnimalsParams(
        query: query.trim(),
        limit: 20,
      ),
    );
  }
}

/// Enumeração para tipos de animais
enum AnimalType {
  bovine('Bovino'),
  equine('Equino');
  
  const AnimalType(this.displayName);
  final String displayName;
}

/// Parâmetros estendidos para busca unificada de animais
class SearchAnimalsParams {
  const SearchAnimalsParams({
    this.query,
    this.breed,
    this.originCountry,
    this.tags,
    this.isActive,
    this.limit = 20,
    this.offset = 0,
    this.animalType,
    this.sortBy = SortField.name,
    this.sortOrder = SortOrder.asc,
    this.aptitude,
    this.breedingSystem,
    this.purpose,
    this.temperament,
    this.coat,
    this.primaryUse,
  });

  final String? query;
  final String? breed;
  final String? originCountry;
  final List<String>? tags;
  final bool? isActive;
  final int limit;
  final int offset;
  final AnimalType? animalType;
  final SortField sortBy;
  final SortOrder sortOrder;
  final BovineAptitude? aptitude;
  final BreedingSystem? breedingSystem;
  final String? purpose;
  final EquineTemperament? temperament;
  final CoatColor? coat;
  final EquinePrimaryUse? primaryUse;
}

/// Resultado da busca de animais
class SearchAnimalsResult extends Equatable {
  const SearchAnimalsResult({
    required this.bovines,
    required this.equines,
    required this.totalCount,
    required this.searchParams,
    this.hasMore = false,
  });

  final List<BovineEntity> bovines;
  final List<EquineEntity> equines;
  final int totalCount;
  final SearchAnimalsParams searchParams;
  final bool hasMore;
  
  /// Retorna todos os animais combinados
  List<AnimalBaseEntity> get allAnimals => [
    ...bovines,
    ...equines,
  ];
  
  /// Retorna se há resultados
  bool get hasResults => totalCount > 0;
  
  /// Retorna se é resultado vazio
  bool get isEmpty => totalCount == 0;

  @override
  List<Object?> get props => [
    bovines,
    equines,
    totalCount,
    searchParams,
    hasMore,
  ];
}

/// Campos disponíveis para ordenação
enum SortField {
  name('Nome'),
  breed('Raça'),
  createdAt('Data de Criação'),
  updatedAt('Data de Atualização'),
  originCountry('País de Origem');
  
  const SortField(this.displayName);
  final String displayName;
}

/// Ordem de ordenação
enum SortOrder {
  asc('Crescente'),
  desc('Decrescente');
  
  const SortOrder(this.displayName);
  final String displayName;
}
