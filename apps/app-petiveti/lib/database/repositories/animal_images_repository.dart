import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../petiveti_database.dart';

/// ============================================================================
/// ANIMAL IMAGES REPOSITORY - Repositório de imagens de animais
/// ============================================================================
///
/// Gerencia operações CRUD e sincronização de imagens dos animais.
///
/// **PADRÃO ESTABELECIDO (gasometer/plantis):**
/// - Imagens comprimidas para Base64 (max 600KB)
/// - Thumbnail automático (150x150, ~30KB)
/// - Stream providers para UI reativa
/// - Suporte a múltiplas imagens por animal
/// - Integração com ImageProcessingService do core
/// ============================================================================
class AnimalImagesRepository {
  AnimalImagesRepository(this._db);
  
  final PetivetiDatabase _db;
  
  // ========== QUERIES ==========
  
  /// Busca todas as imagens de um animal
  Future<List<AnimalImage>> getImagesByAnimalId(int animalId) async {
    return (_db.select(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }
  
  /// Stream de imagens de um animal (reativo)
  Stream<List<AnimalImage>> watchImagesByAnimalId(int animalId) {
    return (_db.select(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
  
  /// Busca a imagem primária de um animal
  Future<AnimalImage?> getPrimaryImage(int animalId) async {
    return (_db.select(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId))
      ..where((t) => t.isPrimary.equals(true))
      ..where((t) => t.isDeleted.equals(false))
      ..limit(1))
        .getSingleOrNull();
  }
  
  /// Stream da imagem primária de um animal (reativo)
  Stream<AnimalImage?> watchPrimaryImage(int animalId) {
    return (_db.select(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId))
      ..where((t) => t.isPrimary.equals(true))
      ..where((t) => t.isDeleted.equals(false))
      ..limit(1))
        .watchSingleOrNull();
  }
  
  /// Busca imagem por ID
  Future<AnimalImage?> getById(int id) async {
    return (_db.select(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }
  
  /// Busca imagem por Firebase ID
  Future<AnimalImage?> getByFirebaseId(String firebaseId) async {
    return (_db.select(_db.animalImages)
      ..where((t) => t.firebaseId.equals(firebaseId)))
        .getSingleOrNull();
  }
  
  /// Busca imagens pendentes de sync
  Future<List<AnimalImage>> getDirtyImages() async {
    return (_db.select(_db.animalImages)
      ..where((t) => t.isDirty.equals(true)))
        .get();
  }
  
  // ========== MUTATIONS ==========
  
  /// Adiciona uma nova imagem processada
  ///
  /// [animalId] - ID do animal
  /// [imageBytes] - Bytes da imagem original
  /// [userId] - ID do usuário
  /// [isPrimary] - Se deve ser a imagem principal
  ///
  /// Retorna o ID da imagem inserida
  Future<int> addImage({
    required int animalId,
    required Uint8List imageBytes,
    required String userId,
    bool isPrimary = false,
    String? fileName,
    String? caption,
  }) async {
    // Processa a imagem usando o serviço do core
    final processed = await ImageProcessingService.instance.processImage(
      imageBytes,
      config: ImageProcessingConfig.standard,
    );
    
    // Gera thumbnail
    final thumbnail = await ImageProcessingService.instance.processImage(
      imageBytes,
      config: ImageProcessingConfig.thumbnail,
    );
    
    // Se for primária, remove flag das outras
    if (isPrimary) {
      await _clearPrimaryFlag(animalId);
    }
    
    final companion = AnimalImagesCompanion.insert(
      animalId: animalId,
      userId: Value(userId),
      imageData: processed.bytes,
      thumbnailData: Value(thumbnail.bytes),
      fileName: Value(fileName),
      mimeType: Value(processed.mimeType),
      sizeBytes: Value(processed.sizeBytes),
      isPrimary: Value(isPrimary),
      caption: Value(caption),
      isDirty: const Value(true),
      createdAt: Value(DateTime.now()),
    );
    
    return _db.into(_db.animalImages).insert(companion);
  }
  
  /// Adiciona imagem já processada (para sync do Firebase)
  Future<int> addProcessedImage({
    required int animalId,
    required String imageBase64,
    String? thumbnailBase64,
    String? firebaseId,
    String? userId,
    String? fileName,
    String mimeType = 'image/jpeg',
    int? sizeBytes,
    int? width,
    int? height,
    bool isPrimary = false,
    String? caption,
    DateTime? lastSyncAt,
    int version = 1,
  }) async {
    if (isPrimary) {
      await _clearPrimaryFlag(animalId);
    }
    
    // Converter base64 para bytes
    final imageBytes = base64Decode(imageBase64.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), ''));
    final thumbnailBytes = thumbnailBase64 != null 
        ? base64Decode(thumbnailBase64.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), ''))
        : null;
    
    final companion = AnimalImagesCompanion.insert(
      animalId: animalId,
      firebaseId: Value(firebaseId),
      userId: Value(userId),
      imageData: imageBytes,
      thumbnailData: Value(thumbnailBytes),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      isPrimary: Value(isPrimary),
      caption: Value(caption),
      isDirty: const Value(false),
      lastSyncAt: Value(lastSyncAt),
      version: Value(version),
      createdAt: Value(DateTime.now()),
    );
    
    return _db.into(_db.animalImages).insert(companion);
  }
  
  /// Atualiza uma imagem existente
  Future<bool> updateImage(int id, AnimalImagesCompanion companion) async {
    final updated = companion.copyWith(
      updatedAt: Value(DateTime.now()),
      isDirty: const Value(true),
    );
    
    return (_db.update(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .write(updated)
        .then((count) => count > 0);
  }
  
  /// Define uma imagem como primária
  Future<void> setPrimaryImage(int animalId, int imageId) async {
    await _db.transaction(() async {
      // Remove flag de todas as imagens do animal
      await _clearPrimaryFlag(animalId);
      
      // Define a nova primária
      await (_db.update(_db.animalImages)
        ..where((t) => t.id.equals(imageId)))
          .write(AnimalImagesCompanion(
            isPrimary: const Value(true),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ));
    });
  }
  
  /// Soft delete de uma imagem
  Future<bool> deleteImage(int id) async {
    return (_db.update(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .write(AnimalImagesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
          isDirty: const Value(true),
        ))
        .then((count) => count > 0);
  }
  
  /// Hard delete (remove definitivamente)
  Future<bool> permanentlyDeleteImage(int id) async {
    return (_db.delete(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .go()
        .then((count) => count > 0);
  }
  
  /// Remove todas as imagens de um animal
  Future<int> deleteAllImagesForAnimal(int animalId) async {
    return (_db.update(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId)))
        .write(AnimalImagesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
          isDirty: const Value(true),
        ));
  }
  
  // ========== SYNC HELPERS ==========
  
  /// Marca imagem como sincronizada
  Future<void> markAsSynced(int id, String firebaseId) async {
    await (_db.update(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .write(AnimalImagesCompanion(
          firebaseId: Value(firebaseId),
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ));
  }
  
  /// Atualiza versão após sync
  Future<void> updateVersion(int id, int newVersion) async {
    await (_db.update(_db.animalImages)
      ..where((t) => t.id.equals(id)))
        .write(AnimalImagesCompanion(
          version: Value(newVersion),
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
        ));
  }
  
  // ========== PRIVATE HELPERS ==========
  
  /// Remove flag isPrimary de todas as imagens de um animal
  Future<void> _clearPrimaryFlag(int animalId) async {
    await (_db.update(_db.animalImages)
      ..where((t) => t.animalId.equals(animalId))
      ..where((t) => t.isPrimary.equals(true)))
        .write(const AnimalImagesCompanion(
          isPrimary: Value(false),
        ));
  }
}
