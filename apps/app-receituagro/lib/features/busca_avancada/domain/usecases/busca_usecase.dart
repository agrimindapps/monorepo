import 'package:core/core.dart' hide Column;
import '../entities/busca_entity.dart';
import '../repositories/i_busca_repository.dart';

/// Use case para busca com filtros
@injectable
class BuscarComFiltrosUseCase
    implements UseCase<List<BuscaResultEntity>, BuscaFiltersEntity> {
  final IBuscaRepository repository;

  BuscarComFiltrosUseCase(this.repository);

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> call(
    BuscaFiltersEntity filters,
  ) async {
    if (!filters.hasActiveFilters) {
      return const Left(
        ValidationFailure('Pelo menos um filtro deve ser selecionado'),
      );
    }
    final result = await repository.buscarComFiltros(filters);
    result.fold(
      (failure) => null,
      (resultados) =>
          unawaited(repository.salvarHistoricoBusca(filters, resultados)),
    );

    return result;
  }
}

/// Use case para busca por texto
@injectable
class BuscarPorTextoUseCase
    implements UseCase<List<BuscaResultEntity>, BuscarPorTextoParams> {
  final IBuscaRepository repository;

  BuscarPorTextoUseCase(this.repository);

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> call(
    BuscarPorTextoParams params,
  ) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure('Texto de busca não pode ser vazio'));
    }

    return await repository.buscarPorTexto(
      params.query,
      tipos: params.tipos,
      limit: params.limit,
    );
  }
}

/// Use case para caregar metadados
@injectable
class GetBuscaMetadosUseCase implements UseCase<BuscaMetadataEntity, NoParams> {
  final IBuscaRepository repository;

  GetBuscaMetadosUseCase(this.repository);

  @override
  Future<Either<Failure, BuscaMetadataEntity>> call(NoParams params) async {
    return await repository.getMetadados();
  }
}

/// Use case para obter sugestões
@injectable
class GetSugestoesUseCase implements UseCase<List<BuscaResultEntity>, int?> {
  final IBuscaRepository repository;

  GetSugestoesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> call(int? limit) async {
    return await repository.getSugestoes(limit: limit ?? 10);
  }
}

/// Use case para buscar diagnósticos específicos
@injectable
class BuscarDiagnosticosUseCase
    implements UseCase<List<BuscaResultEntity>, BuscarDiagnosticosParams> {
  final IBuscaRepository repository;

  BuscarDiagnosticosUseCase(this.repository);

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> call(
    BuscarDiagnosticosParams params,
  ) async {
    return await repository.buscarDiagnosticos(
      culturaId: params.culturaId,
      pragaId: params.pragaId,
      defensivoId: params.defensivoId,
    );
  }
}

/// Use case para obter histórico
@injectable
class GetHistoricoBuscaUseCase
    implements UseCase<List<BuscaFiltersEntity>, int?> {
  final IBuscaRepository repository;

  GetHistoricoBuscaUseCase(this.repository);

  @override
  Future<Either<Failure, List<BuscaFiltersEntity>>> call(int? limit) async {
    return await repository.getHistoricoBusca(limit: limit ?? 20);
  }
}

/// Use case para limpar cache
@injectable
class LimparCacheUseCase implements UseCase<void, NoParams> {
  final IBuscaRepository repository;

  LimparCacheUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.limparCache();
  }
}

class BuscarPorTextoParams {
  final String query;
  final List<String>? tipos;
  final int? limit;

  BuscarPorTextoParams({required this.query, this.tipos, this.limit});
}

class BuscarDiagnosticosParams {
  final String? culturaId;
  final String? pragaId;
  final String? defensivoId;

  BuscarDiagnosticosParams({this.culturaId, this.pragaId, this.defensivoId});
}
