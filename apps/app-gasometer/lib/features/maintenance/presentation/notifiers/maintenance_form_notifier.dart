import 'package:core/core.dart' as core;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide connectivityServiceProvider;
import 'package:flutter/material.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/storage/firebase_storage_service.dart' as local_storage;
import '../../../../features/receipt/domain/services/receipt_image_service.dart';
import '../../../vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/update_maintenance_record.dart';
import '../helpers/maintenance_date_picker_helper.dart';
import '../helpers/maintenance_entity_builder.dart';
import '../helpers/maintenance_form_controller_manager.dart';
import '../helpers/maintenance_form_image_handler.dart';
import '../helpers/maintenance_form_validator_handler.dart';
import '../providers/maintenance_providers.dart';
import 'maintenance_form_state.dart';

part 'maintenance_form_notifier.g.dart';

/// Notifier Riverpod para gerenciar o estado do formulário de manutenção
///
/// Orchestrates form operations using specialized handlers:
/// - [MaintenanceFormControllerManager] for TextEditingControllers
/// - [MaintenanceFormImageHandler] for image operations
/// - [MaintenanceFormValidatorHandler] for validation with debounce
/// - [MaintenanceDatePickerHelper] for date/time picker operations
/// - [MaintenanceEntityBuilder] for building entities
@riverpod
class MaintenanceFormNotifier extends _$MaintenanceFormNotifier {
  late final MaintenanceFormControllerManager _controllerManager;
  late final MaintenanceFormImageHandler _imageHandler;
  late final MaintenanceFormValidatorHandler _validatorHandler;
  late final MaintenanceDatePickerHelper _datePickerHelper;
  late final MaintenanceEntityBuilder _entityBuilder;
  late final GetVehicleById _getVehicleById;
  late final AddMaintenanceRecord _addMaintenanceRecord;
  late final UpdateMaintenanceRecord _updateMaintenanceRecord;

  // Expose controllers for UI binding
  TextEditingController get titleController => _controllerManager.titleController;
  TextEditingController get descriptionController => _controllerManager.descriptionController;
  TextEditingController get costController => _controllerManager.costController;
  TextEditingController get odometerController => _controllerManager.odometerController;
  TextEditingController get workshopNameController => _controllerManager.workshopNameController;
  TextEditingController get workshopPhoneController => _controllerManager.workshopPhoneController;
  TextEditingController get workshopAddressController => _controllerManager.workshopAddressController;
  TextEditingController get nextOdometerController => _controllerManager.nextOdometerController;
  TextEditingController get notesController => _controllerManager.notesController;

  @override
  MaintenanceFormState build() {
    // Initialize handlers
    _controllerManager = MaintenanceFormControllerManager();
    _controllerManager.initialize();

    _validatorHandler = MaintenanceFormValidatorHandler();
    _datePickerHelper = const MaintenanceDatePickerHelper();
    _entityBuilder = const MaintenanceEntityBuilder();

    // Build image handler with dependencies
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
    _imageHandler = MaintenanceFormImageHandler(
      receiptImageService: receiptImageService,
    );

    // Inject use cases
    _getVehicleById = ref.watch(getVehicleByIdProvider);
    _addMaintenanceRecord = ref.watch(addMaintenanceRecordProvider);
    _updateMaintenanceRecord = ref.watch(updateMaintenanceRecordProvider);

    // Setup controller listeners
    _controllerManager.addListeners(
      onTitleChanged: _onTitleChanged,
      onDescriptionChanged: _onDescriptionChanged,
      onCostChanged: _onCostChanged,
      onOdometerChanged: _onOdometerChanged,
      onWorkshopNameChanged: _onWorkshopNameChanged,
      onWorkshopPhoneChanged: _onWorkshopPhoneChanged,
      onWorkshopAddressChanged: _onWorkshopAddressChanged,
      onNextOdometerChanged: _onNextOdometerChanged,
      onNotesChanged: _onNotesChanged,
    );

    ref.onDispose(() {
      _validatorHandler.dispose();
      _controllerManager.dispose();
    });

    return const MaintenanceFormState();
  }

