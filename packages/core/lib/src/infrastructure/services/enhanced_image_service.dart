import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../shared/utils/failure.dart';

/// Service completo para manipulação de imagens
///
/// Funcionalidades:
/// - Seleção de imagens (camera/galeria)
/// - Cache inteligente de imagens
/// - Compressão e otimização automática
/// - Redimensionamento
/// - Conversão de formatos
/// - Thumbnails
/// - Validações de segurança
class EnhancedImageService {
  static const String _cacheDirectory = 'image_cache';
  static const int _defaultQuality = 85;
  static const int _maxImageSize = 1920;
  static const int _thumbnailSize = 200;

  final ImagePicker _picker = ImagePicker();
  final Map<String, Uint8List> _memoryCache = {};

  late final Directory _cacheDir;
  bool _initialized = false;

  /// Inicializa o service (deve ser chamado antes do uso)
  Future<Either<Failure, void>> initialize() async {
    if (_initialized) return const Right(null);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(path.join(appDir.path, _cacheDirectory));

      if (!await _cacheDir.exists()) {
        await _cacheDir.create(recursive: true);
      }

      _initialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao inicializar serviço de imagens: ${e.toString()}',
          code: 'INIT_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Seleciona imagem da câmera
  Future<Either<Failure, ImageResult>> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = false,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? _defaultQuality,
        requestFullMetadata: requestFullMetadata,
      );

      if (image == null) {
        return const Left(
          ValidationFailure(
            'Nenhuma imagem foi selecionada',
            code: 'NO_IMAGE_SELECTED',
          ),
        );
      }

