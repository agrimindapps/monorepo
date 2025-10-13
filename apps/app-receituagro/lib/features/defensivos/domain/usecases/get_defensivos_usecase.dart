import 'package:core/core.dart';
import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use case para buscar todos os defensivos
@injectable
class GetDefensivosUseCase implements UseCase<List<DefensivoEntity>, NoParams> {
  final IDefensivosRepository repository;

  GetDefensivosUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(NoParams params) async {
    return await repository.getAllDefensivos();
  }
}

/// Use case para buscar defensivos por classe
@injectable
class GetDefensivosByClasseUseCase implements UseCase<List<DefensivoEntity>, String> {
  final IDefensivosRepository repository;

  GetDefensivosByClasseUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(String classe) async {
    return await repository.getDefensivosByClasse(classe);
  }
}

/// Use case para pesquisar defensivos
@injectable
class SearchDefensivosUseCase implements UseCase<List<DefensivoEntity>, String> {
  final IDefensivosRepository repository;

  SearchDefensivosUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllDefensivos();
    }
    return await repository.searchDefensivos(query);
  }
}

/// Use case para buscar defensivos recentes
@injectable
class GetDefensivosRecentesUseCase implements UseCase<List<DefensivoEntity>, int?> {
  final IDefensivosRepository repository;

  GetDefensivosRecentesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(int? limit) async {
    return await repository.getDefensivosRecentes(limit: limit ?? 10);
  }
}

/// Use case para buscar estatísticas dos defensivos
@injectable
class GetDefensivosStatsUseCase implements UseCase<Map<String, int>, NoParams> {
  final IDefensivosRepository repository;

  GetDefensivosStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getDefensivosStats();
  }
}

/// Use case para buscar classes agronômicas
@injectable
class GetClassesAgronomicasUseCase implements UseCase<List<String>, NoParams> {
  final IDefensivosRepository repository;

  GetClassesAgronomicasUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getClassesAgronomicas();
  }
}

/// Use case para buscar fabricantes
@injectable
class GetFabricantesUseCase implements UseCase<List<String>, NoParams> {
  final IDefensivosRepository repository;

  GetFabricantesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getFabricantes();
  }
}
