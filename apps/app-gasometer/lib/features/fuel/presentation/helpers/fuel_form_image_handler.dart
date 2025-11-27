import 'package:core/core.dart';
import 'package:image_picker/image_picker.dart';

import '../../../receipt/domain/services/receipt_image_service.dart';

/// Handler for image operations in fuel forms
///
/// Responsibilities:
/// - Image selection (camera/gallery)
/// - Image processing and compression
/// - Image upload to Firebase
/// - Image removal
class FuelFormImageHandler {
  FuelFormImageHandler({
    required ReceiptImageService receiptImageService,
    ImagePicker? imagePicker,
  })  : _receiptImageService = receiptImageService,
        _imagePicker = imagePicker ?? ImagePicker();

  final ReceiptImageService _receiptImageService;
  final ImagePicker _imagePicker;

  /// Result of last processing operation
  ImageProcessingResult? lastProcessingResult;

  /// Captures image using camera and processes it
  Future<Either<Failure, ImageProcessingResult>> captureAndProcessImage({
    required String userId,
    required String fuelSupplyId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        return const Left(CancellationFailure('Captura cancelada'));
      }

      return _processImage(
        imagePath: image.path,
        userId: userId,
        fuelSupplyId: fuelSupplyId,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao capturar imagem: $e'));
    }
  }

  /// Selects image from gallery and processes it
  Future<Either<Failure, ImageProcessingResult>> selectFromGalleryAndProcess({
    required String userId,
    required String fuelSupplyId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) {
        return const Left(CancellationFailure('Seleção cancelada'));
      }

      return _processImage(
        imagePath: image.path,
        userId: userId,
        fuelSupplyId: fuelSupplyId,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao selecionar imagem: $e'));
    }
  }

  /// Processes image (validates, compresses, uploads)
  Future<Either<Failure, ImageProcessingResult>> _processImage({
    required String imagePath,
    required String userId,
    required String fuelSupplyId,
  }) async {
    try {
      // Validate image
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        return const Left(ValidationFailure('Arquivo de imagem inválido'));
      }

      // Process and upload
      final result = await _receiptImageService.processFuelReceiptImage(
        userId: userId,
        fuelSupplyId: fuelSupplyId,
        imagePath: imagePath,
        compressImage: true,
        uploadToFirebase: true,
      );

      lastProcessingResult = result;
      return Right(result);
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao processar imagem: $e'));
    }
  }

  /// Removes image from storage
  Future<Either<Failure, void>> removeImage({
    String? localPath,
    String? downloadUrl,
  }) async {
    try {
      if (localPath == null && downloadUrl == null) {
        return const Right(null);
      }

      await _receiptImageService.deleteReceiptImage(
        localPath: localPath,
        downloadUrl: downloadUrl,
      );

      lastProcessingResult = null;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao remover imagem: $e'));
    }
  }

  /// Syncs local image to Firebase when connection is available
  Future<Either<Failure, String>> syncImageToFirebase({
    required String localPath,
    required String userId,
    required String fuelSupplyId,
  }) async {
    try {
      final result = await _receiptImageService.processFuelReceiptImage(
        userId: userId,
        fuelSupplyId: fuelSupplyId,
        imagePath: localPath,
        compressImage: false, // Already compressed
        uploadToFirebase: true,
      );

      return Right(result.downloadUrl ?? '');
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao sincronizar imagem: $e'));
    }
  }

  /// Generates temporary ID for processing
  String generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Failure for cancellation (not an error)
class CancellationFailure extends Failure {
  const CancellationFailure(String message) : super(message: message);
}
