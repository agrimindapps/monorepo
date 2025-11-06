import 'dart:async';

import 'package:core/core.dart' hide FormState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container_modular.dart' as local_di;
import '../../../../core/services/input_sanitizer.dart';
import '../../../../core/services/receipt_image_service.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../../domain/services/fuel_validator_service.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/update_fuel_record.dart';
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
      receiptImagePath: clearImagePaths
          ? null
          : (receiptImagePath ?? this.receiptImagePath),
      receiptImageUrl: clearImagePaths
          ? null
          : (receiptImageUrl ?? this.receiptImageUrl),
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUploadError: clearImageError
          ? null
          : (imageUploadError ?? this.imageUploadError),
    );
  }
}

/// FuelFormNotifier - Manages fuel record form state
class FuelFormNotifier extends StateNotifier<FuelFormState> {
  FuelFormNotifier({
    required String? initialVehicleId,
    required String? userId,
    required ReceiptImageService receiptImageService,
    required Ref ref,
  }) : _receiptImageService = receiptImageService,
       _ref = ref,
       super(
         FuelFormState(
           formModel: FuelFormModel.initial(
             initialVehicleId ?? '',
             userId ?? '',
           ),
         ),
       ) {
    _formatter = FuelFormatterService();
    _validator = FuelValidatorService();
    _imagePicker = ImagePicker();
  }

  final ReceiptImageService _receiptImageService;
  final Ref _ref;
  late final FuelFormatterService _formatter;
  late final FuelValidatorService _validator;
  late final ImagePicker _imagePicker;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController litersController = TextEditingController();
  final TextEditingController pricePerLiterController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController gasStationController = TextEditingController();
  final TextEditingController gasStationBrandController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  Timer? _litersDebounceTimer;
  Timer? _priceDebounceTimer;
  Timer? _odometerDebounceTimer;

  // FocusNodes for field focus management
  final FocusNode litersFocusNode = FocusNode();
  final FocusNode pricePerLiterFocusNode = FocusNode();
  final FocusNode odometerFocusNode = FocusNode();
  final FocusNode gasStationFocusNode = FocusNode();
  final FocusNode gasStationBrandFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();

  /// Map of field names to their corresponding FocusNodes
  Map<String, FocusNode> get fieldFocusNodes => {
    'liters': litersFocusNode,
    'pricePerLiter': pricePerLiterFocusNode,
    'odometer': odometerFocusNode,
    'gasStationName': gasStationFocusNode,
    'gasStationBrand': gasStationBrandFocusNode,
    'notes': notesFocusNode,
  };

