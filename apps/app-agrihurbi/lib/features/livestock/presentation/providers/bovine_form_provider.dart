import 'package:flutter/material.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/services/bovine_form_service.dart';

/// Provider especializado para gerenciar o estado do formulário de bovino
/// 
/// Responsabilidades:
/// - Gerenciar controllers de forma otimizada
/// - Controlar estado dos campos do formulário
/// - Detectar mudanças não salvas
/// - Validação em tempo real
/// - Memory management dos controllers
class BovineFormProvider extends ChangeNotifier {
  final BovineFormService _formService;

  BovineFormProvider(_formService);

  // =====================================================================
  // CONTROLLERS POOL - Reutilização otimizada
  // =====================================================================
  
  static final Map<String, TextEditingController> _controllerPool = {};
  
  TextEditingController _getController(String key) {
    return _controllerPool.putIfAbsent(key, () => TextEditingController());
  }

  void _returnController(String key) {
    final controller = _controllerPool[key];
    controller?.clear();
    // Mantém na pool para reutilização
  }

  // Controllers principais
  late final TextEditingController _commonNameController = _getController('commonName');
  late final TextEditingController _registrationIdController = _getController('registrationId');
  late final TextEditingController _breedController = _getController('breed');
  late final TextEditingController _originCountryController = _getController('originCountry');
  late final TextEditingController _animalTypeController = _getController('animalType');
  late final TextEditingController _originController = _getController('origin');
  late final TextEditingController _characteristicsController = _getController('characteristics');
  late final TextEditingController _purposeController = _getController('purpose');
  late final TextEditingController _tagsController = _getController('tags');

  // Getters para controllers
  TextEditingController get commonNameController => _commonNameController;
  TextEditingController get registrationIdController => _registrationIdController;
  TextEditingController get breedController => _breedController;
  TextEditingController get originCountryController => _originCountryController;
  TextEditingController get animalTypeController => _animalTypeController;
  TextEditingController get originController => _originController;
  TextEditingController get characteristicsController => _characteristicsController;
  TextEditingController get purposeController => _purposeController;
  TextEditingController get tagsController => _tagsController;

  // =====================================================================
  // FORM STATE
  // =====================================================================

  BovineAptitude? _selectedAptitude;
  BreedingSystem? _selectedBreedingSystem;
  List<String> _selectedTags = [];
  bool _isActive = true;
  bool _isInitialized = false;
  bool _hasUnsavedChanges = false;
  BovineFormData? _originalData;

  // Getters para estado
  BovineAptitude? get selectedAptitude => _selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => _selectedBreedingSystem;
  List<String> get selectedTags => List.unmodifiable(_selectedTags);
  bool get isActive => _isActive;
  bool get isInitialized => _isInitialized;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  // =====================================================================
  // INITIALIZATION
  // =====================================================================

  /// Inicializa o formulário para criação
  void initializeForCreation() {
    _clearForm();
    _isActive = true;
    _selectedAptitude = BovineAptitude.beef;
    _selectedBreedingSystem = BreedingSystem.extensive;
    _isInitialized = true;
    _hasUnsavedChanges = false;
    _originalData = _getCurrentFormData();
    _setupListeners();
    notifyListeners();
  }

  /// Inicializa o formulário para edição
  void initializeForEditing(BovineEntity bovine) {
    _populateForm(bovine);
    _isInitialized = true;
    _hasUnsavedChanges = false;
    _originalData = _getCurrentFormData();
    _setupListeners();
    notifyListeners();
  }

  void _clearForm() {
    _commonNameController.clear();
    _registrationIdController.clear();
    _breedController.clear();
    _originCountryController.clear();
    _animalTypeController.clear();
    _originController.clear();
    _characteristicsController.clear();
    _purposeController.clear();
    _tagsController.clear();
    
    _selectedAptitude = null;
    _selectedBreedingSystem = null;
    _selectedTags = [];
    _isActive = true;
  }

