import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/gasometer_database.dart';
import '../../../database/providers/database_providers.dart';
import '../../../database/repositories/receipt_images_repository.dart';
import '../../../database/repositories/vehicle_images_repository.dart';

/// Serviço para gerenciar armazenamento local de imagens como BLOB
///
/// Responsabilidades:
/// - Converter base64 para bytes e salvar no Drift
/// - Carregar imagens do Drift
/// - Gerenciar cache de imagens em memória
class LocalImageStorageService {
  LocalImageStorageService(
    this._vehicleImagesRepository,
    this._receiptImagesRepository,
  );

  final VehicleImagesDriftRepository _vehicleImagesRepository;
  final ReceiptImagesDriftRepository _receiptImagesRepository;

  // =========================================================================
  // VEHICLE IMAGES
  // =========================================================================

  /// Salva uma imagem base64 de veículo no banco de dados como BLOB
  ///
  /// Retorna o ID local da imagem salva
  Future<int> saveVehicleImage({
    required int vehicleId,
    required String base64Image,
    required String userId,
    String? fileName,
    bool isPrimary = false,
  }) async {
    debugPrint(
        '📷 [LocalImageStorageService] Salvando imagem para veículo $vehicleId');

    // Extrair dados base64
    final mimeType = _extractMimeType(base64Image);
    final pureBase64 = _extractPureBase64(base64Image);

    // Converter para bytes
    final bytes = base64Decode(pureBase64);
    debugPrint(
        '📷 [LocalImageStorageService] Imagem decodificada: ${bytes.length} bytes, mimeType: $mimeType');

    // Salvar no Drift
    final imageId = await _vehicleImagesRepository.saveImage(
      vehicleId: vehicleId,
      imageBytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      isPrimary: isPrimary,
      userId: userId,
    );

    debugPrint('📷 [LocalImageStorageService] Imagem salva com id=$imageId');
    return imageId;
  }

  /// Carrega a imagem primária de um veículo como base64
  Future<String?> getVehiclePrimaryImageAsBase64(int vehicleId) async {
    final image = await _vehicleImagesRepository.getPrimaryImage(vehicleId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Carrega uma imagem de veículo por ID como base64
  Future<String?> getVehicleImageAsBase64(int imageId) async {
    final image = await _vehicleImagesRepository.getImageById(imageId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Carrega todas as imagens de um veículo como base64
  Future<List<String>> getAllVehicleImagesAsBase64(int vehicleId) async {
    final images = await _vehicleImagesRepository.getImagesByVehicleId(vehicleId);
    return images
        .map((VehicleImage img) => _bytesToBase64DataUrl(img.imageData, img.mimeType))
        .toList();
  }

  /// Stream de imagens de um veículo (bytes)
  Stream<List<Uint8List>> watchVehicleImages(int vehicleId) {
    return _vehicleImagesRepository.watchImagesByVehicleId(vehicleId).map(
          (List<VehicleImage> images) => images.map((VehicleImage img) => img.imageData).toList(),
        );
  }

  /// Define imagem de veículo como primária
  Future<void> setVehiclePrimaryImage(int imageId, int vehicleId) async {
    await _vehicleImagesRepository.setPrimaryImage(imageId, vehicleId);
  }

  /// Remove uma imagem de veículo
  Future<void> deleteVehicleImage(int imageId) async {
    await _vehicleImagesRepository.deleteImage(imageId);
  }

  // =========================================================================
  // RECEIPT IMAGES
  // =========================================================================

  /// Salva uma imagem base64 de comprovante no banco de dados como BLOB
  ///
  /// Retorna o ID local da imagem salva
  Future<int> saveReceiptImage({
    required ReceiptEntityType entityType,
    required int entityId,
    required String base64Image,
    required String userId,
    String? fileName,
  }) async {
    debugPrint(
        '📷 [LocalImageStorageService] Salvando comprovante para ${entityType.value} $entityId');

    // Extrair dados base64
    final mimeType = _extractMimeType(base64Image);
    final pureBase64 = _extractPureBase64(base64Image);

    // Converter para bytes
    final bytes = base64Decode(pureBase64);
    debugPrint(
        '📷 [LocalImageStorageService] Comprovante decodificado: ${bytes.length} bytes, mimeType: $mimeType');

    // Salvar no Drift
    final imageId = await _receiptImagesRepository.saveImage(
      entityType: entityType,
      entityId: entityId,
      imageBytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      userId: userId,
    );

    debugPrint(
        '📷 [LocalImageStorageService] Comprovante salvo com id=$imageId');
    return imageId;
  }

  /// Carrega a imagem de comprovante de uma entidade como base64
  Future<String?> getReceiptImageAsBase64(
      ReceiptEntityType entityType, int entityId) async {
    final image =
        await _receiptImagesRepository.getImageByEntity(entityType, entityId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Carrega uma imagem de comprovante por ID como base64
  Future<String?> getReceiptImageByIdAsBase64(int imageId) async {
    final image = await _receiptImagesRepository.getImageById(imageId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Stream de imagens de comprovante de uma entidade
  Stream<List<Uint8List>> watchReceiptImages(
      ReceiptEntityType entityType, int entityId) {
    return _receiptImagesRepository
        .watchImagesByEntity(entityType, entityId)
        .map(
          (List<ReceiptImage> images) => images.map((ReceiptImage img) => img.imageData).toList(),
        );
  }

  /// Remove uma imagem de comprovante
  Future<void> deleteReceiptImage(int imageId) async {
    await _receiptImagesRepository.deleteImage(imageId);
  }

  /// Verifica se uma entidade tem comprovante
  Future<bool> hasReceipt(ReceiptEntityType entityType, int entityId) async {
    return await _receiptImagesRepository.hasReceipt(entityType, entityId);
  }

  // =========================================================================
  // PENDING UPLOADS
  // =========================================================================

  /// Retorna todas as imagens de veículos pendentes de upload
  Future<List<dynamic>> getVehiclePendingUploads() async {
    return await _vehicleImagesRepository.getPendingUploads();
  }

  /// Retorna todas as imagens de comprovantes pendentes de upload
  Future<List<dynamic>> getReceiptPendingUploads() async {
    return await _receiptImagesRepository.getPendingUploads();
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Extrai o MIME type de uma string base64 data URL
  String _extractMimeType(String base64) {
    if (base64.startsWith('data:')) {
      final match = RegExp(r'data:([^;]+);').firstMatch(base64);
      return match?.group(1) ?? 'image/jpeg';
    }
    return 'image/jpeg';
  }

  /// Extrai apenas os dados base64 puros (sem prefixo data:)
  String _extractPureBase64(String base64) {
    if (base64.contains(',')) {
      return base64.split(',').last;
    }
    return base64;
  }

  /// Converte bytes para data URL base64
  String _bytesToBase64DataUrl(Uint8List bytes, String mimeType) {
    final base64String = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64String';
  }
}

/// Provider para LocalImageStorageService
final localImageStorageServiceProvider =
    Provider<LocalImageStorageService>((ref) {
  final vehicleImagesRepository = ref.watch(vehicleImagesDriftRepositoryProvider);
  final receiptImagesRepository = ref.watch(receiptImagesDriftRepositoryProvider);
  return LocalImageStorageService(
    vehicleImagesRepository,
    receiptImagesRepository,
  );
});
