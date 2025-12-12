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
part 'fuel_form_notifier_initialization.dart';
part 'fuel_form_notifier_state.dart';
part 'fuel_form_notifier_validation.dart';
part 'fuel_form_notifier_crud.dart';
part 'fuel_form_notifier_image.dart';

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