  void _populateForm(BovineEntity bovine) {
    _commonNameController.text = bovine.commonName;
    _registrationIdController.text = bovine.registrationId;
    _breedController.text = bovine.breed;
    _originCountryController.text = bovine.originCountry;
    _animalTypeController.text = bovine.animalType;
    _originController.text = bovine.origin;
    _characteristicsController.text = bovine.characteristics;
    _purposeController.text = bovine.purpose;
    _tagsController.text = _formService.tagsToString(bovine.tags);
    
    _selectedAptitude = bovine.aptitude;
    _selectedBreedingSystem = bovine.breedingSystem;
    _selectedTags = List.from(bovine.tags);
    _isActive = bovine.isActive;
  }

  void _setupListeners() {
    // Remove listeners existentes para evitar duplicação
    _removeListeners();
    
    // Adiciona listeners para detectar mudanças
    _commonNameController.addListener(_onFormChanged);
    _registrationIdController.addListener(_onFormChanged);
    _breedController.addListener(_onFormChanged);
    _originCountryController.addListener(_onFormChanged);
    _animalTypeController.addListener(_onFormChanged);
    _originController.addListener(_onFormChanged);
    _characteristicsController.addListener(_onFormChanged);
    _purposeController.addListener(_onFormChanged);
    _tagsController.addListener(_onFormChanged);
  }

  void _removeListeners() {
    _commonNameController.removeListener(_onFormChanged);
    _registrationIdController.removeListener(_onFormChanged);
    _breedController.removeListener(_onFormChanged);
    _originCountryController.removeListener(_onFormChanged);
    _animalTypeController.removeListener(_onFormChanged);
    _originController.removeListener(_onFormChanged);
    _characteristicsController.removeListener(_onFormChanged);
    _purposeController.removeListener(_onFormChanged);
    _tagsController.removeListener(_onFormChanged);
  }

  void _onFormChanged() {
    final currentData = _getCurrentFormData();
    final hasChanges = _originalData != null && 
                      _formService.hasFormChanged(currentData, _originalData!);
    
    if (hasChanges != _hasUnsavedChanges) {
      _hasUnsavedChanges = hasChanges;
      notifyListeners();
    }
  }

  // =====================================================================
  // FIELD UPDATES
  // =====================================================================

  void updateAptitude(BovineAptitude? aptitude) {
    if (_selectedAptitude != aptitude) {
      _selectedAptitude = aptitude;
      _onFormChanged();
      notifyListeners();
    }
  }

  void updateBreedingSystem(BreedingSystem? system) {
    if (_selectedBreedingSystem != system) {
      _selectedBreedingSystem = system;
      _onFormChanged();
      notifyListeners();
    }
  }

  void updateTags(List<String> tags) {
    if (_selectedTags.length != tags.length || 
        !_selectedTags.every(tags.contains)) {
      _selectedTags = List.from(tags);
      _onFormChanged();
      notifyListeners();
    }
  }

  void updateActiveStatus(bool isActive) {
    if (_isActive != isActive) {
      _isActive = isActive;
      _onFormChanged();
      notifyListeners();
    }
  }

  // =====================================================================
  // VALIDATION
  // =====================================================================

  FormValidationResult validateForm() {
    final formData = _getCurrentFormData();
    return _formService.validateCompleteForm(formData);
  }

  String? validateField(String fieldName, String? value) {
    switch (fieldName) {
      case 'commonName':
        return _formService.validateCommonName(value);
      case 'registrationId':
        return _formService.validateRegistrationId(value);
      case 'breed':
        return _formService.validateBreed(value);
      case 'originCountry':
        return _formService.validateOriginCountry(value);
      case 'animalType':
        return _formService.validateAnimalType(value);
      case 'origin':
        return _formService.validateOrigin(value);
      case 'characteristics':
        return _formService.validateCharacteristics(value);
      case 'purpose':
        return _formService.validatePurpose(value);
      default:
        return null;
    }
  }

  // =====================================================================
  // DATA PREPARATION
  // =====================================================================

