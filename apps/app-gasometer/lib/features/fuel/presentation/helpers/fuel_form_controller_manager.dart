import 'package:flutter/material.dart';

import '../../domain/services/fuel_formatter_service.dart';
import '../models/fuel_form_model.dart';

/// Callback type for controller change events
typedef ControllerChangeCallback = void Function();

/// Manager for TextEditingControllers used in fuel forms
///
/// Responsibilities:
/// - Creating and disposing controllers
/// - Adding/removing listeners
/// - Updating controller values from state
/// - Synchronizing state changes
class FuelFormControllerManager {
  FuelFormControllerManager({
    FuelFormatterService? formatter,
  }) : _formatter = formatter ?? FuelFormatterService();

  final FuelFormatterService _formatter;

  // Controllers
  late final TextEditingController litersController;
  late final TextEditingController pricePerLiterController;
  late final TextEditingController odometerController;
  late final TextEditingController gasStationController;
  late final TextEditingController gasStationBrandController;
  late final TextEditingController notesController;

  // FocusNodes
  late final FocusNode litersFocusNode;
  late final FocusNode pricePerLiterFocusNode;
  late final FocusNode odometerFocusNode;
  late final FocusNode gasStationFocusNode;
  late final FocusNode gasStationBrandFocusNode;
  late final FocusNode notesFocusNode;

  // Listener callbacks
  ControllerChangeCallback? _onLitersChanged;
  ControllerChangeCallback? _onPricePerLiterChanged;
  ControllerChangeCallback? _onOdometerChanged;
  ControllerChangeCallback? _onGasStationChanged;
  ControllerChangeCallback? _onGasStationBrandChanged;
  ControllerChangeCallback? _onNotesChanged;

  bool _isInitialized = false;

  /// Map of field names to their corresponding FocusNodes
  Map<String, FocusNode> get fieldFocusNodes => {
        'liters': litersFocusNode,
        'pricePerLiter': pricePerLiterFocusNode,
        'odometer': odometerFocusNode,
        'gasStationName': gasStationFocusNode,
        'gasStationBrand': gasStationBrandFocusNode,
        'notes': notesFocusNode,
      };

  /// Initializes all text controllers and focus nodes
  void initialize() {
    if (_isInitialized) return;

    litersController = TextEditingController();
    pricePerLiterController = TextEditingController();
    odometerController = TextEditingController();
    gasStationController = TextEditingController();
    gasStationBrandController = TextEditingController();
    notesController = TextEditingController();

    litersFocusNode = FocusNode();
    pricePerLiterFocusNode = FocusNode();
    odometerFocusNode = FocusNode();
    gasStationFocusNode = FocusNode();
    gasStationBrandFocusNode = FocusNode();
    notesFocusNode = FocusNode();

    _isInitialized = true;
  }

  /// Adds listeners to all controllers
  void addListeners({
    required ControllerChangeCallback onLitersChanged,
    required ControllerChangeCallback onPricePerLiterChanged,
    required ControllerChangeCallback onOdometerChanged,
    required ControllerChangeCallback onGasStationChanged,
    required ControllerChangeCallback onGasStationBrandChanged,
    required ControllerChangeCallback onNotesChanged,
  }) {
    _onLitersChanged = onLitersChanged;
    _onPricePerLiterChanged = onPricePerLiterChanged;
    _onOdometerChanged = onOdometerChanged;
    _onGasStationChanged = onGasStationChanged;
    _onGasStationBrandChanged = onGasStationBrandChanged;
    _onNotesChanged = onNotesChanged;

    litersController.addListener(_handleLitersChanged);
    pricePerLiterController.addListener(_handlePricePerLiterChanged);
    odometerController.addListener(_handleOdometerChanged);
    gasStationController.addListener(_handleGasStationChanged);
    gasStationBrandController.addListener(_handleGasStationBrandChanged);
    notesController.addListener(_handleNotesChanged);
  }

  void _handleLitersChanged() => _onLitersChanged?.call();
  void _handlePricePerLiterChanged() => _onPricePerLiterChanged?.call();
  void _handleOdometerChanged() => _onOdometerChanged?.call();
  void _handleGasStationChanged() => _onGasStationChanged?.call();
  void _handleGasStationBrandChanged() => _onGasStationBrandChanged?.call();
  void _handleNotesChanged() => _onNotesChanged?.call();

  /// Updates controllers with values from form model
  void updateFromModel(FuelFormModel formModel) {
    litersController.text = formModel.liters > 0
        ? _formatter.formatLiters(formModel.liters)
        : '';

    pricePerLiterController.text = formModel.pricePerLiter > 0
        ? _formatter.formatPricePerLiter(formModel.pricePerLiter)
        : '';

    odometerController.text = formModel.odometer > 0
        ? _formatter.formatOdometer(formModel.odometer)
        : '';

    gasStationController.text = formModel.gasStationName;
    gasStationBrandController.text = formModel.gasStationBrand;
    notesController.text = formModel.notes;
  }

  /// Clears all controller values
  void clearAll() {
    litersController.clear();
    pricePerLiterController.clear();
    odometerController.clear();
    gasStationController.clear();
    gasStationBrandController.clear();
    notesController.clear();
  }

  /// Disposes all controllers, focus nodes and removes listeners
  void dispose() {
    if (!_isInitialized) return;

    litersController.removeListener(_handleLitersChanged);
    pricePerLiterController.removeListener(_handlePricePerLiterChanged);
    odometerController.removeListener(_handleOdometerChanged);
    gasStationController.removeListener(_handleGasStationChanged);
    gasStationBrandController.removeListener(_handleGasStationBrandChanged);
    notesController.removeListener(_handleNotesChanged);

    litersController.dispose();
    pricePerLiterController.dispose();
    odometerController.dispose();
    gasStationController.dispose();
    gasStationBrandController.dispose();
    notesController.dispose();

    litersFocusNode.dispose();
    pricePerLiterFocusNode.dispose();
    odometerFocusNode.dispose();
    gasStationFocusNode.dispose();
    gasStationBrandFocusNode.dispose();
    notesFocusNode.dispose();

    _isInitialized = false;
  }
}
