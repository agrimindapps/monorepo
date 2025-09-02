import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/cultura_entity.dart';
import '../repositories/i_culturas_repository.dart';

/// Use case para buscar todas as culturas
/// Implementa lógica de negócio específica para listagem de culturas
class GetCulturasUseCase implements UseCase<List<CulturaEntity>, NoParams> {
  final ICulturasRepository repository;

  GetCulturasUseCase(this.repository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> call(NoParams params) async {
    return await repository.getAllCulturas();
  }
}

/// Use case para buscar culturas por grupo
class GetCulturasByGrupoUseCase implements UseCase<List<CulturaEntity>, String> {
  final ICulturasRepository repository;

  GetCulturasByGrupoUseCase(this.repository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> call(String grupo) async {
    return await repository.getCulturasByGrupo(grupo);
  }
}

/// Use case para pesquisar culturas
class SearchCulturasUseCase implements UseCase<List<CulturaEntity>, String> {
  final ICulturasRepository repository;

  SearchCulturasUseCase(this.repository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllCulturas();
    }
    return await repository.searchCulturas(query);
  }
}

/// Use case para buscar grupos de culturas
class GetGruposCulturasUseCase implements UseCase<List<String>, NoParams> {
  final ICulturasRepository repository;

  GetGruposCulturasUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getGruposCulturas();
  }
}