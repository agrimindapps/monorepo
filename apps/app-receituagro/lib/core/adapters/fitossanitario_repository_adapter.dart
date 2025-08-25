import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../features/defensivos/domain/entities/defensivo_entity.dart';
import '../../features/defensivos/domain/repositories/i_defensivos_repository.dart';
import '../models/fitossanitario_hive.dart';
import '../repositories/fitossanitario_core_repository.dart';

/// Adapter para conectar FitossanitarioCoreRepository com a interface IDefensivosRepository
/// Converte entre as entidades Hive e as entidades do domínio
class FitossanitarioRepositoryAdapter implements IDefensivosRepository {
  final FitossanitarioCoreRepository _repository;

  FitossanitarioRepositoryAdapter(this._repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final fitossanitarios = await _repository.getAllAsync();
      
      // Aplicar paginação se necessário
      List<FitossanitarioHive> paginated = fitossanitarios;
      if (offset != null && offset > 0) {
        paginated = paginated.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        paginated = paginated.take(limit).toList();
      }
      
      final entities = paginated.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity?>> getById(String id) async {
    try {
      final fitossanitario = await _repository.getByIdAsync(id);
      if (fitossanitario == null) return const Right(null);
      return Right(_convertToEntity(fitossanitario));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getActiveDefensivos() async {
    try {
      final ativos = await _repository.getActiveDefensivos();
      final entities = ativos.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getElegibleDefensivos() async {
    try {
      // Usar método existente no FitossanitarioCoreRepository
      final elegiveis = await _repository.getElegibleDefensivos();
      final entities = elegiveis.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar elegíveis: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByNomeComum(String searchTerm) async {
    try {
      final fitossanitarios = await _repository.searchByNomeComumAsync(searchTerm);
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByIngredienteAtivo(String searchTerm) async {
    try {
      final fitossanitarios = await _repository.searchByIngredienteAtivoAsync(searchTerm);
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por ingrediente: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByFabricante(String fabricante) async {
    try {
      final fitossanitarios = await _repository.searchByMultipleCriteriaAsync(fabricante: fabricante);
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por fabricante: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByClasseAgronomica(String classe) async {
    try {
      final fitossanitarios = await _repository.searchByMultipleCriteriaAsync(classeAgronomica: classe);
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por classe: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<DefensivoEntity>>> searchAdvanced(DefensivoSearchFilters filters) async {
    try {
      final fitossanitarios = await _repository.searchByMultipleCriteriaAsync(
        nomeComum: filters.nomeComum,
        ingredienteAtivo: filters.ingredienteAtivo,
        fabricante: filters.fabricante,
        classeAgronomica: filters.classeAgronomica,
      );
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca avançada: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByMultipleCriteria({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgronomica,
    bool? status,
    int? comercializado,
    bool? elegivel,
  }) async {
    try {
      final fitossanitarios = await _repository.searchByMultipleCriteriaAsync(
        nomeComum: nomeComum,
        ingredienteAtivo: ingredienteAtivo,
        fabricante: fabricante,
        classeAgronomica: classeAgronomica,
      );
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por múltiplos critérios: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchWithFilters(
    DefensivoSearchFilters filters,
  ) async {
    try {
      final fitossanitarios = await _repository.searchByMultipleCriteriaAsync(
        nomeComum: filters.nomeComum,
        ingredienteAtivo: filters.ingredienteAtivo,
        fabricante: filters.fabricante,
        classeAgronomica: filters.classeAgronomica,
      );
      final entities = fitossanitarios.map(_convertToEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getRelatedDefensivos(
    String defensivoId, {
    int limit = 5,
  }) async {
    try {
      // Buscar o defensivo principal para obter ingrediente ativo
      final principalResult = await getById(defensivoId);
      return principalResult.fold(
        (failure) => Left(failure),
        (principal) async {
          if (principal == null) {
            return const Right(<DefensivoEntity>[]);
          }
          
          // Buscar relacionados por ingrediente ativo  
          final relatedResult = await searchByIngredienteAtivo(principal.ingredienteAtivo ?? '');
          return relatedResult.fold(
            (failure) => Left(failure),
            (related) {
              // Remover o defensivo principal e limitar
              final filtered = related
                  .where((d) => d.id != defensivoId)
                  .take(limit)
                  .toList();
              return Right(filtered);
            },
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar relacionados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getPopularDefensivos({int limit = 10}) async {
    try {
      // Retorna os primeiros como "populares" (pode ser implementado com lógica específica)
      final result = await getAll(limit: limit);
      return result;
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar populares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivosStats>> getStatistics() async {
    try {
      // Implementação simplificada para estatísticas
      final allResult = await getAll();
      return allResult.fold(
        (failure) => Left(failure),
        (defensivos) {
          final stats = DefensivosStats(
            total: defensivos.length,
            ativos: defensivos.where((d) => d.isActive).length,
            elegiveis: defensivos.where((d) => d.isElegible).length,
            inseticides: 0,
            herbicides: 0,
            fungicides: 0,
            acaricides: defensivos.length,
            byFabricante: <String, int>{},
            byClasseAgronomica: <String, int>{},
          );
          return Right(stats);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      final result = await getById(id);
      return result.fold(
        (failure) => Left(failure),
        (defensivo) => Right(defensivo != null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> countByFilters(DefensivoSearchFilters filters) async {
    try {
      final result = await searchAdvanced(filters);
      return result.fold(
        (failure) => Left(failure),
        (defensivos) => Right(defensivos.length),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao contar por filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllFabricantes() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          final fabricantes = defensivos
              .where((d) => d.fabricante?.isNotEmpty == true)
              .map((d) => d.fabricante!)
              .toSet()
              .toList()
            ..sort();
          return Right(fabricantes);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter fabricantes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllClassesAgronomicas() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          final classes = defensivos
              .where((d) => d.classeAgronomica?.isNotEmpty == true)
              .map((d) => d.classeAgronomica!)
              .toSet()
              .toList()
            ..sort();
          return Right(classes);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter classes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllIngredientesAtivos() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          final ingredientes = defensivos
              .where((d) => d.ingredienteAtivo?.isNotEmpty == true)
              .map((d) => d.ingredienteAtivo!)
              .toSet()
              .toList()
            ..sort();
          return Right(ingredientes);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter ingredientes ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getRecentDefensivos({int limit = 10}) async {
    try {
      final result = await getAll(limit: limit);
      return result;
    } catch (e) {
      return Left(CacheFailure('Erro ao obter recentes: ${e.toString()}'));
    }
  }

  /// Converte FitossanitarioHive para DefensivoEntity
  DefensivoEntity _convertToEntity(FitossanitarioHive fitossanitario) {
    return DefensivoEntity(
      id: fitossanitario.idReg,
      nomeComum: fitossanitario.nomeComum,
      nomeTecnico: fitossanitario.nomeComum, // Usando nomeComum como fallback
      ingredienteAtivo: fitossanitario.ingredienteAtivo,
      fabricante: fitossanitario.fabricante,
      classeAgronomica: fitossanitario.classeAgronomica,
      modoAcao: fitossanitario.modoAcao,
      quantProduto: fitossanitario.quantProduto,
      status: fitossanitario.status,
      comercializado: fitossanitario.comercializado,
      elegivel: fitossanitario.comercializado == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fitossanitario.createdAt ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fitossanitario.updatedAt ?? 0),
    );
  }
}