import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Interface para abstração do ImageService
abstract class IImageService {
  Future<Either<Failure, String>> pickFromCamera();
  Future<Either<Failure, String>> pickFromGallery();
  Future<Either<Failure, List<String>>> uploadImages(List<String> base64Images);
  Future<Either<Failure, void>> deleteImage(String imageUrl);
}

/// Adapter para o ImageService - Cross-platform
class ImageServiceAdapter implements IImageService {
  final ImageService _imageService;

  ImageServiceAdapter(this._imageService);

  @override
  Future<Either<Failure, String>> pickFromCamera() async {
    try {
      final result = await _imageService.pickImageFromCamera();
      return result.fold(
        (error) => Left(CacheFailure(error.message)),
        (image) => Right(image.toBase64DataUri()),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao capturar imagem: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> pickFromGallery() async {
    try {
      debugPrint('📷 [ImageServiceAdapter] pickFromGallery - Iniciando');
      final result = await _imageService.pickImageFromGallery();
      debugPrint(
        '📷 [ImageServiceAdapter] pickFromGallery - pickImageFromGallery concluído: ${result.fold((_) => "Erro", (_) => "Sucesso")}',
      );

      return result.fold(
        (error) {
          debugPrint(
            '📷 [ImageServiceAdapter] pickFromGallery - Erro: ${error.message}',
          );
          return Left(CacheFailure(error.message));
        },
        (image) {
          debugPrint(
            '📷 [ImageServiceAdapter] pickFromGallery - Imagem recebida: ${image.name}, ${image.sizeInKB.toStringAsFixed(2)} KB',
          );
          final base64 = image.toBase64DataUri();
          debugPrint(
            '📷 [ImageServiceAdapter] pickFromGallery - Convertido para Base64, tamanho: ${base64.length} chars',
          );
          return Right(base64);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('📷 [ImageServiceAdapter] pickFromGallery - EXCEÇÃO: $e');
      debugPrint(
        '📷 [ImageServiceAdapter] pickFromGallery - StackTrace: $stackTrace',
      );
      return Left(CacheFailure('Erro ao selecionar imagem: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(
    List<String> base64Images,
  ) async {
    try {
      final results = <String>[];

      for (final base64Data in base64Images) {
        final image = PickedImage.fromBase64(base64Data);
        final result = await _imageService.uploadImage(image);
        result.fold(
          (error) => throw Exception(error.message),
          (uploadResult) => results.add(uploadResult.downloadUrl),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(NetworkFailure('Erro ao enviar imagens: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    try {
      final result = await _imageService.deleteImage(imageUrl);
      return result.fold(
        (error) => Left(CacheFailure(error.message)),
        (success) => const Right(null),
      );
    } catch (e) {
      return Left(NetworkFailure('Erro ao deletar imagem: $e'));
    }
  }
}

/// Serviço responsável APENAS por gerenciamento de imagens de plantas
/// Resolve violação SRP - separando lógica de imagens do estado UI
class ImageManagementService {
  final IImageService _imageService;

  ImageManagementService({required IImageService imageService})
    : _imageService = imageService;

  /// Factory usando dependency injection
  factory ImageManagementService.create({IImageService? imageService}) {
    final service = imageService ?? ImageServiceAdapter(ImageService());
    return ImageManagementService(imageService: service);
  }

  /// Captura imagem da câmera
  Future<Either<Failure, String>> captureFromCamera() async {
    try {
      final result = await _imageService.pickFromCamera();

      return result.fold(
        (failure) => Left(
          _mapImageFailure(failure, 'Erro ao capturar imagem da câmera'),
        ),
        (base64Image) {
          if (_isValidBase64Image(base64Image)) {
            return Right(base64Image);
          } else {
            return const Left(ValidationFailure('Imagem capturada inválida'));
          }
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro inesperado ao capturar imagem: $e'));
    }
  }

  /// Seleciona imagem da galeria
  Future<Either<Failure, String>> selectFromGallery() async {
    try {
      debugPrint('📷 [ImageManagementService] selectFromGallery - Iniciando');
      final result = await _imageService.pickFromGallery();
      debugPrint(
        '📷 [ImageManagementService] selectFromGallery - pickFromGallery concluído: ${result.isRight() ? "Sucesso" : "Falha"}',
      );

      return result.fold(
        (failure) {
          debugPrint(
            '📷 [ImageManagementService] selectFromGallery - Falha: ${failure.message}',
          );
          return Left(
            _mapImageFailure(failure, 'Erro ao selecionar imagem da galeria'),
          );
        },
        (base64Image) {
          debugPrint(
            '📷 [ImageManagementService] selectFromGallery - Base64 recebido, tamanho: ${base64Image.length}',
          );
          if (_isValidBase64Image(base64Image)) {
            debugPrint(
              '📷 [ImageManagementService] selectFromGallery - Imagem válida',
            );
            return Right(base64Image);
          } else {
            debugPrint(
              '📷 [ImageManagementService] selectFromGallery - Imagem inválida',
            );
            return const Left(ValidationFailure('Imagem selecionada inválida'));
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('📷 [ImageManagementService] selectFromGallery - EXCEÇÃO: $e');
      debugPrint(
        '📷 [ImageManagementService] selectFromGallery - StackTrace: $stackTrace',
      );
      return Left(CacheFailure('Erro inesperado ao selecionar imagem: $e'));
    }
  }

  /// Adiciona imagem à lista
  ImageListResult addImageToList(List<String> currentImages, String newImage) {
    const maxImages = 5; // Limite máximo de imagens por planta

    if (currentImages.length >= maxImages) {
      return ImageListResult.failure(
        'Máximo de $maxImages imagens permitidas por planta',
        currentImages,
      );
    }

    if (currentImages.contains(newImage)) {
      return ImageListResult.failure(
        'Esta imagem já foi adicionada',
        currentImages,
      );
    }

    final updatedList = List<String>.from(currentImages)..add(newImage);

    return ImageListResult.success(
      'Imagem adicionada com sucesso',
      updatedList,
    );
  }

  /// Remove imagem da lista
  ImageListResult removeImageFromList(List<String> currentImages, int index) {
    if (index < 0 || index >= currentImages.length) {
      return ImageListResult.failure('Índice da imagem inválido', currentImages);
    }

    final updatedList = List<String>.from(currentImages)..removeAt(index);

    return ImageListResult.success('Imagem removida com sucesso', updatedList);
  }

  /// Remove imagem específica da lista
  ImageListResult removeSpecificImage(
    List<String> currentImages,
    String imageToRemove,
  ) {
    if (!currentImages.contains(imageToRemove)) {
      return ImageListResult.failure(
        'Imagem não encontrada na lista',
        currentImages,
      );
    }

    final updatedList = List<String>.from(currentImages)..remove(imageToRemove);

    return ImageListResult.success('Imagem removida com sucesso', updatedList);
  }

  /// Upload de múltiplas imagens (Cross-platform)
  /// Funciona em Web, Mobile e Desktop
  Future<Either<Failure, List<String>>> uploadImages(
    List<String> base64Images, {
    void Function(int index, double progress)? onProgress,
  }) async {
    if (base64Images.isEmpty) {
      return const Right([]);
    }

    try {
      for (final image in base64Images) {
        if (!_isValidBase64Image(image)) {
          return const Left(
            ValidationFailure('Uma ou mais imagens são inválidas'),
          );
        }
      }

      // Upload usando a interface IImageService
      final result = await _imageService.uploadImages(base64Images);
      return result;
    } catch (e) {
      return Left(NetworkFailure('Erro no upload: $e'));
    }
  }

  /// Deleta imagem do servidor
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    if (imageUrl.trim().isEmpty) {
      return const Left(ValidationFailure('URL da imagem é obrigatória'));
    }

    try {
      final result = await _imageService.deleteImage(imageUrl);

      return result.fold(
        (failure) => Left(_mapImageFailure(failure, 'Erro ao deletar imagem')),
        (success) => const Right(null),
      );
    } catch (e) {
      return Left(NetworkFailure('Erro inesperado ao deletar: $e'));
    }
  }

  /// Valida se uma imagem base64 é válida
  bool _isValidBase64Image(String base64Image) {
    if (base64Image.trim().isEmpty) return false;

    try {
      if (!base64Image.startsWith('data:image/')) {
        return false;
      }
      if (base64Image.length < 100) {
        return false;
      }
      const maxSizeBytes = 14 * 1024 * 1024; // 14MB para margem
      if (base64Image.length > maxSizeBytes) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mapeia falhas de imagem para mensagens mais específicas
  Failure _mapImageFailure(Failure originalFailure, String context) {
    switch (originalFailure) {
      case NetworkFailure _:
        return NetworkFailure('$context: Sem conexão com a internet');
      case ServerFailure _:
        return ServerFailure('$context: Erro no servidor');
      case ValidationFailure _:
        return ValidationFailure('$context: ${originalFailure.message}');
      case CacheFailure _:
        return CacheFailure('$context: ${originalFailure.message}');
      default:
        return CacheFailure('$context: ${originalFailure.message}');
    }
  }

  /// Obtém informações sobre as imagens
  ImageListInfo getImageListInfo(List<String> images) {
    const maxImages = 5;

    return ImageListInfo(
      currentCount: images.length,
      maxCount: maxImages,
      canAddMore: images.length < maxImages,
      remainingSlots: maxImages - images.length,
      isEmpty: images.isEmpty,
      isFull: images.length >= maxImages,
    );
  }

  /// Valida lista de imagens
  ImageListValidation validateImageList(List<String> images) {
    const maxImages = 5;
    final errors = <String>[];

    if (images.length > maxImages) {
      errors.add('Máximo de $maxImages imagens permitidas');
    }

    for (int i = 0; i < images.length; i++) {
      if (!_isValidBase64Image(images[i])) {
        errors.add('Imagem ${i + 1} é inválida');
      }
    }
    final uniqueImages = images.toSet();
    if (uniqueImages.length != images.length) {
      errors.add('Existem imagens duplicadas');
    }

    return ImageListValidation(isValid: errors.isEmpty, errors: errors);
  }
}

/// Resultado de operação em lista de imagens
class ImageListResult {
  final bool isSuccess;
  final String message;
  final List<String> updatedImages;

  const ImageListResult._({
    required this.isSuccess,
    required this.message,
    required this.updatedImages,
  });

  factory ImageListResult.success(String message, List<String> images) {
    return ImageListResult._(
      isSuccess: true,
      message: message,
      updatedImages: images,
    );
  }

  factory ImageListResult.failure(String message, List<String> currentImages) {
    return ImageListResult._(
      isSuccess: false,
      message: message,
      updatedImages: currentImages,
    );
  }

  bool get isError => !isSuccess;
}

/// Informações sobre lista de imagens
class ImageListInfo {
  final int currentCount;
  final int maxCount;
  final bool canAddMore;
  final int remainingSlots;
  final bool isEmpty;
  final bool isFull;

  const ImageListInfo({
    required this.currentCount,
    required this.maxCount,
    required this.canAddMore,
    required this.remainingSlots,
    required this.isEmpty,
    required this.isFull,
  });
}

/// Validação de lista de imagens
class ImageListValidation {
  final bool isValid;
  final List<String> errors;

  const ImageListValidation({required this.isValid, required this.errors});

  bool get hasErrors => errors.isNotEmpty;
}
