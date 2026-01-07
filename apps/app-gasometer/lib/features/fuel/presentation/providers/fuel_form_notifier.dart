import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide FormState, connectivityServiceProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/storage/firebase_storage_service.dart'
    as local_storage;
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../../receipt/domain/services/receipt_image_service.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../helpers/helpers.dart';
import '../models/fuel_form_model.dart';
import 'fuel_form_state.dart';
import 'fuel_riverpod_notifier.dart';

part 'fuel_form_notifier.g.dart';

/// FuelFormNotifier - Orchestrates fuel record form state using helpers
@riverpod
class FuelFormNotifier extends _$FuelFormNotifier {
  late FuelFormControllerManager _controllerManager;
  late FuelFormValidatorHandler _validatorHandler;
  late FuelFormImageHandler _imageHandler;
  late FuelFormCalculator _calculator;
  bool _listenersSetup = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Expose controllers via manager
  TextEditingController get litersController =>
      _controllerManager.litersController;
  TextEditingController get pricePerLiterController =>
      _controllerManager.pricePerLiterController;
  TextEditingController get odometerController =>
      _controllerManager.odometerController;
  TextEditingController get gasStationController =>
      _controllerManager.gasStationController;
  TextEditingController get gasStationBrandController =>
      _controllerManager.gasStationBrandController;
  TextEditingController get notesController =>
      _controllerManager.notesController;

  // Expose focus nodes via manager
  Map<String, FocusNode> get fieldFocusNodes =>
      _controllerManager.fieldFocusNodes;
  FocusNode get litersFocusNode => _controllerManager.litersFocusNode;
  FocusNode get pricePerLiterFocusNode =>
      _controllerManager.pricePerLiterFocusNode;
  FocusNode get odometerFocusNode => _controllerManager.odometerFocusNode;
  FocusNode get gasStationFocusNode => _controllerManager.gasStationFocusNode;
  FocusNode get gasStationBrandFocusNode =>
      _controllerManager.gasStationBrandFocusNode;
  FocusNode get notesFocusNode => _controllerManager.notesFocusNode;

  @override
  FuelFormState build(String vehicleId) {
    final userId = ref.watch(userIdProvider);

    _initializeHelpers();

    ref.onDispose(() {
      _validatorHandler.dispose();
      _controllerManager.dispose();
    });

    return FuelFormState(
      formModel: FuelFormModel.initial(vehicleId, userId),
    );
  }

