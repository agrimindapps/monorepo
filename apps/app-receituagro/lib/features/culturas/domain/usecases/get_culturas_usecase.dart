import 'package:core/core.dart';

import '../entities/cultura_entity.dart';
import '../repositories/i_culturas_repository.dart';
import 'get_culturas_params.dart';

/// Use Case consolidado para todas as operações de culturas
@injectable
class GetCulturasUseCase {
  final ICulturasRepository repository;

  const GetCulturasUseCase(this.repository);

  Future<Either<Failure, dynamic>> call(GetCulturasParams params) async {
    return switch (params) {
      GetAllCulturasParams p => await _getAll(p),
      GetCulturasByGrupoParams p => await _getByGrupo(p),
      GetCulturaByIdParams p => await _getById(p),
      SearchCulturasParams p => await _search(p),
      GetGruposCulturasParams p => await _getGrupos(p),
      _ => const Left(CacheFailure('Parâmetros inválidos para culturas')),
    };
  }

  Future<Either<Failure, List<CulturaEntity>>> _getAll(
    GetAllCulturasParams params,
  ) async {
    try {
      return await repository.getAllCulturas();
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<CulturaEntity>>> _getByGrupo(
    GetCulturasByGrupoParams params,
  ) async {
    try {
      return await repository.getCulturasByGrupo(params.grupo);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar culturas por grupo: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, CulturaEntity?>> _getById(
    GetCulturaByIdParams params,
  ) async {
    try {
      if (params.id.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      return await repository.getCulturaById(params.id);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<CulturaEntity>>> _search(
    SearchCulturasParams params,
  ) async {
    try {
      if (params.query.trim().isEmpty) {
        return await repository.getAllCulturas();
      }
      return await repository.searchCulturas(params.query);
    } catch (e) {
      return Left(CacheFailure('Erro na busca de culturas: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<String>>> _getGrupos(
    GetGruposCulturasParams params,
  ) async {
    try {
      return await repository.getGruposCulturas();
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar grupos de culturas: ${e.toString()}'),
      );
    }
  }
}

/// ============================================================================
/// DEPRECATED - As classes abaixo foram consolidadas na classe GetCulturasUseCase
/// Use a classe consolidada com tipos GetCulturasParams
/// ============================================================================

/// Use case para buscar todas as culturas [DEPRECATED]
@deprecated
@injectable
class GetAllCulturasUseCase implements UseCase<List<CulturaEntity>, NoParams> {
  final ICulturasRepository repository;

  @deprecated
  GetAllCulturasUseCase(this.repository);

  @override
  @deprecated
  Future<Either<Failure, List<CulturaEntity>>> call(NoParams params) async {
    return await repository.getAllCulturas();
  }
}

/// Use case para buscar culturas por grupo [DEPRECATED]
@deprecated
@injectable
class GetCulturasByGrupoUseCase
    implements UseCase<List<CulturaEntity>, String> {
  final ICulturasRepository repository;

  @deprecated
  GetCulturasByGrupoUseCase(this.repository);

  @override
  @deprecated
  Future<Either<Failure, List<CulturaEntity>>> call(String grupo) async {
    return await repository.getCulturasByGrupo(grupo);
  }
}

/// Use case para pesquisar culturas [DEPRECATED]
@deprecated
@injectable
class SearchCulturasUseCase implements UseCase<List<CulturaEntity>, String> {
  final ICulturasRepository repository;

  @deprecated
  SearchCulturasUseCase(this.repository);

  @override
  @deprecated
  Future<Either<Failure, List<CulturaEntity>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllCulturas();
    }
    return await repository.searchCulturas(query);
  }
}

/// Use case para buscar grupos de culturas [DEPRECATED]
@deprecated
@injectable
class GetGruposCulturasUseCase implements UseCase<List<String>, NoParams> {
  final ICulturasRepository repository;

  @deprecated
  GetGruposCulturasUseCase(this.repository);

  @override
  @deprecated
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getGruposCulturas();
  }
}