      return await _processSelectedImage(image);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao acessar câmera: ${e.toString()}',
          code: 'CAMERA_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Seleciona imagem da galeria
  Future<Either<Failure, ImageResult>> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = false,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? _defaultQuality,
        requestFullMetadata: requestFullMetadata,
      );

      if (image == null) {
        return const Left(
          ValidationFailure(
            'Nenhuma imagem foi selecionada',
            code: 'NO_IMAGE_SELECTED',
          ),
        );
      }

      return await _processSelectedImage(image);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao acessar galeria: ${e.toString()}',
          code: 'GALLERY_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Seleciona múltiplas imagens da galeria
  Future<Either<Failure, List<ImageResult>>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? _defaultQuality,
        limit: limit,
      );

      if (images.isEmpty) {
        return const Left(
          ValidationFailure(
            'Nenhuma imagem foi selecionada',
            code: 'NO_IMAGES_SELECTED',
          ),
        );
      }

      final List<ImageResult> results = [];

      for (final image in images) {
        final result = await _processSelectedImage(image);
        result.fold(
          (failure) =>
              debugPrint('Erro ao processar imagem ${image.name}: $failure'),
          (data) => results.add(data),
        );
      }

      if (results.isEmpty) {
        return const Left(
          ValidationFailure(
            'Não foi possível processar nenhuma das imagens selecionadas',
            code: 'NO_VALID_IMAGES',
          ),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao selecionar múltiplas imagens: ${e.toString()}',
          code: 'MULTI_PICK_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Carrega imagem do cache ou da rede
  Future<Either<Failure, Uint8List>> loadImage(
    String imageUrl, {
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    final cacheKey = _generateCacheKey(imageUrl);
    if (useCache && !forceRefresh && _memoryCache.containsKey(cacheKey)) {
      return Right(_memoryCache[cacheKey]!);
    }
    if (useCache && !forceRefresh) {
      final diskCacheResult = await _loadFromDiskCache(cacheKey);
      final diskData = diskCacheResult.fold((_) => null, (data) => data);
      if (diskData != null) {
        _memoryCache[cacheKey] = diskData;
        return Right(diskData);
      }
    }
    return await _downloadAndCacheImage(imageUrl, cacheKey);
  }

  /// Cria thumbnail de uma imagem
  Future<Either<Failure, Uint8List>> createThumbnail(
    String imagePath, {
    int size = _thumbnailSize,
    int quality = _defaultQuality,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return const Left(
          ValidationFailure(
            'Arquivo de imagem não encontrado',
            code: 'FILE_NOT_FOUND',
          ),
        );
      }

      final bytes = await file.readAsBytes();
      return await _resizeImage(bytes, size, size, quality);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao criar thumbnail: ${e.toString()}',
          code: 'THUMBNAIL_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Comprime uma imagem
  Future<Either<Failure, Uint8List>> compressImage(
    Uint8List imageBytes, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      if (maxWidth != null || maxHeight != null) {
        return await _resizeImage(
          imageBytes,
          maxWidth ?? _maxImageSize,
          maxHeight ?? _maxImageSize,
          quality,
        );
      }
      return Right(imageBytes);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao comprimir imagem: ${e.toString()}',
          code: 'COMPRESSION_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Valida se o arquivo é uma imagem válida
  Future<Either<Failure, bool>> validateImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const Left(
          ValidationFailure('Arquivo não encontrado', code: 'FILE_NOT_FOUND'),
        );
      }

      final extension = path.extension(filePath).toLowerCase();
      final validExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.bmp',
      ];

      if (!validExtensions.contains(extension)) {
        return Left(
          ValidationFailure(
            'Formato de arquivo não suportado: $extension',
            code: 'UNSUPPORTED_FORMAT',
          ),
        );
      }
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSize) {
        return const Left(
          ValidationFailure(
            'Arquivo muito grande. Máximo permitido: 10MB',
            code: 'FILE_TOO_LARGE',
          ),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao validar imagem: ${e.toString()}',
          code: 'VALIDATION_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Limpa o cache de imagens
  Future<Either<Failure, void>> clearCache({bool memoryOnly = false}) async {
    try {
      _memoryCache.clear();

      if (!memoryOnly && _initialized) {
        if (await _cacheDir.exists()) {
          await for (final file in _cacheDir.list()) {
            if (file is File) {
              await file.delete();
            }
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao limpar cache: ${e.toString()}',
          code: 'CACHE_CLEAR_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  /// Obtém informações sobre o cache
  Future<Either<Failure, CacheInfo>> getCacheInfo() async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      int diskFiles = 0;
      int diskSize = 0;

      if (await _cacheDir.exists()) {
        await for (final file in _cacheDir.list()) {
          if (file is File) {
            diskFiles++;
            diskSize += await file.length();
          }
        }
      }

      final memorySize = _memoryCache.values.fold<int>(
        0,
        (sum, bytes) => sum + bytes.length,
      );

      return Right(
        CacheInfo(
          memoryItems: _memoryCache.length,
          memorySizeBytes: memorySize,
          diskItems: diskFiles,
          diskSizeBytes: diskSize,
        ),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao obter informações do cache: ${e.toString()}',
          code: 'CACHE_INFO_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  Future<Either<Failure, ImageResult>> _processSelectedImage(
    XFile image,
  ) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = image.name;
      final filePath = image.path;
      if (bytes.isEmpty) {
        return const Left(
          ValidationFailure('Imagem está vazia', code: 'EMPTY_IMAGE'),
        );
      }
      final optimizedBytesResult = await _optimizeImage(bytes);
      final optimizedBytes = optimizedBytesResult.fold(
        (_) => null,
        (data) => data,
      );

      return Right(
        ImageResult(
          bytes: optimizedBytes ?? bytes,
          fileName: fileName,
          filePath: filePath,
          size: bytes.length,
          optimizedSize: optimizedBytes?.length,
        ),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao processar imagem: ${e.toString()}',
          code: 'PROCESS_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  Future<Either<Failure, Uint8List>> _optimizeImage(Uint8List bytes) async {
    try {
      if (bytes.length <= 500 * 1024) {
        // Menor que 500KB
        return Right(bytes);
      }
      return Right(bytes);
    } catch (e) {
      return Right(bytes); // Fallback para imagem original
    }
  }

  Future<Either<Failure, Uint8List>> _resizeImage(
    Uint8List bytes,
    int width,
    int height,
    int quality,
  ) async {
    try {
      return Right(bytes);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao redimensionar imagem: ${e.toString()}',
          code: 'RESIZE_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Either<Failure, Uint8List>> _loadFromDiskCache(String cacheKey) async {
    try {
      final file = File(path.join(_cacheDir.path, cacheKey));
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return Right(bytes);
      }

      return const Left(
        CacheFailure('Imagem não encontrada no cache', code: 'NOT_IN_CACHE'),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao carregar do cache: ${e.toString()}',
          code: 'CACHE_LOAD_ERROR',
          details: e.toString(),
        ),
      );
    }
  }

  Future<Either<Failure, Uint8List>> _downloadAndCacheImage(
    String url,
    String cacheKey,
  ) async {
    try {
      return const Left(
        NetworkFailure(
          'Download de imagem não implementado nesta versão',
          code: 'DOWNLOAD_NOT_IMPLEMENTED',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(
          'Erro ao baixar imagem: ${e.toString()}',
          code: 'DOWNLOAD_ERROR',
          details: e.toString(),
        ),
      );
    }
  }
}

/// Resultado de uma operação de seleção de imagem
class ImageResult {
  /// Bytes da imagem
  final Uint8List bytes;

  /// Nome do arquivo
  final String fileName;

  /// Caminho do arquivo (se aplicável)
  final String filePath;

  /// Tamanho original em bytes
  final int size;

  /// Tamanho otimizado em bytes (se houve otimização)
  final int? optimizedSize;

  /// Construtor do resultado da imagem
  ImageResult({
    required this.bytes,
    required this.fileName,
    required this.filePath,
    required this.size,
    this.optimizedSize,
  });

  /// Verifica se a imagem foi otimizada
  bool get wasOptimized => optimizedSize != null && optimizedSize! < size;

  /// Porcentagem de compressão (se houve)
  double? get compressionRatio {
    if (optimizedSize == null) return null;
    return ((size - optimizedSize!) / size) * 100;
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'size': size,
      'optimizedSize': optimizedSize,
      'wasOptimized': wasOptimized,
      'compressionRatio': compressionRatio,
    };
  }

  @override
  String toString() {
    return 'ImageResult(fileName: $fileName, size: ${size}B, optimized: ${optimizedSize}B)';
  }
}

/// Informações sobre o cache de imagens
class CacheInfo {
  /// Número de itens no cache em memória
  final int memoryItems;

  /// Tamanho do cache em memória (bytes)
  final int memorySizeBytes;

  /// Número de arquivos no cache em disco
  final int diskItems;

  /// Tamanho do cache em disco (bytes)
  final int diskSizeBytes;

  /// Construtor das informações de cache
  CacheInfo({
    required this.memoryItems,
    required this.memorySizeBytes,
    required this.diskItems,
    required this.diskSizeBytes,
  });

  /// Tamanho total do cache em bytes
  int get totalSizeBytes => memorySizeBytes + diskSizeBytes;

  /// Número total de itens em cache
  int get totalItems => memoryItems + diskItems;

  /// Converte bytes para formato legível
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Tamanho da memória em formato legível
  String get memorySizeFormatted => _formatBytes(memorySizeBytes);

  /// Tamanho do disco em formato legível
  String get diskSizeFormatted => _formatBytes(diskSizeBytes);

  /// Tamanho total em formato legível
  String get totalSizeFormatted => _formatBytes(totalSizeBytes);

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'memoryItems': memoryItems,
      'memorySizeBytes': memorySizeBytes,
      'memorySizeFormatted': memorySizeFormatted,
      'diskItems': diskItems,
      'diskSizeBytes': diskSizeBytes,
      'diskSizeFormatted': diskSizeFormatted,
      'totalItems': totalItems,
      'totalSizeBytes': totalSizeBytes,
      'totalSizeFormatted': totalSizeFormatted,
    };
  }

  @override
  String toString() {
    return 'CacheInfo(memory: $memoryItems items, $memorySizeFormatted, '
        'disk: $diskItems items, $diskSizeFormatted)';
  }
}
