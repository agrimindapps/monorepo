import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface do repositório de storage (Firebase Storage)
/// Define os contratos para operações de upload/download de arquivos
abstract class IStorageRepository {
  /// Faz upload de um arquivo
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
    Function(double)? onProgress,
  });

  /// Faz upload de uma imagem com redimensionamento opcional
  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String path,
    int? maxWidth,
    int? maxHeight,
    int? quality,
    Function(double)? onProgress,
  });

  /// Faz download de um arquivo
  Future<Either<Failure, File>> downloadFile({
    required String url,
    required String localPath,
    Function(double)? onProgress,
  });

  /// Obtém URL de download de um arquivo
  Future<Either<Failure, String>> getDownloadUrl({
    required String path,
  });

  /// Deleta um arquivo
  Future<Either<Failure, void>> deleteFile({
    required String path,
  });

  /// Lista arquivos em um diretório
  Future<Either<Failure, List<StorageItem>>> listFiles({
    required String path,
    int? maxResults,
  });

  /// Verifica se um arquivo existe
  Future<Either<Failure, bool>> fileExists({
    required String path,
  });

  /// Obtém metadados de um arquivo
  Future<Either<Failure, StorageMetadata>> getMetadata({
    required String path,
  });

  /// Atualiza metadados de um arquivo
  Future<Either<Failure, StorageMetadata>> updateMetadata({
    required String path,
    required Map<String, String> metadata,
  });

  /// Copia um arquivo para outro local
  Future<Either<Failure, String>> copyFile({
    required String sourcePath,
    required String destinationPath,
  });

  /// Move um arquivo para outro local
  Future<Either<Failure, String>> moveFile({
    required String sourcePath,
    required String destinationPath,
  });

  /// Upload com diferentes formatos de imagem
  Future<Either<Failure, StorageImageUploadResult>> uploadImageWithVariants({
    required File imageFile,
    required String basePath,
    List<ImageVariant>? variants,
    Function(double)? onProgress,
  });
}

/// Informações de um item no storage
class StorageItem {
  const StorageItem({
    required this.name,
    required this.path,
    required this.fullPath,
    required this.bucket,
    this.size,
    this.contentType,
    this.timeCreated,
    this.updated,
    this.metadata,
  });

  /// Nome do arquivo
  final String name;

  /// Caminho relativo
  final String path;

  /// Caminho completo
  final String fullPath;

  /// Bucket do storage
  final String bucket;

  /// Tamanho em bytes
  final int? size;

  /// Tipo de conteúdo (MIME type)
  final String? contentType;

  /// Data de criação
  final DateTime? timeCreated;

  /// Data da última atualização
  final DateTime? updated;

  /// Metadados customizados
  final Map<String, String>? metadata;

  /// Se é uma imagem
  bool get isImage {
    return contentType?.startsWith('image/') ?? false;
  }

  /// Se é um vídeo
  bool get isVideo {
    return contentType?.startsWith('video/') ?? false;
  }

  /// Tamanho formatado (KB, MB, etc.)
  String get formattedSize {
    if (size == null) return 'Desconhecido';
    if (size! < 1024) return '${size!} B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Metadados de um arquivo no storage
class StorageMetadata {
  const StorageMetadata({
    required this.bucket,
    required this.fullPath,
    required this.name,
    this.size,
    this.contentType,
    this.timeCreated,
    this.updated,
    this.md5Hash,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.customMetadata,
  });

  final String bucket;
  final String fullPath;
  final String name;
  final int? size;
  final String? contentType;
  final DateTime? timeCreated;
  final DateTime? updated;
  final String? md5Hash;
  final String? cacheControl;
  final String? contentDisposition;
  final String? contentEncoding;
  final String? contentLanguage;
  final Map<String, String>? customMetadata;
}

/// Variante de imagem para upload
class ImageVariant {
  const ImageVariant({
    required this.suffix,
    this.maxWidth,
    this.maxHeight,
    this.quality = 85,
  });

  /// Sufixo para o nome do arquivo (ex: '_thumb', '_medium')
  final String suffix;

  /// Largura máxima
  final int? maxWidth;

  /// Altura máxima
  final int? maxHeight;

  /// Qualidade da imagem (0-100)
  final int quality;
}

/// Resultado do upload de imagem com variantes
class StorageImageUploadResult {
  const StorageImageUploadResult({
    required this.originalUrl,
    required this.variants,
  });

  /// URL da imagem original
  final String originalUrl;

  /// URLs das variantes geradas
  final Map<String, String> variants;

  /// Obtém URL de uma variante específica
  String? getVariantUrl(String suffix) => variants[suffix];

  /// Obtém a melhor URL baseada no tamanho desejado
  String getBestUrl({int? preferredWidth}) {
    if (preferredWidth == null) return originalUrl;
    if (preferredWidth <= 150 && variants.containsKey('_thumb')) {
      return variants['_thumb']!;
    }
    if (preferredWidth <= 400 && variants.containsKey('_small')) {
      return variants['_small']!;
    }
    if (preferredWidth <= 800 && variants.containsKey('_medium')) {
      return variants['_medium']!;
    }

    return originalUrl;
  }
}