  void _initializeHelpers() {
    final compressionService = core.ImageCompressionService();
    final storageService = local_storage.FirebaseStorageService();
    final connectivityService = ref.watch(connectivityServiceProvider);
    final imageSyncService = ref.watch(imageSyncServiceProvider);

    final receiptImageService = ReceiptImageService(
      compressionService,
      storageService,
      connectivityService,
      imageSyncService,
    );

    _controllerManager = FuelFormControllerManager();
    _controllerManager.initialize();

    _validatorHandler = FuelFormValidatorHandler();
    _imageHandler = FuelFormImageHandler(
      receiptImageService: receiptImageService,
    );
    _calculator = const FuelFormCalculator();
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Initializes the form with optional vehicle and user IDs
  Future<void> initialize({String? vehicleId, String? userId}) async {
    try {
      final selectedVehicleId = vehicleId ?? state.formModel.vehicleId;

      if (selectedVehicleId.isEmpty) {
        throw Exception('Nenhum veículo selecionado');
      }

      final formModel =
          FuelFormModel.initial(selectedVehicleId, userId ?? '');
      // ignore: unawaited_futures
      Future.microtask(() {
        state = state.copyWith(formModel: formModel, isLoading: true);
      });

      await _loadVehicleData(selectedVehicleId);
      _setupControllers();
      _controllerManager.updateFromModel(state.formModel);

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

  /// Sets up controller listeners
  void _setupControllers() {
    if (_listenersSetup) return;

    _controllerManager.addListeners(
      onLitersChanged: _onLitersChanged,
      onPricePerLiterChanged: _onPricePerLiterChanged,
      onOdometerChanged: _onOdometerChanged,
      onGasStationChanged: _onGasStationChanged,
      onGasStationBrandChanged: _onGasStationBrandChanged,
      onNotesChanged: _onNotesChanged,
    );
    _listenersSetup = true;
  }

  /// Loads vehicle data from repository
  Future<void> _loadVehicleData(String vehicleId) async {
    try {
      final vehiclesNotifier = ref.read(vehiclesProvider.notifier);
      final vehicle = await vehiclesNotifier.getVehicleById(vehicleId);

      if (vehicle != null) {
        state = state.copyWith(
          formModel: state.formModel.copyWith(
            vehicle: vehicle,
            fuelType: vehicle.supportedFuels.isNotEmpty
                ? vehicle.supportedFuels.first
                : FuelType.gasoline,
          ),
          lastOdometerReading: vehicle.currentOdometer,
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

  /// Loads form from existing fuel record
  Future<void> loadFromFuelRecord(FuelRecordEntity record) async {
    try {
      state = state.copyWith(formModel: FuelFormModel.fromFuelRecord(record));
      await _loadVehicleData(record.vehicleId);
      _controllerManager.updateFromModel(state.formModel);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar registro: $e');
      }
      state = state.copyWith(lastError: 'Erro ao carregar registro: $e');
    }
  }

  /// Clears all form fields and state
  void clearForm() {
    _controllerManager.clearAll();
    state = state.copyWith(
      formModel: FuelFormModel.initial(
        state.formModel.vehicleId,
        state.formModel.userId,
      ),
      clearImagePaths: true,
      clearImageError: true,
    );
  }

  /// Resets form to initial state
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

  // ==================== STATE MANAGEMENT METHODS ====================

  // Controller change handlers
  void _onLitersChanged() {
    _validatorHandler.validateLitersWithDebounce(
      value: litersController.text,
      onParsedValue: _updateLiters,
    );
  }

  void _onPricePerLiterChanged() {
    _validatorHandler.validatePriceWithDebounce(
      value: pricePerLiterController.text,
      onParsedValue: _updatePricePerLiter,
    );
  }

  void _onOdometerChanged() {
    _validatorHandler.validateOdometerWithDebounce(
      value: odometerController.text,
      onParsedValue: _updateOdometer,
    );
  }

  void _onGasStationChanged() {
    final sanitized =
        _validatorHandler.sanitizeGasStationName(gasStationController.text);
    _updateGasStationName(sanitized);
  }

  void _onGasStationBrandChanged() {
    final sanitized = _validatorHandler
        .sanitizeGasStationBrand(gasStationBrandController.text);
    _updateGasStationBrand(sanitized);
  }

  void _onNotesChanged() {
    final sanitized = _validatorHandler.sanitizeNotes(notesController.text);
    _updateNotes(sanitized);
  }

  // Internal state update methods
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

  // Public update methods
  /// Updates the fuel type
  void updateFuelType(FuelType fuelType) {
    if (state.formModel.fuelType == fuelType) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(fuelType: fuelType, hasChanges: true)
          .clearFieldError('fuelType'),
    );
  }

  /// Updates the fuel supply date
  void updateDate(DateTime date) {
    if (state.formModel.date == date) return;
    state = state.copyWith(
      formModel: state.formModel
          .copyWith(date: date, hasChanges: true)
          .clearFieldError('date'),
    );
  }

  /// Updates the full tank flag
  void updateFullTank(bool fullTank) {
    if (state.formModel.fullTank == fullTank) return;
    state = state.copyWith(
      formModel: state.formModel.copyWith(fullTank: fullTank, hasChanges: true),
    );
  }

  /// Calculates total price from liters and price per liter
  void _calculateTotalPrice() {
    if (state.isCalculating) return;
    state = state.copyWith(isCalculating: true);

    final total = _calculator.calculateTotalPrice(
      state.formModel.liters,
      state.formModel.pricePerLiter,
    );

    state = state.copyWith(
      formModel: state.formModel.copyWith(totalPrice: total),
      isCalculating: false,
    );
  }

  // ==================== VALIDATION METHODS ====================

  /// Validates a single form field
  String? validateField(String field, String? value) {
    return _validatorHandler.validateField(
      field,
      value,
      tankCapacity: state.formModel.vehicle?.tankCapacity,
      currentOdometer: state.formModel.vehicle?.currentOdometer,
      lastRecordOdometer: state.lastOdometerReading,
    );
  }

  /// Validates the complete form
  /// Returns (isValid, firstErrorField)
  (bool, String?) validateForm() {
    final errors = _validatorHandler.validateCompleteForm(
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

    state = state.copyWith(formModel: state.formModel.copyWith(errors: errors));

    if (errors.isEmpty) return (true, null);

    const fieldPriority = [
      'liters',
      'pricePerLiter',
      'odometer',
      'fuelType',
      'gasStationName',
      'notes',
    ];

    for (final field in fieldPriority) {
      if (errors.containsKey(field)) return (false, field);
    }

    return (false, errors.keys.first);
  }

  // ==================== CRUD OPERATIONS ====================

  /// Saves the fuel record (create or update)
  Future<Either<Failure, FuelRecordEntity?>> saveFuelRecord() async {
    try {
      final (isValid, firstErrorField) = validateForm();
      if (!isValid) {
        final errorMsg = firstErrorField != null
            ? state.formModel.errors[firstErrorField] ?? 'Formulário inválido'
            : 'Formulário inválido';
        return Left(ValidationFailure(errorMsg));
      }

      state = state.copyWith(isLoading: true, clearError: true);

      final fuelEntity = state.formModel.toFuelRecord();
      bool success = false;

      if (state.formModel.id.isEmpty) {
        success = await ref
            .read(fuelRiverpodProvider.notifier)
            .addFuelRecord(fuelEntity);
      } else {
        success = await ref
            .read(fuelRiverpodProvider.notifier)
            .updateFuelRecord(fuelEntity);
      }

      state = state.copyWith(isLoading: false);

      if (success) {
        return Right(fuelEntity);
      } else {
        final error = ref.read(fuelRiverpodProvider).value?.errorMessage ??
            'Erro desconhecido ao salvar';
        return Left(UnexpectedFailure(error));
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        lastError: 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }

  // ==================== IMAGE HANDLING ====================

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

/// Derived providers for form state
@riverpod
bool fuelFormCanSubmit(Ref ref, String vehicleId) {
  return ref.watch(fuelFormProvider(vehicleId)).canSubmit;
}

@riverpod
bool fuelFormHasChanges(Ref ref, String vehicleId) {
  return ref.watch(fuelFormProvider(vehicleId)).hasChanges;
}

@riverpod
bool fuelFormHasErrors(Ref ref, String vehicleId) {
  return ref.watch(fuelFormProvider(vehicleId)).hasErrors;
}

@riverpod
bool fuelFormImageState(Ref ref, String vehicleId) {
  return ref.watch(fuelFormProvider(vehicleId)).hasReceiptImage;
}

