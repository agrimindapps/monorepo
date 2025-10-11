import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// Configuração para o ImageService
class ImageServiceConfig {
  final int maxWidth;
  final int maxHeight;
  final int imageQuality;
  final int maxImagesCount;
  final int maxFileSizeInMB;
  final List<String> allowedFormats;
  final String defaultFolder;
  final Map<String, String> folders;

  const ImageServiceConfig({
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.imageQuality = 85,
    this.maxImagesCount = 5,
    this.maxFileSizeInMB = 10,
    this.allowedFormats = const ['.jpg', '.jpeg', '.png', '.webp'],
    this.defaultFolder = 'images',
    this.folders = const {},
  });

  ImageServiceConfig copyWith({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? maxImagesCount,
    int? maxFileSizeInMB,
    List<String>? allowedFormats,
    String? defaultFolder,
    Map<String, String>? folders,
  }) {
    return ImageServiceConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      imageQuality: imageQuality ?? this.imageQuality,
      maxImagesCount: maxImagesCount ?? this.maxImagesCount,
      maxFileSizeInMB: maxFileSizeInMB ?? this.maxFileSizeInMB,
      allowedFormats: allowedFormats ?? this.allowedFormats,
      defaultFolder: defaultFolder ?? this.defaultFolder,
      folders: folders ?? this.folders,
    );
  }
}

/// Resultado de upload de imagem
class ImageUploadResult {
  final String downloadUrl;
  final String fileName;
  final String folder;
  final DateTime uploadedAt;

  const ImageUploadResult({
    required this.downloadUrl,
    required this.fileName,
    required this.folder,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'downloadUrl': downloadUrl,
      'fileName': fileName,
      'folder': folder,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

/// Resultado de upload múltiplo
class MultipleImageUploadResult {
  final List<ImageUploadResult> successful;
  final List<AppError> failed;

  const MultipleImageUploadResult({
    required this.successful,
    required this.failed,
  });

  bool get hasFailures => failed.isNotEmpty;
  bool get allSuccessful => failed.isEmpty;
  int get successCount => successful.length;
  int get failureCount => failed.length;
}

/// Serviço genérico para manipulação de imagens
/// Configurável para diferentes apps e casos de uso
class ImageService {
  final ImagePicker _picker;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final ImageServiceConfig config;

  ImageService({
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    this.config = const ImageServiceConfig(),
  }) : _picker = picker ?? ImagePicker(),
       _storage = storage ?? FirebaseStorage.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Selecionar imagem da galeria
  Future<Result<File>> pickImageFromGallery() async {
    return ResultUtils.tryExecuteAsync(() async {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: config.maxWidth.toDouble(),
        maxHeight: config.maxHeight.toDouble(),
        imageQuality: config.imageQuality,
      );

      if (image == null) {
        return Future.error(
          ValidationError(message: 'Nenhuma imagem foi selecionada'),
        );
      }

      final file = File(image.path);
      final validationResult = validateImage(file);
      if (validationResult.isError) {
        return Future.error(validationResult.error!);
      }

      return file;
    });
  }

  /// Capturar imagem da câmera
  Future<Result<File>> pickImageFromCamera() async {
    return ResultUtils.tryExecuteAsync(() async {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: config.maxWidth.toDouble(),
        maxHeight: config.maxHeight.toDouble(),
        imageQuality: config.imageQuality,
      );

      if (image == null) {
        return Future.error(
          ValidationError(message: 'Nenhuma imagem foi capturada'),
        );
      }

      final file = File(image.path);
      final validationResult = validateImage(file);
      if (validationResult.isError) {
        return Future.error(validationResult.error!);
      }

      return file;
    });
  }

  /// Selecionar múltiplas imagens
  Future<Result<List<File>>> pickMultipleImages({int? maxImages}) async {
    return ResultUtils.tryExecuteAsync(() async {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: config.maxWidth.toDouble(),
        maxHeight: config.maxHeight.toDouble(),
        imageQuality: config.imageQuality,
      );

      if (images.isEmpty) {
        return Future.error(
          ValidationError(message: 'Nenhuma imagem foi selecionada'),
        );
      }

      final maxCount = maxImages ?? config.maxImagesCount;
      final limitedImages = images.take(maxCount).toList();

      final List<File> files = [];
      for (final xFile in limitedImages) {
        final file = File(xFile.path);
        final validationResult = validateImage(file);
        if (validationResult.isError) {
          return Future.error(validationResult.error!);
        }

        files.add(file);
      }

      return files;
    });
  }

