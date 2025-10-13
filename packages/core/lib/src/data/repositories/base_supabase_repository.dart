import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/cache/cache_service.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/secure_logger.dart';
import '../../shared/utils/supabase_failure.dart';

/// Repository base para operações CRUD com Supabase
///
/// Implementa padrão Repository com suporte a:
/// - CRUD completo (Create, Read, Update, Delete)
/// - Cache opcional
/// - Error handling com Either<Failure, T>
/// - Busca e filtragem
/// - Paginação
///
/// Exemplo de uso:
/// ```dart
/// class PlantsRepository extends BaseSupabaseRepository<PlantModel, PlantEntity> {
///   PlantsRepository(super.client) : super(tableName: 'plants');
///
///   @override
///   PlantEntity toEntity(Map<String, dynamic> json) {
///     return PlantModel.fromJson(json);
///   }
///
///   @override
///   Map<String, dynamic> toJson(PlantEntity entity) {
///     return (entity as PlantModel).toJson();
///   }
/// }
/// ```
abstract class BaseSupabaseRepository<TModel, TEntity> {
  final SupabaseClient client;
  final String tableName;
  final String idField;
  final bool enableCache;
  final Duration cacheDuration;

  BaseSupabaseRepository({
    required this.client,
    required this.tableName,
    this.idField = 'id',
    this.enableCache = false,
    this.cacheDuration = const Duration(minutes: 30),
  });

  // ==================== Abstract Methods ====================

  /// Converte JSON do Supabase para Entity do domínio
  TEntity toEntity(Map<String, dynamic> json);

  /// Converte Entity do domínio para JSON do Supabase
  Map<String, dynamic> toJson(TEntity entity);

  // ==================== CRUD Operations ====================

