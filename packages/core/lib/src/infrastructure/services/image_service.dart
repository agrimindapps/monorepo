import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/failure.dart';
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

/// Imagem selecionada - Cross-platform (funciona em Web, Mobile e Desktop)
/// Substitui o uso de dart:io File que não funciona na Web
class PickedImage {
  /// Bytes da imagem
  final Uint8List bytes;

  /// Nome do arquivo
  final String name;

  /// Caminho do arquivo (pode ser vazio na Web)
  final String path;

  /// MIME type da imagem
  final String mimeType;

  const PickedImage({
    required this.bytes,
    required this.name,
    required this.path,
    required this.mimeType,
  });

  /// Tamanho em bytes
  int get sizeInBytes => bytes.length;

  /// Tamanho em KB
  double get sizeInKB => sizeInBytes / 1024;

  /// Tamanho em MB
  double get sizeInMB => sizeInKB / 1024;

  /// Extensão do arquivo
  String get extension {
    final lastDot = name.lastIndexOf('.');
    if (lastDot == -1) return '';
    return name.substring(lastDot).toLowerCase();
  }

  /// Converte para Base64 com prefixo data URI
  String toBase64DataUri() {
    final base64String = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Converte para Base64 puro (sem prefixo)
  String toBase64() => base64Encode(bytes);

  /// Cria PickedImage a partir de XFile
  static Future<PickedImage> fromXFile(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final mimeType = xFile.mimeType ?? _getMimeTypeFromPath(xFile.path);

    return PickedImage(
      bytes: bytes,
      name: xFile.name,
      path: xFile.path,
      mimeType: mimeType,
    );
  }

  /// Cria PickedImage a partir de Base64
  static PickedImage fromBase64(String base64Data, {String? fileName}) {
    String mimeType = 'image/jpeg';
    String base64String = base64Data;

    if (base64Data.startsWith('data:')) {
      final mimeMatch = RegExp(r'data:([^;]+)').firstMatch(base64Data);
      if (mimeMatch != null) {
        mimeType = mimeMatch.group(1) ?? 'image/jpeg';
      }
      base64String = base64Data.split(',').last;
    }

    final bytes = base64Decode(base64String);
    final ext = _getExtensionFromMimeType(mimeType);
    final name =
        fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}$ext';

    return PickedImage(bytes: bytes, name: name, path: '', mimeType: mimeType);
  }

  static String _getMimeTypeFromPath(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.gif')) return 'image/gif';
    if (ext.endsWith('.bmp')) return 'image/bmp';
    return 'image/jpeg';
  }

  static String _getExtensionFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/gif':
        return '.gif';
      case 'image/bmp':
        return '.bmp';
      default:
        return '.jpg';
    }
  }
}

