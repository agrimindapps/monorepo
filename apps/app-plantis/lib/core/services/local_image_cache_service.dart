import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Representa uma imagem em cache local
class CachedImage {
  final String id;
  final String base64Data;
  final String? fileName;
  final String? folder;
  final DateTime cachedAt;
  final String? mimeType;
  final bool syncedToServer;
  final String? downloadUrl;

  CachedImage({
    required this.id,
    required this.base64Data,
    this.fileName,
    this.folder,
    DateTime? cachedAt,
    this.mimeType,
    this.syncedToServer = false,
    this.downloadUrl,
  }) : cachedAt = cachedAt ?? DateTime.now();

  /// Converte para JSON para armazenamento
  Map<String, dynamic> toJson() => {
        'id': id,
        'base64Data': base64Data,
        'fileName': fileName,
        'folder': folder,
        'cachedAt': cachedAt.toIso8601String(),
        'mimeType': mimeType,
        'syncedToServer': syncedToServer,
        'downloadUrl': downloadUrl,
      };

  /// Cria a partir de JSON
  factory CachedImage.fromJson(Map<String, dynamic> json) => CachedImage(
        id: json['id'] as String,
        base64Data: json['base64Data'] as String,
        fileName: json['fileName'] as String?,
        folder: json['folder'] as String?,
        cachedAt: DateTime.parse(json['cachedAt'] as String),
        mimeType: json['mimeType'] as String?,
        syncedToServer: json['syncedToServer'] as bool? ?? false,
        downloadUrl: json['downloadUrl'] as String?,
      );
}

/// Configuração para cache local
class LocalImageCacheConfig {
  /// Habilitar cache apenas em web
  final bool onlyOnWeb;

  /// Máximo de imagens em cache
  final int maxCachedImages;

  /// TTL para cache (dias)
  final int cacheTTLDays;

  /// Prefixo de chave para SharedPreferences
  final String keyPrefix;

  const LocalImageCacheConfig({
    this.onlyOnWeb = true,
    this.maxCachedImages = 50,
    this.cacheTTLDays = 7,
    this.keyPrefix = 'plantis_image_cache_',
  });
}

/// Serviço de cache local para imagens
/// Armazena imagens em local storage quando offline
/// Sincroniza com servidor quando volta online
class LocalImageCacheService {
  final LocalImageCacheConfig config;
  late final SharedPreferences _prefs;
  bool _initialized = false;

  LocalImageCacheService({
    LocalImageCacheConfig? config,
  }) : config = config ?? const LocalImageCacheConfig();