  Future<void> initialize({String? vehicleId, String? userId}) async {
    try {
      final selectedVehicleId = vehicleId ?? state.formModel.vehicleId;

      if (selectedVehicleId.isEmpty) {
        throw Exception('Nenhum veículo selecionado');
      }

      final formModel = FuelFormModel.initial(selectedVehicleId, userId ?? '');
      Future.microtask(() {
        state = state.copyWith(formModel: formModel, isLoading: true);
      });
      await _loadVehicleData(selectedVehicleId);
      _setupControllers();
      _updateTextControllers();

      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao inicializar formulário: $e');
      }
      state = state.copyWith(
        lastError: 'Erro ao inicializar: $e',
        isLoading: false,
      );
    }
  }

  void _setupControllers() {
    litersController.addListener(_onLitersChanged);
    pricePerLiterController.addListener(_onPricePerLiterChanged);
    odometerController.addListener(_onOdometerChanged);
    gasStationController.addListener(_onGasStationChanged);
    gasStationBrandController.addListener(_onGasStationBrandChanged);
    notesController.addListener(_onNotesChanged);
  }

  Future<void> _loadVehicleData(String vehicleId) async {
    try {
      final vehiclesNotifier = _ref.read(vehiclesNotifierProvider.notifier);
      final vehicle = await vehiclesNotifier.getVehicleById(vehicleId);

      if (vehicle != null) {
        final lastOdometer = vehicle.currentOdometer;

        state = state.copyWith(
          formModel: state.formModel.copyWith(
            vehicle: vehicle,
            odometer: vehicle.currentOdometer,
            fuelType: vehicle.supportedFuels.isNotEmpty
                ? vehicle.supportedFuels.first
                : FuelType.gasoline,
          ),
          lastOdometerReading: lastOdometer,
        );
      } else {
        throw Exception('Veículo não encontrado');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar dados do veículo: $e');
      }
      state = state.copyWith(lastError: 'Erro ao carregar veículo: $e');
    }
  }

  void _updateTextControllers() {
    litersController.text = state.formModel.liters > 0
        ? _formatter.formatLiters(state.formModel.liters)
        : '';

    pricePerLiterController.text = state.formModel.pricePerLiter > 0
        ? _formatter.formatPricePerLiter(state.formModel.pricePerLiter)
        : '';

    odometerController.text = state.formModel.odometer > 0
        ? _formatter.formatOdometer(state.formModel.odometer)
        : '';

    gasStationController.text = state.formModel.gasStationName;
    gasStationBrandController.text = state.formModel.gasStationBrand;
    notesController.text = state.formModel.notes;
  }

  void _onLitersChanged() {
    _litersDebounceTimer?.cancel();
    _litersDebounceTimer = Timer(
      const Duration(milliseconds: FuelConstants.litersDebounceMs),
      () {
        final value = _formatter.parseFormattedValue(litersController.text);
        _updateLiters(value);
      },
    );
  }

  void _onPricePerLiterChanged() {
    _priceDebounceTimer?.cancel();
    _priceDebounceTimer = Timer(
      const Duration(milliseconds: FuelConstants.priceDebounceMs),
      () {
        final value = _formatter.parseFormattedValue(
          pricePerLiterController.text,
        );
        _updatePricePerLiter(value);
      },
    );
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: FuelConstants.odometerDebounceMs),
      () {
        final value = _formatter.parseFormattedValue(odometerController.text);
        _updateOdometer(value);
      },
    );
  }

  void _onGasStationChanged() {
    final sanitized = InputSanitizer.sanitizeName(gasStationController.text);
    _updateGasStationName(sanitized);
  }

  void _onGasStationBrandChanged() {
    final sanitized = InputSanitizer.sanitizeName(
      gasStationBrandController.text,
    );
    _updateGasStationBrand(sanitized);
  }

  void _onNotesChanged() {
    final sanitized = InputSanitizer.sanitizeDescription(notesController.text);
    _updateNotes(sanitized);
  }

  void _updateLiters(double value) {
    if (state.formModel.liters == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(liters: value, hasChanges: true)
          .clearFieldError('liters'),
    );

    _calculateTotalPrice();
  }

  void _updatePricePerLiter(double value) {
    if (state.formModel.pricePerLiter == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(pricePerLiter: value, hasChanges: true)
          .clearFieldError('pricePerLiter'),
    );

    _calculateTotalPrice();
  }

  void _updateOdometer(double value) {
    if (state.formModel.odometer == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(odometer: value, hasChanges: true)
          .clearFieldError('odometer'),
    );
  }

  void _updateGasStationName(String value) {
    if (state.formModel.gasStationName == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(gasStationName: value, hasChanges: true)
          .clearFieldError('gasStationName'),
    );
  }

  void _updateGasStationBrand(String value) {
    if (state.formModel.gasStationBrand == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(gasStationBrand: value, hasChanges: true)
          .clearFieldError('gasStationBrand'),
    );
  }

  void _updateNotes(String value) {
    if (state.formModel.notes == value) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(notes: value, hasChanges: true)
          .clearFieldError('notes'),
    );
  }

  void updateFuelType(FuelType fuelType) {
    if (state.formModel.fuelType == fuelType) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(fuelType: fuelType, hasChanges: true)
          .clearFieldError('fuelType'),
    );
  }

  void updateDate(DateTime date) {
    if (state.formModel.date == date) return;

    state = state.copyWith(
      formModel: state.formModel
          .copyWith(date: date, hasChanges: true)
          .clearFieldError('date'),
    );
  }

  void updateFullTank(bool fullTank) {
    if (state.formModel.fullTank == fullTank) return;

    state = state.copyWith(
      formModel: state.formModel.copyWith(fullTank: fullTank, hasChanges: true),
    );
  }

  void _calculateTotalPrice() {
    if (state.isCalculating) return;

    state = state.copyWith(isCalculating: true);

    final total = _validator.calculateTotalPrice(
      state.formModel.liters,
      state.formModel.pricePerLiter,
    );

    state = state.copyWith(
      formModel: state.formModel.copyWith(totalPrice: total),
      isCalculating: false,
    );
  }

  String? validateField(String field, String? value) {
    switch (field) {
      case 'liters':
        return _validator.validateLiters(
          value,
          tankCapacity: state.formModel.vehicle?.tankCapacity,
        );
      case 'pricePerLiter':
        return _validator.validatePricePerLiter(value);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: state.formModel.vehicle?.currentOdometer,
          lastRecordOdometer: state.lastOdometerReading,
        );
      case 'gasStationName':
        return _validator.validateGasStationName(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Validates the complete form and returns validation result with first error field
  ///
  /// Returns a record with:
  /// - bool: whether the form is valid
  /// - String?: the key of the first field with an error (null if valid)
  (bool, String?) validateForm() {
    if (kDebugMode) {
      debugPrint('[FUEL VALIDATION] Starting form validation...');
      debugPrint('[FUEL VALIDATION] liters: "${litersController.text}"');
      debugPrint(
        '[FUEL VALIDATION] pricePerLiter: "${pricePerLiterController.text}"',
      );
      debugPrint('[FUEL VALIDATION] odometer: "${odometerController.text}"');
    }

    final errors = _validator.validateCompleteForm(
      liters: litersController.text,
      pricePerLiter: pricePerLiterController.text,
      odometer: odometerController.text,
      fuelType: state.formModel.fuelType,
      date: state.formModel.date,
      gasStationName: gasStationController.text,
      notes: notesController.text,
      vehicle: state.formModel.vehicle,
      lastRecordOdometer: state.lastOdometerReading,
    );

    if (kDebugMode) {
      debugPrint('[FUEL VALIDATION] Validation errors: $errors');
      debugPrint(
        '[FUEL VALIDATION] Form is ${errors.isEmpty ? "VALID" : "INVALID"}',
      );
    }

    state = state.copyWith(formModel: state.formModel.copyWith(errors: errors));

    if (errors.isEmpty) {
      return (true, null);
    }

    // Priority order for field focus (most important fields first)
    const fieldPriority = [
      'liters',
      'pricePerLiter',
      'odometer',
      'fuelType',
      'gasStationName',
      'notes',
    ];

    // Find first error field according to priority
    for (final field in fieldPriority) {
      if (errors.containsKey(field)) {
        if (kDebugMode) {
          debugPrint('[FUEL VALIDATION] First error field: $field');
        }
        return (false, field);
      }
    }

    // If no priority field has error, return first error found
    final firstErrorField = errors.keys.first;
    if (kDebugMode) {
      debugPrint(
        '[FUEL VALIDATION] First error field (fallback): $firstErrorField',
      );
    }
    return (false, firstErrorField);
  }

  /// Salva o registro de abastecimento (criar ou atualizar)
  Future<Either<Failure, FuelRecordEntity?>> saveFuelRecord() async {
    try {
      // Valida antes de salvar
      final (isValid, firstErrorField) = validateForm();
      if (!isValid) {
        final errorMsg = firstErrorField != null
            ? state.formModel.errors[firstErrorField] ?? 'Formulário inválido'
            : 'Formulário inválido';
        return Left(ValidationFailure(errorMsg));
      }

      state = state.copyWith(isLoading: true, clearError: true);

      // Cria entidade a partir do formulário
      final fuelEntity = state.formModel.toFuelRecord();

      // Decide se é criar ou atualizar
      final Either<Failure, FuelRecordEntity> result;

      if (state.formModel.id.isEmpty) {
        // Criar novo
        final addUseCase = local_di.getIt<AddFuelRecord>();
        result = await addUseCase(AddFuelRecordParams(fuelRecord: fuelEntity));
      } else {
        // Atualizar existente
        final updateUseCase = local_di.getIt<UpdateFuelRecord>();
        result = await updateUseCase(
          UpdateFuelRecordParams(fuelRecord: fuelEntity),
        );
      }

      state = state.copyWith(isLoading: false);

      return result.fold((failure) => Left(failure), (entity) => Right(entity));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }

  void clearForm() {
    litersController.clear();
    pricePerLiterController.clear();
    odometerController.clear();
    gasStationController.clear();
    gasStationBrandController.clear();
    notesController.clear();

    state = state.copyWith(
      formModel: FuelFormModel.initial(
        state.formModel.vehicleId,
        state.formModel.userId,
      ),
      clearImagePaths: true,
      clearImageError: true,
    );
  }

  void resetForm() {
    clearForm();
    state = state.copyWith(
      formModel: state.formModel.copyWith(
        hasChanges: false,
        errors: const {},
        lastError: null,
      ),
      clearError: true,
    );
  }

  Future<void> loadFromFuelRecord(FuelRecordEntity record) async {
    try {
      state = state.copyWith(formModel: FuelFormModel.fromFuelRecord(record));
      await _loadVehicleData(record.vehicleId);
      _updateTextControllers();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar registro: $e');
      }
      state = state.copyWith(lastError: 'Erro ao carregar registro: $e');
    }
  }

  Future<void> captureReceiptImage() async {
    try {
      state = state.copyWith(imageUploadError: null, clearImageError: true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      state = state.copyWith(imageUploadError: 'Erro ao capturar imagem: $e');
    }
  }

  Future<void> selectReceiptImageFromGallery() async {
    try {
      state = state.copyWith(imageUploadError: null, clearImageError: true);

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      state = state.copyWith(imageUploadError: 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _processReceiptImage(String imagePath) async {
    try {
      state = state.copyWith(
        isUploadingImage: true,
        imageUploadError: null,
        clearImageError: true,
      );
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        throw Exception('Arquivo de imagem inválido');
      }
      final result = await _receiptImageService.processFuelReceiptImage(
        userId: state.formModel.userId,
        fuelSupplyId: _generateTemporaryId(),
        imagePath: imagePath,
        compressImage: true,
        uploadToFirebase: true,
      );

      state = state.copyWith(
        receiptImagePath: result.localPath,
        receiptImageUrl: result.downloadUrl,
        isUploadingImage: false,
        formModel: state.formModel.copyWith(hasChanges: true),
      );

      if (kDebugMode) {
        debugPrint('[FUEL FORM] Image processed successfully');
        debugPrint('[FUEL FORM] Local path: ${result.localPath}');
        debugPrint('[FUEL FORM] Download URL: ${result.downloadUrl}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FUEL FORM] Image processing error: $e');
      }
      state = state.copyWith(
        imageUploadError: 'Erro ao processar imagem: $e',
        isUploadingImage: false,
      );
    }
  }

  Future<void> removeReceiptImage() async {
    try {
      if (state.receiptImagePath != null || state.receiptImageUrl != null) {
        await _receiptImageService.deleteReceiptImage(
          localPath: state.receiptImagePath,
          downloadUrl: state.receiptImageUrl,
        );
      }

      state = state.copyWith(
        receiptImagePath: null,
        receiptImageUrl: null,
        imageUploadError: null,
        formModel: state.formModel.copyWith(hasChanges: true),
        clearImagePaths: true,
        clearImageError: true,
      );
    } catch (e) {
      state = state.copyWith(imageUploadError: 'Erro ao remover imagem: $e');
    }
  }

  Future<void> syncImageToFirebase(String actualFuelSupplyId) async {
    if (state.receiptImagePath == null || state.receiptImageUrl != null) {
      return; // Nothing to sync
    }

    try {
      state = state.copyWith(isUploadingImage: true);

      final result = await _receiptImageService.processFuelReceiptImage(
        userId: state.formModel.userId,
        fuelSupplyId: actualFuelSupplyId,
        imagePath: state.receiptImagePath!,
        compressImage: false, // Already compressed
        uploadToFirebase: true,
      );

      state = state.copyWith(
        receiptImageUrl: result.downloadUrl,
        isUploadingImage: false,
      );

      if (kDebugMode) {
        debugPrint(
          '[FUEL FORM] Image synced to Firebase: ${result.downloadUrl}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FUEL FORM] Failed to sync image: $e');
      }
      state = state.copyWith(isUploadingImage: false);
    }
  }

  String _generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _litersDebounceTimer?.cancel();
    _priceDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();

    litersController.dispose();
    pricePerLiterController.dispose();
    odometerController.dispose();
    gasStationController.dispose();
    gasStationBrandController.dispose();
    notesController.dispose();

    // Dispose FocusNodes
    litersFocusNode.dispose();
    pricePerLiterFocusNode.dispose();
    odometerFocusNode.dispose();
    gasStationFocusNode.dispose();
    gasStationBrandFocusNode.dispose();
    notesFocusNode.dispose();

    super.dispose();
  }
}

/// Fuel form notifier provider factory
final fuelFormNotifierProvider =
    StateNotifierProvider.family<FuelFormNotifier, FuelFormState, String>((
      ref,
      vehicleId,
    ) {
      final userId = ref.watch(userIdProvider);
      return FuelFormNotifier(
        initialVehicleId: vehicleId,
        userId: userId,
        receiptImageService: local_di.getIt<ReceiptImageService>(),
        ref: ref,
      );
    });

/// Derived providers for form state
final fuelFormCanSubmitProvider = Provider.family<bool, String>((
  ref,
  vehicleId,
) {
  return ref.watch(fuelFormNotifierProvider(vehicleId)).canSubmit;
});

final fuelFormHasChangesProvider = Provider.family<bool, String>((
  ref,
  vehicleId,
) {
  return ref.watch(fuelFormNotifierProvider(vehicleId)).hasChanges;
});

final fuelFormHasErrorsProvider = Provider.family<bool, String>((
  ref,
  vehicleId,
) {
  return ref.watch(fuelFormNotifierProvider(vehicleId)).hasErrors;
});

final fuelFormImageStateProvider = Provider.family<bool, String>((
  ref,
  vehicleId,
) {
  return ref.watch(fuelFormNotifierProvider(vehicleId)).hasReceiptImage;
});
