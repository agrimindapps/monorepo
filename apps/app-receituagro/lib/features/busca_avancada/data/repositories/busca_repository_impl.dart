import 'package:core/core.dart' hide Column;

import '../../domain/entities/busca_entity.dart';
import '../../domain/repositories/i_busca_repository.dart';

/// Stub implementation of IBuscaRepository
/// TODO: Implement full business logic in future phase
///
/// Currently returns NotImplemented failures for all operations
/// to satisfy Injectable dependencies without breaking build.
@LazySingleton(as: IBuscaRepository)
class BuscaRepositoryImpl implements IBuscaRepository {
  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarComFiltros(
    BuscaFiltersEntity filters,
  ) async {
    return Left(
      UnknownFailure('buscarComFiltros not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPorTexto(
    String query, {
    List<String>? tipos,
    int? limit,
  }) async {
    return Left(
      UnknownFailure('buscarPorTexto not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    return Left(
      UnknownFailure('buscarDiagnosticos not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPragasPorCultura(
    String culturaId,
  ) async {
    return Left(
      UnknownFailure('buscarPragasPorCultura not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDefensivosPorPraga(
    String pragaId,
  ) async {
    return Left(
      UnknownFailure('buscarDefensivosPorPraga not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, BuscaMetadataEntity>> getMetadados() async {
    return Left(
      UnknownFailure('getMetadados not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> getSugestoes({
    int limit = 10,
  }) async {
    return Left(
      UnknownFailure('getSugestoes not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, void>> salvarHistoricoBusca(
    BuscaFiltersEntity filters,
    List<BuscaResultEntity> resultados,
  ) async {
    return Left(
      UnknownFailure('salvarHistoricoBusca not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, List<BuscaFiltersEntity>>> getHistoricoBusca({
    int limit = 20,
  }) async {
    return Left(
      UnknownFailure('getHistoricoBusca not yet implemented'),
    );
  }

  @override
  Future<Either<Failure, void>> limparCache() async {
    return Left(
      UnknownFailure('limparCache not yet implemented'),
    );
  }
}
