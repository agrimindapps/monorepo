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
