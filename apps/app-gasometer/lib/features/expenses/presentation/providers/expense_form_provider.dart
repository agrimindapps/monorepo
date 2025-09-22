import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/services/input_sanitizer.dart';
import '../../../../core/services/receipt_image_service.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_validation_service.dart';
import '../models/expense_form_model.dart';

/// Provider reativo para gerenciar o estado do formulário de despesas
/// 
/// ARCHITECTURAL NOTE: This provider now uses dependency injection pattern
/// instead of direct provider coupling to avoid circular dependencies.
/// VehiclesProvider is accessed via BuildContext when needed.
class ExpenseFormProvider extends BaseProvider {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ExpenseFormatterService _formatter = ExpenseFormatterService();
  final ExpenseValidationService _validator = const ExpenseValidationService();
  final ReceiptImageService _receiptImageService;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Store context for accessing providers when needed
  BuildContext? _context;

  // Image management state
  String? _receiptImagePath;
  String? _receiptImageUrl;
  bool _isUploadingImage = false;
  String? _imageUploadError;

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

  ExpenseFormProvider({
    String? initialVehicleId, 
    String? userId,
    required ReceiptImageService receiptImageService,
  }) : _receiptImageService = receiptImageService,
       _formModel = ExpenseFormModel.initial(initialVehicleId ?? '', userId ?? '') {
    _initializeControllers();
  }

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  ExpenseFormModel get formModel => _formModel;
  bool get isInitialized => _isInitialized;
  
  // Image management getters
  String? get receiptImagePath => _receiptImagePath;
  String? get receiptImageUrl => _receiptImageUrl;
  bool get hasReceiptImage => _receiptImagePath != null || _receiptImageUrl != null;
  bool get isUploadingImage => _isUploadingImage;
  String? get imageUploadError => _imageUploadError;

  /// Sets the BuildContext for dependency injection access.
  /// This should be called when the provider is used in a widget.
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Safely access VehiclesProvider through dependency injection
  VehiclesProvider? get _vehiclesProvider {
    if (_context == null) return null;
    try {
      return _context!.read<VehiclesProvider>();
    } catch (e) {
      debugPrint('Warning: VehiclesProvider not available in context: $e');
      return null;
    }
  }
  bool get isUpdating => _isUpdating;
  
  @override
  bool get isLoading => super.isLoading || _isUploadingImage;

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
    // Safely access VehiclesProvider through dependency injection
    final vehiclesProvider = _vehiclesProvider;
    if (vehiclesProvider == null) {
      // If context not set, skip vehicle loading for now
      // This prevents null exceptions during initialization
      debugPrint('Warning: VehiclesProvider not available, skipping vehicle data loading');
      return;
    }

    await executeDataOperation(
      () => vehiclesProvider.getVehicleById(vehicleId),
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
          debugPrint('Warning: Vehicle not found for id: $vehicleId');
          // Don't throw here, just log the warning
          // Set a default odometer value when vehicle is not found
          _formModel = _formModel.copyWith(
            vehicle: null,
            odometer: 0.0,
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
        
        // Aplicar sanitização específica para descrições
        final sanitized = InputSanitizer.sanitizeDescription(descriptionController.text);
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
    // Aplicar sanitização específica para localizações
    final sanitized = InputSanitizer.sanitize(locationController.text);
    _updateLocation(sanitized);
  }

  void _onNotesChanged() {
    // Aplicar sanitização específica para observações
    final sanitized = InputSanitizer.sanitizeDescription(notesController.text);
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            ),
          ),
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

  // ===== IMAGE MANAGEMENT METHODS =====

  /// Captura imagem usando a câmera
  Future<void> captureReceiptImage() async {
    try {
      _imageUploadError = null;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      _imageUploadError = 'Erro ao capturar imagem: $e';
      notifyListeners();
    }
  }

  /// Seleciona imagem da galeria
  Future<void> selectReceiptImageFromGallery() async {
    try {
      _imageUploadError = null;
      notifyListeners();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        await _processReceiptImage(image.path);
      }
    } catch (e) {
      _imageUploadError = 'Erro ao selecionar imagem: $e';
      notifyListeners();
    }
  }

  /// Processa e faz upload da imagem do comprovante
  Future<void> _processReceiptImage(String imagePath) async {
    try {
      _isUploadingImage = true;
      _imageUploadError = null;
      notifyListeners();

      // Validar imagem
      final isValid = await _receiptImageService.isValidImage(imagePath);
      if (!isValid) {
        throw Exception('Arquivo de imagem inválido');
      }

      // Processar imagem (comprimir + upload se online)
      final result = await _receiptImageService.processExpenseReceiptImage(
        userId: _formModel.userId,
        expenseId: _generateTemporaryId(),
        imagePath: imagePath,
        compressImage: true,
        uploadToFirebase: true,
      );

      _receiptImagePath = result.localPath;
      _receiptImageUrl = result.downloadUrl;
      
      // Atualizar modelo do formulário
      _formModel = _formModel.copyWith(hasChanges: true);

      debugPrint('[EXPENSE FORM] Image processed successfully');
      debugPrint('[EXPENSE FORM] Local path: ${result.localPath}');
      debugPrint('[EXPENSE FORM] Download URL: ${result.downloadUrl}');

    } catch (e) {
      _imageUploadError = 'Erro ao processar imagem: $e';
      debugPrint('[EXPENSE FORM] Image processing error: $e');
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Remove imagem do comprovante
  Future<void> removeReceiptImage() async {
    try {
      if (_receiptImagePath != null || _receiptImageUrl != null) {
        await _receiptImageService.deleteReceiptImage(
          localPath: _receiptImagePath,
          downloadUrl: _receiptImageUrl,
        );
      }

      _receiptImagePath = null;
      _receiptImageUrl = null;
      _imageUploadError = null;
      _formModel = _formModel.copyWith(hasChanges: true);
      
      notifyListeners();
    } catch (e) {
      _imageUploadError = 'Erro ao remover imagem: $e';
      notifyListeners();
    }
  }

  /// Gera ID temporário para processar imagem antes do save
  String _generateTemporaryId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Sincroniza imagem local com Firebase (para casos offline)
  Future<void> syncImageToFirebase(String actualExpenseId) async {
    if (_receiptImagePath == null || _receiptImageUrl != null) {
      return; // Nada para sincronizar
    }

    try {
      _isUploadingImage = true;
      notifyListeners();

      final result = await _receiptImageService.processExpenseReceiptImage(
        userId: _formModel.userId,
        expenseId: actualExpenseId,
        imagePath: _receiptImagePath!,
        compressImage: false, // Já foi comprimida
        uploadToFirebase: true,
      );

      _receiptImageUrl = result.downloadUrl;
      
      debugPrint('[EXPENSE FORM] Image synced to Firebase: ${result.downloadUrl}');
      
    } catch (e) {
      debugPrint('[EXPENSE FORM] Failed to sync image: $e');
      // Não exibir erro para usuário, continua com imagem local
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  /// Limpa estado de imagem
  void _clearImageState() {
    _receiptImagePath = null;
    _receiptImageUrl = null;
    _imageUploadError = null;
    _isUploadingImage = false;
  }

  /// Limpa todos os campos do formulário
  void clearForm() {
    descriptionController.clear();
    amountController.clear();
    odometerController.clear();
    locationController.clear();
    notesController.clear();

    _clearImageState();
    _formModel = ExpenseFormModel.initial(_formModel.vehicleId, _formModel.userId);
    notifyListeners();
  }

  /// Reseta formulário para estado inicial
  void resetForm() {
    clearForm();
    _clearImageState();
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