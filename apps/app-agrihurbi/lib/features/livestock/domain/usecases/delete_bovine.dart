import 'package:core/core.dart';
import '../repositories/livestock_repository.dart';

/// Use case para deletar um bovino com validação e regras de negócio
/// 
/// Implementa UseCase com soft delete por padrão
/// Inclui verificações de confirmação e operações em cascata
@lazySingleton
class DeleteBovineUseCase implements UseCase<void, DeleteBovineParams> {
  final LivestockRepository repository;
  
  const DeleteBovineUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(DeleteBovineParams params) async {
    // Validação básica do ID
    if (params.bovineId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do bovino é obrigatório para exclusão'));
    }
    
    // Verificar se o bovino existe
    final existingBovineResult = await repository.getBovineById(params.bovineId);
    if (existingBovineResult.isLeft()) {
      return Left(
        existingBovineResult.fold(
          (failure) => failure is NotFoundFailure 
            ? const NotFoundFailure('Bovino não encontrado')
            : failure,
          (r) => throw UnimplementedError(),
        ),
      );
    }
    
    final existingBovine = existingBovineResult.fold((l) => throw UnimplementedError(), (r) => r);
    
    // Validar confirmação se necessária
    if (params.requireConfirmation && !params.confirmed) {
      return const Left(ValidationFailure('Confirmação é obrigatória para exclusão'));
    }
    
    // Validar regras de negócio específicas
    final businessRuleValidation = await _validateBusinessRules(existingBovine, params);
    if (businessRuleValidation != null) {
      return Left(businessRuleValidation);
    }
    
    // Executar operações em cascata se necessário
    if (params.deleteRelatedData) {
      final cascadeResult = await _performCascadeOperations(params.bovineId);
      if (cascadeResult.isLeft()) {
        return cascadeResult;
      }
    }
    
    // Deletar imagens se especificado
    if (params.deleteImages && existingBovine.imageUrls.isNotEmpty) {
      final imageDeleteResult = await repository.deleteAnimalImages(
        params.bovineId, 
        existingBovine.imageUrls,
      );
      if (imageDeleteResult.isLeft()) {
        // Log erro mas não falha a operação principal
        // TODO: Implementar logging quando disponível
      }
    }
    
    // Executar a exclusão (soft delete por padrão)
    return await repository.deleteBovine(params.bovineId);
  }
  
  /// Valida regras de negócio específicas para exclusão
  Future<Failure?> _validateBusinessRules(dynamic existingBovine, DeleteBovineParams params) async {
    // Verificar se bovino está inativo (já foi "deletado" anteriormente)
    if (existingBovine.isActive == false && !params.forceDelete) {
      return const ValidationFailure('Bovino já foi removido anteriormente');
    }
    
    // Outras validações de business rules podem ser adicionadas aqui
    // Ex: verificar se bovino tem dependências, se está em processo reprodutivo, etc.
    
    return null;
  }
  
  /// Executa operações em cascata relacionadas
  Future<Either<Failure, void>> _performCascadeOperations(String bovineId) async {
    // Implementar operações em cascata quando o sistema estiver completo
    // Ex: remover registros de vacinas, histórico médico, registros de reprodução, etc.
    
    // Por ora, retorna sucesso
    return const Right(null);
  }
}

/// Parâmetros para exclusão de bovino
class DeleteBovineParams extends Equatable {
  const DeleteBovineParams({
    required this.bovineId,
    this.requireConfirmation = true,
    this.confirmed = false,
    this.deleteImages = false,
    this.deleteRelatedData = false,
    this.forceDelete = false,
    this.reason,
  });

  /// ID do bovino a ser deletado
  final String bovineId;
  
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
    bovineId,
    requireConfirmation,
    confirmed,
    deleteImages,
    deleteRelatedData,
    forceDelete,
    reason,
  ];
}

/// Use case especializado para exclusão rápida sem confirmações
@lazySingleton
class QuickDeleteBovineUseCase implements UseCase<void, String> {
  final DeleteBovineUseCase _deleteUseCase;
  
  const QuickDeleteBovineUseCase(this._deleteUseCase);
  
  @override
  Future<Either<Failure, void>> call(String bovineId) async {
    return await _deleteUseCase.call(
      DeleteBovineParams(
        bovineId: bovineId,
        requireConfirmation: false,
        confirmed: true,
        deleteImages: false,
        deleteRelatedData: false,
      ),
    );
  }
}