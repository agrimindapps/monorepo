import 'package:core/core.dart';

import '../entities/equine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para obter lista de equinos com filtros opcionais
/// 
/// Permite buscar todos os equinos ou aplicar filtros específicos
/// Implementa UseCase com EquineSearchParams opcionais
@lazySingleton
class GetEquinesUseCase implements UseCase<List<EquineEntity>, GetEquinesParams> {
  final LivestockRepository repository;
  
  const GetEquinesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<EquineEntity>>> call(GetEquinesParams params) async {
    if (params.searchParams == null) {
      return await repository.getEquines();
    }
    return await repository.searchEquines(params.searchParams!);
  }
}

/// Use case simples para obter todos os equinos sem filtros
@lazySingleton
class GetAllEquinesUseCase implements NoParamsUseCase<List<EquineEntity>> {
  final LivestockRepository repository;
  
  const GetAllEquinesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<EquineEntity>>> call() async {
    return await repository.getEquines();
  }
}

/// Use case para obter equino por ID
@lazySingleton
class GetEquineByIdUseCase implements UseCase<EquineEntity, String> {
  final LivestockRepository repository;
  
  const GetEquineByIdUseCase(this.repository);
  
  @override
  Future<Either<Failure, EquineEntity>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do equino é obrigatório'));
    }
    
    return await repository.getEquineById(id);
  }
}

/// Parâmetros para o GetEquinesUseCase
class GetEquinesParams {
  const GetEquinesParams({
    this.searchParams,
    this.includeInactive = false,
  });

  final EquineSearchParams? searchParams;
  final bool includeInactive;
}