import 'package:drift/drift.dart';

import '../gasometer_database.dart';

/// Repository para gerenciar imagens de veículos no Drift
///
/// Armazena imagens como BLOB para funcionamento offline-first.
/// Responsabilidades:
/// - CRUD de imagens locais
/// - Gerenciamento de imagem primária
/// - Controle de status de upload
class VehicleImagesDriftRepository {
  VehicleImagesDriftRepository(this._db);

  final GasometerDatabase _db;

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem para um veículo
  ///
  /// [vehicleId] - ID local do veículo
  /// [imageBytes] - Bytes da imagem
  /// [fileName] - Nome original do arquivo
  /// [mimeType] - Tipo MIME (image/jpeg, image/png)
  /// [isPrimary] - Se é a imagem principal
  /// [userId] - ID do usuário
  Future<int> saveImage({
    required int vehicleId,
    required Uint8List imageBytes,
    required String userId,
    String? fileName,
    String mimeType = 'image/jpeg',
    bool isPrimary = false,
  }) async {
    // Se for primária, remove flag de outras imagens
    if (isPrimary) {
      await _clearPrimaryFlag(vehicleId);
    }

    final companion = VehicleImagesCompanion(
      vehicleId: Value(vehicleId),
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

    final id = await _db.into(_db.vehicleImages).insert(companion);
    print(
        '📷 [VehicleImagesDriftRepository] Imagem salva: id=$id, vehicleId=$vehicleId, size=${imageBytes.length} bytes');
    return id;
  }

  // =========================================================================
  // READ
  // =========================================================================

  /// Retorna a imagem primária de um veículo
  Future<VehicleImage?> getPrimaryImage(int vehicleId) async {
    return (_db.select(_db.vehicleImages)
          ..where((i) =>
              i.vehicleId.equals(vehicleId) &
              i.isPrimary.equals(true) &
              i.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Retorna todas as imagens de um veículo
  Future<List<VehicleImage>> getImagesByVehicleId(int vehicleId) async {
    return (_db.select(_db.vehicleImages)
          ..where(
              (i) => i.vehicleId.equals(vehicleId) & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.isPrimary),
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .get();
  }

  /// Retorna uma imagem pelo ID
  Future<VehicleImage?> getImageById(int id) async {
    return (_db.select(_db.vehicleImages)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retorna imagens pendentes de upload
  Future<List<VehicleImage>> getPendingUploads() async {
    return (_db.select(_db.vehicleImages)
          ..where((i) =>
              i.uploadStatus.equals('pending') & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.asc(i.createdAt),
          ]))
        .get();
  }

  /// Stream de imagens de um veículo (reativo)
  Stream<List<VehicleImage>> watchImagesByVehicleId(int vehicleId) {
    return (_db.select(_db.vehicleImages)
          ..where(
              (i) => i.vehicleId.equals(vehicleId) & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.isPrimary),
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .watch();
  }

  /// Stream da imagem primária de um veículo
  Stream<VehicleImage?> watchPrimaryImage(int vehicleId) {
    return (_db.select(_db.vehicleImages)
          ..where((i) =>
              i.vehicleId.equals(vehicleId) &
              i.isPrimary.equals(true) &
              i.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  /// Define uma imagem como primária
  Future<void> setPrimaryImage(int imageId, int vehicleId) async {
    await _clearPrimaryFlag(vehicleId);

    await (_db.update(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .write(VehicleImagesCompanion(
      isPrimary: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Atualiza status de upload após envio ao Firebase Storage
  Future<void> updateUploadStatus({
    required int imageId,
    required String status,
    String? storageUrl,
    String? firebaseId,
  }) async {
    final companion = VehicleImagesCompanion(
      uploadStatus: Value(status),
      storageUrl: Value(storageUrl),
      firebaseId: Value(firebaseId),
      isDirty: Value(status != 'completed'),
      lastSyncAt:
          status == 'completed' ? Value(DateTime.now()) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await (_db.update(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .write(companion);

    print(
        '📷 [VehicleImagesDriftRepository] Upload status atualizado: id=$imageId, status=$status');
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  /// Marca uma imagem como deletada (soft delete)
  Future<void> deleteImage(int imageId) async {
    await (_db.update(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .write(VehicleImagesCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    print(
        '📷 [VehicleImagesDriftRepository] Imagem marcada como deletada: id=$imageId');
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .go();
    print(
        '📷 [VehicleImagesDriftRepository] Imagem removida permanentemente: id=$imageId');
  }

  /// Remove todas as imagens de um veículo
  Future<void> deleteAllImagesForVehicle(int vehicleId) async {
    await (_db.update(_db.vehicleImages)
          ..where((i) => i.vehicleId.equals(vehicleId)))
        .write(VehicleImagesCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Remove flag isPrimary de todas as imagens de um veículo
  Future<void> _clearPrimaryFlag(int vehicleId) async {
    await (_db.update(_db.vehicleImages)
          ..where(
              (i) => i.vehicleId.equals(vehicleId) & i.isPrimary.equals(true)))
        .write(const VehicleImagesCompanion(
      isPrimary: Value(false),
    ));
  }

  /// Conta imagens de um veículo
  Future<int> countImagesForVehicle(int vehicleId) async {
    final count = _db.vehicleImages.id.count();
    final query = _db.selectOnly(_db.vehicleImages)
      ..addColumns([count])
      ..where(_db.vehicleImages.vehicleId.equals(vehicleId) &
          _db.vehicleImages.isDeleted.equals(false));

    return await query.map((row) => row.read(count)!).getSingle();
  }
}