  /// Inicializa formulário para nova manutenção
  Future<void> initialize({
    required String vehicleId,
    required String userId,
  }) async {
    if (vehicleId.isEmpty) {
      state = state.copyWith(errorMessage: () => 'Nenhum veículo selecionado');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state =
              MaintenanceFormState.initial(
                vehicleId: vehicleId,
                userId: userId,
              ).copyWith(
                vehicle: vehicle,
                odometer: vehicle.currentOdometer,
                isLoading: false,
                isInitialized: true,
              );

          _controllerManager.updateFromState(state);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao inicializar formulário: $e',
      );
    }
  }

  /// Inicializa com manutenção existente para edição
  Future<void> initializeWithMaintenance(MaintenanceEntity maintenance) async {
    state = state.copyWith(isLoading: true);

    try {
      final vehicleResult = await _getVehicleById(
        GetVehicleByIdParams(vehicleId: maintenance.vehicleId),
      );

      await vehicleResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => failure.message,
          );
        },
        (vehicle) async {
          state = MaintenanceFormState.fromMaintenance(maintenance).copyWith(
            vehicle: vehicle,
            isLoading: false,
            isInitialized: true,
          );

          _controllerManager.updateFromState(state);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao carregar manutenção: $e',
      );
    }
  }

  // Controller change handlers using validator handler
  void _onTitleChanged() {
    _validatorHandler.validateTitleWithDebounce(
      value: titleController.text,
      onSanitizedValue: (sanitized) {
        state = state
            .copyWith(title: sanitized, hasChanges: true)
            .clearFieldError('title');
      },
      onSuggestedType: (suggestedType) {
        if (suggestedType != null) {
          updateType(suggestedType);
        }
      },
      currentType: state.type,
    );
  }

  void _onDescriptionChanged() {
    _validatorHandler.validateDescriptionWithDebounce(
      value: descriptionController.text,
      onSanitizedValue: (sanitized) {
        state = state
            .copyWith(description: sanitized, hasChanges: true)
            .clearFieldError('description');
      },
    );
  }

  void _onCostChanged() {
    _validatorHandler.validateCostWithDebounce(
      value: costController.text,
      onParsedValue: (value) {
        state = state
            .copyWith(cost: value, hasChanges: true)
            .clearFieldError('cost');
      },
    );
  }

  void _onOdometerChanged() {
    _validatorHandler.validateOdometerWithDebounce(
      value: odometerController.text,
      onParsedValue: (value) {
        state = state
            .copyWith(odometer: value, hasChanges: true)
            .clearFieldError('odometer');
      },
    );
  }

  void _onWorkshopNameChanged() {
    final sanitized = _validatorHandler.sanitizeWorkshopName(
      workshopNameController.text,
    );
    state = state
        .copyWith(workshopName: sanitized, hasChanges: true)
        .clearFieldError('workshopName');
  }

  void _onWorkshopPhoneChanged() {
    final formatted = _validatorHandler.formatPhone(workshopPhoneController.text);
    _controllerManager.updatePhoneFormatted(formatted);
    state = state
        .copyWith(workshopPhone: formatted, hasChanges: true)
        .clearFieldError('workshopPhone');
  }

  void _onWorkshopAddressChanged() {
    final sanitized = _validatorHandler.sanitizeWorkshopAddress(
      workshopAddressController.text,
    );
    state = state
        .copyWith(workshopAddress: sanitized, hasChanges: true)
        .clearFieldError('workshopAddress');
  }

  void _onNextOdometerChanged() {
    final value = _validatorHandler.parseNextOdometer(
      nextOdometerController.text,
    );
    state = state
        .copyWith(
          nextServiceOdometer: value,
          hasChanges: true,
        )
        .clearFieldError('nextServiceOdometer');
  }

  void _onNotesChanged() {
    final sanitized = _validatorHandler.sanitizeNotes(notesController.text);
    state = state
        .copyWith(notes: sanitized, hasChanges: true)
        .clearFieldError('notes');
  }

  /// Atualiza tipo de manutenção
  void updateType(MaintenanceType type) {
    if (state.type == type) return;

    state = state
        .copyWith(type: type, hasChanges: true)
        .clearFieldError('type');
  }

  /// Atualiza status da manutenção
  void updateStatus(MaintenanceStatus status) {
    if (state.status == status) return;

    state = state
        .copyWith(status: status, hasChanges: true)
        .clearFieldError('status');
  }

  /// Atualiza data do serviço
  void updateServiceDate(DateTime date) {
    if (state.serviceDate == date) return;

    state = state
        .copyWith(serviceDate: date, hasChanges: true)
        .clearFieldError('serviceDate');
  }

  /// Atualiza data da próxima manutenção
  void updateNextServiceDate(DateTime? date) {
    if (state.nextServiceDate == date) return;

    state = state
        .copyWith(nextServiceDate: date, hasChanges: true)
        .clearFieldError('nextServiceDate');
  }

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

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  /// Limpa erro de imagem
  void clearImageError() {
    state = state.clearImageError();
  }

  /// Valida campo específico (para TextFormField)
  String? validateField(String field, String? value) {
    return _validatorHandler.validateField(
      field,
      value,
      type: state.type,
      currentOdometer: state.vehicle?.currentOdometer,
    );
  }

  /// Valida formulário completo
  bool validateForm() {
    debugPrint('[MAINTENANCE VALIDATION] Starting form validation...');
    
    final errors = _validatorHandler.validator.validateCompleteForm(
      type: state.type,
      title: titleController.text,
      description: descriptionController.text,
      cost: costController.text,
      odometer: odometerController.text,
      serviceDate: state.serviceDate,
      workshopName: workshopNameController.text,
      workshopPhone: workshopPhoneController.text,
      workshopAddress: workshopAddressController.text,
      nextServiceDate: state.nextServiceDate,
      nextServiceOdometer: nextOdometerController.text,
      notes: notesController.text,
      vehicle: state.vehicle,
    );

    debugPrint('[MAINTENANCE VALIDATION] Validation errors: $errors');
    debugPrint(
      '[MAINTENANCE VALIDATION] Form is ${errors.isEmpty ? "VALID" : "INVALID"}',
    );

    state = state.copyWith(fieldErrors: errors);
    return errors.isEmpty;
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

  /// Salva o registro de manutenção (criar ou atualizar)
  Future<Either<Failure, MaintenanceEntity?>> saveMaintenanceRecord() async {
    try {
      if (!validateForm()) {
        final firstError = state.fieldErrors.values.isNotEmpty
            ? state.fieldErrors.values.first
            : 'Formulário inválido';
        return Left(ValidationFailure(firstError));
      }

      state = state.copyWith(isLoading: true, errorMessage: () => null);

      final maintenanceEntity = _entityBuilder.buildFromForm(
        state: state,
        title: titleController.text,
        description: descriptionController.text,
        cost: costController.text,
        odometer: odometerController.text,
        workshopName: workshopNameController.text,
        workshopPhone: workshopPhoneController.text,
        workshopAddress: workshopAddressController.text,
        nextOdometer: nextOdometerController.text,
        notes: notesController.text,
      );

      final Either<Failure, MaintenanceEntity> result;

      if (state.id.isEmpty) {
        result = await _addMaintenanceRecord(
          AddMaintenanceRecordParams(maintenance: maintenanceEntity),
        );
      } else {
        result = await _updateMaintenanceRecord(
          UpdateMaintenanceRecordParams(maintenance: maintenanceEntity),
        );
      }

      state = state.copyWith(isLoading: false);
      return result.fold((failure) => Left(failure), (entity) => Right(entity));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Erro ao salvar: ${e.toString()}',
      );
      return Left(UnexpectedFailure('Erro ao salvar: ${e.toString()}'));
    }
  }

  /// Limpa formulário
  void clearForm() {
    _controllerManager.clearAll();

    state = MaintenanceFormState.initial(
      vehicleId: state.vehicleId,
      userId: state.userId,
    ).copyWith(vehicle: state.vehicle);
  }

  /// Reseta formulário
  void resetForm() {
    clearForm();
    state = state.copyWith(
      hasChanges: false,
      fieldErrors: const {},
      errorMessage: () => null,
      imageUploadError: () => null,
      clearReceiptImage: true,
      clearReceiptUrl: true,
    );
  }
}
