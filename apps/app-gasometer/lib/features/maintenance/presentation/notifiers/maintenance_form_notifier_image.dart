part of 'maintenance_form_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

/// Extension for image and photo-related methods of MaintenanceFormNotifier
extension MaintenanceFormNotifierImage on MaintenanceFormNotifier {
  /// Adiciona foto
  Future<void> addPhoto() async {
    final result = await _imageHandler.pickPhoto();

    result.fold(
      (failure) {
        if (failure is! CancellationFailure) {
          state = state.copyWith(errorMessage: () => failure.message);
        }
      },
      (photoPath) {
        final newPaths = List<String>.from(state.photosPaths);
        newPaths.add(photoPath);
        state = state.copyWith(photosPaths: newPaths, hasChanges: true);
      },
    );
  }

  /// Remove foto
  void removePhoto(String photoPath) {
    final newPaths = List<String>.from(state.photosPaths);
    newPaths.remove(photoPath);
    state = state.copyWith(photosPaths: newPaths, hasChanges: true);
  }

  /// Captura imagem usando câmera
  Future<void> captureReceiptImage() async {
    state = state.clearImageError();

    final result = await _imageHandler.captureAndProcessImage(
      userId: state.userId,
      maintenanceId: _imageHandler.generateTemporaryId(),
    );

    result.fold(
      (failure) {
        if (failure is! CancellationFailure) {
          state = state.copyWith(
            imageUploadError: () => failure.message,
          );
        }
      },
      (imageResult) {
        state = state.copyWith(
          receiptImagePath: imageResult.localPath,
          receiptImageUrl: imageResult.downloadUrl,
          hasChanges: true,
          isUploadingImage: false,
        );
        debugPrint('[MAINTENANCE FORM] Image processed successfully');
      },
    );
  }

  /// Seleciona imagem da galeria
  Future<void> selectReceiptImageFromGallery() async {
    state = state.clearImageError();

    final result = await _imageHandler.selectFromGalleryAndProcess(
      userId: state.userId,
      maintenanceId: _imageHandler.generateTemporaryId(),
    );

    result.fold(
      (failure) {
        if (failure is! CancellationFailure) {
          state = state.copyWith(
            imageUploadError: () => failure.message,
          );
        }
      },
      (imageResult) {
        state = state.copyWith(
          receiptImagePath: imageResult.localPath,
          receiptImageUrl: imageResult.downloadUrl,
          hasChanges: true,
          isUploadingImage: false,
        );
        debugPrint('[MAINTENANCE FORM] Image selected successfully');
      },
    );
  }

  /// Remove imagem do comprovante
  Future<void> removeReceiptImage() async {
    final result = await _imageHandler.removeImage(
      localPath: state.receiptImagePath,
      downloadUrl: state.receiptImageUrl,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          imageUploadError: () => failure.message,
        );
      },
      (_) {
        state = state
            .copyWith(
              hasChanges: true,
              clearReceiptImage: true,
              clearReceiptUrl: true,
            )
            .clearImageError();
      },
    );
  }

  /// Sincroniza imagem local com Firebase (para casos offline)
  Future<void> syncImageToFirebase(String actualMaintenanceId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) {
      return;
    }

    state = state.copyWith(isUploadingImage: true);

    final result = await _imageHandler.syncImageToFirebase(
      localPath: state.receiptImagePath!,
      userId: state.userId,
      maintenanceId: actualMaintenanceId,
    );

    result.fold(
      (failure) {
        debugPrint('[MAINTENANCE FORM] Failed to sync image: ${failure.message}');
        state = state.copyWith(isUploadingImage: false);
      },
      (downloadUrl) {
        state = state.copyWith(
          receiptImageUrl: downloadUrl,
          isUploadingImage: false,
        );
        debugPrint('[MAINTENANCE FORM] Image synced to Firebase: $downloadUrl');
      },
    );
  }

  /// Abre picker de data do serviço
  Future<void> pickServiceDate(BuildContext context) async {
    final date = await _datePickerHelper.pickServiceDate(
      context,
      currentDate: state.serviceDate,
    );
    if (date != null) {
      updateServiceDate(date);
    }
  }

  /// Abre picker de hora do serviço
  Future<void> pickServiceTime(BuildContext context) async {
    final date = await _datePickerHelper.pickServiceTime(
      context,
      currentDate: state.serviceDate,
    );
    if (date != null) {
      updateServiceDate(date);
    }
  }

  /// Abre picker de data da próxima manutenção
  Future<void> pickNextServiceDate(BuildContext context) async {
    final date = await _datePickerHelper.pickNextServiceDate(
      context,
      currentNextDate: state.nextServiceDate,
      serviceDate: state.serviceDate,
    );
    if (date != null) {
      updateNextServiceDate(date);
    }
  }
}
