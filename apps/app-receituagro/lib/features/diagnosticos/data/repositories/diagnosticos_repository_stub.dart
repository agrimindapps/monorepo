import 'package:core/core.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';

/// Stub temporário para IDiagnosticosRepository
/// EMERGENCY FIX: Esta implementação retorna dados vazios/padrão para evitar erros
/// durante a correção do sistema Hive
class DiagnosticosRepositoryStub implements IDiagnosticosRepository {
  const DiagnosticosRepositoryStub();

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    // Retorna lista vazia para evitar erros
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(String idDefensivo) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCultura(String idCultura) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByPraga(String idPraga) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }


  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTipoAplicacao(TipoAplicacao tipo) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCompletude(DiagnosticoCompletude completude) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByFaixaDosagem({
    required double dosagemMinima,
    required double dosagemMaxima,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, DiagnosticosStats>> getStatistics() async {
    const stats = DiagnosticosStats(
      total: 0,
      completos: 0,
      parciais: 0,
      incompletos: 0,
      porDefensivo: <String, int>{},
      porCultura: <String, int>{},
      porPraga: <String, int>{},
      topDiagnosticos: <DiagnosticoPopular>[],
    );
    return const Right(stats);
  }

  @override
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    return const Right(<DiagnosticoPopular>[]);
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, int>> countByFilters(DiagnosticoSearchFilters filters) async {
    return const Right(0);
  }

  @override
  Future<Either<Failure, List<String>>> getAllDefensivos() async {
    return const Right(<String>[]);
  }

  @override
  Future<Either<Failure, List<String>>> getAllCulturas() async {
    return const Right(<String>[]);
  }

  @override
  Future<Either<Failure, List<String>>> getAllPragas() async {
    return const Right(<String>[]);
  }

  @override
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, List<String>>> getUnidadesMedida() async {
    return const Right(<String>['L/ha', 'kg/ha', 'g/100L']);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(String pattern) async {
    return const Right(<DiagnosticoEntity>[]);
  }
}