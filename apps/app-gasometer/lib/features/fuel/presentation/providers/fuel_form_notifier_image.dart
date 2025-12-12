part of 'fuel_form_notifier.dart';

/// Extension for FuelFormNotifier image handling methods
extension FuelFormNotifierImage on FuelFormNotifier {
  /// Captures a receipt image using camera
  Future<void> captureReceiptImage() async {
    state = state.copyWith(clearImageError: true);

    final result = await _imageHandler.captureAndProcessImage(
      userId: state.formModel.userId,
      fuelSupplyId: _imageHandler.generateTemporaryId(),
    );

    result.fold(
      (failure) {
        if (failure is! CancellationFailure) {
          state = state.copyWith(imageUploadError: failure.message);
        }
      },
      (imageResult) {
        state = state.copyWith(
          receiptImagePath: imageResult.localPath,
          receiptImageUrl: imageResult.downloadUrl,
          formModel: state.formModel.copyWith(hasChanges: true),
        );
      },
    );
  }

  /// Selects a receipt image from gallery
  Future<void> selectReceiptImageFromGallery() async {
    state = state.copyWith(clearImageError: true);

    final result = await _imageHandler.selectFromGalleryAndProcess(
      userId: state.formModel.userId,
      fuelSupplyId: _imageHandler.generateTemporaryId(),
    );

    result.fold(
      (failure) {
        if (failure is! CancellationFailure) {
          state = state.copyWith(imageUploadError: failure.message);
        }
      },
      (imageResult) {
        state = state.copyWith(
          receiptImagePath: imageResult.localPath,
          receiptImageUrl: imageResult.downloadUrl,
          formModel: state.formModel.copyWith(hasChanges: true),
        );
      },
    );
  }

  /// Removes the receipt image
  Future<void> removeReceiptImage() async {
    final result = await _imageHandler.removeImage(
      localPath: state.receiptImagePath,
      downloadUrl: state.receiptImageUrl,
    );

    result.fold(
      (failure) => state = state.copyWith(imageUploadError: failure.message),
      (_) => state = state.copyWith(
        clearImagePaths: true,
        clearImageError: true,
        formModel: state.formModel.copyWith(hasChanges: true),
      ),
    );
  }

  /// Syncs local image to Firebase Storage
  Future<void> syncImageToFirebase(String actualFuelSupplyId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) return;

    state = state.copyWith(isUploadingImage: true);

    final result = await _imageHandler.syncImageToFirebase(
      localPath: state.receiptImagePath!,
      userId: state.formModel.userId,
      fuelSupplyId: actualFuelSupplyId,
    );

    result.fold(
      (_) => state = state.copyWith(isUploadingImage: false),
      (url) => state = state.copyWith(
        receiptImageUrl: url,
        isUploadingImage: false,
      ),
    );
  }
}
