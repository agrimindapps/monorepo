import 'package:core/core.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';

/// Stub temporário para IDiagnosticosRepository
/// REFACTORED: Updated to match simplified interface (Phase 4 - God Object Refactoring)
/// Esta implementação retorna dados vazios/padrão para evitar erros durante testes
class DiagnosticosRepositoryStub implements IDiagnosticosRepository {
  const DiagnosticosRepositoryStub();

  // ========== CRUD Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    return const Right(null);
  }

  // ========== Basic Query Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByDefensivo(
    String idDefensivo,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByCultura(
    String idCultura,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPraga(
    String idPraga,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPattern(
    String pattern,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  // ========== Metadata Operations ==========

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllDefensivos() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCulturas() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllPragas() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<String>>> getUnidadesMedida() async {
    return const Right(<String>[]);
  }

  // ========== Recommendation Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String culturaId,
    required String pragaId,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  // ========== Search Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters({
    String? defensivo,
    String? cultura,
    String? praga,
    String? tipoAplicacao,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String idDiagnostico,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  // ========== Statistics Operations ==========

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    return const Right(<String, dynamic>{
      'total': 0,
      'totalDefensivos': 0,
      'totalCulturas': 0,
      'totalPragas': 0,
    });
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, int>> countByFilters({
    String? defensivo,
    String? cultura,
    String? praga,
  }) async {
    return const Right(0);
  }

  // ========== Validation Operations ==========

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    return const Right(false);
  }

  // ========== Legacy Methods ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(
    String defensivoId,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCultura(
    String culturaId,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByPraga(
    String pragaId,
  ) async {
    return const Right(<DiagnosticoEntity>[]);
  }
}
