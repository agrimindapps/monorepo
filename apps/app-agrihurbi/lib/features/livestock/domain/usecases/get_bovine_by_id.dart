import 'package:core/core.dart';

import '../entities/bovine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Parâmetros para obter bovino por ID
class GetBovineByIdParams extends Equatable {
  const GetBovineByIdParams({required this.bovineId});

  final String bovineId;

  @override
  List<Object?> get props => [bovineId];
}

/// Use case para obter um bovino específico por ID
/// 
/// Implementa carregamento individual com estratégia local-first:
/// 1. Busca no cache local primeiro
/// 2. Se não encontrar e houver conectividade, busca remotamente
/// 3. Salva automaticamente no cache para consultas futuras
@lazySingleton
class GetBovineByIdUseCase implements UseCase<BovineEntity, GetBovineByIdParams> {
  const GetBovineByIdUseCase(this._repository);

  final LivestockRepository _repository;

  @override
  Future<Either<Failure, BovineEntity>> call(GetBovineByIdParams params) async {
    return await _repository.getBovineById(params.bovineId);
  }
}