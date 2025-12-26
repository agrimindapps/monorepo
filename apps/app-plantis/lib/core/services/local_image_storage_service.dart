import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/providers/database_providers.dart';
import '../../database/repositories/plant_images_drift_repository.dart';

/// Serviço para gerenciar armazenamento local de imagens como BLOB
///
/// Responsabilidades:
/// - Converter base64 para bytes e salvar no Drift
/// - Carregar imagens do Drift
/// - Gerenciar cache de imagens em memória
class LocalImageStorageService {
  final PlantImagesDriftRepository _repository;

  LocalImageStorageService(this._repository);

  /// Salva uma imagem base64 no banco de dados como BLOB
  ///
  /// Retorna o ID local da imagem salva
  Future<int> saveBase64Image({
    required int plantId,
    required String base64Image,
    String? fileName,
    bool isPrimary = false,
    String? userId,
  }) async {
    debugPrint(
      '📷 [LocalImageStorageService] Salvando imagem para planta $plantId',
    );

    // Extrair dados base64
    final mimeType = _extractMimeType(base64Image);
    final pureBase64 = _extractPureBase64(base64Image);

    // Converter para bytes
    final bytes = base64Decode(pureBase64);
    debugPrint(
      '📷 [LocalImageStorageService] Imagem decodificada: ${bytes.length} bytes, mimeType: $mimeType',
    );

    // Salvar no Drift
    final imageId = await _repository.saveImage(
      plantId: plantId,
      imageBytes: bytes,
      fileName: fileName,
      isPrimary: isPrimary,
      userId: userId,
    );

    debugPrint('📷 [LocalImageStorageService] Imagem salva com id=$imageId');
    return imageId;
  }

  /// Carrega a imagem primária de uma planta como base64
  Future<String?> getPrimaryImageAsBase64(int plantId) async {
    final image = await _repository.getPrimaryImage(plantId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Carrega uma imagem por ID como base64
  Future<String?> getImageAsBase64(int imageId) async {
    final image = await _repository.getImageById(imageId);
    if (image == null) return null;

    return _bytesToBase64DataUrl(image.imageData, image.mimeType);
  }

  /// Carrega todas as imagens de uma planta como base64
  Future<List<String>> getAllImagesAsBase64(int plantId) async {
    final images = await _repository.getImagesByPlantId(plantId);
    return images
        .map((img) => _bytesToBase64DataUrl(img.imageData, img.mimeType))
        .toList();
  }

  /// Stream de imagens de uma planta (bytes)
  Stream<List<Uint8List>> watchPlantImages(int plantId) {
    return _repository
        .watchImagesByPlantId(plantId)
        .map((images) => images.map((img) => img.imageData).toList());
  }

  /// Define imagem como primária
  Future<void> setPrimaryImage(int imageId, int plantId) async {
    await _repository.setPrimaryImage(imageId, plantId);
  }

  /// Remove uma imagem
  Future<void> deleteImage(int imageId) async {
    await _repository.deleteImage(imageId);
  }

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
final localImageStorageServiceProvider = Provider<LocalImageStorageService>((
  ref,
) {
  final repository = ref.watch(plantImagesDriftRepositoryProvider);
  return LocalImageStorageService(repository);
});
