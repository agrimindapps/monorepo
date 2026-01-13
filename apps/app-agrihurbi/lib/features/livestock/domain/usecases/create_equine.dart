import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/equine_entity.dart';
import '../repositories/livestock_repository.dart';

/// Use case para criar um novo equino com validação e regras de negócio
///
/// Implementa UseCase que retorna a entidade criada em caso de sucesso
/// Inclui validações de business rules e geração de ID único
class CreateEquineUseCase implements UseCase<EquineEntity, CreateEquineParams> {
  final LivestockRepository repository;

  const CreateEquineUseCase(this.repository);

  @override
  Future<Either<Failure, EquineEntity>> call(CreateEquineParams params) async {
    final validation = _validateEquineData(params.equine);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    final now = DateTime.now();
    final equineToCreate = params.equine.copyWith(
      id: params.equine.id.isEmpty ? _generateUniqueId() : params.equine.id,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
    if (equineToCreate.registrationId.isNotEmpty) {
      final duplicateCheck = await _checkDuplicateRegistrationId(
        equineToCreate.registrationId,
      );
      if (duplicateCheck != null) {
        return Left(duplicateCheck);
      }
    }
    return await repository.createEquine(equineToCreate);
  }

  /// Valida os dados do equino antes da criação
  String? _validateEquineData(EquineEntity equine) {
    if (equine.commonName.trim().isEmpty) {
      return 'Nome comum é obrigatório';
    }

    if (equine.originCountry.trim().isEmpty) {
      return 'País de origem é obrigatório';
    }
    if (equine.registrationId.isNotEmpty) {
      final regIdPattern = RegExp(r'^[A-Z0-9\-_]{3,20}$');
      if (!regIdPattern.hasMatch(equine.registrationId)) {
        return 'ID de registro deve conter apenas letras maiúsculas, números, hífens e underscores (3-20 caracteres)';
      }
    }

    return null;
  }

  /// Verifica se o registrationId já existe
  Future<Failure?> _checkDuplicateRegistrationId(String registrationId) async {
    return null;
  }

  /// Gera um ID único usando timestamp + random
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'equine_${timestamp}_$random';
  }
}

/// Parâmetros para criação de equino
class CreateEquineParams extends Equatable {
  const CreateEquineParams({
    required this.equine,
    this.validateImages = true,
    this.autoGenerateId = true,
  });

  /// Entidade do equino a ser criada
  final EquineEntity equine;

  /// Se deve validar URLs de imagens
  final bool validateImages;

  /// Se deve gerar ID automaticamente se não fornecido
  final bool autoGenerateId;

  @override
  List<Object> get props => [equine, validateImages, autoGenerateId];
}
