import 'package:flutter/foundation.dart';

import 'entity_image.dart';
import 'image_processing_service.dart';

/// Interface para repository de imagens
///
/// Define contrato que cada app deve implementar usando seu database Drift
abstract class IEntityImageRepository {
  /// Salva uma nova imagem processada
  Future<EntityImage> saveImage({
    required String entityType,
    required String entityId,
    required Uint8List imageBytes,
    required String moduleName,
    String? userId,
    String? fileName,
    bool isPrimary = false,
    int sortOrder = 0,
    ImageProcessingConfig config = ImageProcessingConfig.standard,
  });

  /// Retorna a imagem primária de uma entidade
  Future<EntityImage?> getPrimaryImage({
    required String entityType,
    required String entityId,
  });

  /// Retorna todas as imagens de uma entidade
  Future<List<EntityImage>> getImagesByEntity({
    required String entityType,
    required String entityId,
  });

  /// Retorna uma imagem pelo ID
  Future<EntityImage?> getImageById(int id);

  /// Retorna uma imagem pelo Firebase ID
  Future<EntityImage?> getImageByFirebaseId(String firebaseId);

  /// Define uma imagem como primária
  Future<void> setPrimaryImage({
    required int imageId,
    required String entityType,
    required String entityId,
  });

  /// Atualiza ordem de exibição das imagens
  Future<void> updateSortOrder({
    required int imageId,
    required int sortOrder,
  });

  /// Marca imagem como deletada (soft delete)
  Future<void> deleteImage(int imageId);

  /// Remove imagem permanentemente
  Future<void> hardDeleteImage(int imageId);

  /// Remove todas as imagens de uma entidade
  Future<void> deleteAllImagesForEntity({
    required String entityType,
    required String entityId,
  });

  /// Retorna imagens pendentes de sincronização
  Future<List<EntityImage>> getDirtyImages();

  /// Marca imagem como sincronizada
  Future<void> markAsSynced({
    required int imageId,
    required String firebaseId,
  });

  /// Conta imagens de uma entidade
  Future<int> countImagesForEntity({
    required String entityType,
    required String entityId,
  });

  /// Stream de imagens de uma entidade (reativo)
  Stream<List<EntityImage>> watchImagesByEntity({
    required String entityType,
    required String entityId,
  });

  /// Stream da imagem primária de uma entidade
  Stream<EntityImage?> watchPrimaryImage({
    required String entityType,
    required String entityId,
  });
}

/// Implementação base com lógica comum
///
/// Apps devem estender esta classe e implementar os métodos de persistência
abstract class EntityImageRepositoryBase implements IEntityImageRepository {
  final ImageProcessingService _processingService =
      ImageProcessingService.instance;

  /// Processa imagem antes de salvar
  @protected
  Future<ProcessedImage> processImage(
    Uint8List imageBytes,
    ImageProcessingConfig config,
  ) async {
    return _processingService.processImage(imageBytes, config: config);
  }

  /// Cria entidade de imagem a partir de dados processados
  @protected
  EntityImage createEntityImage({
    required String entityType,
    required String entityId,
    required String moduleName,
    required ProcessedImage processed,
    String? userId,
    String? fileName,
    bool isPrimary = false,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return EntityImage(
      moduleName: moduleName,
      entityType: entityType,
      entityId: entityId,
      imageBase64: processed.base64DataUri,
      mimeType: processed.mimeType,
      sizeBytes: processed.sizeBytes,
      width: processed.width,
      height: processed.height,
      fileName: fileName,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
      isDeleted: false,
      version: 1,
    );
  }

  /// Valida se a imagem está dentro dos limites
  @protected
  bool validateImageSize(Uint8List imageBytes, {int? maxBytes}) {
    return _processingService.isValidSize(imageBytes, maxBytes: maxBytes);
  }

  /// Log de debug para operações
  @protected
  void logDebug(String message) {
    if (kDebugMode) {
      debugPrint('📷 [EntityImageRepository] $message');
    }
  }
}

/// Helper para gerenciar imagens de uma entidade específica
///
/// Facilita operações comuns encapsulando entityType e entityId
class EntityImageHelper {
  final IEntityImageRepository _repository;
  final String entityType;
  final String entityId;
  final String moduleName;
  final String? userId;

  EntityImageHelper({
    required IEntityImageRepository repository,
    required this.entityType,
    required this.entityId,
    required this.moduleName,
    this.userId,
  }) : _repository = repository;

  /// Adiciona uma nova imagem
  Future<EntityImage> addImage(
    Uint8List imageBytes, {
    String? fileName,
    bool isPrimary = false,
    ImageProcessingConfig config = ImageProcessingConfig.standard,
  }) {
    return _repository.saveImage(
      entityType: entityType,
      entityId: entityId,
      imageBytes: imageBytes,
      moduleName: moduleName,
      userId: userId,
      fileName: fileName,
      isPrimary: isPrimary,
      config: config,
    );
  }

  /// Retorna a imagem primária
  Future<EntityImage?> getPrimaryImage() {
    return _repository.getPrimaryImage(
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Retorna todas as imagens
  Future<List<EntityImage>> getAllImages() {
    return _repository.getImagesByEntity(
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Define uma imagem como primária
  Future<void> setPrimary(int imageId) {
    return _repository.setPrimaryImage(
      imageId: imageId,
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Remove uma imagem
  Future<void> deleteImage(int imageId) {
    return _repository.deleteImage(imageId);
  }

  /// Remove todas as imagens
  Future<void> deleteAllImages() {
    return _repository.deleteAllImagesForEntity(
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Conta imagens
  Future<int> countImages() {
    return _repository.countImagesForEntity(
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Stream de imagens (reativo)
  Stream<List<EntityImage>> watchImages() {
    return _repository.watchImagesByEntity(
      entityType: entityType,
      entityId: entityId,
    );
  }

  /// Stream da imagem primária (reativo)
  Stream<EntityImage?> watchPrimary() {
    return _repository.watchPrimaryImage(
      entityType: entityType,
      entityId: entityId,
    );
  }
}
