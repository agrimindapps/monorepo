import 'package:core/core.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../domain/repositories/i_pragas_cultura_repository.dart';
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
/// - Repositórios base (CulturaHiveRepository, FitossanitarioHiveRepository)
@LazySingleton(as: IPragasCulturaRepository)
class PragasCulturaRepositoryImpl implements IPragasCulturaRepository {
  final PragasCulturaIntegrationDataSource integrationDataSource;
  final PragasCulturaLocalDataSource localDataSource;
  final CulturaHiveRepository culturaRepository;
  final FitossanitarioHiveRepository fitossanitarioRepository;

  const PragasCulturaRepositoryImpl({
    required this.integrationDataSource,
    required this.localDataSource,
    required this.culturaRepository,
    required this.fitossanitarioRepository,
  });

  @override
  Future<Either<Failure, List<dynamic>>> getCulturas() async {
    try {
      // Buscar culturas diretamente do repositório Hive
      final result = await culturaRepository.getAll();

      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao carregar culturas: ${result.error?.message}'),
        );
      }

      final culturas = result.data ?? [];
      return Right(culturas as List<dynamic>);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar culturas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getPragasPorCultura(String culturaId) async {
    try {
      // Validar ID
      if (culturaId.isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
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
      return Left(ServerFailure('Erro ao carregar pragas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getDefensivos(String pragaId) async {
    try {
      // Validar ID
      if (pragaId.isEmpty) {
        return const Left(
          ValidationFailure('ID da praga não pode ser vazio'),
        );
      }

      // Obter defensivos do repositório Hive
      final result = await fitossanitarioRepository.getAll();

      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao carregar defensivos: ${result.error?.message}'),
        );
      }

      final defensivos = result.data ?? [];

      // Filtrar apenas defensivos elegíveis e ativos
      final List<dynamic> defensivosElegibles = defensivos
          .where((dynamic d) => d.status == true && d.comercializado == 1)
          .toList();

      return Right(defensivosElegibles);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar defensivos: $e'));
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
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      if (pragas.isEmpty) {
        return const Left(
          ValidationFailure('Lista de pragas não pode estar vazia'),
        );
      }

      // Armazenar em cache
      await localDataSource.cachePragas(culturaId, pragas);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao cachear pragas: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache(String culturaId) async {
    try {
      // Validar ID
      if (culturaId.isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      // Limpar cache
      await localDataSource.clearCache(culturaId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  /// Limpa todo o cache de pragas
  /// Útil para sincronização ou reset completo
  Future<Either<Failure, void>> clearAllCache() async {
    try {
      await localDataSource.clearAllCache();
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache completo: $e'));
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
        return const Left(
          ValidationFailure('pragaId e culturaId são obrigatórios'),
        );
      }

      // Buscar praga completa com integração
      final pragaCompleta =
          await integrationDataSource.getPragaCompleta(pragaId, culturaId);

      return Right(pragaCompleta);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar praga completa: $e'));
    }
  }

  /// Obtém estatísticas de cache (debug/admin)
  Future<Either<Failure, Map<String, dynamic>>> getCacheStats() async {
    try {
      final stats = await localDataSource.getCacheStats();
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas de cache: $e'));
    }
  }

  /// Verifica se existe cache válido para uma cultura
  Future<Either<Failure, bool>> hasCachedPragas(String culturaId) async {
    try {
      if (culturaId.isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      final hasCached = await localDataSource.hasCachedPragas(culturaId);
      return Right(hasCached);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar cache: $e'));
    }
  }
}
