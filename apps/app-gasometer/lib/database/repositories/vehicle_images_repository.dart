import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../gasometer_database.dart';

/// Repository para gerenciar imagens de veículos no Drift
///
/// Armazena imagens como Base64 para sincronização com Firestore.
/// Usa ImageProcessingService para compressão automática (max 600KB).
///
/// Responsabilidades:
/// - CRUD de imagens locais
/// - Processamento e compressão automática
/// - Gerenciamento de imagem primária
/// - Controle de sincronização
class VehicleImagesDriftRepository {
  VehicleImagesDriftRepository(this._db);

  final GasometerDatabase _db;
  final _processingService = ImageProcessingService.instance;

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Salva uma nova imagem para um veículo
  ///
  /// A imagem é automaticamente processada e comprimida para max 600KB.
  ///
  /// [vehicleId] - ID local do veículo
  /// [imageBytes] - Bytes da imagem original
  /// [fileName] - Nome original do arquivo
  /// [isPrimary] - Se é a imagem principal
  /// [userId] - ID do usuário
  /// [config] - Configuração de processamento (default: standard)
  Future<int> saveImage({
    required int vehicleId,
    required Uint8List imageBytes,
    required String userId,
    String? fileName,
    bool isPrimary = false,
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
      await _clearPrimaryFlag(vehicleId);
    }

    final companion = VehicleImagesCompanion(
      vehicleId: Value(vehicleId),
      imageBase64: Value(base64Encode(processed.bytes)),
      fileName: Value(fileName),
      mimeType: Value(processed.mimeType),
      sizeBytes: Value(processed.sizeBytes),
      isPrimary: Value(isPrimary),
      userId: Value(userId),
      isDirty: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _db.into(_db.vehicleImages).insert(companion);
    _log('Imagem salva: id=$id, vehicleId=$vehicleId, size=${processed.sizeBytes} bytes');
    return id;
  }

  /// Salva imagem já processada (Base64)
  ///
  /// Útil para sincronização quando a imagem já vem processada do Firestore.
  Future<int> saveProcessedImage({
    required int vehicleId,
    required String imageBase64,
    required String userId,
    String? fileName,
    String mimeType = 'image/jpeg',
    int? sizeBytes,
    int? width,
    int? height,
    bool isPrimary = false,
    String? firebaseId,
  }) async {
    if (isPrimary) {
      await _clearPrimaryFlag(vehicleId);
    }

    final cleanedBase64 = imageBase64.replaceAll(RegExp(r'^data:image\/[^;]+;base64,'), '');

    final companion = VehicleImagesCompanion(
      vehicleId: Value(vehicleId),
      imageBase64: Value(cleanedBase64),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      isPrimary: Value(isPrimary),
      userId: Value(userId),
      firebaseId: Value(firebaseId),
      isDirty: Value(firebaseId == null), // Dirty se não tem firebaseId
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      lastSyncAt: firebaseId != null ? Value(DateTime.now()) : const Value.absent(),
    );

    final id = await _db.into(_db.vehicleImages).insert(companion);
    _log('Imagem processada salva: id=$id, vehicleId=$vehicleId');
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

  /// Retorna uma imagem pelo Firebase ID
  Future<VehicleImage?> getImageByFirebaseId(String firebaseId) async {
    return (_db.select(_db.vehicleImages)
          ..where((i) => i.firebaseId.equals(firebaseId)))
        .getSingleOrNull();
  }

  /// Retorna imagens pendentes de sincronização
  Future<List<VehicleImage>> getDirtyImages() async {
    return (_db.select(_db.vehicleImages)
          ..where((i) => i.isDirty.equals(true) & i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
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
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Marca imagem como sincronizada
  Future<void> markAsSynced({
    required int imageId,
    required String firebaseId,
  }) async {
    await (_db.update(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .write(VehicleImagesCompanion(
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
    await (_db.update(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .write(VehicleImagesCompanion(
      isDeleted: const Value(true),
      isDirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
    _log('Imagem marcada como deletada: id=$imageId');
  }

  /// Remove permanentemente uma imagem
  Future<void> hardDeleteImage(int imageId) async {
    await (_db.delete(_db.vehicleImages)..where((i) => i.id.equals(imageId)))
        .go();
    _log('Imagem removida permanentemente: id=$imageId');
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
      isDirty: Value(true),
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

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('📷 [VehicleImagesDriftRepository] $message');
    }
  }
}
