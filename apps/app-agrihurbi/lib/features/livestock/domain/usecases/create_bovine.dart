import 'package:core/core.dart';

import '../entities/bovine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para criar um novo bovino com validação e regras de negócio
/// 
/// Implementa UseCase que retorna a entidade criada em caso de sucesso
/// Inclui validações de business rules e geração de ID único
@lazySingleton
class CreateBovineUseCase implements UseCase<BovineEntity, CreateBovineParams> {
  final LivestockRepository repository;
  
  const CreateBovineUseCase(this.repository);
  
  @override
  Future<Either<Failure, BovineEntity>> call(CreateBovineParams params) async {
    // Validação dos campos obrigatórios
    final validation = _validateBovineData(params.bovine);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    
    // Preparar entidade para criação
    final now = DateTime.now();
    final bovineToCreate = params.bovine.copyWith(
      id: params.bovine.id.isEmpty ? _generateUniqueId() : params.bovine.id,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
    
    // Validar registrationId único se fornecido
    if (bovineToCreate.registrationId.isNotEmpty) {
      final duplicateCheck = await _checkDuplicateRegistrationId(bovineToCreate.registrationId);
      if (duplicateCheck != null) {
        return Left(duplicateCheck);
      }
    }
    
    // Criar no repositório
    return await repository.createBovine(bovineToCreate);
  }
  
  /// Valida os dados do bovino antes da criação
  String? _validateBovineData(BovineEntity bovine) {
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
  
  /// Verifica se o registrationId já existe
  Future<Failure?> _checkDuplicateRegistrationId(String registrationId) async {
    // Esta verificação será implementada quando o repository estiver completo
    // Por ora, retornamos null (sem duplicata)
    return null;
  }
  
  /// Gera um ID único usando timestamp + random
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'bovine_${timestamp}_$random';
  }
}

/// Parâmetros para criação de bovino
class CreateBovineParams extends Equatable {
  const CreateBovineParams({
    required this.bovine,
    this.validateImages = true,
    this.autoGenerateId = true,
  });

  /// Entidade do bovino a ser criada
  final BovineEntity bovine;
  
  /// Se deve validar URLs de imagens
  final bool validateImages;
  
  /// Se deve gerar ID automaticamente se não fornecido
  final bool autoGenerateId;
  
  @override
  List<Object> get props => [bovine, validateImages, autoGenerateId];
}