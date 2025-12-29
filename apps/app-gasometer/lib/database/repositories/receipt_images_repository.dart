import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

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
/// Armazena imagens de recibos como Base64 para sincronização com Firestore.
/// Usa ImageProcessingService para compressão automática (max 600KB).
///
/// Responsabilidades:
/// - CRUD de imagens de comprovantes
/// - Processamento e compressão automática
/// - Associação com abastecimentos, manutenções e despesas
/// - Controle de sincronização
class ReceiptImagesDriftRepository {
  ReceiptImagesDriftRepository(this._db);

  final GasometerDatabase _db;
  final _processingService = ImageProcessingService.instance;

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem de comprovante
  ///
  /// A imagem é automaticamente processada e comprimida para max 600KB.
  /// Usa configuração 'receipt' que preserva melhor a legibilidade.
  ///
  /// [entityType] - Tipo da entidade (fuel_supply, maintenance, expense)
  /// [entityId] - ID da entidade
  /// [imageBytes] - Bytes da imagem original
  /// [fileName] - Nome original do arquivo
  /// [userId] - ID do usuário
  Future<int> saveImage({
    required ReceiptEntityType entityType,
    required int entityId,
    required Uint8List imageBytes,
    required String userId,
    String? fileName,
  }) async {
    // Processar e comprimir imagem (usa config receipt para melhor legibilidade)
    final processed = await _processingService.processImage(
      imageBytes,
      config: ImageProcessingConfig.receipt,
    );

    _log('Comprovante processado: ${processed.sizeBytes} bytes '
        '(${processed.width}x${processed.height}), '
        'economia: ${processed.savedPercent.toStringAsFixed(1)}%');

    final companion = ReceiptImagesCompanion(
      entityType: Value(entityType.value),
      entityId: Value(entityId),
      imageBase64: Value(base64Encode(processed.bytes)),
      fileName: Value(fileName),
      mimeType: Value(processed.mimeType),
      sizeBytes: Value(processed.sizeBytes),
      userId: Value(userId),
      isDirty: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.receiptImages).insert(companion);
    _log('Comprovante salvo: id=$id, entityType=${entityType.value}, '
        'entityId=$entityId, size=${processed.sizeBytes} bytes');
    return id;
  }

  /// Salva imagem já processada (Base64)
  ///
  /// Útil para sincronização quando a imagem já vem processada do Firestore.
  Future<int> saveProcessedImage({
    required ReceiptEntityType entityType,
    required int entityId,
    required String imageBase64,
    required String userId,
    String? fileName,
    String mimeType = 'image/jpeg',
    int? sizeBytes,
    int? width,
    int? height,
    String? firebaseId,
  }) async {
    final cleanedBase64 = imageBase64.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');

    final companion = ReceiptImagesCompanion(
      entityType: Value(entityType.value),
      entityId: Value(entityId),
      imageBase64: Value(cleanedBase64),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      userId: Value(userId),
      firebaseId: Value(firebaseId),
      isDirty: Value(firebaseId == null),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      lastSyncAt: firebaseId != null ? Value(DateTime.now()) : const Value.absent(),
    );

    final id = await _db.into(_db.receiptImages).insert(companion);
    _log('Comprovante processado salvo: id=$id, entityType=${entityType.value}');
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

  /// Retorna uma imagem pelo Firebase ID
  Future<ReceiptImage?> getImageByFirebaseId(String firebaseId) async {
    return (_db.select(_db.receiptImages)
          ..where((i) => i.firebaseId.equals(firebaseId)))
        .getSingleOrNull();
  }

  /// Retorna imagens pendentes de sincronização
  Future<List<ReceiptImage>> getDirtyImages() async {
    return (_db.select(_db.receiptImages)
          ..where((i) => i.isDirty.equals(true) & i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
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

  /// Marca imagem como sincronizada
  Future<void> markAsSynced({
    required int imageId,
    required String firebaseId,
  }) async {
    await (_db.update(_db.receiptImages)..where((i) => i.id.equals(imageId)))
        .write(ReceiptImagesCompanion(
      firebaseId: Value(firebaseId),
      isDirty: const Value(false),
      lastSyncAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    _log('Comprovante $imageId marcado como sincronizado: $firebaseId');
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
    _log('Comprovante marcado como deletado: id=$imageId');
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(_db.receiptImages)..where((i) => i.id.equals(imageId)))
        .go();
    _log('Comprovante removido permanentemente: id=$imageId');
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

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('📷 [ReceiptImagesDriftRepository] $message');
    }
  }
}
