import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../plantis_database.dart';

/// Repository para gerenciar imagens de plantas no Drift
///
/// Armazena imagens como Base64 para sincronização com Firestore.
/// Usa ImageProcessingService para compressão automática (max 600KB).
///
/// Responsabilidades:
/// - CRUD de imagens locais
/// - Processamento e compressão automática
/// - Gerenciamento de imagem primária
/// - Controle de sincronização
class PlantImagesDriftRepository {
  final PlantisDatabase _db;
  final _processingService = ImageProcessingService.instance;

  PlantImagesDriftRepository(this._db);

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem para uma planta
  ///
  /// A imagem é automaticamente processada e comprimida para max 600KB.
  ///
  /// [plantId] - ID local da planta
  /// [imageBytes] - Bytes da imagem original
  /// [fileName] - Nome original do arquivo
  /// [isPrimary] - Se é a imagem principal
  /// [userId] - ID do usuário
  /// [config] - Configuração de processamento (default: standard)
  Future<int> saveImage({
    required int plantId,
    required Uint8List imageBytes,
    String? fileName,
    bool isPrimary = false,
    String? userId,
    ImageProcessingConfig config = ImageProcessingConfig.standard,
  }) async {
    // Processar e comprimir imagem
    final processed = await _processingService.processImage(
      imageBytes,
      config: config,
    );

    _log('Imagem processada: ${processed.sizeBytes} bytes '
        '(${processed.width}x${processed.height}), '
        'economia: ${processed.savedPercent.toStringAsFixed(1)}%');

    // Se for primária, remove flag de outras imagens
    if (isPrimary) {
      await _clearPrimaryFlag(plantId);
    }

    final companion = PlantImagesCompanion(
      plantId: Value(plantId),
      imageData: Value(processed.bytes),
      fileName: Value(fileName),
      mimeType: Value(processed.mimeType),
      sizeBytes: Value(processed.sizeBytes),
      isPrimary: Value(isPrimary),
      userId: Value(userId),
      isDirty: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.plantImages).insert(companion);
    _log('Imagem salva: id=$id, plantId=$plantId, size=${processed.sizeBytes} bytes');
    return id;
  }

  /// Salva imagem já processada (Base64)
  ///
  /// Útil para sincronização quando a imagem já vem processada do Firestore.
  Future<int> saveProcessedImage({
    required int plantId,
    required String imageBase64,
    String? userId,
    String? fileName,
    String mimeType = 'image/jpeg',
    int? sizeBytes,
    int? width,
    int? height,
    bool isPrimary = false,
    String? firebaseId,
  }) async {
    if (isPrimary) {
      await _clearPrimaryFlag(plantId);
    }

    // Converter base64 para bytes
    final bytes = base64Decode(imageBase64.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), ''));

    final companion = PlantImagesCompanion(
      plantId: Value(plantId),
      imageData: Value(bytes),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      isPrimary: Value(isPrimary),
      userId: Value(userId),
      firebaseId: Value(firebaseId),
      isDirty: Value(firebaseId == null),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      lastSyncAt: firebaseId != null ? Value(DateTime.now()) : const Value.absent(),
    );

    final id = await _db.into(_db.plantImages).insert(companion);
    _log('Imagem processada salva: id=$id, plantId=$plantId');
    return id;
  }

  // =========================================================================
  // READ
  // =========================================================================

  /// Retorna a imagem primária de uma planta
  Future<PlantImage?> getPrimaryImage(int plantId) async {
    return (_db.select(_db.plantImages)..where(
          (i) =>
              i.plantId.equals(plantId) &
              i.isPrimary.equals(true) &
              i.isDeleted.equals(false),
        ))
        .getSingleOrNull();
  }

  /// Retorna todas as imagens de uma planta
  Future<List<PlantImage>> getImagesByPlantId(int plantId) async {
    return (_db.select(_db.plantImages)
          ..where((i) => i.plantId.equals(plantId) & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.isPrimary),
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .get();
  }

  /// Retorna uma imagem pelo ID
  Future<PlantImage?> getImageById(int id) async {
    return (_db.select(
      _db.plantImages,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// Retorna uma imagem pelo Firebase ID
  Future<PlantImage?> getImageByFirebaseId(String firebaseId) async {
    return (_db.select(_db.plantImages)
          ..where((i) => i.firebaseId.equals(firebaseId)))
        .getSingleOrNull();
  }

  /// Retorna imagens pendentes de sincronização
  Future<List<PlantImage>> getDirtyImages() async {
    return (_db.select(_db.plantImages)
          ..where((i) => i.isDirty.equals(true) & i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
        .get();
  }

  /// Stream de imagens de uma planta (reativo)
  Stream<List<PlantImage>> watchImagesByPlantId(int plantId) {
    return (_db.select(_db.plantImages)
          ..where((i) => i.plantId.equals(plantId) & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.isPrimary),
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .watch();
  }

  /// Stream da imagem primária de uma planta
  Stream<PlantImage?> watchPrimaryImage(int plantId) {
    return (_db.select(_db.plantImages)..where(
          (i) =>
              i.plantId.equals(plantId) &
              i.isPrimary.equals(true) &
              i.isDeleted.equals(false),
        ))
        .watchSingleOrNull();
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  /// Define uma imagem como primária
  Future<void> setPrimaryImage(int imageId, int plantId) async {
    await _clearPrimaryFlag(plantId);

    await (_db.update(_db.plantImages)..where((i) => i.id.equals(imageId)))
        .write(PlantImagesCompanion(
      isPrimary: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Marca imagem como sincronizada
  Future<void> markAsSynced({
    required int imageId,
    required String firebaseId,
  }) async {
    await (_db.update(_db.plantImages)..where((i) => i.id.equals(imageId)))
        .write(PlantImagesCompanion(
      firebaseId: Value(firebaseId),
      isDirty: const Value(false),
      lastSyncAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    _log('Imagem $imageId marcada como sincronizada: $firebaseId');
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  /// Marca uma imagem como deletada (soft delete)
  Future<void> deleteImage(int imageId) async {
    await (_db.update(
      _db.plantImages,
    )..where((i) => i.id.equals(imageId))).write(
      PlantImagesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    _log('Imagem marcada como deletada: id=$imageId');
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(
      _db.plantImages,
    )..where((i) => i.id.equals(imageId))).go();
    _log('Imagem removida permanentemente: id=$imageId');
  }

  /// Remove todas as imagens de uma planta
  Future<void> deleteAllImagesForPlant(int plantId) async {
    await (_db.update(
      _db.plantImages,
    )..where((i) => i.plantId.equals(plantId))).write(
      PlantImagesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Remove flag isPrimary de todas as imagens de uma planta
  Future<void> _clearPrimaryFlag(int plantId) async {
    await (_db.update(_db.plantImages)
          ..where((i) => i.plantId.equals(plantId) & i.isPrimary.equals(true)))
        .write(const PlantImagesCompanion(
      isPrimary: Value(false),
      isDirty: Value(true),
    ));
  }

  /// Conta imagens de uma planta
  Future<int> countImagesForPlant(int plantId) async {
    final count = _db.plantImages.id.count();
    final query = _db.selectOnly(_db.plantImages)
      ..addColumns([count])
      ..where(
        _db.plantImages.plantId.equals(plantId) &
            _db.plantImages.isDeleted.equals(false),
      );

    return await query.map((row) => row.read(count)!).getSingle();
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('📷 [PlantImagesDriftRepository] $message');
    }
  }
}