  /// Upload de imagem para Firebase Storage
  Future<Result<ImageUploadResult>> uploadImage(
    File imageFile, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double)? onProgress,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      final validationResult = validateImage(imageFile);
      if (validationResult.isError) {
        return Future.error(validationResult.error!);
      }
      final targetFolder = _determineFolder(folder, uploadType);
      final finalFileName =
          fileName ?? '${_generateFirebaseId()}${_getFileExtension(imageFile.path)}';
      final Reference storageRef = _storage.ref().child(
        '$targetFolder/$finalFileName',
      );
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(imageFile.path),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'uploadType': uploadType ?? 'general',
          'originalSize': imageFile.lengthSync().toString(),
        },
      );
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return ImageUploadResult(
        downloadUrl: downloadUrl,
        fileName: finalFileName,
        folder: targetFolder,
        uploadedAt: DateTime.now(),
      );
    });
  }

  /// Upload de imagem com retry logic
  /// Tenta fazer upload com retry automático em caso de falha de rede
  Future<Result<ImageUploadResult>> uploadImageWithRetry(
    File imageFile, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double)? onProgress,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    AppError? lastError;

    while (attempt < maxRetries) {
      final result = await uploadImage(
        imageFile,
        folder: folder,
        fileName: fileName,
        uploadType: uploadType,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        return result;
      }

      lastError = result.error;
      attempt++;

      if (attempt < maxRetries) {
        // Exponential backoff: 2s, 4s, 8s
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    return Result.error(
      NetworkError(
        message: 'Upload falhou após $maxRetries tentativas',
        details: lastError?.message,
      ),
    );
  }

  /// Upload de múltiplas imagens
  Future<Result<MultipleImageUploadResult>> uploadMultipleImages(
    List<File> imageFiles, {
    String? folder,
    String? uploadType,
    void Function(int index, double progress)? onProgress,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      final List<ImageUploadResult> successful = [];
      final List<AppError> failed = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];

        final uploadResult = await uploadImage(
          file,
          folder: folder,
          uploadType: uploadType,
          onProgress:
              onProgress != null ? (progress) => onProgress(i, progress) : null,
        );

        if (uploadResult.isSuccess) {
          successful.add(uploadResult.data!);
        } else {
          failed.add(uploadResult.error!);
        }
      }

      return MultipleImageUploadResult(successful: successful, failed: failed);
    });
  }

  /// Deletar imagem do Firebase Storage
  Future<Result<void>> deleteImage(String downloadUrl) async {
    return ResultUtils.tryExecuteAsync(() async {
      try {
        final Reference ref = _storage.refFromURL(downloadUrl);
        await ref.delete();
      } catch (e) {
        return Future.error(
          ExternalServiceError(
            message: 'Erro ao deletar imagem do storage',
            details: e.toString(),
            serviceName: 'Firebase Storage',
          ),
        );
      }
    });
  }

  /// Deletar múltiplas imagens
  Future<Result<List<AppError>>> deleteMultipleImages(
    List<String> downloadUrls,
  ) async {
    return ResultUtils.tryExecuteAsync(() async {
      final List<AppError> errors = [];

      for (final url in downloadUrls) {
        final result = await deleteImage(url);
        if (result.isError) {
          errors.add(result.error!);
        }
      }

      return errors;
    });
  }

  /// Validar imagem
  Result<void> validateImage(File imageFile) {
    if (!imageFile.existsSync()) {
      return Result.error(
        ValidationError(message: 'Arquivo de imagem não encontrado'),
      );
    }
    if (!_isValidImageFormat(imageFile.path)) {
      return Result.error(
        ValidationError(
          message:
              'Formato de imagem não suportado. '
              'Formatos aceitos: ${config.allowedFormats.join(', ')}',
        ),
      );
    }
    if (!_isValidFileSize(imageFile)) {
      return Result.error(
        ValidationError(
          message:
              'Arquivo muito grande. '
              'Tamanho máximo: ${config.maxFileSizeInMB}MB',
        ),
      );
    }

    return Result.success(null);
  }

  /// Validar formato de imagem
  bool _isValidImageFormat(String filePath) {
    final String extension = _getFileExtension(filePath).toLowerCase();
    return config.allowedFormats.contains(extension);
  }

  /// Validar tamanho do arquivo
  bool _isValidFileSize(File file) {
    final int fileSizeInBytes = file.lengthSync();
    final int maxSizeInBytes = config.maxFileSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Extrair extensão do arquivo
  String _getFileExtension(String filePath) {
    final int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return filePath.substring(lastDotIndex);
  }

  /// Determinar content type baseado na extensão
  String _getContentType(String filePath) {
    final extension = _getFileExtension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Determinar pasta de upload
  String _determineFolder(String? folder, String? uploadType) {
    if (folder != null) return folder;

    if (uploadType != null && config.folders.containsKey(uploadType)) {
      return config.folders[uploadType]!;
    }

    return config.defaultFolder;
  }

  /// Gerar ID único usando Firebase Firestore
  /// Substitui o uso de UUID por IDs nativos do Firebase
  String _generateFirebaseId() {
    return _firestore.collection('_').doc().id;
  }

  /// Comprimir imagem (placeholder para implementação futura)
  Future<Result<File>> compressImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    return ResultUtils.tryExecuteAsync(() async {
      return imageFile;
    });
  }
}

/// Tipos de upload pré-definidos para apps
enum ImageUploadType {
  plant('plants'),
  space('spaces'),
  task('tasks'),
  profile('profiles'),
  gasometer('gasometers'),
  diagnostic('diagnostics'),
  defensivo('defensivos'),
  praga('pragas'),
  general('general');

  const ImageUploadType(this.folder);
  final String folder;
}

/// Generic configurations that apps can use as a base
/// Apps should define their own specific configurations in their respective folders
class DefaultImageConfigs {
  /// Standard quality configuration for most use cases
  static const standard = ImageServiceConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
    maxImagesCount: 5,
    defaultFolder: 'images',
    folders: {},
  );

  /// High quality configuration for apps that need better image quality
  static const highQuality = ImageServiceConfig(
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 95,
    maxImagesCount: 3,
    defaultFolder: 'images',
    folders: {},
  );

  /// Optimized configuration for mobile with lower quality for bandwidth saving
  static const optimized = ImageServiceConfig(
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 75,
    maxImagesCount: 10,
    defaultFolder: 'images',
    folders: {},
  );
}
