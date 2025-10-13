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
}
