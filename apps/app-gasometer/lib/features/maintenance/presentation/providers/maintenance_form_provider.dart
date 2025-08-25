import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/maintenance_constants.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../../domain/services/maintenance_validator_service.dart';
import '../models/maintenance_form_model.dart';

/// Provider reativo para gerenciar o estado do formulário de manutenção
class MaintenanceFormProvider extends ChangeNotifier {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MaintenanceFormatterService _formatter = MaintenanceFormatterService();
  final MaintenanceValidatorService _validator = MaintenanceValidatorService();
  final VehiclesProvider _vehiclesProvider;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers para campos de texto
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController workshopNameController = TextEditingController();
  final TextEditingController workshopPhoneController = TextEditingController();
  final TextEditingController workshopAddressController = TextEditingController();
  final TextEditingController nextOdometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Timers de debounce para otimização
  Timer? _costDebounceTimer;
  Timer? _odometerDebounceTimer;
  Timer? _titleDebounceTimer;
  Timer? _descriptionDebounceTimer;

  // Estado do formulário
  MaintenanceFormModel _formModel;
  bool _isInitialized = false;
  final bool _isUpdating = false;

  MaintenanceFormProvider(this._vehiclesProvider, {String? initialVehicleId, String? userId}) 
      : _formModel = MaintenanceFormModel.initial(initialVehicleId ?? '', userId ?? '') {
    _initializeControllers();
  }

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  MaintenanceFormModel get formModel => _formModel;
  bool get isInitialized => _isInitialized;
  bool get isUpdating => _isUpdating;

  void _initializeControllers() {
    // Adicionar listeners para reagir a mudanças nos campos
    titleController.addListener(_onTitleChanged);
    descriptionController.addListener(_onDescriptionChanged);
    costController.addListener(_onCostChanged);
    odometerController.addListener(_onOdometerChanged);
    workshopNameController.addListener(_onWorkshopNameChanged);
    workshopPhoneController.addListener(_onWorkshopPhoneChanged);
    workshopAddressController.addListener(_onWorkshopAddressChanged);
    nextOdometerController.addListener(_onNextOdometerChanged);
    notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    // Cancelar timers
    _costDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();
    _titleDebounceTimer?.cancel();
    _descriptionDebounceTimer?.cancel();

    // Dispose controllers
    titleController.dispose();
    descriptionController.dispose();
    costController.dispose();
    odometerController.dispose();
    workshopNameController.dispose();
    workshopPhoneController.dispose();
    workshopAddressController.dispose();
    nextOdometerController.dispose();
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

      _formModel = MaintenanceFormModel.initial(selectedVehicleId, userId ?? '');
      
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

  /// Inicializa com uma manutenção existente para edição
  Future<void> initializeWithMaintenance(MaintenanceEntity maintenance) async {
    try {
      _formModel = MaintenanceFormModel.fromMaintenanceEntity(maintenance);
      
      // Carregar dados do veículo
      await _loadVehicleData(maintenance.vehicleId);
      
      // Configurar campos com dados da manutenção
      _updateTextControllers();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao carregar manutenção: $e',
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
    titleController.text = _formModel.title;
    descriptionController.text = _formModel.description;
    
    costController.text = _formModel.cost > 0 
        ? _formatter.formatAmount(_formModel.cost)
        : '';
        
    odometerController.text = _formModel.odometer > 0
        ? _formatter.formatOdometer(_formModel.odometer)
        : '';

    workshopNameController.text = _formModel.workshopName;
    workshopPhoneController.text = _formModel.workshopPhone;
    workshopAddressController.text = _formModel.workshopAddress;
    
    nextOdometerController.text = _formModel.nextServiceOdometer != null
        ? _formatter.formatOdometer(_formModel.nextServiceOdometer!)
        : '';
        
    notesController.text = _formModel.notes;
  }

  // Event handlers para mudanças nos campos

  void _onTitleChanged() {
    _titleDebounceTimer?.cancel();
    _titleDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.titleDebounceMs),
      () {
        final sanitized = _formatter.sanitizeInput(titleController.text);
        _updateTitle(sanitized);
        
        // Sugerir tipo baseado no título se ainda não foi definido
        if (sanitized.isNotEmpty && _formModel.type == MaintenanceType.preventive) {
          final suggestedType = _validator.suggestTypeFromDescription(sanitized);
          if (suggestedType != MaintenanceType.preventive) {
            _updateType(suggestedType);
          }
        }
      },
    );
  }