  /// Inicializa o serviço
  Future<Either<Failure, void>> initialize() async {
    try {
      if (config.onlyOnWeb && !kIsWeb) {
        return const Right(null);
      }

      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao inicializar cache local: $e'),
      );
    }
  }

  /// Salva imagem em cache local
  Future<Either<Failure, CachedImage>> saveImage(
    String base64Data, {
    required String id,
    String? fileName,
    String? folder,
    String? mimeType,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      if (config.onlyOnWeb && !kIsWeb) {
        return Right(
          CachedImage(
            id: id,
            base64Data: base64Data,
            fileName: fileName,
            folder: folder,
            mimeType: mimeType,
          ),
        );
      }

      final cachedImage = CachedImage(
        id: id,
        base64Data: base64Data,
        fileName: fileName,
        folder: folder,
        mimeType: mimeType,
      );

      // Verifica limite de cache
      final currentCount = _getImageCount();
      if (currentCount >= config.maxCachedImages) {
        // Remove imagem mais antiga
        await _removeOldestImage();
      }

      // Salva no SharedPreferences
      final key = '${config.keyPrefix}$id';
      final success = await _prefs.setString(
        key,
        _encodeImage(cachedImage),
      );

      if (!success) {
        return Left(
          CacheFailure('Erro ao salvar imagem em cache'),
        );
      }

      return Right(cachedImage);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao salvar imagem em cache: $e'),
      );
    }
  }

  /// Recupera imagem do cache
  Future<Either<Failure, CachedImage>> getImage(String id) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      if (config.onlyOnWeb && !kIsWeb) {
        return Left(CacheFailure('Cache não disponível em mobile'));
      }

      final key = '${config.keyPrefix}$id';
      final data = _prefs.getString(key);

      if (data == null) {
        return Left(
          CacheFailure('Imagem não encontrada em cache: $id'),
        );
      }

      final image = _decodeImage(data);

      // Verifica se expirou
      if (_hasExpired(image)) {
        await removeImage(id);
        return Left(
          CacheFailure('Imagem expirada: $id'),
        );
      }

      return Right(image);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao recuperar imagem do cache: $e'),
      );
    }
  }

  /// Lista todas as imagens em cache
  Future<Either<Failure, List<CachedImage>>> listCachedImages() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      if (config.onlyOnWeb && !kIsWeb) {
        return const Right([]);
      }

      final images = <CachedImage>[];

      for (final key in _prefs.getKeys()) {
        if (key.startsWith(config.keyPrefix)) {
          try {
            final data = _prefs.getString(key);
            if (data != null) {
              final image = _decodeImage(data);

              // Remove se expirou
              if (_hasExpired(image)) {
                final id = key.replaceFirst(config.keyPrefix, '');
                await removeImage(id);
              } else {
                images.add(image);
              }
            }
          } catch (_) {
            // Ignora erros ao decodificar
          }
        }
      }

      return Right(images);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao listar imagens em cache: $e'),
      );
    }
  }

  /// Remove imagem do cache
  Future<Either<Failure, void>> removeImage(String id) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final key = '${config.keyPrefix}$id';
      await _prefs.remove(key);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao remover imagem do cache: $e'),
      );
    }
  }

  /// Limpa todo o cache
  Future<Either<Failure, void>> clearCache() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      for (final key in _prefs.getKeys().toList()) {
        if (key.startsWith(config.keyPrefix)) {
          await _prefs.remove(key);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao limpar cache: $e'),
      );
    }
  }

  /// Marca imagem como sincronizada
  Future<Either<Failure, void>> markAsSynced(
    String id, {
    String? downloadUrl,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final imageResult = await getImage(id);

      return await imageResult.fold(
        (failure) => Left(failure),
        (image) async {
          final syncedImage = CachedImage(
            id: image.id,
            base64Data: image.base64Data,
            fileName: image.fileName,
            folder: image.folder,
            cachedAt: image.cachedAt,
            mimeType: image.mimeType,
            syncedToServer: true,
            downloadUrl: downloadUrl,
          );

          final key = '${config.keyPrefix}$id';
          final success = await _prefs.setString(
            key,
            _encodeImage(syncedImage),
          );

          if (!success) {
            return Left(CacheFailure('Erro ao atualizar cache'));
          }

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao marcar como sincronizado: $e'),
      );
    }
  }

  /// Lista imagens não sincronizadas (offline queue)
  Future<Either<Failure, List<CachedImage>>> getUnsyncedImages() async {
    try {
      final imagesResult = await listCachedImages();

      return imagesResult.fold(
        (failure) => Left(failure),
        (images) => Right(
          images.where((img) => !img.syncedToServer).toList(),
        ),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao listar imagens não sincronizadas: $e'),
      );
    }
  }

  // ============ HELPERS ============

  int _getImageCount() {
    return _prefs.getKeys().where((key) => key.startsWith(config.keyPrefix)).length;
  }

  Future<void> _removeOldestImage() async {
    DateTime? oldestTime;
    String? oldestKey;

    for (final key in _prefs.getKeys()) {
      if (key.startsWith(config.keyPrefix)) {
        try {
          final data = _prefs.getString(key);
          if (data != null) {
            final image = _decodeImage(data);
            if (oldestTime == null || image.cachedAt.isBefore(oldestTime)) {
              oldestTime = image.cachedAt;
              oldestKey = key;
            }
          }
        } catch (_) {}
      }
    }

    if (oldestKey != null) {
      await _prefs.remove(oldestKey);
    }
  }

  bool _hasExpired(CachedImage image) {
    final expirationTime = image.cachedAt.add(
      Duration(days: config.cacheTTLDays),
    );
    return DateTime.now().isAfter(expirationTime);
  }

  String _encodeImage(CachedImage image) {
    // Simples JSON string (pode ser melhorado com compressão)
    return image.toJson().toString();
  }

  CachedImage _decodeImage(String data) {
    // Parse do toString() format
    // Em produção, usar json.decode()
    final json = _parseJsonString(data);
    return CachedImage.fromJson(json);
  }

  Map<String, dynamic> _parseJsonString(String str) {
    // Remove "{ e }" extras do toString()
    final cleaned = str.replaceAll(RegExp(r'^{|}$'), '');
    final pairs = cleaned.split(', ');
    final json = <String, dynamic>{};

    for (final pair in pairs) {
      final parts = pair.split(': ');
      if (parts.length == 2) {
        final key = parts[0].trim();
        var value = parts[1].trim();

        // Parse do valor
        if (value == 'true') {
          json[key] = true;
        } else if (value == 'false') {
          json[key] = false;
        } else if (value.startsWith('"') && value.endsWith('"')) {
          json[key] = value.substring(1, value.length - 1);
        } else {
          json[key] = value;
        }
      }
    }

    return json;
  }
}