  /// Busca todos os registros
  Future<Either<Failure, List<TEntity>>> getAll({
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      final cacheKey = '${tableName}_all_${orderBy ?? 'default'}_$limit';

      // Tenta obter do cache
      if (enableCache) {
        final cached = await CacheService.get<List<dynamic>>(
          cacheKey,
          ttl: cacheDuration,
        );

        if (cached != null) {
          SecureLogger.debug('Cache hit para $cacheKey');
          final entities = cached
              .map((item) => toEntity(item as Map<String, dynamic>))
              .toList();
          return Right(entities);
        }
      }

      // Busca do banco
      dynamic query = client.from(tableName).select();

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response as List);
      final entities = data.map((json) => toEntity(json)).toList();

      // Salva no cache
      if (enableCache) {
        await CacheService.set(cacheKey, data, ttl: cacheDuration);
      }

      SecureLogger.debug('Buscados ${entities.length} registros de $tableName');
      return Right(entities);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao buscar registros de $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Busca registro por ID
  Future<Either<Failure, TEntity>> getById(String id) async {
    try {
      final cacheKey = '${tableName}_$id';

      // Tenta obter do cache
      if (enableCache) {
        final cached = await CacheService.get<Map<String, dynamic>>(
          cacheKey,
          ttl: cacheDuration,
        );

        if (cached != null) {
          SecureLogger.debug('Cache hit para $cacheKey');
          return Right(toEntity(cached));
        }
      }

      // Busca do banco
      final response = await client
          .from(tableName)
          .select()
          .eq(idField, id)
          .limit(1);

      if (response.isEmpty) {
        return Left(SupabaseNotFoundFailure('Registro não encontrado'));
      }

      final data = response.first as Map<String, dynamic>;
      final entity = toEntity(data);

      // Salva no cache
      if (enableCache) {
        await CacheService.set(cacheKey, data, ttl: cacheDuration);
      }

      SecureLogger.debug('Buscado registro $id de $tableName');
      return Right(entity);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao buscar registro $id de $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Cria novo registro
  Future<Either<Failure, TEntity>> create(TEntity entity) async {
    try {
      final json = toJson(entity);

      final response = await client
          .from(tableName)
          .insert(json)
          .select()
          .single();

      final data = response as Map<String, dynamic>;
      final createdEntity = toEntity(data);

      // Invalida cache
      if (enableCache) {
        await CacheService.invalidatePattern(tableName);
      }

      SecureLogger.debug('Registro criado em $tableName');
      return Right(createdEntity);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao criar registro em $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Atualiza registro existente
  Future<Either<Failure, TEntity>> update(String id, TEntity entity) async {
    try {
      final json = toJson(entity);

      final response = await client
          .from(tableName)
          .update(json)
          .eq(idField, id)
          .select()
          .single();

      final data = response as Map<String, dynamic>;
      final updatedEntity = toEntity(data);

      // Invalida cache
      if (enableCache) {
        await CacheService.invalidatePattern(tableName);
        await CacheService.remove('${tableName}_$id');
      }

      SecureLogger.debug('Registro $id atualizado em $tableName');
      return Right(updatedEntity);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao atualizar registro $id em $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Deleta registro
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await client.from(tableName).delete().eq(idField, id);

      // Invalida cache
      if (enableCache) {
        await CacheService.invalidatePattern(tableName);
        await CacheService.remove('${tableName}_$id');
      }

      SecureLogger.debug('Registro $id deletado de $tableName');
      return const Right(null);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao deletar registro $id de $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  // ==================== Query Operations ====================

  /// Busca com filtros customizados
  Future<Either<Failure, List<TEntity>>> search({
    required String field,
    required String query,
    int? limit,
  }) async {
    try {
      dynamic queryBuilder = client.from(tableName).select().ilike(field, '%$query%');

      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      final response = await queryBuilder;
      final data = List<Map<String, dynamic>>.from(response as List);
      final entities = data.map((json) => toEntity(json)).toList();

      SecureLogger.debug(
        'Busca em $tableName por "$query" retornou ${entities.length} resultados',
      );
      return Right(entities);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao buscar em $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Busca com múltiplos filtros
  Future<Either<Failure, List<TEntity>>> filter({
    required Map<String, dynamic> filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = client.from(tableName).select();

      // Aplica filtros
      filters.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            query = query.inFilter(key, value);
          } else {
            query = query.eq(key, value);
          }
        }
      });

      // Aplica ordenação
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Aplica limite
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response as List);
      final entities = data.map((json) => toEntity(json)).toList();

      SecureLogger.debug(
        'Filtro em $tableName retornou ${entities.length} resultados',
      );
      return Right(entities);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao filtrar em $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Busca com paginação
  Future<Either<Failure, List<TEntity>>> paginate({
    required int page,
    required int pageSize,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = client.from(tableName).select();

      // Aplica ordenação
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Aplica paginação
      final offset = (page - 1) * pageSize;
      query = query.range(offset, offset + pageSize - 1);

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response as List);
      final entities = data.map((json) => toEntity(json)).toList();

      SecureLogger.debug(
        'Página $page de $tableName retornou ${entities.length} resultados',
      );
      return Right(entities);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao paginar $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Conta registros
  Future<Either<Failure, int>> count({Map<String, dynamic>? filters}) async {
    try {
      dynamic query = client.from(tableName).select();

      // Aplica filtros se fornecidos
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      final response = await query.count(CountOption.exact);
      final count = (response.count ?? 0) as int;

      SecureLogger.debug('Contagem em $tableName: $count registros');
      return Right(count);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao contar registros de $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  /// Verifica se existe pelo menos um registro
  Future<Either<Failure, bool>> exists({
    String? field,
    Object? value,
  }) async {
    try {
      dynamic query = client.from(tableName).select();

      if (field != null && value != null) {
        query = query.eq(field, value);
      }

      query = query.limit(1);

      final response = await query;
      final exists = (response as List).isNotEmpty;

      SecureLogger.debug('Verificação de existência em $tableName: $exists');
      return Right(exists);
    } catch (e, stackTrace) {
      SecureLogger.error(
        'Erro ao verificar existência em $tableName',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(e.toSupabaseFailure());
    }
  }

  // ==================== Cache Management ====================

  /// Invalida todo o cache desta tabela
  Future<void> invalidateCache() async {
    if (enableCache) {
      await CacheService.invalidatePattern(tableName);
      SecureLogger.debug('Cache invalidado para $tableName');
    }
  }

  /// Pré-carrega dados no cache
  Future<void> preloadCache() async {
    if (enableCache) {
      await getAll();
      SecureLogger.debug('Cache pré-carregado para $tableName');
    }
  }
}
