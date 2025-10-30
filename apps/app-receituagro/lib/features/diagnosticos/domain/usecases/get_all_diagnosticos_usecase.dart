import 'package:core/core.dart';

import '../entities/diagnostico_entity.dart';
import '../repositories/i_diagnosticos_repository.dart';

/// Use Case para buscar todos os diagnósticos com paginação
/// Responsabilidade única: Retornar lista completa de diagnósticos
@injectable
class GetAllDiagnosticosUseCase {
  final IDiagnosticosRepository _repository;

  const GetAllDiagnosticosUseCase(this._repository);

  /// Retorna lista de todos os diagnósticos
  ///
  /// Parâmetros:
  /// - [limit]: Quantidade máxima de registros a retornar (opcional)
  /// - [offset]: Número de registros a pular para paginação (opcional)
  ///
  /// Retorna: Either com List<DiagnosticoEntity> ou Failure
  Future<Either<Failure, List<DiagnosticoEntity>>> call({
    int? limit,
    int? offset,
  }) async {
    try {
      if (limit != null && limit <= 0) {
        return const Left(CacheFailure('Limit deve ser maior que 0'));
      }

      if (offset != null && offset < 0) {
        return const Left(CacheFailure('Offset não pode ser negativo'));
      }

      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }
}
