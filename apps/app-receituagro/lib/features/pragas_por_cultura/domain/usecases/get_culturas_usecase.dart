import 'package:core/core.dart';

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

  const GetCulturasUseCase(this._repository);

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
        UnexpectedFailure('Erro ao carregar culturas: ${e.toString()}'),
      );
    }
  }
}
