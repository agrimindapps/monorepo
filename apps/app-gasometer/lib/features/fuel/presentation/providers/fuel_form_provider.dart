import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/presentation/forms/base_form_page.dart';
import '../../../../core/services/input_sanitizer.dart';
import '../../../../core/services/receipt_image_service.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../../domain/services/fuel_validator_service.dart';
import '../models/fuel_form_model.dart';

/// Provider reativo para gerenciar o estado do formulário de abastecimento
/// 
/// ARCHITECTURAL NOTE: This provider now uses dependency injection pattern
/// instead of direct provider coupling to avoid circular dependencies.
/// VehiclesProvider is accessed via BuildContext when needed.
class FuelFormProvider extends ChangeNotifier implements IFormProvider {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FuelFormatterService _formatter = FuelFormatterService();
  final FuelValidatorService _validator = FuelValidatorService();
  final ReceiptImageService _receiptImageService;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Store context for accessing providers when needed
  BuildContext? _context;
  
  // For odometer validation
  double? _lastOdometerReading;

  // Image management state
  String? _receiptImagePath;
  String? _receiptImageUrl;
  bool _isUploadingImage = false;
  String? _imageUploadError;

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
  bool _isLoading = false;
  String? _lastError;

  FuelFormProvider({
    String? initialVehicleId, 
    String? userId,
    required ReceiptImageService receiptImageService,
  }) : _receiptImageService = receiptImageService,
       _formModel = FuelFormModel.initial(initialVehicleId ?? '', userId ?? '') {
    _initializeControllers();
  }

  // Getters
  @override
  GlobalKey<FormState>? get formKey => _formKey;
  FuelFormModel get formModel => _formModel;
  bool get isInitialized => _isInitialized;
  bool get isCalculating => _isCalculating;
  double? get lastOdometerReading => _lastOdometerReading;
  
  // Image management getters
  String? get receiptImagePath => _receiptImagePath;
  String? get receiptImageUrl => _receiptImageUrl;
  bool get hasReceiptImage => _receiptImagePath != null || _receiptImageUrl != null;
  bool get isUploadingImage => _isUploadingImage;
  String? get imageUploadError => _imageUploadError;
  
  // IFormProvider implementation
  @override
  bool get isLoading => _isLoading || _isUploadingImage;
  
  @override
  String? get lastError => _lastError;
  
  @override
  bool get canSubmit => 
      !_isLoading && 
      litersController.text.isNotEmpty && 
      pricePerLiterController.text.isNotEmpty &&
      odometerController.text.isNotEmpty;

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
    // Cancelar timers de forma segura
    _litersDebounceTimer?.cancel();
    _litersDebounceTimer = null;
    _priceDebounceTimer?.cancel();
    _priceDebounceTimer = null;
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = null;

