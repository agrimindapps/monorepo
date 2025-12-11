import 'package:drift/drift.dart';

import '../plantis_database.dart';

/// Repository para gerenciar imagens de plantas no Drift
///
/// Armazena imagens como BLOB para funcionamento offline-first.
/// Responsabilidades:
/// - CRUD de imagens locais
/// - Gerenciamento de imagem primária
/// - Controle de status de upload
class PlantImagesDriftRepository {
  final PlantisDatabase _db;

  PlantImagesDriftRepository(this._db);

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem para uma planta
  ///
  /// [plantId] - ID local da planta
  /// [imageBytes] - Bytes da imagem
  /// [fileName] - Nome original do arquivo
  /// [mimeType] - Tipo MIME (image/jpeg, image/png)
  /// [isPrimary] - Se é a imagem principal
  /// [userId] - ID do usuário
  Future<int> saveImage({
    required int plantId,
    required Uint8List imageBytes,
    String? fileName,
    String mimeType = 'image/jpeg',
    bool isPrimary = false,
    String? userId,
  }) async {
    // Se for primária, remove flag de outras imagens
    if (isPrimary) {
      await _clearPrimaryFlag(plantId);
    }

    final companion = PlantImagesCompanion(
      plantId: Value(plantId),
      imageData: Value(imageBytes),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(imageBytes.length),
      isPrimary: Value(isPrimary),
      userId: Value(userId),
      isDirty: const Value(true),
      uploadStatus: const Value('pending'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.plantImages).insert(companion);
    print(
      '📷 [PlantImagesDriftRepository] Imagem salva: id=$id, plantId=$plantId, size=${imageBytes.length} bytes',
    );
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

  /// Retorna imagens pendentes de upload
  Future<List<PlantImage>> getPendingUploads() async {
    return (_db.select(_db.plantImages)
          ..where(
            (i) => i.uploadStatus.equals('pending') & i.isDeleted.equals(false),
          )
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

    await (_db.update(
      _db.plantImages,
    )..where((i) => i.id.equals(imageId))).write(
      const PlantImagesCompanion(
        isPrimary: Value(true),
        updatedAt: Value(null), // Será atualizado pelo trigger
      ),
    );

    // Atualizar updatedAt manualmente
    await (_db.update(_db.plantImages)..where((i) => i.id.equals(imageId)))
        .write(PlantImagesCompanion(updatedAt: Value(DateTime.now())));
  }

  /// Atualiza status de upload após envio ao Firebase Storage
  Future<void> updateUploadStatus({
    required int imageId,
    required String status,
    String? storageUrl,
    String? firebaseId,
  }) async {
    final companion = PlantImagesCompanion(
      uploadStatus: Value(status),
      storageUrl: Value(storageUrl),
      firebaseId: Value(firebaseId),
      isDirty: Value(status != 'completed'),
      lastSyncAt: status == 'completed'
          ? Value(DateTime.now())
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await (_db.update(
      _db.plantImages,
    )..where((i) => i.id.equals(imageId))).write(companion);

    print(
      '📷 [PlantImagesDriftRepository] Upload status atualizado: id=$imageId, status=$status',
    );
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

    print(
      '📷 [PlantImagesDriftRepository] Imagem marcada como deletada: id=$imageId',
    );
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(
      _db.plantImages,
    )..where((i) => i.id.equals(imageId))).go();
    print(
      '📷 [PlantImagesDriftRepository] Imagem removida permanentemente: id=$imageId',
    );
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
        .write(const PlantImagesCompanion(isPrimary: Value(false)));
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
}
