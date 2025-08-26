import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../models/expense_form_model.dart';

/// Provider reativo para gerenciar o estado do formulário de despesas
class ExpenseFormProvider extends BaseProvider {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ExpenseFormatterService _formatter = ExpenseFormatterService();
  final ExpenseValidationService _validator = const ExpenseValidationService();
  final VehiclesProvider _vehiclesProvider;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers para campos de texto
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Timers de debounce para otimização
  Timer? _amountDebounceTimer;
  Timer? _odometerDebounceTimer;
  Timer? _descriptionDebounceTimer;

  // Estado do formulário
  ExpenseFormModel _formModel;
  bool _isInitialized = false;
  final bool _isUpdating = false;

  ExpenseFormProvider(this._vehiclesProvider, {String? initialVehicleId, String? userId}) 
      : _formModel = ExpenseFormModel.initial(initialVehicleId ?? '', userId ?? '') {
    _initializeControllers();
  }

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  ExpenseFormModel get formModel => _formModel;
  bool get isInitialized => _isInitialized;
  bool get isUpdating => _isUpdating;

  void _initializeControllers() {
    // Adicionar listeners para reagir a mudanças nos campos
    descriptionController.addListener(_onDescriptionChanged);
    amountController.addListener(_onAmountChanged);
    odometerController.addListener(_onOdometerChanged);
    locationController.addListener(_onLocationChanged);
    notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    // Cancelar timers de forma segura
    _amountDebounceTimer?.cancel();
    _amountDebounceTimer = null;
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = null;
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = null;

    // Remover listeners antes do dispose para evitar callbacks órfãos
    descriptionController.removeListener(_onDescriptionChanged);
    amountController.removeListener(_onAmountChanged);
    odometerController.removeListener(_onOdometerChanged);
    locationController.removeListener(_onLocationChanged);
    notesController.removeListener(_onNotesChanged);

    // Dispose controllers
    descriptionController.dispose();
    amountController.dispose();
    odometerController.dispose();
    locationController.dispose();
    notesController.dispose();

    super.dispose();
  }

  /// Inicializa o formulário com dados do veículo selecionado
  Future<void> initialize({String? vehicleId, String? userId}) async {
    await executeOperation(
      () async {
        final selectedVehicleId = vehicleId ?? _formModel.vehicleId;
        
        if (selectedVehicleId.isEmpty) {
          throw const BusinessLogicError(
            message: 'No vehicle selected for expense form',
            userFriendlyMessage: 'Nenhum veículo selecionado',
          );
        }

        _formModel = ExpenseFormModel.initial(selectedVehicleId, userId ?? '');
        
        // Carregar dados do veículo
        await _loadVehicleData(selectedVehicleId);
        
        // Configurar estado inicial dos campos
        _updateTextControllers();
        
        _isInitialized = true;
      },
      operationName: 'initialize',
      parameters: {
        'vehicleId': vehicleId,
        'userId': userId,
      },
    );
  }

  /// Inicializa com uma despesa existente para edição
  Future<void> initializeWithExpense(ExpenseEntity expense) async {
    await executeOperation(
      () async {
        _formModel = ExpenseFormModel.fromExpenseEntity(expense);
        
        // Carregar dados do veículo
        await _loadVehicleData(expense.vehicleId);
        
        // Configurar campos com dados da despesa
        _updateTextControllers();
        
        _isInitialized = true;
      },
      operationName: 'initializeWithExpense',
      parameters: {
        'expenseId': expense.id,
        'vehicleId': expense.vehicleId,
      },
    );
  }

  /// Carrega dados do veículo selecionado
  Future<void> _loadVehicleData(String vehicleId) async {
    final vehicle = await executeDataOperation(
      () => _vehiclesProvider.getVehicleById(vehicleId),
      operationName: '_loadVehicleData',
      parameters: {'vehicleId': vehicleId},
      showLoading: false,
      onSuccess: (vehicle) {
        if (vehicle != null) {
          _formModel = _formModel.copyWith(
            vehicle: vehicle,
            odometer: vehicle.currentOdometer,
          );
        } else {
          throw const VehicleNotFoundError(
            technicalDetails: 'Vehicle data not found in provider',
          );
        }
      },
    );
  }

  /// Atualiza controllers com valores do modelo
  void _updateTextControllers() {
    descriptionController.text = _formModel.description;
    
    amountController.text = _formModel.amount > 0 
        ? _formatter.formatAmount(_formModel.amount)
        : '';
        
    odometerController.text = _formModel.odometer > 0
        ? _formatter.formatOdometer(_formModel.odometer)
        : '';
        
    locationController.text = _formModel.location;
    notesController.text = _formModel.notes;
  }

