import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/culturas_repository.dart';
import '../../../../core/data/repositories/fitossanitario_legacy_repository.dart';
import '../../../../features/culturas/data/mappers/cultura_mapper.dart';
import '../../domain/repositories/i_pragas_cultura_repository.dart';
import '../../presentation/services/pragas_cultura_error_message_service.dart';
import '../datasources/pragas_cultura_integration_datasource.dart';
import '../datasources/pragas_cultura_local_datasource.dart';

/// Implementação do repositório de Pragas por Cultura
///
/// Padrão: Repository Pattern com estratégia Cache-First
/// Segue Clean Architecture + Either[Failure, T] para tratamento de erros
///
/// Orquestração entre:
/// - PragasCulturaIntegrationDataSource (integração de dados)
/// - PragasCulturaLocalDataSource (cache local)
/// - Repositórios base (CulturasRepository Drift, FitossanitarioLegacyRepository)
@LazySingleton(as: IPragasCulturaRepository)
class PragasCulturaRepositoryImpl implements IPragasCulturaRepository {
  final PragasCulturaIntegrationDataSource integrationDataSource;
  final PragasCulturaLocalDataSource localDataSource;
  final CulturasRepository culturaRepository;
  final FitossanitarioLegacyRepository fitossanitarioRepository;
  final PragasCulturaErrorMessageService errorService;

  const PragasCulturaRepositoryImpl({
    required this.integrationDataSource,
    required this.localDataSource,
    required this.culturaRepository,
    required this.fitossanitarioRepository,
    required this.errorService,
  });

  @override
  Future<Either<Failure, List<dynamic>>> getCulturas() async {
    try {
      // Buscar culturas diretamente do repositório Drift
      final culturas = await culturaRepository.findAll();

      // Convert Drift models to entities
      final culturasEntities = CulturaMapper.fromDriftToEntityList(culturas);

      return Right(culturasEntities as List<dynamic>);
    } catch (e) {
      return Left(
        CacheFailure(errorService.getLoadCulturasError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getPragasPorCultura(
    String culturaId,
  ) async {
    try {
      // Validar ID
      if (culturaId.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyCulturaIdError()));
      }

      // ESTRATÉGIA: Cache-First
      // 1. Tentar obter do cache local
      final cached = await localDataSource.getCachedPragas(culturaId);
      if (cached != null && cached.isNotEmpty) {
        return Right(cached);
      }

      // 2. Se não houver cache, buscar da integração
      final pragas = await integrationDataSource.getPragasPorCultura(culturaId);

      // 3. Cache resultado (fire-and-forget, não bloqueia)
      unawaited(localDataSource.cachePragas(culturaId, pragas));

      return Right(pragas);
    } on ValidationFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(errorService.getLoadPragasError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getDefensivos(String pragaId) async {
    try {
      // Validar ID
      if (pragaId.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyPragaIdError()));
      }

      // Obter defensivos do repositório Hive
      final result = await fitossanitarioRepository.getAll();

      if (result.isFailure) {
        return Left(
          CacheFailure(
            errorService.getLoadDefensivosError(result.error?.message),
          ),
        );
      }

      final defensivos = result.data ?? [];

      // Filtrar apenas defensivos elegíveis e ativos
      final List<dynamic> defensivosElegibles = defensivos
          .where((dynamic d) => d.status == true && d.comercializado == 1)
          .toList();

      return Right(defensivosElegibles);
    } catch (e) {
      return Left(
        CacheFailure(errorService.getLoadDefensivosError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cachePragas(
    String culturaId,
    List<dynamic> pragas,
  ) async {
    try {
      // Validar parâmetros
      if (culturaId.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyCulturaIdError()));
      }

      if (pragas.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyPragasListError()));
      }

      // Armazenar em cache
      await localDataSource.cachePragas(culturaId, pragas);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(errorService.getCachePragasError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache(String culturaId) async {
    try {
      // Validar ID
      if (culturaId.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyCulturaIdError()));
      }

      // Limpar cache
      await localDataSource.clearCache(culturaId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(errorService.getClearCacheError(e.toString())));
    }
  }

  /// Limpa todo o cache de pragas
  /// Útil para sincronização ou reset completo
  Future<Either<Failure, void>> clearAllCache() async {
    try {
      await localDataSource.clearAllCache();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left(
        CacheFailure(errorService.getClearAllCacheError(e.toString())),
      );
    }
  }

  /// Obtém praga completa com dados integrados
  /// Usado para tela detalhada
  ///
  /// [pragaId]: ID da praga
  /// [culturaId]: ID da cultura
  Future<Either<Failure, Map<String, dynamic>>> getPragaCompleta(
    String pragaId,
    String culturaId,
  ) async {
    try {
      // Validar IDs
      if (pragaId.isEmpty || culturaId.isEmpty) {
        return Left(ValidationFailure(errorService.getRequiredIdsError()));
      }

      // Buscar praga completa com integração
      final pragaCompleta = await integrationDataSource.getPragaCompleta(
        pragaId,
        culturaId,
      );

      return Right(pragaCompleta);
    } catch (e) {
      return Left(
        ServerFailure(errorService.getFetchFullPragaError(e.toString())),
      );
    }
  }

  /// Obtém estatísticas de cache (debug/admin)
  Future<Either<Failure, Map<String, dynamic>>> getCacheStats() async {
    try {
      final stats = await localDataSource.getCacheStats();
      return Right(stats);
    } catch (e) {
      return Left(
        CacheFailure(errorService.getGetCacheStatsError(e.toString())),
      );
    }
  }

  /// Verifica se existe cache válido para uma cultura
  Future<Either<Failure, bool>> hasCachedPragas(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyCulturaIdError()));
      }

      final hasCached = await localDataSource.hasCachedPragas(culturaId);
      return Right(hasCached);
    } catch (e) {
      return Left(CacheFailure(errorService.getVerifyCacheError(e.toString())));
    }
  }
}
