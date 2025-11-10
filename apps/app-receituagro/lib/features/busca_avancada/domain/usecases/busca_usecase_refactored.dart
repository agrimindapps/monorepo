import 'package:core/core.dart' hide Column;
import '../repositories/i_busca_repository.dart';
import 'busca_params.dart';

/// Use case consolidado para busca avançada
/// Consolida 7 usecases em 1 genérico com type-safe params
@injectable
class BuscaUseCase implements UseCase<dynamic, BuscaParams> {
  final IBuscaRepository repository;

  BuscaUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(BuscaParams params) async {
    if (params is BuscarComFiltrosParams) {
      if (!params.filters.hasActiveFilters) {
        return const Left(
          ValidationFailure('Pelo menos um filtro deve ser selecionado'),
        );
      }
      final result = await repository.buscarComFiltros(params.filters);
      result.fold(
        (failure) => null,
        (resultados) => unawaited(
          repository.salvarHistoricoBusca(params.filters, resultados),
        ),
      );
      return result;
    }

    if (params is BuscarPorTextoParams) {
      if (params.query.trim().isEmpty) {
        return const Left(
          ValidationFailure('Texto de busca não pode ser vazio'),
        );
      }
      return await repository.buscarPorTexto(
        params.query,
        tipos: params.tipos,
        limit: params.limit,
      );
    }

    if (params is GetBuscaMetadosParams) {
      return await repository.getMetadados();
    }

    if (params is GetSugestoesParams) {
      return await repository.getSugestoes(limit: params.limit);
    }

    if (params is BuscarDiagnosticosParams) {
      return await repository.buscarDiagnosticos(
        culturaId: params.culturaId,
        pragaId: params.pragaId,
        defensivoId: params.defensivoId,
      );
    }

    if (params is GetHistoricoBuscaParams) {
      return await repository.getHistoricoBusca(limit: params.limit);
    }

    if (params is LimparCacheBuscaParams) {
      return await repository.limparCache();
    }

    return const Left(
      UnknownFailure('Tipo de parâmetro desconhecido para BuscaUseCase'),
    );
  }
}