  void _onDescriptionChanged() {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.descriptionDebounceMs),
      () {
        final sanitized = _formatter.sanitizeInput(descriptionController.text);
        _updateDescription(sanitized);
      },
    );
  }

  void _onCostChanged() {
    _costDebounceTimer?.cancel();
    _costDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.costDebounceMs),
      () {
        final value = _formatter.parseFormattedAmount(costController.text);
        _updateCost(value);
      },
    );
  }

  void _onOdometerChanged() {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.odometerDebounceMs),
      () {
        final value = _formatter.parseFormattedOdometer(odometerController.text);
        _updateOdometer(value);
      },
    );
  }

  void _onWorkshopNameChanged() {
    final sanitized = _formatter.sanitizeInput(workshopNameController.text);
    _updateWorkshopName(sanitized);
  }

  void _onWorkshopPhoneChanged() {
    final formatted = _formatter.formatPhone(workshopPhoneController.text);
    if (formatted != workshopPhoneController.text) {
      // Atualizar o campo com a formatação
      workshopPhoneController.value = workshopPhoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    _updateWorkshopPhone(formatted);
  }

  void _onWorkshopAddressChanged() {
    final sanitized = _formatter.sanitizeInput(workshopAddressController.text);
    _updateWorkshopAddress(sanitized);
  }

  void _onNextOdometerChanged() {
    final value = _formatter.parseFormattedOdometer(nextOdometerController.text);
    _updateNextServiceOdometer(value > 0 ? value : null);
  }

  void _onNotesChanged() {
    final sanitized = _formatter.sanitizeInput(notesController.text);
    _updateNotes(sanitized);
  }

  // Métodos para atualizar campos individuais

  void _updateTitle(String value) {
    if (_formModel.title == value) return;

    _formModel = _formModel.copyWith(
      title: value,
      hasChanges: true,
    ).clearFieldError('title');

    notifyListeners();
  }

  void _updateDescription(String value) {
    if (_formModel.description == value) return;

    _formModel = _formModel.copyWith(
      description: value,
      hasChanges: true,
    ).clearFieldError('description');

    notifyListeners();
  }

  void _updateCost(double value) {
    if (_formModel.cost == value) return;

    _formModel = _formModel.copyWith(
      cost: value,
      hasChanges: true,
    ).clearFieldError('cost');

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

  void _updateWorkshopName(String value) {
    if (_formModel.workshopName == value) return;

    _formModel = _formModel.copyWith(
      workshopName: value,
      hasChanges: true,
    ).clearFieldError('workshopName');

    notifyListeners();
  }

  void _updateWorkshopPhone(String value) {
    if (_formModel.workshopPhone == value) return;

    _formModel = _formModel.copyWith(
      workshopPhone: value,
      hasChanges: true,
    ).clearFieldError('workshopPhone');

    notifyListeners();
  }

  void _updateWorkshopAddress(String value) {
    if (_formModel.workshopAddress == value) return;

    _formModel = _formModel.copyWith(
      workshopAddress: value,
      hasChanges: true,
    ).clearFieldError('workshopAddress');

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

  /// Atualiza tipo de manutenção
  void updateType(MaintenanceType type) {
    _updateType(type);
  }

  void _updateType(MaintenanceType type) {
    if (_formModel.type == type) return;

    _formModel = _formModel.copyWith(
      type: type,
      hasChanges: true,
    ).clearFieldError('type');

    notifyListeners();
  }

  /// Atualiza status da manutenção
  void updateStatus(MaintenanceStatus status) {
    if (_formModel.status == status) return;

    _formModel = _formModel.copyWith(
      status: status,
      hasChanges: true,
    ).clearFieldError('status');

    notifyListeners();
  }

  /// Atualiza data do serviço
  void updateServiceDate(DateTime date) {
    if (_formModel.serviceDate == date) return;

    _formModel = _formModel.copyWith(
      serviceDate: date,
      hasChanges: true,
    ).clearFieldError('serviceDate');

    notifyListeners();
  }

  /// Atualiza data da próxima manutenção
  void updateNextServiceDate(DateTime? date) {
    if (_formModel.nextServiceDate == date) return;

    _formModel = _formModel.copyWith(
      nextServiceDate: date,
      hasChanges: true,
    ).clearFieldError('nextServiceDate');

    notifyListeners();
  }

  void _updateNextServiceOdometer(double? value) {
    if (_formModel.nextServiceOdometer == value) return;

    _formModel = _formModel.copyWith(
      nextServiceOdometer: value,
      hasChanges: true,
    ).clearFieldError('nextServiceOdometer');

    notifyListeners();
  }

  /// Adiciona foto
  Future<void> addPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: Implementar salvamento da imagem em local seguro
        final newPaths = List<String>.from(_formModel.photosPaths);
        newPaths.add(image.path);
        
        _formModel = _formModel.copyWith(
          photosPaths: newPaths,
          hasChanges: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao adicionar foto: $e',
      );
      notifyListeners();
    }
  }

  /// Remove foto
  void removePhoto(String photoPath) {
    final newPaths = List<String>.from(_formModel.photosPaths);
    newPaths.remove(photoPath);
    
    _formModel = _formModel.copyWith(
      photosPaths: newPaths,
      hasChanges: true,
    );
    notifyListeners();
  }

  /// Valida um campo específico
  String? validateField(String field, String? value) {
    switch (field) {
      case 'title':
        return _validator.validateTitle(value);
      case 'description':
        return _validator.validateDescription(value);
      case 'cost':
        return _validator.validateCost(value, type: _formModel.type);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: _formModel.vehicle?.currentOdometer,
        );
      case 'workshopName':
        return _validator.validateWorkshopName(value);
      case 'workshopPhone':
        return _validator.validatePhone(value);
      case 'workshopAddress':
        return _validator.validateAddress(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Valida todo o formulário
  bool validateForm() {
    final errors = _validator.validateCompleteForm(
      type: _formModel.type,
      title: titleController.text,
      description: descriptionController.text,
      cost: costController.text,
      odometer: odometerController.text,
      serviceDate: _formModel.serviceDate,
      workshopName: workshopNameController.text,
      workshopPhone: workshopPhoneController.text,
      workshopAddress: workshopAddressController.text,
      nextServiceDate: _formModel.nextServiceDate,
      nextServiceOdometer: nextOdometerController.text,
      notes: notesController.text,
      vehicle: _formModel.vehicle,
    );

    _formModel = _formModel.copyWith(errors: errors);
    notifyListeners();

    return errors.isEmpty;
  }

  /// Pickers para data e hora
  Future<void> pickServiceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _formModel.serviceDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * MaintenanceConstants.maxYearsBack)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (date != null) {
      // Manter hora atual
      final currentTime = TimeOfDay.fromDateTime(_formModel.serviceDate);
      final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        currentTime.hour,
        currentTime.minute,
      );
      updateServiceDate(newDateTime);
    }
  }

  Future<void> pickServiceTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_formModel.serviceDate),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      final newDateTime = DateTime(
        _formModel.serviceDate.year,
        _formModel.serviceDate.month,
        _formModel.serviceDate.day,
        time.hour,
        time.minute,
      );
      updateServiceDate(newDateTime);
    }
  }

  Future<void> pickNextServiceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _formModel.nextServiceDate ?? _formModel.serviceDate.add(const Duration(days: 180)),
      firstDate: _formModel.serviceDate,
      lastDate: _formModel.serviceDate.add(const Duration(days: 365 * MaintenanceConstants.maxYearsForward)),
      locale: const Locale('pt', 'BR'),
    );

    if (date != null) {
      updateNextServiceDate(date);
    }
  }

  /// Limpa todos os campos do formulário
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    costController.clear();
    odometerController.clear();
    workshopNameController.clear();
    workshopPhoneController.clear();
    workshopAddressController.clear();
    nextOdometerController.clear();
    notesController.clear();

    _formModel = MaintenanceFormModel.initial(_formModel.vehicleId, _formModel.userId);
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

  /// Limpa erro atual
  void clearError() {
    _formModel = _formModel.copyWith(
      lastError: null,
      clearLastError: true,
    );
    notifyListeners();
  }
}