  BovineFormData _getCurrentFormData() {
    return BovineFormData(
      commonName: _commonNameController.text,
      registrationId: _registrationIdController.text,
      breed: _breedController.text,
      originCountry: _originCountryController.text,
      animalType: _animalTypeController.text,
      origin: _originController.text,
      characteristics: _characteristicsController.text,
      purpose: _purposeController.text,
      tagsString: _tagsController.text,
      aptitude: _selectedAptitude,
      breedingSystem: _selectedBreedingSystem,
      isActive: _isActive,
    );
  }

  BovineEntity prepareBovineForSaving({
    bool isEditing = false,
    String? existingId,
    List<String>? existingImageUrls,
    DateTime? existingCreatedAt,
  }) {
    final formData = _getCurrentFormData();
    return _formService.prepareBovineData(
      formData: formData,
      isEditing: isEditing,
      existingId: existingId,
      existingImageUrls: existingImageUrls,
      existingCreatedAt: existingCreatedAt,
    );
  }

  // =====================================================================
  // FORM OPERATIONS
  // =====================================================================

  void resetToOriginal() {
    if (_originalData != null) {
      _populateFormFromData(_originalData!);
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  void _populateFormFromData(BovineFormData data) {
    _commonNameController.text = data.commonName ?? '';
    _registrationIdController.text = data.registrationId ?? '';
    _breedController.text = data.breed ?? '';
    _originCountryController.text = data.originCountry ?? '';
    _animalTypeController.text = data.animalType ?? '';
    _originController.text = data.origin ?? '';
    _characteristicsController.text = data.characteristics ?? '';
    _purposeController.text = data.purpose ?? '';
    _tagsController.text = data.tagsString ?? '';
    
    _selectedAptitude = data.aptitude;
    _selectedBreedingSystem = data.breedingSystem;
    _selectedTags = _formService.processTags(data.tagsString ?? '');
    _isActive = data.isActive ?? true;
  }

  void markAsSaved() {
    _originalData = _getCurrentFormData();
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // =====================================================================
  // HELPER METHODS
  // =====================================================================

  int getCharacterCount(String fieldName) {
    switch (fieldName) {
      case 'commonName':
        return _commonNameController.text.trim().length;
      case 'registrationId':
        return _registrationIdController.text.trim().length;
      case 'breed':
        return _breedController.text.trim().length;
      case 'originCountry':
        return _originCountryController.text.trim().length;
      case 'animalType':
        return _animalTypeController.text.trim().length;
      case 'origin':
        return _originController.text.trim().length;
      case 'characteristics':
        return _characteristicsController.text.trim().length;
      case 'purpose':
        return _purposeController.text.trim().length;
      default:
        return 0;
    }
  }

  bool isFieldNearLimit(String fieldName, int maxLength) {
    final currentLength = getCharacterCount(fieldName);
    return _formService.isNearCharLimit(
      currentLength.toString(), 
      maxLength,
    );
  }

  // =====================================================================
  // CLEANUP
  // =====================================================================

  void cleanup() {
    _removeListeners();
    
    // Retorna controllers para a pool
    _returnController('commonName');
    _returnController('registrationId');
    _returnController('breed');
    _returnController('originCountry');
    _returnController('animalType');
    _returnController('origin');
    _returnController('characteristics');
    _returnController('purpose');
    _returnController('tags');
    
    _isInitialized = false;
    _hasUnsavedChanges = false;
    _originalData = null;
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }

  // =====================================================================
  // STATIC METHODS - Pool Management
  // =====================================================================

  /// Limpa a pool de controllers para liberar memória
  static void clearControllerPool() {
    for (final controller in _controllerPool.values) {
      controller.dispose();
    }
    _controllerPool.clear();
  }

  /// Retorna estatísticas da pool para debugging
  static Map<String, dynamic> getPoolStats() {
    return {
      'poolSize': _controllerPool.length,
      'controllers': _controllerPool.keys.toList(),
    };
  }
}