import 'package:core/core.dart' hide Column;

import '../../presentation/services/pragas_cultura_error_message_service.dart';
import '../repositories/i_pragas_cultura_repository.dart';

/// Use Case para carregar todas as culturas disponíveis.
///
/// Responsabilidade: Buscar lista completa de culturas sem filtros
/// Parâmetros: Nenhum (NoParams)
/// Retorno: Either<Failure, List<dynamic>> com as culturas disponíveis
/// Validações: Nenhuma (apenas carrega)
@injectable
class GetCulturasUseCase {
  final IPragasCulturaRepository _repository;
  final PragasCulturaErrorMessageService errorService;

  const GetCulturasUseCase(this._repository, this.errorService);

  /// Executa a busca de todas as culturas.
  ///
  /// Retorna um [Future] contendo:
  /// - [Right] com [List<dynamic>] de culturas em caso de sucesso
  /// - [Left] com [Failure] em caso de erro
  Future<Either<Failure, List<dynamic>>> call() async {
    try {
      // Carrega as culturas do repositório
      final result = await _repository.getCulturas();
      return result;
    } catch (e) {
      return Left(
        UnexpectedFailure(errorService.getLoadCulturasError(e.toString())),
      );
    }
  }
}
