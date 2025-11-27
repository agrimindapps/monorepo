import 'package:flutter/material.dart';

import '../../domain/services/maintenance_formatter_service.dart';
import '../notifiers/maintenance_form_state.dart';

/// Callback type for controller change events
typedef ControllerChangeCallback = void Function();

/// Manager for TextEditingControllers used in maintenance forms
///
/// Responsibilities:
/// - Creating and disposing controllers
/// - Adding/removing listeners
/// - Updating controller values from state
/// - Synchronizing state changes
class MaintenanceFormControllerManager {
  MaintenanceFormControllerManager({
    MaintenanceFormatterService? formatter,
  }) : _formatter = formatter ?? MaintenanceFormatterService();

  final MaintenanceFormatterService _formatter;

  // Controllers
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController costController;
  late final TextEditingController odometerController;
  late final TextEditingController workshopNameController;
  late final TextEditingController workshopPhoneController;
  late final TextEditingController workshopAddressController;
  late final TextEditingController nextOdometerController;
  late final TextEditingController notesController;

  // Listener callbacks
  ControllerChangeCallback? _onTitleChanged;
  ControllerChangeCallback? _onDescriptionChanged;
  ControllerChangeCallback? _onCostChanged;
  ControllerChangeCallback? _onOdometerChanged;
  ControllerChangeCallback? _onWorkshopNameChanged;
  ControllerChangeCallback? _onWorkshopPhoneChanged;
  ControllerChangeCallback? _onWorkshopAddressChanged;
  ControllerChangeCallback? _onNextOdometerChanged;
  ControllerChangeCallback? _onNotesChanged;

  bool _isInitialized = false;

  /// Initializes all text controllers
  void initialize() {
    if (_isInitialized) return;

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    costController = TextEditingController();
    odometerController = TextEditingController();
    workshopNameController = TextEditingController();
    workshopPhoneController = TextEditingController();
    workshopAddressController = TextEditingController();
    nextOdometerController = TextEditingController();
    notesController = TextEditingController();

    _isInitialized = true;
  }

  /// Adds listeners to all controllers
  void addListeners({
    required ControllerChangeCallback onTitleChanged,
    required ControllerChangeCallback onDescriptionChanged,
    required ControllerChangeCallback onCostChanged,
    required ControllerChangeCallback onOdometerChanged,
    required ControllerChangeCallback onWorkshopNameChanged,
    required ControllerChangeCallback onWorkshopPhoneChanged,
    required ControllerChangeCallback onWorkshopAddressChanged,
    required ControllerChangeCallback onNextOdometerChanged,
    required ControllerChangeCallback onNotesChanged,
  }) {
    _onTitleChanged = onTitleChanged;
    _onDescriptionChanged = onDescriptionChanged;
    _onCostChanged = onCostChanged;
    _onOdometerChanged = onOdometerChanged;
    _onWorkshopNameChanged = onWorkshopNameChanged;
    _onWorkshopPhoneChanged = onWorkshopPhoneChanged;
    _onWorkshopAddressChanged = onWorkshopAddressChanged;
    _onNextOdometerChanged = onNextOdometerChanged;
    _onNotesChanged = onNotesChanged;

    titleController.addListener(_handleTitleChanged);
    descriptionController.addListener(_handleDescriptionChanged);
    costController.addListener(_handleCostChanged);
    odometerController.addListener(_handleOdometerChanged);
    workshopNameController.addListener(_handleWorkshopNameChanged);
    workshopPhoneController.addListener(_handleWorkshopPhoneChanged);
    workshopAddressController.addListener(_handleWorkshopAddressChanged);
    nextOdometerController.addListener(_handleNextOdometerChanged);
    notesController.addListener(_handleNotesChanged);
  }

  void _handleTitleChanged() => _onTitleChanged?.call();
  void _handleDescriptionChanged() => _onDescriptionChanged?.call();
  void _handleCostChanged() => _onCostChanged?.call();
  void _handleOdometerChanged() => _onOdometerChanged?.call();
  void _handleWorkshopNameChanged() => _onWorkshopNameChanged?.call();
  void _handleWorkshopPhoneChanged() => _onWorkshopPhoneChanged?.call();
  void _handleWorkshopAddressChanged() => _onWorkshopAddressChanged?.call();
  void _handleNextOdometerChanged() => _onNextOdometerChanged?.call();
  void _handleNotesChanged() => _onNotesChanged?.call();

  /// Updates controllers with values from state
  void updateFromState(MaintenanceFormState state) {
    titleController.text = state.title;
    descriptionController.text = state.description;

    costController.text = state.cost > 0
        ? _formatter.formatAmount(state.cost)
        : '';

    odometerController.text = state.odometer > 0
        ? _formatter.formatOdometer(state.odometer)
        : '';

    workshopNameController.text = state.workshopName;
    workshopPhoneController.text = state.workshopPhone;
    workshopAddressController.text = state.workshopAddress;

    nextOdometerController.text = state.nextServiceOdometer != null
        ? _formatter.formatOdometer(state.nextServiceOdometer!)
        : '';

    notesController.text = state.notes;
  }

  /// Updates phone controller with formatted value
  void updatePhoneFormatted(String formatted) {
    if (formatted != workshopPhoneController.text) {
      workshopPhoneController.value = workshopPhoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  /// Clears all controller values
  void clearAll() {
    titleController.clear();
    descriptionController.clear();
    costController.clear();
    odometerController.clear();
    workshopNameController.clear();
    workshopPhoneController.clear();
    workshopAddressController.clear();
    nextOdometerController.clear();
    notesController.clear();
  }

  /// Disposes all controllers and removes listeners
  void dispose() {
    if (!_isInitialized) return;

    titleController.removeListener(_handleTitleChanged);
    descriptionController.removeListener(_handleDescriptionChanged);
    costController.removeListener(_handleCostChanged);
    odometerController.removeListener(_handleOdometerChanged);
    workshopNameController.removeListener(_handleWorkshopNameChanged);
    workshopPhoneController.removeListener(_handleWorkshopPhoneChanged);
    workshopAddressController.removeListener(_handleWorkshopAddressChanged);
    nextOdometerController.removeListener(_handleNextOdometerChanged);
    notesController.removeListener(_handleNotesChanged);

    titleController.dispose();
    descriptionController.dispose();
    costController.dispose();
    odometerController.dispose();
    workshopNameController.dispose();
    workshopPhoneController.dispose();
    workshopAddressController.dispose();
    nextOdometerController.dispose();
    notesController.dispose();

    _isInitialized = false;
  }
}
