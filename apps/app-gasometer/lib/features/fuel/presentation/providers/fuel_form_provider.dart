import 'dart:async';

import 'package:flutter/material.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../../domain/services/fuel_validator_service.dart';
import '../models/fuel_form_model.dart';

/// Provider reativo para gerenciar o estado do formulário de abastecimento
class FuelFormProvider extends ChangeNotifier {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FuelFormatterService _formatter = FuelFormatterService();
  final FuelValidatorService _validator = FuelValidatorService();
  final VehiclesProvider _vehiclesProvider;

  // Controllers para campos de texto
  final TextEditingController litersController = TextEditingController();
  final TextEditingController pricePerLiterController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController gasStationController = TextEditingController();
  final TextEditingController gasStationBrandController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Timers de debounce para otimização
  Timer? _litersDebounceTimer;
  Timer? _priceDebounceTimer;
  Timer? _odometerDebounceTimer;

  // Estado do formulário
  FuelFormModel _formModel;
  bool _isInitialized = false;
  bool _isCalculating = false;

  FuelFormProvider(this._vehiclesProvider, {String? initialVehicleId, String? userId}) 
      : _formModel = FuelFormModel.initial(initialVehicleId ?? '', userId ?? '') {
    _initializeControllers();
  }

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  FuelFormModel get formModel => _formModel;
  bool get isInitialized => _isInitialized;
  bool get isCalculating => _isCalculating;

  void _initializeControllers() {
    // Adicionar listeners para reagir a mudanças nos campos
    litersController.addListener(_onLitersChanged);
    pricePerLiterController.addListener(_onPricePerLiterChanged);
    odometerController.addListener(_onOdometerChanged);
    gasStationController.addListener(_onGasStationChanged);
    gasStationBrandController.addListener(_onGasStationBrandChanged);
    notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    // Cancelar timers
    _litersDebounceTimer?.cancel();
    _priceDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();

    // Dispose controllers
    litersController.dispose();
    pricePerLiterController.dispose();
    odometerController.dispose();
    gasStationController.dispose();
    gasStationBrandController.dispose();
    notesController.dispose();

    super.dispose();
  }