  // Event handlers para mudanças nos campos
  void _onDescriptionChanged() {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.descriptionDebounceMs),
      () {
        // Verificar se o provider ainda está ativo
        if (_descriptionDebounceTimer == null) return;
        
        final sanitized = _formatter.sanitizeInput(descriptionController.text);
        _updateDescription(sanitized);
        
        // Sugerir categoria baseada na descrição
        if (sanitized.isNotEmpty && _formModel.expenseType == ExpenseType.other) {
          final suggestedType = _validator.suggestCategoryFromDescription(sanitized);
          if (suggestedType != ExpenseType.other) {
            _updateExpenseType(suggestedType);
          }
        }
      },
    );
  }

  void _onAmountChanged() {
    _amountDebounceTimer?.cancel();
    _amountDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.amountDebounceMs),
      () {
        // Verificar se o provider ainda está ativo
        if (_amountDebounceTimer == null) return;
        
        final value = _formatter.parseFormattedAmount(amountController.text);
        _updateAmount(value);
      },
    );
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.odometerDebounceMs),
      () {
        // Verificar se o provider ainda está ativo
        if (_odometerDebounceTimer == null) return;
        
        final value = _formatter.parseFormattedOdometer(odometerController.text);
        _updateOdometer(value);
      },
    );
  }

  void _onLocationChanged() {
    final sanitized = _formatter.sanitizeInput(locationController.text);
    _updateLocation(sanitized);
  }

  void _onNotesChanged() {
    final sanitized = _formatter.sanitizeInput(notesController.text);
    _updateNotes(sanitized);
  }

  // Métodos para atualizar campos individuais
  void _updateDescription(String value) {
    if (_formModel.description == value) return;

    _formModel = _formModel.copyWith(
      description: value,
      hasChanges: true,
    ).clearFieldError('description');

    notifyListeners();
  }

  void _updateAmount(double value) {
    if (_formModel.amount == value) return;

    _formModel = _formModel.copyWith(
      amount: value,
      hasChanges: true,
    ).clearFieldError('amount');

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

  void _updateLocation(String value) {
    if (_formModel.location == value) return;

    _formModel = _formModel.copyWith(
      location: value,
      hasChanges: true,
    ).clearFieldError('location');

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

  /// Atualiza tipo de despesa
  void updateExpenseType(ExpenseType expenseType) {
    _updateExpenseType(expenseType);
  }

  void _updateExpenseType(ExpenseType expenseType) {
    if (_formModel.expenseType == expenseType) return;

    _formModel = _formModel.copyWith(
      expenseType: expenseType,
      hasChanges: true,
    ).clearFieldError('expenseType');

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

  /// Adiciona foto do comprovante
  Future<void> addReceiptImage() async {
    await executeDataOperation(
      () async {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: ExpenseConstants.imageMaxWidth.toDouble(),
          maxHeight: ExpenseConstants.imageMaxHeight.toDouble(),
          imageQuality: ExpenseConstants.imageQuality,
        );

        if (image != null) {
          // TODO: Implementar salvamento da imagem em local seguro
          _formModel = _formModel.copyWith(
            receiptImagePath: image.path,
            hasChanges: true,
          );
          notifyListeners();
          return image.path;
        }
        return null;
      },
      operationName: 'addReceiptImage',
      showLoading: false,
    );
  }

  /// Remove foto do comprovante
  void removeReceiptImage() {
    if (_formModel.receiptImagePath == null) return;

    _formModel = _formModel.copyWith(
      clearReceiptImage: true,
      hasChanges: true,
    );
    notifyListeners();
  }

  /// Valida um campo específico
  String? validateField(String field, String? value) {
    switch (field) {
      case 'description':
        return _validator.validateDescription(value);
      case 'amount':
        return _validator.validateAmount(value, expenseType: _formModel.expenseType);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: _formModel.vehicle?.currentOdometer,
        );
      case 'location':
        return _validator.validateLocation(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Valida todo o formulário
  bool validateForm() {
    final errors = _validator.validateCompleteForm(
      expenseType: _formModel.expenseType,
      description: descriptionController.text,
      amount: amountController.text,
      odometer: odometerController.text,
      date: _formModel.date,
      location: locationController.text,
      notes: notesController.text,
      vehicle: _formModel.vehicle,
    );

    _formModel = _formModel.copyWith(errors: errors);
    notifyListeners();

    return errors.isEmpty;
  }

  /// Pickers para data e hora
  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _formModel.date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * ExpenseConstants.maxYearsBack)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (date != null) {
      // Manter hora atual
      final currentTime = TimeOfDay.fromDateTime(_formModel.date);
      final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      );
      updateDate(newDateTime);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_formModel.date),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      final newDateTime = DateTime(
        _formModel.date.year,
        _formModel.date.month,
        _formModel.date.day,
        time.hour,
        time.minute,
      );
      updateDate(newDateTime);
    }
  }

  /// Limpa todos os campos do formulário
  void clearForm() {
    descriptionController.clear();
    amountController.clear();
    odometerController.clear();
    locationController.clear();
    notesController.clear();

    _formModel = ExpenseFormModel.initial(_formModel.vehicleId, _formModel.userId);
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

  /// Obtém arquivo da imagem do comprovante
  File? get receiptImageFile {
    if (_formModel.receiptImagePath == null) return null;
    return File(_formModel.receiptImagePath!);
  }

  /// Verifica se tem imagem do comprovante
  bool get hasReceiptImage => _formModel.hasReceipt;

  /// Limpa os erros do formulário e provider
  void clearFormErrors() {
    clearError(); // BaseProvider method
    _formModel = _formModel.copyWith(
      lastError: null,
      errors: const {},
    );
    notifyListeners();
  }
}