    // Remove listeners primeiro
    litersController.removeListener(_onLitersChanged);
    pricePerLiterController.removeListener(_onPricePerLiterChanged);
    odometerController.removeListener(_onOdometerChanged);
    gasStationController.removeListener(_onGasStationChanged);
    gasStationBrandController.removeListener(_onGasStationBrandChanged);
    notesController.removeListener(_onNotesChanged);

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
      // Delay notification to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao inicializar: $e',
        isLoading: false,
      );
      // Delay notification to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Carrega dados do veículo selecionado
  Future<void> _loadVehicleData(String vehicleId) async {
    try {
      _formModel = _formModel.copyWith(isLoading: true);
      // Delay notification to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Safely access VehiclesProvider through dependency injection
      final vehiclesProvider = _vehiclesProvider;
      if (vehiclesProvider == null) {
        throw Exception('VehiclesProvider não disponível. Certifique-se de chamar setContext() primeiro.');
      }

      final vehicle = await vehiclesProvider.getVehicleById(vehicleId);
      
      if (vehicle != null) {
        // Set the last odometer reading from the vehicle's current odometer
        // This could be enhanced to fetch the actual last fuel record's odometer
        _lastOdometerReading = vehicle.currentOdometer;
        
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
      
      // Notify after successful completion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao carregar veículo: $e',
        isLoading: false,
      );
      
      // Notify after error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
    // Aplicar sanitização específica para nomes de postos
    final sanitized = InputSanitizer.sanitizeName(gasStationController.text);
    _updateGasStationName(sanitized);
  }

  void _onGasStationBrandChanged() {
    // Aplicar sanitização específica para marcas de postos  
    final sanitized = InputSanitizer.sanitizeName(gasStationBrandController.text);
    _updateGasStationBrand(sanitized);
  }

  void _onNotesChanged() {
    // Aplicar sanitização específica para descrições/observações
    final sanitized = InputSanitizer.sanitizeDescription(notesController.text);
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
          lastRecordOdometer: _lastOdometerReading,
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
  @override
  bool validateForm() {
    debugPrint('[FUEL VALIDATION] Starting form validation...');
    debugPrint('[FUEL VALIDATION] liters: "${litersController.text}"');
    debugPrint('[FUEL VALIDATION] pricePerLiter: "${pricePerLiterController.text}"');
    debugPrint('[FUEL VALIDATION] odometer: "${odometerController.text}"');
    debugPrint('[FUEL VALIDATION] fuelType: ${_formModel.fuelType}');
    debugPrint('[FUEL VALIDATION] date: ${_formModel.date}');
    debugPrint('[FUEL VALIDATION] gasStationName: "${gasStationController.text}"');
    debugPrint('[FUEL VALIDATION] notes: "${notesController.text}"');
    debugPrint('[FUEL VALIDATION] vehicle: ${_formModel.vehicle?.displayName ?? "null"}');
    debugPrint('[FUEL VALIDATION] lastRecordOdometer: $_lastOdometerReading');
    
    final errors = _validator.validateCompleteForm(
      liters: litersController.text,
      pricePerLiter: pricePerLiterController.text,
      odometer: odometerController.text,
      fuelType: _formModel.fuelType,
      date: _formModel.date,
      gasStationName: gasStationController.text,
      notes: notesController.text,
      vehicle: _formModel.vehicle,
      lastRecordOdometer: _lastOdometerReading,
    );

    debugPrint('[FUEL VALIDATION] Validation errors: $errors');
    debugPrint('[FUEL VALIDATION] Form is ${errors.isEmpty ? "VALID" : "INVALID"}');

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

    _clearImageState();
    _formModel = FuelFormModel.initial(_formModel.vehicleId, _formModel.userId);
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

  /// Carrega dados de um registro existente para edição
  Future<void> loadFromFuelRecord(FuelRecordEntity record) async {
    try {
      // Atualizar o modelo do formulário com dados do registro
      _formModel = FuelFormModel.fromFuelRecord(record);
      
      // Carregar dados do veículo associado
      await _loadVehicleData(record.vehicleId);
      
      // Atualizar os controllers com os valores do registro
      _updateTextControllers();
      
      // Carregar imagem se existir
      // Note: FuelRecordEntity pode precisar ser atualizada para incluir campos de imagem
      
      notifyListeners();
    } catch (e) {
      _formModel = _formModel.copyWith(
        lastError: 'Erro ao carregar registro: $e',
        isLoading: false,
      );
      notifyListeners();
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

      // Verificar se precisa de compressão
      final needsCompression = await _receiptImageService.needsCompression(imagePath);
      
      if (needsCompression) {
        debugPrint('[FUEL FORM] Compressing image: $imagePath');
      }

      // Processar imagem (comprimir + upload se online)
      final result = await _receiptImageService.processFuelReceiptImage(
        userId: _formModel.userId,
        fuelSupplyId: _generateTemporaryId(), // Will be replaced with actual ID on save
        imagePath: imagePath,
        compressImage: true,
        uploadToFirebase: true, // Upload immediately if online
      );

      _receiptImagePath = result.localPath;
      _receiptImageUrl = result.downloadUrl;
      
      // Atualizar modelo do formulário
      _formModel = _formModel.copyWith(hasChanges: true);

      debugPrint('[FUEL FORM] Image processed successfully');
      debugPrint('[FUEL FORM] Local path: ${result.localPath}');
      debugPrint('[FUEL FORM] Download URL: ${result.downloadUrl}');
      debugPrint('[FUEL FORM] Was compressed: ${result.wasCompressed}');

      if (result.wasCompressed && result.compressionStats.isNotEmpty) {
        final stats = result.compressionStats;
        debugPrint('[FUEL FORM] Compression saved: ${stats['spaceSavedPercent']}%');
      }

    } catch (e) {
      _imageUploadError = 'Erro ao processar imagem: $e';
      debugPrint('[FUEL FORM] Image processing error: $e');
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

  /// Obtém estatísticas da imagem atual
  Future<Map<String, dynamic>> getImageStats() async {
    if (_receiptImagePath == null) return {};
    
    try {
      final size = await _receiptImageService.getImageSize(_receiptImagePath!);
      final dimensions = await _receiptImageService.getImageDimensions(_receiptImagePath!);
      
      return {
        'size': size,
        'dimensions': dimensions,
        'hasRemoteUrl': _receiptImageUrl != null,
        'isUploaded': _receiptImageUrl != null,
      };
    } catch (e) {
      return {};
    }
  }

  /// Sincroniza imagem local com Firebase (para casos offline)
  Future<void> syncImageToFirebase(String actualFuelSupplyId) async {
    if (_receiptImagePath == null || _receiptImageUrl != null) {
      return; // Nada para sincronizar
    }

    try {
      _isUploadingImage = true;
      notifyListeners();

      final result = await _receiptImageService.processFuelReceiptImage(
        userId: _formModel.userId,
        fuelSupplyId: actualFuelSupplyId,
        imagePath: _receiptImagePath!,
        compressImage: false, // Já foi comprimida
        uploadToFirebase: true,
      );

      _receiptImageUrl = result.downloadUrl;
      
      debugPrint('[FUEL FORM] Image synced to Firebase: $result.downloadUrl');
      
    } catch (e) {
      debugPrint('[FUEL FORM] Failed to sync image: $e');
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
}