  /// Inicializa o formulário com dados do veículo selecionado
  Future<void> initialize({String? vehicleId, String? userId}) async {
    try {
      final selectedVehicleId = vehicleId ?? _formModel.vehicleId;
      
      if (selectedVehicleId.isEmpty) {
        throw Exception('Nenhum veículo selecionado');
      }

      _formModel = FuelFormModel.initial(selectedVehicleId, userId ?? '');
      
      // Carregar dados do veículo
      await _loadVehicleData(selectedVehicleId);
      
      // Configurar estado inicial dos campos
      _updateTextControllers();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao inicializar: $e',
        isLoading: false,
      );
      notifyListeners();
    }
  }

  /// Carrega dados do veículo selecionado
  Future<void> _loadVehicleData(String vehicleId) async {
    try {
      _formModel = _formModel.copyWith(isLoading: true);
      notifyListeners();

      final vehicle = await _vehiclesProvider.getVehicleById(vehicleId);
      
      if (vehicle != null) {
        _formModel = _formModel.copyWith(
          vehicle: vehicle,
          odometer: vehicle.currentOdometer,
          fuelType: vehicle.supportedFuels.isNotEmpty 
              ? vehicle.supportedFuels.first 
              : FuelType.gasoline,
          isLoading: false,
        );
      } else {
        throw Exception('Veículo não encontrado');
      }
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao carregar veículo: $e',
        isLoading: false,
      );
    }
  }

  /// Atualiza controllers com valores do modelo
  void _updateTextControllers() {
    litersController.text = _formModel.liters > 0 
        ? _formatter.formatLiters(_formModel.liters)
        : '';
        
    pricePerLiterController.text = _formModel.pricePerLiter > 0
        ? _formatter.formatPricePerLiter(_formModel.pricePerLiter)
        : '';
        
    odometerController.text = _formModel.odometer > 0
        ? _formatter.formatOdometer(_formModel.odometer)
        : '';
        
    gasStationController.text = _formModel.gasStationName;
    gasStationBrandController.text = _formModel.gasStationBrand;
    notesController.text = _formModel.notes;
  }

  // Event handlers para mudanças nos campos
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
        final value = _formatter.parseFormattedValue(pricePerLiterController.text);
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
    final sanitized = _formatter.sanitizeInput(gasStationController.text);
    _updateGasStationName(sanitized);
  }

  void _onGasStationBrandChanged() {
    final sanitized = _formatter.sanitizeInput(gasStationBrandController.text);
    _updateGasStationBrand(sanitized);
  }

  void _onNotesChanged() {
    final sanitized = _formatter.sanitizeInput(notesController.text);
    _updateNotes(sanitized);
  }

  // Métodos para atualizar campos individuais
  void _updateLiters(double value) {
    if (_formModel.liters == value) return;

    _formModel = _formModel.copyWith(
      liters: value,
      hasChanges: true,
    ).clearFieldError('liters');

    _calculateTotalPrice();
    notifyListeners();
  }

  void _updatePricePerLiter(double value) {
    if (_formModel.pricePerLiter == value) return;

    _formModel = _formModel.copyWith(
      pricePerLiter: value,
      hasChanges: true,
    ).clearFieldError('pricePerLiter');

    _calculateTotalPrice();
    notifyListeners();
  }

  void _updateOdometer(double value) {
    if (_formModel.odometer == value) return;

    _formModel = _formModel.copyWith(
      odometer: value,
      hasChanges: true,
    ).clearFieldError('odometer');

    notifyListeners();
  }

  void _updateGasStationName(String value) {
    if (_formModel.gasStationName == value) return;

    _formModel = _formModel.copyWith(
      gasStationName: value,
      hasChanges: true,
    ).clearFieldError('gasStationName');

    notifyListeners();
  }

  void _updateGasStationBrand(String value) {
    if (_formModel.gasStationBrand == value) return;

    _formModel = _formModel.copyWith(
      gasStationBrand: value,
      hasChanges: true,
    ).clearFieldError('gasStationBrand');

    notifyListeners();
  }

  void _updateNotes(String value) {
    if (_formModel.notes == value) return;

    _formModel = _formModel.copyWith(
      notes: value,
      hasChanges: true,
    ).clearFieldError('notes');

    notifyListeners();
  }

  /// Atualiza tipo de combustível
  void updateFuelType(FuelType fuelType) {
    if (_formModel.fuelType == fuelType) return;

    _formModel = _formModel.copyWith(
      fuelType: fuelType,
      hasChanges: true,
    ).clearFieldError('fuelType');

    notifyListeners();
  }

  /// Atualiza data
  void updateDate(DateTime date) {
    if (_formModel.date == date) return;

    _formModel = _formModel.copyWith(
      date: date,
      hasChanges: true,
    ).clearFieldError('date');

    notifyListeners();
  }

  /// Atualiza status de tanque cheio
  void updateFullTank(bool fullTank) {
    if (_formModel.fullTank == fullTank) return;

    _formModel = _formModel.copyWith(
      fullTank: fullTank,
      hasChanges: true,
    );

    notifyListeners();
  }

  /// Calcula valor total com base em litros e preço por litro
  void _calculateTotalPrice() {
    if (_isCalculating) return;

    _isCalculating = true;
    
    final total = _validator.calculateTotalPrice(
      _formModel.liters,
      _formModel.pricePerLiter,
    );

    _formModel = _formModel.copyWith(totalPrice: total);
    _isCalculating = false;
  }

  /// Valida um campo específico
  String? validateField(String field, String? value) {
    switch (field) {
      case 'liters':
        return _validator.validateLiters(value, tankCapacity: _formModel.vehicle?.tankCapacity);
      case 'pricePerLiter':
        return _validator.validatePricePerLiter(value);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: _formModel.vehicle?.currentOdometer,
        );
      case 'gasStationName':
        return _validator.validateGasStationName(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Valida todo o formulário
  bool validateForm() {
    final errors = _validator.validateCompleteForm(
      liters: litersController.text,
      pricePerLiter: pricePerLiterController.text,
      odometer: odometerController.text,
      fuelType: _formModel.fuelType,
      date: _formModel.date,
      gasStationName: gasStationController.text,
      notes: notesController.text,
      vehicle: _formModel.vehicle,
    );

    _formModel = _formModel.copyWith(errors: errors);
    notifyListeners();

    return errors.isEmpty;
  }

  /// Limpa todos os campos do formulário
  void clearForm() {
    litersController.clear();
    pricePerLiterController.clear();
    odometerController.clear();
    gasStationController.clear();
    gasStationBrandController.clear();
    notesController.clear();

    _formModel = FuelFormModel.initial(_formModel.vehicleId, _formModel.userId);
    notifyListeners();
  }

  /// Reseta formulário para estado inicial
  void resetForm() {
    clearForm();
    _formModel = _formModel.copyWith(
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
    notifyListeners();
  }
}