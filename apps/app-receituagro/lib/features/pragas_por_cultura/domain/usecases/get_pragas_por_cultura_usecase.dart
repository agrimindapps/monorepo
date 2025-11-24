import 'package:core/core.dart' hide Column;

import '../../presentation/services/pragas_cultura_error_message_service.dart';
import '../repositories/i_pragas_cultura_repository.dart';
import 'pragas_cultura_params.dart';

/// Use Case para carregar pragas de uma cultura específica.
///
/// Responsabilidade: Buscar pragas associadas a uma cultura
/// Parâmetros: [GetPragasPorCulturaParams] com culturaId
/// Retorno: Either<Failure, List<dynamic>> com as pragas da cultura
/// Validações: culturaId não vazio

class GetPragasPorCulturaUseCase {
  final IPragasCulturaRepository _repository;
  final PragasCulturaErrorMessageService errorService;

  const GetPragasPorCulturaUseCase(this._repository, this.errorService);

  /// Executa a busca de pragas para uma cultura.
  ///
  /// Parâmetros:
  /// - [params] contém [culturaId] obrigatório
  ///
  /// Retorna um [Future] contendo:
  /// - [Right] com [List<dynamic>] de pragas em caso de sucesso
  /// - [Left] com [Failure] em caso de erro ou validação falha
  ///
  /// Validações:
  /// - culturaId não pode ser vazio ou nulo
  Future<Either<Failure, List<dynamic>>> call(
    GetPragasPorCulturaParams params,
  ) async {
    try {
      // Valida se o culturaId não está vazio
      if (params.culturaId.trim().isEmpty) {
        return Left(ValidationFailure(errorService.getEmptyCulturaIdError()));
      }

      // Busca as pragas da cultura no repositório
      final result = await _repository.getPragasPorCultura(params.culturaId);
      return result;
    } catch (e) {
      return Left(
        UnexpectedFailure(errorService.getLoadPragasError(e.toString())),
      );
    }
  }
}
