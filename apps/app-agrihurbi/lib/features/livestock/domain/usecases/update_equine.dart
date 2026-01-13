import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/equine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para atualizar um equino existente
class UpdateEquineUseCase implements UseCase<EquineEntity, UpdateEquineParams> {
  final LivestockRepository repository;

  const UpdateEquineUseCase(this.repository);

  @override
  Future<Either<Failure, EquineEntity>> call(UpdateEquineParams params) async {
    final validation = _validateEquineData(params.equine);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    
    // Atualiza timestamp
    final equineToUpdate = params.equine.copyWith(
      updatedAt: DateTime.now(),
    );

    return await repository.updateEquine(equineToUpdate);
  }

  /// Valida os dados do equino antes da atualização
  String? _validateEquineData(EquineEntity equine) {
    if (equine.id.trim().isEmpty) {
      return 'ID do equino é obrigatório';
    }
    if (equine.commonName.trim().isEmpty) {
      return 'Nome comum é obrigatório';
    }
    if (equine.originCountry.trim().isEmpty) {
      return 'País de origem é obrigatório';
    }
    
    return null;
  }
}

/// Parâmetros para atualização de equino
class UpdateEquineParams extends Equatable {
  const UpdateEquineParams({
    required this.equine,
  });

  /// Entidade do equino a ser atualizada
  final EquineEntity equine;

  @override
  List<Object> get props => [equine];
}
