import '../models/fuel_form_model.dart';

/// Form state for fuel record creation/editing
class FuelFormState {
  const FuelFormState({
    required this.formModel,
    this.isInitialized = false,
    this.isCalculating = false,
    this.isLoading = false,
    this.lastError,
    this.lastOdometerReading,
    this.receiptImagePath,
    this.receiptImageUrl,
    this.isUploadingImage = false,
    this.imageUploadError,
  });

  final FuelFormModel formModel;
  final bool isInitialized;
  final bool isCalculating;
  final bool isLoading;
  final String? lastError;
  final double? lastOdometerReading;
  final String? receiptImagePath;
  final String? receiptImageUrl;
  final bool isUploadingImage;
  final String? imageUploadError;

  bool get hasReceiptImage =>
      receiptImagePath != null || receiptImageUrl != null;
  bool get canSubmit =>
      !isLoading &&
      !isUploadingImage &&
      formModel.liters > 0 &&
      formModel.pricePerLiter > 0 &&
      formModel.odometer > 0;
  bool get hasChanges => formModel.hasChanges;
  bool get hasErrors => formModel.errors.isNotEmpty || lastError != null;

  FuelFormState copyWith({
    FuelFormModel? formModel,
    bool? isInitialized,
    bool? isCalculating,
    bool? isLoading,
    String? lastError,
    double? lastOdometerReading,
    String? receiptImagePath,
    String? receiptImageUrl,
    bool? isUploadingImage,
    String? imageUploadError,
    bool clearError = false,
    bool clearImagePaths = false,
    bool clearImageError = false,
  }) {
    return FuelFormState(
      formModel: formModel ?? this.formModel,
      isInitialized: isInitialized ?? this.isInitialized,
      isCalculating: isCalculating ?? this.isCalculating,
      isLoading: isLoading ?? this.isLoading,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastOdometerReading: lastOdometerReading ?? this.lastOdometerReading,
      receiptImagePath:
          clearImagePaths ? null : (receiptImagePath ?? this.receiptImagePath),
      receiptImageUrl:
          clearImagePaths ? null : (receiptImageUrl ?? this.receiptImageUrl),
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUploadError:
          clearImageError ? null : (imageUploadError ?? this.imageUploadError),
    );
  }
}
