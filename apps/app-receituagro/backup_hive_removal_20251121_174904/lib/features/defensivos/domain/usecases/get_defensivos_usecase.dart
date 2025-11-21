import 'package:core/core.dart' hide Column;
import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';
import 'get_defensivos_params.dart';

/// Use case consolidado para buscar defensivos
/// Consolida 7 usecases em 1 genérico com type-safe params
///
/// Padrão: Consolidação de Usecases
/// Reduz boilerplate de 7 classes para 1
///
/// Exemplo:
/// ```dart
/// // Antes (7 usecases)
/// final result = await getDefensivosUseCase.call(NoParams());
/// final byClass = await getDefensivosByClasseUseCase.call('insecticida');
/// final search = await searchDefensivosUseCase.call('parathion');
///
/// // Depois (1 usecase)
/// final result = await getDefensivosUseCase.call(const GetAllDefensivosParams());
/// final byClass = await getDefensivosUseCase.call(const GetDefensivosByClasseParams('insecticida'));
/// final search = await getDefensivosUseCase.call(const SearchDefensivosParams('parathion'));
/// ```
@injectable
class GetDefensivosUseCase implements UseCase<dynamic, GetDefensivosParams> {
  final IDefensivosRepository repository;

  GetDefensivosUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(GetDefensivosParams params) async {
    if (params is GetAllDefensivosParams) {
      return await repository.getAllDefensivos();
    }

    if (params is GetDefensivosByClasseParams) {
      return await repository.getDefensivosByClasse(params.classe);
    }

    if (params is SearchDefensivosParams) {
      if (params.query.trim().isEmpty) {
        return await repository.getAllDefensivos();
      }
      return await repository.searchDefensivos(params.query);
    }

    if (params is GetDefensivosRecentesParams) {
      return await repository.getDefensivosRecentes(limit: params.limit);
    }

    if (params is GetDefensivosStatsParams) {
      return await repository.getDefensivosStats();
    }

    if (params is GetClassesAgronomicasParams) {
      return await repository.getClassesAgronomicas();
    }

    if (params is GetFabricantesParams) {
      return await repository.getFabricantes();
    }

    return const Left(
      UnknownFailure(
        'Tipo de parâmetro desconhecido para GetDefensivosUseCase',
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DEPRECATED: Usecases antigos mantidos para compatibilidade
// Use GetDefensivosUseCase com seus respectivos Params
// ═══════════════════════════════════════════════════════════════

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(const GetAllDefensivosParams())`
@Deprecated('Use GetDefensivosUseCase com GetAllDefensivosParams')
@injectable
class GetDefensivosUseCaseOld
    implements UseCase<List<DefensivoEntity>, NoParams> {
  final IDefensivosRepository repository;

  GetDefensivosUseCaseOld(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(NoParams params) async {
    return await repository.getAllDefensivos();
  }
}

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(GetDefensivosByClasseParams(classe))`
@Deprecated('Use GetDefensivosUseCase com GetDefensivosByClasseParams')
@injectable
class GetDefensivosByClasseUseCase
    implements UseCase<List<DefensivoEntity>, String> {
  final IDefensivosRepository repository;

  GetDefensivosByClasseUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(String classe) async {
    return await repository.getDefensivosByClasse(classe);
  }
}

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(SearchDefensivosParams(query))`
@Deprecated('Use GetDefensivosUseCase com SearchDefensivosParams')
@injectable
class SearchDefensivosUseCase
    implements UseCase<List<DefensivoEntity>, String> {
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

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(GetDefensivosRecentesParams(limit))`
@Deprecated('Use GetDefensivosUseCase com GetDefensivosRecentesParams')
@injectable
class GetDefensivosRecentesUseCase
    implements UseCase<List<DefensivoEntity>, int?> {
  final IDefensivosRepository repository;

  GetDefensivosRecentesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(int? limit) async {
    return await repository.getDefensivosRecentes(limit: limit ?? 10);
  }
}

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(const GetDefensivosStatsParams())`
@Deprecated('Use GetDefensivosUseCase com GetDefensivosStatsParams')
@injectable
class GetDefensivosStatsUseCase implements UseCase<Map<String, int>, NoParams> {
  final IDefensivosRepository repository;

  GetDefensivosStatsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getDefensivosStats();
  }
}

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(const GetClassesAgronomicasParams())`
@Deprecated('Use GetDefensivosUseCase com GetClassesAgronomicasParams')
@injectable
class GetClassesAgronomicasUseCase implements UseCase<List<String>, NoParams> {
  final IDefensivosRepository repository;

  GetClassesAgronomicasUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getClassesAgronomicas();
  }
}

/// @Deprecated("Deprecated - use alternative") Use `GetDefensivosUseCase(const GetFabricantesParams())`
@Deprecated('Use GetDefensivosUseCase com GetFabricantesParams')
@injectable
class GetFabricantesUseCase implements UseCase<List<String>, NoParams> {
  final IDefensivosRepository repository;

  GetFabricantesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getFabricantes();
  }
}
