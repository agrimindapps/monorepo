import 'package:core/core.dart';
import 'package:image_picker/image_picker.dart';

import '../../../receipt/domain/services/receipt_image_service.dart';

/// Handler for image operations in maintenance forms
///
/// Responsibilities:
/// - Image selection (camera/gallery)
/// - Image processing and compression
/// - Image upload to Firebase
/// - Image removal
class MaintenanceFormImageHandler {
  MaintenanceFormImageHandler({
    required ReceiptImageService receiptImageService,
    ImagePicker? imagePicker,
  })  : _receiptImageService = receiptImageService,
        _imagePicker = imagePicker ?? ImagePicker();

  final ReceiptImageService _receiptImageService;
  final ImagePicker _imagePicker;

  /// Result of image processing operation
  ImageProcessingResult? lastProcessingResult;

  /// Captures image using camera and processes it
  Future<Either<Failure, ImageProcessingResult>> captureAndProcessImage({
    required String userId,
    required String maintenanceId,
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
        maintenanceId: maintenanceId,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao capturar imagem: $e'));
    }
  }

  /// Selects image from gallery and processes it
  Future<Either<Failure, ImageProcessingResult>> selectFromGalleryAndProcess({
    required String userId,
    required String maintenanceId,
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
        maintenanceId: maintenanceId,
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao selecionar imagem: $e'));
    }
  }

  /// Processes image (validates, compresses, uploads)
  Future<Either<Failure, ImageProcessingResult>> _processImage({
    required String imagePath,
    required String userId,
    required String maintenanceId,
  }) async {
    try {
      // Validate image
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        return const Left(ValidationFailure('Arquivo de imagem inválido'));
      }

      // Process and upload
      final result = await _receiptImageService.processMaintenanceReceiptImage(
        userId: userId,
        maintenanceId: maintenanceId,
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
    required String maintenanceId,
  }) async {
    try {
      final result = await _receiptImageService.processMaintenanceReceiptImage(
        userId: userId,
        maintenanceId: maintenanceId,
        imagePath: localPath,
        compressImage: false, // Already compressed
        uploadToFirebase: true,
      );

      return Right(result.downloadUrl ?? '');
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao sincronizar imagem: $e'));
    }
  }

  /// Picks photo without processing (for photos list)
  Future<Either<Failure, String>> pickPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        return const Left(CancellationFailure('Captura cancelada'));
      }

      return Right(image.path);
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao adicionar foto: $e'));
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
