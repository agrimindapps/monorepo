import 'package:core/core.dart';

import '../entities/bovine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para obter lista de bovinos com filtros opcionais
/// 
/// Permite buscar todos os bovinos ou aplicar filtros específicos
/// Implementa UseCase com BovineSearchParams opcionais
@lazySingleton
@lazySingleton
class GetBovinesUseCase implements UseCase<List<BovineEntity>, GetBovinesParams> {
  final LivestockRepository repository;
  
  const GetBovinesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<BovineEntity>>> call(GetBovinesParams params) async {
    if (params.searchParams == null) {
      return await repository.getBovines();
    }
    return await repository.searchBovines(params.searchParams!);
  }
}

/// Use case simples para obter todos os bovinos sem filtros
@lazySingleton
@lazySingleton
class GetAllBovinesUseCase implements NoParamsUseCase<List<BovineEntity>> {
  final LivestockRepository repository;
  
  const GetAllBovinesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<BovineEntity>>> call() async {
    return await repository.getBovines();
  }
}

/// Parâmetros para o GetBovinesUseCase
class GetBovinesParams {
  const GetBovinesParams({
    this.searchParams,
    this.includeInactive = false,
  });

  final BovineSearchParams? searchParams;
  final bool includeInactive;
}