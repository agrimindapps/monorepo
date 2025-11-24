import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';
import '../repositories/i_diagnosticos_repository.dart';

/// Use Case para buscar diagnóstico específico por ID
/// Responsabilidade única: Retornar um diagnóstico ou null

class GetDiagnosticoByIdUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticoByIdUseCase(this._repository);

  /// Retorna um diagnóstico específico
  ///
  /// Parâmetros:
  /// - [id]: ID único do diagnóstico
  ///
  /// Retorna: Either com DiagnosticoEntity? ou Failure
  /// - Retorna null se não encontrar
  Future<Either<Failure, DiagnosticoEntity?>> call(String id) async {
    try {
      if (id.isEmpty) {
        return const Left(
          CacheFailure('ID do diagnóstico não pode estar vazio'),
        );
      }

      return await _repository.getById(id);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar diagnóstico por ID: ${e.toString()}'),
      );
    }
  }
}
