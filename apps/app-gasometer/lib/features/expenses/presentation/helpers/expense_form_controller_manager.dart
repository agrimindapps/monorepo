import 'package:flutter/material.dart';

import '../../domain/services/expense_formatter_service.dart';
import '../notifiers/expense_form_state.dart';

/// Callback type for controller change events
typedef ControllerChangeCallback = void Function();

/// Manager for TextEditingControllers used in expense forms
///
/// Responsibilities:
/// - Creating and disposing controllers
/// - Adding/removing listeners
/// - Updating controller values from state
/// - Synchronizing state changes
class ExpenseFormControllerManager {
  ExpenseFormControllerManager({
    ExpenseFormatterService? formatter,
  }) : _formatter = formatter ?? ExpenseFormatterService();

  final ExpenseFormatterService _formatter;

  // Controllers
  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  late final TextEditingController odometerController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;

  // Listener callbacks
  ControllerChangeCallback? _onDescriptionChanged;
  ControllerChangeCallback? _onAmountChanged;
  ControllerChangeCallback? _onOdometerChanged;
  ControllerChangeCallback? _onLocationChanged;
  ControllerChangeCallback? _onNotesChanged;

  bool _isInitialized = false;

  /// Initializes all text controllers
  void initialize() {
    if (_isInitialized) return;

    descriptionController = TextEditingController();
    amountController = TextEditingController();
    odometerController = TextEditingController();
    locationController = TextEditingController();
    notesController = TextEditingController();

    _isInitialized = true;
  }

  /// Adds listeners to all controllers
  void addListeners({
    required ControllerChangeCallback onDescriptionChanged,
    required ControllerChangeCallback onAmountChanged,
    required ControllerChangeCallback onOdometerChanged,
    required ControllerChangeCallback onLocationChanged,
    required ControllerChangeCallback onNotesChanged,
  }) {
    _onDescriptionChanged = onDescriptionChanged;
    _onAmountChanged = onAmountChanged;
    _onOdometerChanged = onOdometerChanged;
    _onLocationChanged = onLocationChanged;
    _onNotesChanged = onNotesChanged;

    descriptionController.addListener(_handleDescriptionChanged);
    amountController.addListener(_handleAmountChanged);
    odometerController.addListener(_handleOdometerChanged);
    locationController.addListener(_handleLocationChanged);
    notesController.addListener(_handleNotesChanged);
  }

  void _handleDescriptionChanged() => _onDescriptionChanged?.call();
  void _handleAmountChanged() => _onAmountChanged?.call();
  void _handleOdometerChanged() => _onOdometerChanged?.call();
  void _handleLocationChanged() => _onLocationChanged?.call();
  void _handleNotesChanged() => _onNotesChanged?.call();

  /// Updates controllers with values from state
  void updateFromState(ExpenseFormState state) {
    descriptionController.text = state.description;

    amountController.text =
        state.amount > 0 ? _formatter.formatAmount(state.amount) : '';

    odometerController.text =
        state.odometer > 0 ? _formatter.formatOdometer(state.odometer) : '';

    locationController.text = state.location;
    notesController.text = state.notes;
  }

  /// Clears all controller values
  void clearAll() {
    descriptionController.clear();
    amountController.clear();
    odometerController.clear();
    locationController.clear();
    notesController.clear();
  }

  /// Disposes all controllers and removes listeners
  void dispose() {
    if (!_isInitialized) return;

    descriptionController.removeListener(_handleDescriptionChanged);
    amountController.removeListener(_handleAmountChanged);
    odometerController.removeListener(_handleOdometerChanged);
    locationController.removeListener(_handleLocationChanged);
    notesController.removeListener(_handleNotesChanged);

    descriptionController.dispose();
    amountController.dispose();
    odometerController.dispose();
    locationController.dispose();
    notesController.dispose();

    _isInitialized = false;
  }
}
