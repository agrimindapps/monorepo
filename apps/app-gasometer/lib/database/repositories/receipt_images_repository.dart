import 'package:drift/drift.dart';

import '../gasometer_database.dart';

/// Tipos de entidades que podem ter comprovantes
enum ReceiptEntityType {
  fuelSupply,
  maintenance,
  expense,
}

extension ReceiptEntityTypeExtension on ReceiptEntityType {
  String get value {
    switch (this) {
      case ReceiptEntityType.fuelSupply:
        return 'fuel_supply';
      case ReceiptEntityType.maintenance:
        return 'maintenance';
      case ReceiptEntityType.expense:
        return 'expense';
    }
  }

  static ReceiptEntityType fromString(String value) {
    switch (value) {
      case 'fuel_supply':
        return ReceiptEntityType.fuelSupply;
      case 'maintenance':
        return ReceiptEntityType.maintenance;
      case 'expense':
        return ReceiptEntityType.expense;
      default:
        throw ArgumentError('Unknown ReceiptEntityType: $value');
    }
  }
}

/// Repository para gerenciar imagens de comprovantes no Drift
///
/// Armazena imagens de recibos como BLOB para funcionamento offline-first.
/// Responsabilidades:
/// - CRUD de imagens de comprovantes
/// - Associação com abastecimentos, manutenções e despesas
/// - Controle de status de upload
class ReceiptImagesDriftRepository {
  ReceiptImagesDriftRepository(this._db);

  final GasometerDatabase _db;

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem de comprovante
  ///
  /// [entityType] - Tipo da entidade (fuel_supply, maintenance, expense)
  /// [entityId] - ID da entidade
  /// [imageBytes] - Bytes da imagem
  /// [fileName] - Nome original do arquivo
  /// [mimeType] - Tipo MIME (image/jpeg, image/png)
  /// [userId] - ID do usuário
  Future<int> saveImage({
    required ReceiptEntityType entityType,
    required int entityId,
    required Uint8List imageBytes,
    required String userId,
    String? fileName,
    String mimeType = 'image/jpeg',
  }) async {
    final companion = ReceiptImagesCompanion(
      entityType: Value(entityType.value),
      entityId: Value(entityId),
      imageData: Value(imageBytes),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(imageBytes.length),
      userId: Value(userId),
      isDirty: const Value(true),
      uploadStatus: const Value('pending'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.receiptImages).insert(companion);
    print(
        '📷 [ReceiptImagesDriftRepository] Imagem salva: id=$id, entityType=${entityType.value}, entityId=$entityId, size=${imageBytes.length} bytes');
    return id;
  }

  // =========================================================================
  // READ
  // =========================================================================

  /// Retorna a imagem de comprovante de uma entidade
  Future<ReceiptImage?> getImageByEntity(
      ReceiptEntityType entityType, int entityId) async {
    return (_db.select(_db.receiptImages)
          ..where((i) =>
              i.entityType.equals(entityType.value) &
              i.entityId.equals(entityId) &
              i.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Retorna todas as imagens de uma entidade
  Future<List<ReceiptImage>> getImagesByEntity(
      ReceiptEntityType entityType, int entityId) async {
    return (_db.select(_db.receiptImages)
          ..where((i) =>
              i.entityType.equals(entityType.value) &
              i.entityId.equals(entityId) &
              i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .get();
  }

  /// Retorna uma imagem pelo ID
  Future<ReceiptImage?> getImageById(int id) async {
    return (_db.select(_db.receiptImages)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retorna imagens pendentes de upload
  Future<List<ReceiptImage>> getPendingUploads() async {
    return (_db.select(_db.receiptImages)
          ..where((i) =>
              i.uploadStatus.equals('pending') & i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.asc(i.createdAt),
          ]))
        .get();
  }

  /// Stream de imagens de uma entidade (reativo)
  Stream<List<ReceiptImage>> watchImagesByEntity(
      ReceiptEntityType entityType, int entityId) {
    return (_db.select(_db.receiptImages)
          ..where((i) =>
              i.entityType.equals(entityType.value) &
              i.entityId.equals(entityId) &
              i.isDeleted.equals(false))
          ..orderBy([
            (i) => OrderingTerm.desc(i.createdAt),
          ]))
        .watch();
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  /// Atualiza status de upload após envio ao Firebase Storage
  Future<void> updateUploadStatus({
    required int imageId,
    required String status,
    String? storageUrl,
    String? firebaseId,
  }) async {
    final companion = ReceiptImagesCompanion(
      uploadStatus: Value(status),
      storageUrl: Value(storageUrl),
      firebaseId: Value(firebaseId),
      isDirty: Value(status != 'completed'),
      lastSyncAt:
          status == 'completed' ? Value(DateTime.now()) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await (_db.update(_db.receiptImages)..where((i) => i.id.equals(imageId)))
        .write(companion);

    print(
        '📷 [ReceiptImagesDriftRepository] Upload status atualizado: id=$imageId, status=$status');
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  /// Marca uma imagem como deletada (soft delete)
  Future<void> deleteImage(int imageId) async {
    await (_db.update(_db.receiptImages)..where((i) => i.id.equals(imageId)))
        .write(ReceiptImagesCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    print(
        '📷 [ReceiptImagesDriftRepository] Imagem marcada como deletada: id=$imageId');
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(_db.receiptImages)..where((i) => i.id.equals(imageId)))
        .go();
    print(
        '📷 [ReceiptImagesDriftRepository] Imagem removida permanentemente: id=$imageId');
  }

  /// Remove todas as imagens de uma entidade
  Future<void> deleteAllImagesForEntity(
      ReceiptEntityType entityType, int entityId) async {
    await (_db.update(_db.receiptImages)
          ..where((i) =>
              i.entityType.equals(entityType.value) &
              i.entityId.equals(entityId)))
        .write(ReceiptImagesCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Conta imagens de uma entidade
  Future<int> countImagesForEntity(
      ReceiptEntityType entityType, int entityId) async {
    final count = _db.receiptImages.id.count();
    final query = _db.selectOnly(_db.receiptImages)
      ..addColumns([count])
      ..where(_db.receiptImages.entityType.equals(entityType.value) &
          _db.receiptImages.entityId.equals(entityId) &
          _db.receiptImages.isDeleted.equals(false));

    return await query.map((row) => row.read(count)!).getSingle();
  }

  /// Verifica se uma entidade tem comprovante
  Future<bool> hasReceipt(ReceiptEntityType entityType, int entityId) async {
    final count = await countImagesForEntity(entityType, entityId);
    return count > 0;
  }
}
