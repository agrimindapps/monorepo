import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/livestock_repository.dart';

/// Use case para deletar um equino com validação e regras de negócio
class DeleteEquineUseCase implements UseCase<void, DeleteEquineParams> {
  final LivestockRepository repository;

  const DeleteEquineUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteEquineParams params) async {
    if (params.equineId.trim().isEmpty) {
      return Left<Failure, void>(const ValidationFailure('ID do equino é obrigatório para exclusão'));
    }
    
    // Verifica se equino existe
    final existingEquineResult = await repository.getEquineById(params.equineId);
    if (existingEquineResult.isLeft()) {
      return Left(
        existingEquineResult.fold(
          (failure) => failure is NotFoundFailure 
            ? const NotFoundFailure('Equino não encontrado')
            : failure,
          (r) => throw UnimplementedError(),
        ),
      );
    }
    
    final existingEquine = existingEquineResult.fold((l) => throw UnimplementedError(), (r) => r);
    
    // Validação de confirmação
    if (params.requireConfirmation && !params.confirmed) {
      return Left<Failure, void>(const ValidationFailure('Confirmação é obrigatória para exclusão'));
    }
    
    // Validação de regras de negócio
    if (existingEquine.isActive == false && !params.forceDelete) {
      return Left<Failure, void>(const ValidationFailure('Equino já foi removido anteriormente'));
    }

    // Exclusão de imagens se solicitado
    if (params.deleteImages && existingEquine.imageUrls.isNotEmpty) {
      // Ignorando erro na deleção de imagens para não bloquear a exclusão do registro
      await repository.deleteAnimalImages(
        params.equineId, 
        existingEquine.imageUrls,
      );
    }
    
    return await repository.deleteEquine(params.equineId);
  }
}

/// Parâmetros para exclusão de equino
class DeleteEquineParams extends Equatable {
  const DeleteEquineParams({
    required this.equineId,
    this.requireConfirmation = true,
    this.confirmed = false,
    this.deleteImages = false,
    this.deleteRelatedData = false,
    this.forceDelete = false,
    this.reason,
  });

  /// ID do equino a ser deletado
  final String equineId;
  
  /// Se requer confirmação explícita
  final bool requireConfirmation;
  
  /// Se a exclusão foi confirmada
  final bool confirmed;
  
  /// Se deve deletar as imagens associadas
  final bool deleteImages;
  
  /// Se deve deletar dados relacionados (cascata)
  final bool deleteRelatedData;
  
  /// Se deve forçar exclusão mesmo se já inativo
  final bool forceDelete;
  
  /// Motivo da exclusão (opcional, para auditoria)
  final String? reason;
  
  @override
  List<Object?> get props => [
    equineId,
    requireConfirmation,
    confirmed,
    deleteImages,
    deleteRelatedData,
    forceDelete,
    reason,
  ];
}
