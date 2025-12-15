import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import 'image_compression_service.dart' as app_compression;
import 'local_image_cache_service.dart';

/// Gerenciador completo de upload de imagens para web
/// Combina compressão, cache local e sincronização automática
class WebImageUploadManager {
  final app_compression.ImageCompressionService _compressionService;
  final LocalImageCacheService _cacheService;
  final ImageService _imageService;

  WebImageUploadManager({
    app_compression.ImageCompressionService? compressionService,
    LocalImageCacheService? cacheService,
    ImageService? imageService,
  }) : _compressionService =
           compressionService ?? app_compression.ImageCompressionService(),
       _cacheService = cacheService ?? LocalImageCacheService(),
       _imageService = imageService ?? ImageService();

  /// Faz upload de imagem com compressão e cache automáticos
  /// Fluxo completo:
  /// 1. Comprime a imagem (se em web e maior que 500KB)
  /// 2. Salva em cache local (para offline)
  /// 3. Tenta upload
  /// 4. Se offline, marca para sincronização posterior
  /// 5. Quando voltar online, sincroniza automaticamente
  Future<Either<Failure, String>> uploadImageWithCompressionAndCache(
    String base64Data, {
    required String imageId,
    String? fileName,
    String? folder,
    String? mimeType,
    void Function(double)? onProgress,
  }) async {
    try {
      // 1. Inicializa cache (se não estiver)
      await _cacheService.initialize();

      // 2. Comprime a imagem (redutor que funciona em web)
      final compressedBase64 = await _compressionService.compressBase64Image(
        base64Data,
      );

      // 3. Log das estatísticas de compressão
      if (kIsWeb) {
        final stats = _compressionService.getCompressionStats(
          base64Data,
          compressedBase64,
        );
        if (kDebugMode) {
          debugPrint('[ImageCompression] Stats: $stats');
        }
      }

      // 4. Salva em cache local
      final cacheResult = await _cacheService.saveImage(
        compressedBase64,
        id: imageId,
        fileName: fileName,
        folder: folder,
        mimeType: mimeType,
      );

      cacheResult.fold((failure) {
        if (kDebugMode) {
          debugPrint('[WebImageUploadManager] Falha ao cachear: $failure');
        }
      }, (_) => null);

      // 5. Tenta fazer upload
      final uploadResult = await _tryUploadWithFallback(
        compressedBase64,
        folder: folder,
        fileName: fileName,
        mimeType: mimeType ?? 'image/jpeg',
        onProgress: onProgress,
      );

      // 6. Se upload bem-sucedido, marca como sincronizado
      return uploadResult.fold(
        (failure) {
          // Se falhou (offline), imagem já está em cache para sincronizar depois
          return const Left(
            NetworkFailure(
              'Imagem salva em cache. Será sincronizada quando conectar',
            ),
          );
        },
        (downloadUrl) async {
          await _cacheService.markAsSynced(imageId, downloadUrl: downloadUrl);
          return Right(downloadUrl);
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Erro no upload com compressão: $e'));
    }
  }

  /// Sincroniza imagens não sincronizadas (offline queue)
  Future<Either<Failure, Map<String, String>>> syncUnsyncedImages({
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final unsyncedResult = await _cacheService.getUnsyncedImages();

      return await unsyncedResult.fold((failure) => Left(failure), (
        unsynced,
      ) async {
        final results = <String, String>{};
        final total = unsynced.length;

        for (int i = 0; i < unsynced.length; i++) {
          final image = unsynced[i];
          onProgress?.call(i + 1, total);

          // Tenta fazer upload de novo
          final uploadResult = await _tryUploadWithFallback(
            image.base64Data,
            folder: image.folder,
            fileName: image.fileName,
            mimeType: image.mimeType ?? 'image/jpeg',
          );

          await uploadResult.fold(
            (_) async => null,
            (downloadUrl) async {
              results[image.id] = downloadUrl;

              // Marca como sincronizado
              await _cacheService.markAsSynced(
                image.id,
                downloadUrl: downloadUrl,
              );
            },
          );
        }

        return Right(results);
      });
    } catch (e) {
      return Left(NetworkFailure('Erro ao sincronizar imagens: $e'));
    }
  }

  /// Tenta fazer upload com fallback para cache
  Future<Either<Failure, String>> _tryUploadWithFallback(
    String base64Data, {
    String? folder,
    String? fileName,
    required String mimeType,
    void Function(double)? onProgress,
  }) async {
    try {
      // Em web, usa uploadImageFromBase64
      if (kIsWeb) {
        final result = await _imageService.uploadImageFromBase64(
          base64Data,
          folder: folder,
          fileName: fileName,
          mimeType: mimeType,
          onProgress: onProgress,
        );

        // Converte Result para Either
        if (result.isSuccess) {
          return Right(result.data!.downloadUrl);
        } else {
          return Left(
            NetworkFailure(result.error?.message ?? 'Erro no upload'),
          );
        }
      }

      // Em mobile/desktop, não deve chegar aqui (usaria WebImageUploadManager)
      return const Left(
        NetworkFailure('Upload de Base64 não suportado em mobile/desktop'),
      );
    } catch (e) {
      return Left(NetworkFailure('Erro ao fazer upload: $e'));
    }
  }

  /// Limpa cache de imagens sincronizadas
  Future<Either<Failure, void>> clearSyncedImages() async {
    try {
      final imagesResult = await _cacheService.listCachedImages();

      return await imagesResult.fold((failure) => Left(failure), (
        images,
      ) async {
        for (final image in images) {
          if (image.syncedToServer) {
            await _cacheService.removeImage(image.id);
          }
        }

        return const Right(null);
      });
    } catch (e) {
      return Left(NetworkFailure('Erro ao limpar cache: $e'));
    }
  }

  /// Limpa todo o cache
  Future<Either<Failure, void>> clearAllCache() {
    return _cacheService.clearCache();
  }

  /// Obtém estatísticas do cache
  Future<Either<Failure, Map<String, dynamic>>> getCacheStats() async {
    try {
      final imagesResult = await _cacheService.listCachedImages();

      return await imagesResult.fold((failure) => Left(failure), (images) {
        int synced = 0;
        int unsynced = 0;
        int totalSizeMB = 0;

        for (final img in images) {
          if (img.syncedToServer) {
            synced++;
          } else {
            unsynced++;
          }
          // Estima tamanho do Base64
          totalSizeMB += (img.base64Data.length / (1024 * 1024)).ceil();
        }

        return Right({
          'totalImages': images.length,
          'syncedImages': synced,
          'unsyncedImages': unsynced,
          'estimatedCacheSizeMB': totalSizeMB,
          'maxCachedImages': _cacheService.config.maxCachedImages,
        });
      });
    } catch (e) {
      return Left(NetworkFailure('Erro ao obter estatísticas: $e'));
    }
  }
}