/// Serviço genérico para manipulação de imagens
/// Cross-platform: funciona em Web, Mobile e Desktop
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

  /// Selecionar imagem (Cross-platform)
  Future<Either<Failure, PickedImage>> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    return EitherUtils.tryExecuteAsync(() async {
      debugPrint('📷 [ImageService] pickImage - Iniciando (source: $source)');

      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: config.maxWidth.toDouble(),
        maxHeight: config.maxHeight.toDouble(),
        imageQuality: config.imageQuality,
      );

      debugPrint(
        '📷 [ImageService] pickImage - pickImage retornou: ${xFile != null ? "XFile válido" : "null"}',
      );

      if (xFile == null) {
        debugPrint(
          '📷 [ImageService] pickImage - Nenhuma imagem selecionada/capturada',
        );
        return Future.error(
          ValidationFailure(
            source == ImageSource.camera
                ? 'Nenhuma imagem foi capturada'
                : 'Nenhuma imagem foi selecionada',
          ),
        );
      }

      debugPrint(
        '📷 [ImageService] pickImage - Convertendo XFile para PickedImage...',
      );
      debugPrint('📷 [ImageService] pickImage - XFile path: ${xFile.path}');
      debugPrint('📷 [ImageService] pickImage - XFile name: ${xFile.name}');

      final pickedImage = await PickedImage.fromXFile(xFile);
      debugPrint(
        '📷 [ImageService] pickImage - PickedImage criado: ${pickedImage.sizeInKB.toStringAsFixed(2)} KB',
      );

      final validationResult = validatePickedImage(pickedImage);
      return validationResult.fold(
        (failure) {
          debugPrint(
            '📷 [ImageService] pickImage - Validação falhou: ${failure.message}',
          );
          return Future.error(failure);
        },
        (_) {
          debugPrint('📷 [ImageService] pickImage - Imagem válida, retornando');
          return pickedImage;
        },
      );
    });
  }

  /// Selecionar imagem da galeria
  Future<Either<Failure, PickedImage>> pickImageFromGallery() async {
    debugPrint('📷 [ImageService] pickImageFromGallery - Chamando pickImage');
    return pickImage(source: ImageSource.gallery);
  }

  /// Capturar imagem da câmera
  Future<Either<Failure, PickedImage>> pickImageFromCamera() async {
    debugPrint('📷 [ImageService] pickImageFromCamera - Chamando pickImage');
    return pickImage(source: ImageSource.camera);
  }

  /// Selecionar múltiplas imagens (Cross-platform)
  Future<Either<Failure, List<PickedImage>>> pickMultipleImages({
    int? maxImages,
  }) async {
    return EitherUtils.tryExecuteAsync(() async {
      final List<XFile> xFiles = await _picker.pickMultiImage(
        maxWidth: config.maxWidth.toDouble(),
        maxHeight: config.maxHeight.toDouble(),
        imageQuality: config.imageQuality,
      );

      if (xFiles.isEmpty) {
        return Future.error(
          const ValidationFailure('Nenhuma imagem foi selecionada'),
        );
      }

      final maxCount = maxImages ?? config.maxImagesCount;
      final limitedFiles = xFiles.take(maxCount).toList();

      final List<PickedImage> images = [];
      for (final xFile in limitedFiles) {
        final pickedImage = await PickedImage.fromXFile(xFile);
        final validationResult = validatePickedImage(pickedImage);
        final error = validationResult.fold((failure) => failure, (_) => null);
        if (error != null) {
          return Future.error(error);
        }
        images.add(pickedImage);
      }

      return images;
    });
  }

  /// Upload de imagem (Cross-platform)
  Future<Either<Failure, ImageUploadResult>> uploadImage(
    PickedImage image, {
    String? folder,
    String? fileName,
    String? uploadType,
    void Function(double)? onProgress,
  }) async {
    return EitherUtils.tryExecuteAsync(() async {
      final validationResult = validatePickedImage(image);
      final error = validationResult.fold((failure) => failure, (_) => null);
      if (error != null) {
        return Future.error(error);
      }

      final targetFolder = _determineFolder(folder, uploadType);
      final finalFileName =
          fileName ??
          '${_generateFirebaseId()}${image.extension.isNotEmpty ? image.extension : '.jpg'}';

      final Reference storageRef = _storage.ref().child(
        '$targetFolder/$finalFileName',
      );

      final SettableMetadata metadata = SettableMetadata(
        contentType: image.mimeType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'uploadType': uploadType ?? 'general',
          'originalSize': image.sizeInBytes.toString(),
          'platform': kIsWeb ? 'web' : 'native',
        },
      );

      final UploadTask uploadTask = storageRef.putData(image.bytes, metadata);

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

  /// Upload com retry logic
  Future<Either<Failure, ImageUploadResult>> uploadImageWithRetry(
    PickedImage image, {
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
        image,
        folder: folder,
        fileName: fileName,
        uploadType: uploadType,
        onProgress: onProgress,
      );

      if (result.isRight()) {
        return result;
      }

      lastError = result.fold(
        (failure) => AppErrorFactory.fromFailure(failure),
        (_) => null,
      );
      attempt++;

      if (attempt < maxRetries) {
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    return Left(
      NetworkFailure(
        'Upload falhou após $maxRetries tentativas',
        details: lastError?.message,
      ),
    );
  }

  /// Upload de imagem diretamente de Base64
  Future<Either<Failure, ImageUploadResult>> uploadImageFromBase64(
    String base64Data, {
    String? folder,
    String? fileName,
    String? uploadType,
    String mimeType = 'image/jpeg',
    void Function(double)? onProgress,
  }) async {
    try {
      final image = PickedImage.fromBase64(base64Data, fileName: fileName);
      return uploadImage(
        image,
        folder: folder,
        fileName: fileName,
        uploadType: uploadType,
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(ValidationFailure('Erro ao processar Base64: $e'));
    }
  }

  /// Upload múltiplo de Base64
  Future<Either<Failure, MultipleImageUploadResult>>
  uploadMultipleImagesFromBase64(
    List<String> base64Images, {
    String? folder,
    String? uploadType,
    String mimeType = 'image/jpeg',
    void Function(int index, double progress)? onProgress,
  }) async {
    return EitherUtils.tryExecuteAsync(() async {
      final List<ImageUploadResult> successful = [];
      final List<AppError> failed = [];

      for (int i = 0; i < base64Images.length; i++) {
        final uploadResult = await uploadImageFromBase64(
          base64Images[i],
          folder: folder,
          uploadType: uploadType,
          mimeType: mimeType,
          onProgress: onProgress != null
              ? (progress) => onProgress(i, progress)
              : null,
        );

        uploadResult.fold(
          (failure) => failed.add(AppErrorFactory.fromFailure(failure)),
          (data) => successful.add(data),
        );
      }

      return MultipleImageUploadResult(successful: successful, failed: failed);
    });
  }

  /// Upload de múltiplas imagens
  Future<Either<Failure, MultipleImageUploadResult>> uploadMultipleImages(
    List<PickedImage> images, {
    String? folder,
    String? uploadType,
    void Function(int index, double progress)? onProgress,
  }) async {
    return EitherUtils.tryExecuteAsync(() async {
      final List<ImageUploadResult> successful = [];
      final List<AppError> failed = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final uploadResult = await uploadImage(
          image,
          folder: folder,
          uploadType: uploadType,
          onProgress: onProgress != null
              ? (progress) => onProgress(i, progress)
              : null,
        );

        uploadResult.fold(
          (failure) => failed.add(AppErrorFactory.fromFailure(failure)),
          (data) => successful.add(data),
        );
      }

      return MultipleImageUploadResult(successful: successful, failed: failed);
    });
  }

  /// Deletar imagem do Firebase Storage
  Future<Either<Failure, void>> deleteImage(String downloadUrl) async {
    return EitherUtils.tryExecuteAsync(() async {
      try {
        final Reference ref = _storage.refFromURL(downloadUrl);
        await ref.delete();
      } catch (e) {
        return Future.error(
          ServerFailure(
            'Erro ao deletar imagem do storage',
            details: e.toString(),
          ),
        );
      }
    });
  }

  /// Deletar múltiplas imagens
  Future<Either<Failure, List<AppError>>> deleteMultipleImages(
    List<String> downloadUrls,
  ) async {
    return EitherUtils.tryExecuteAsync(() async {
      final List<AppError> errors = [];

      for (final url in downloadUrls) {
        final result = await deleteImage(url);
        result.fold(
          (failure) => errors.add(AppErrorFactory.fromFailure(failure)),
          (_) => null,
        );
      }

      return errors;
    });
  }

  /// Validar PickedImage
  Either<Failure, void> validatePickedImage(PickedImage image) {
    if (image.bytes.isEmpty) {
      return const Left(ValidationFailure('Imagem está vazia'));
    }

    if (!_isValidImageFormat(image.name)) {
      return Left(
        ValidationFailure(
          'Formato de imagem não suportado. '
          'Formatos aceitos: ${config.allowedFormats.join(', ')}',
        ),
      );
    }

    final maxSizeBytes = config.maxFileSizeInMB * 1024 * 1024;
    if (image.sizeInBytes > maxSizeBytes) {
      return Left(
        ValidationFailure(
          'Arquivo muito grande. '
          'Tamanho máximo: ${config.maxFileSizeInMB}MB',
        ),
      );
    }

    return const Right(null);
  }

  bool _isValidImageFormat(String fileName) {
    final String extension = _getFileExtension(fileName).toLowerCase();
    return config.allowedFormats.contains(extension);
  }

  String _getFileExtension(String filePath) {
    final int lastDotIndex = filePath.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return filePath.substring(lastDotIndex);
  }

  String _determineFolder(String? folder, String? uploadType) {
    if (folder != null) return folder;
    if (uploadType != null && config.folders.containsKey(uploadType)) {
      return config.folders[uploadType]!;
    }
    return config.defaultFolder;
  }

  String _generateFirebaseId() {
    return _firestore.collection('_').doc().id;
  }

  /// Comprimir imagem (placeholder)
  Future<Either<Failure, PickedImage>> compressImage(
    PickedImage image, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    return Right(image);
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

/// Configurações padrão
class DefaultImageConfigs {
  static const standard = ImageServiceConfig(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
    maxImagesCount: 5,
    defaultFolder: 'images',
    folders: {},
  );

  static const highQuality = ImageServiceConfig(
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 95,
    maxImagesCount: 3,
    defaultFolder: 'images',
    folders: {},
  );

  static const optimized = ImageServiceConfig(
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 75,
    maxImagesCount: 10,
    defaultFolder: 'images',
    folders: {},
  );
}
