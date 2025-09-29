import 'package:core/core.dart';

import '../entities/bovine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para atualizar um bovino existente com validação e regras de negócio
/// 
/// Implementa UseCase que retorna a entidade atualizada em caso de sucesso
/// Inclui validações, verificação de existência e controle de versão otimista
@lazySingleton
class UpdateBovineUseCase implements UseCase<BovineEntity, UpdateBovineParams> {
  final LivestockRepository repository;
  
  const UpdateBovineUseCase(this.repository);
  
  @override
  Future<Either<Failure, BovineEntity>> call(UpdateBovineParams params) async {
    // Validação básica do ID
    if (params.bovine.id.isEmpty) {
      return const Left(ValidationFailure('ID do bovino é obrigatório para atualização'));
    }
    
    // Verificar se o bovino existe
    final existingBovineResult = await repository.getBovineById(params.bovine.id);
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
    
    // Validação dos dados de atualização
    final validation = _validateUpdateData(params.bovine);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    
    // Verificar se registrationId não conflita com outros bovinos
    if (params.bovine.registrationId != existingBovine.registrationId && 
        params.bovine.registrationId.isNotEmpty) {
      final duplicateCheck = await _checkDuplicateRegistrationId(params.bovine.registrationId, params.bovine.id);
      if (duplicateCheck != null) {
        return Left(duplicateCheck);
      }
    }
    
    // Preparar entidade para atualização
    final now = DateTime.now();
    final bovineToUpdate = params.bovine.copyWith(
      updatedAt: now,
      createdAt: existingBovine.createdAt, // Preservar data de criação
    );
    
    // Controle de versão otimista se habilitado
    if (params.enableOptimisticLocking && params.lastUpdatedAt != null) {
      if (existingBovine.updatedAt?.isAfter(params.lastUpdatedAt!) == true) {
        return const Left(ValidationFailure('Bovino foi modificado por outro usuário. Recarregue e tente novamente.'));
      }
    }
    
    // Atualizar no repositório
    return await repository.updateBovine(bovineToUpdate);
  }
  
  /// Valida os dados de atualização do bovino
  String? _validateUpdateData(BovineEntity bovine) {
    if (bovine.commonName.trim().isEmpty) {
      return 'Nome comum é obrigatório';
    }
    
    if (bovine.breed.trim().isEmpty) {
      return 'Raça é obrigatória';
    }
    
    if (bovine.originCountry.trim().isEmpty) {
      return 'País de origem é obrigatório';
    }
    
    // Validar formato do registrationId se fornecido
    if (bovine.registrationId.isNotEmpty) {
      final regIdPattern = RegExp(r'^[A-Z0-9\-_]{3,20}$');
      if (!regIdPattern.hasMatch(bovine.registrationId)) {
        return 'ID de registro deve conter apenas letras maiúsculas, números, hífens e underscores (3-20 caracteres)';
      }
    }
    
    // Validar tags se fornecidas
    if (bovine.tags.any((tag) => tag.trim().isEmpty)) {
      return 'Tags não podem estar vazias';
    }
    
    return null;
  }
  
  /// Verifica se o registrationId já existe em outro bovino
  Future<Failure?> _checkDuplicateRegistrationId(String registrationId, String currentId) async {
    // Esta verificação será implementada quando o repository estiver completo
    // Por ora, retornamos null (sem duplicata)
    return null;
  }
}

/// Parâmetros para atualização de bovino
class UpdateBovineParams extends Equatable {
  const UpdateBovineParams({
    required this.bovine,
    this.enableOptimisticLocking = false,
    this.lastUpdatedAt,
    this.validateImages = true,
    this.partialUpdate = false,
  });

  /// Entidade do bovino a ser atualizada
  final BovineEntity bovine;
  
  /// Habilitar controle de versão otimista
  final bool enableOptimisticLocking;
  
  /// Data da última atualização conhecida (para controle otimista)
  final DateTime? lastUpdatedAt;
  
  /// Se deve validar URLs de imagens
  final bool validateImages;
  
  /// Se é uma atualização parcial (apenas campos não-nulos)
  final bool partialUpdate;
  
  @override
  List<Object?> get props => [
    bovine, 
    enableOptimisticLocking, 
    lastUpdatedAt, 
    validateImages, 
    partialUpdate
  ];
}