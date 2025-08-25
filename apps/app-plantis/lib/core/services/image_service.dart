import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Tipos de upload disponíveis para o app-plantis
enum ImageUploadType {
  plant('plants'),
  space('spaces'),
  task('tasks'),
  profile('profiles');

  const ImageUploadType(this.folder);
  final String folder;
}

/// Service de imagens local para app-plantis
/// Mantido para compatibilidade com código existente
class PlantisImageService {
  static final PlantisImageService _instance = PlantisImageService._internal();
  factory PlantisImageService() => _instance;
  PlantisImageService._internal();

  final ImagePicker _picker = ImagePicker();
  core.ImageService? _coreImageService;
  
  /// Obter instância do core image service (lazy initialization)
  core.ImageService get _getCoreImageService {
    return _coreImageService ??= core.ImageService(
      config: core.AppImageConfigs.plantisConfig,
    );
  }

  /// Selecionar imagem da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (error) {
      debugPrint('Erro ao selecionar imagem da galeria: $error');
      return null;
    }
  }

  /// Capturar imagem da câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (error) {
      debugPrint('Erro ao capturar imagem da câmera: $error');
      return null;
    }
  }

  /// Selecionar múltiplas imagens
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultipleMedia(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      // Filtrar apenas imagens
      final List<File> imageFiles = [];
      for (final xFile in images) {
        final file = File(xFile.path);
        if (isValidImageFile(file)) {
          imageFiles.add(file);
        }
      }
      
      return imageFiles;
    } catch (error) {
      debugPrint('Erro ao selecionar múltiplas imagens: $error');
      return [];
    }
  }

  /// Verificar se um arquivo é uma imagem válida
  bool isValidImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
           extension.endsWith('.jpeg') ||
           extension.endsWith('.png') ||
           extension.endsWith('.webp');
  }

  /// Verificar tamanho do arquivo
  Future<bool> isFileSizeValid(File file, {int maxSizeInMB = 5}) async {
    try {
      final int bytes = await file.length();
      final int maxBytes = maxSizeInMB * 1024 * 1024;
      return bytes <= maxBytes;
    } catch (error) {
      debugPrint('Erro ao verificar tamanho do arquivo: $error');
      return false;
    }
  }

  /// Obter tamanho do arquivo em MB
  Future<double> getFileSizeInMB(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (error) {
      debugPrint('Erro ao obter tamanho do arquivo: $error');
      return 0.0;
    }
  }

  /// Upload de imagem para Firebase Storage
  Future<String?> uploadImage(
    File imageFile, {
    required String folder,
    Function(double)? onProgress,
  }) async {
    try {
      final result = await _getCoreImageService.uploadImage(
        imageFile,
        folder: folder,
        onProgress: onProgress,
      );
      
      if (result.isSuccess) {
        return result.data!.downloadUrl;
      } else {
        debugPrint('Erro no upload: ${result.error!.userMessage}');
        return null;
      }
    } catch (error) {
      debugPrint('Erro ao fazer upload da imagem: $error');
      return null;
    }
  }

  /// Deletar imagem do Firebase Storage
  Future<void> deleteImage(String downloadUrl) async {
    try {
      final result = await _getCoreImageService.deleteImage(downloadUrl);
      if (result.isError) {
        debugPrint('Erro ao deletar imagem: ${result.error!.userMessage}');
      }
    } catch (error) {
      debugPrint('Erro ao deletar imagem: $error');
    }
  }

  /// Construir widget de preview de imagem
  Widget buildImagePreview(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildDefaultPlaceholder(width, height, borderRadius);
    }

    Widget imageWidget;

    // Verificar se é uma URL de rede ou caminho local
    if (imageUrl.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(width, height),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorPlaceholder(width, height),
        memCacheWidth: width?.round(),
        memCacheHeight: height?.round(),
      );
    } else {
      // Imagem local
      imageWidget = Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder(width, height);
        },
        cacheWidth: width?.round(),
        cacheHeight: height?.round(),
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// Placeholder padrão quando não há imagem
  Widget _buildDefaultPlaceholder(double? width, double? height, BorderRadius? borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: (width != null && height != null) ? (width < height ? width : height) * 0.4 : 40,
      ),
    );
  }

  /// Placeholder de loading
  Widget _buildLoadingPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Placeholder de erro
  Widget _buildErrorPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.error_outline,
        color: Colors.red.shade400,
        size: (width != null && height != null) ? (width < height ? width : height) * 0.4 : 40,
      ),
    );
  }
}

// Alias para compatibilidade
typedef ImageService = PlantisImageService;