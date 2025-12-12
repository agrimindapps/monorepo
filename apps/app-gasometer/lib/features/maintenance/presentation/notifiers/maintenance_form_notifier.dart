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
part 'maintenance_form_notifier_validation.dart';
part 'maintenance_form_notifier_image.dart';
part 'maintenance_form_notifier_persistence.dart';

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
}
