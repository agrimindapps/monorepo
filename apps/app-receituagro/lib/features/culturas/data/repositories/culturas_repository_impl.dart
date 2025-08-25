import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/models/cultura_hive.dart';
import '../../../../core/repositories/cultura_core_repository.dart';
import '../../domain/entities/cultura_entity.dart';
import '../../domain/repositories/i_culturas_repository.dart';
import '../mappers/cultura_mapper.dart';

/// Implementação do repositório de culturas (Data Layer)
/// Conecta o domínio com o Core Package
class CulturasRepositoryImpl implements ICulturasRepository {
  final CulturaCoreRepository _coreRepository;

  const CulturasRepositoryImpl(this._coreRepository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final culturasHive = await _coreRepository.getAllAsync();
      
      // Aplicar paginação se necessário
      List<dynamic> culturasPaginated = culturasHive;
      if (offset != null && offset > 0) {
        culturasPaginated = culturasHive.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        culturasPaginated = culturasPaginated.take(limit).toList();
      }
      
      final entities = culturasPaginated
          .whereType<CulturaHive>()
          .map((hive) => CulturaMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CulturaEntity?>> getById(String id) async {
    try {
      final culturaHive = await _coreRepository.getByIdAsync(id);
      if (culturaHive == null) {
        return const Right(null);
      }
      
      final entity = CulturaMapper.fromHive(culturaHive);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getActiveCulturas() async {
    try {
      final culturasHive = await _coreRepository.getActiveCulturas();
      final entities = culturasHive
          .map((hive) => CulturaMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas ativas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CulturaEntity?>> getByNome(String nome) async {
    try {
      final culturaHive = await _coreRepository.findByName(nome);
      if (culturaHive == null) {
        return const Right(null);
      }
      
      final entity = CulturaMapper.fromHive(culturaHive);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchByNome(String searchTerm) async {
    try {
      final culturasHive = await _coreRepository.searchByName(searchTerm);
      final entities = culturasHive
          .map((hive) => CulturaMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchByFamilia(String familia) async {
    try {
      // Como CulturaHive não tem campo família, fazemos busca por nome que contenha a família
      final culturasHive = await _coreRepository.searchByCriteria(familia: familia);
      final entities = culturasHive
          .map((hive) => CulturaMapper.fromHive(hive))
          .where((entity) => entity.familia?.toLowerCase().contains(familia.toLowerCase()) == true)
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por família: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchByTipo(CulturaTipo tipo) async {
    try {
      // Busca todas as culturas e filtra por tipo
      final allResult = await getActiveCulturas();
      return allResult.fold(
        (failure) => Left(failure),
        (culturas) {
          final filtered = culturas
              .where((cultura) => cultura.tipo == tipo)
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por tipo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchByMultipleCriteria({
    String? nome,
    String? familia,
    String? categoria,
    CulturaTipo? tipo,
    bool? isAtiva,
  }) async {
    try {
      // Inicia com todas as culturas ativas ou todas conforme isAtiva
      final baseResult = isAtiva == false 
          ? await getAll()
          : await getActiveCulturas();
      
      return baseResult.fold(
        (failure) => Left(failure),
        (culturas) {
          var filtered = culturas;
          
          // Aplicar filtros
          if (nome?.isNotEmpty == true) {
            filtered = filtered
                .where((c) => c.nome.toLowerCase().contains(nome!.toLowerCase()))
                .toList();
          }
          
          if (familia?.isNotEmpty == true) {
            filtered = filtered
                .where((c) => c.familia?.toLowerCase().contains(familia!.toLowerCase()) == true)
                .toList();
          }
          
          if (categoria?.isNotEmpty == true) {
            filtered = filtered
                .where((c) => c.categoria?.toLowerCase().contains(categoria!.toLowerCase()) == true)
                .toList();
          }
          
          if (tipo != null) {
            filtered = filtered.where((c) => c.tipo == tipo).toList();
          }
          
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro na busca múltipla: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchWithFilters(
    CulturaSearchFilters filters,
  ) async {
    return await searchByMultipleCriteria(
      nome: filters.nome,
      familia: filters.familia,
      categoria: filters.categoria,
      tipo: filters.tipo,
      isAtiva: filters.isAtiva,
    );
  }

  @override
  Future<Either<Failure, CulturasStats>> getStatistics() async {
    try {
      final stats = await _coreRepository.getCulturaStats();
      final statsEntity = CulturaMapper.statsFromHiveStats(stats);
      return Right(statsEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaPopular>>> getPopularCulturas({
    int limit = 10,
  }) async {
    try {
      final statsResult = await getStatistics();
      return statsResult.fold(
        (failure) => Left(failure),
        (stats) => Right(stats.topCulturas.take(limit).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas populares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getRelatedCulturas(
    String culturaId, {
    int limit = 5,
  }) async {
    try {
      // Busca a cultura original
      final originalResult = await getById(culturaId);
      if (originalResult.isLeft()) {
        return const Left(CacheFailure('Cultura original não encontrada'));
      }

      final original = originalResult.fold(
        (failure) => null,
        (cultura) => cultura,
      );
      if (original == null) {
        return const Right(<CulturaEntity>[]);
      }

      // Busca culturas do mesmo tipo
      final relatedResult = await searchByTipo(original.tipo);
      
      return relatedResult.fold(
        (failure) => Left(failure),
        (culturas) {
          // Remove a cultura original e limita resultados
          final related = culturas
              .where((c) => c.id != culturaId)
              .take(limit)
              .toList();
          return Right(related);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas relacionadas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      final result = await getById(id);
      return result.fold(
        (failure) => Left(failure),
        (cultura) => Right(cultura != null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> existsByNome(String nome) async {
    try {
      final exists = await _coreRepository.culturaExists(nome);
      return Right(exists);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> countByFilters(CulturaSearchFilters filters) async {
    try {
      final result = await searchWithFilters(filters);
      return result.fold(
        (failure) => Left(failure),
        (culturas) => Right(culturas.length),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao contar por filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaTipo>>> getAllTipos() async {
    try {
      // Retorna todos os tipos possíveis de cultura
      return const Right(CulturaTipo.values);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter tipos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllFamilias() async {
    try {
      final result = await getActiveCulturas();
      return result.fold(
        (failure) => Left(failure),
        (culturas) {
          final familias = CulturaMapper.extractUniqueFamilias(culturas)
              .where((familia) => familia.isNotEmpty)
              .toList();
          return Right(familias);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter famílias: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategorias() async {
    try {
      final result = await getActiveCulturas();
      return result.fold(
        (failure) => Left(failure),
        (culturas) {
          final categorias = CulturaMapper.extractUniqueCategorias(culturas)
              .where((categoria) => categoria.isNotEmpty)
              .toList();
          return Right(categorias);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter categorias: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getRecentCulturas({
    int limit = 10,
  }) async {
    try {
      final result = await getActiveCulturas();
      return result.fold(
        (failure) => Left(failure),
        (culturas) {
          // Ordena por data de criação/atualização (mais recentes primeiro)
          final sorted = List<CulturaEntity>.from(culturas);
          sorted.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
          
          return Right(sorted.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateCulturaData(CulturaEntity cultura) async {
    try {
      // Validações básicas
      if (!cultura.isValid) {
        return const Right(false);
      }

      // Verifica se já existe cultura com mesmo nome (exceto ela mesma)
      final existsResult = await existsByNome(cultura.nome);
      return existsResult.fold(
        (failure) => Left(failure),
        (exists) {
          if (exists) {
            // Se existe, verifica se é a mesma cultura (para updates)
            return getByNome(cultura.nome).then((result) {
              return result.fold(
                (failure) => Left(failure),
                (existing) {
                  if (existing != null && existing.id != cultura.id) {
                    return const Right(false); // Já existe outra cultura com mesmo nome
                  }
                  return const Right(true);
                },
              );
            });
          }
          return const Right(true);
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchByPattern(String pattern) async {
    try {
      // Busca por nome que contenha o padrão
      final byNomeResult = await searchByNome(pattern);
      
      return byNomeResult.fold(
        (failure) => Left(failure),
        (culturas) {
          // Também busca na descrição se disponível
          final filtered = culturas.where((cultura) {
            final nomeMatch = cultura.nome.toLowerCase().contains(pattern.toLowerCase());
            final descricaoMatch = cultura.descricao?.toLowerCase().contains(pattern.toLowerCase()) == true;
            return nomeMatch || descricaoMatch;
          }).toList();
          
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }
}