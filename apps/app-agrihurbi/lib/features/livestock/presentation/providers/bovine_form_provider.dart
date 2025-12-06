import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/bovine_entity.dart';
import '../../domain/services/bovine_form_service.dart';
import '../../domain/services/livestock_validation_service.dart';

part 'bovine_form_provider.g.dart';

/// State class for BovineForm
class BovineFormState {
  final BovineAptitude? selectedAptitude;
  final BreedingSystem? selectedBreedingSystem;
  final List<String> selectedTags;
  final bool isActive;
  final bool isInitialized;
  final bool hasUnsavedChanges;
  final BovineFormData? originalData;

  const BovineFormState({
    this.selectedAptitude,
    this.selectedBreedingSystem,
    this.selectedTags = const [],
    this.isActive = true,
    this.isInitialized = false,
    this.hasUnsavedChanges = false,
    this.originalData,
  });

  BovineFormState copyWith({
    BovineAptitude? selectedAptitude,
    BreedingSystem? selectedBreedingSystem,
    List<String>? selectedTags,
    bool? isActive,
    bool? isInitialized,
    bool? hasUnsavedChanges,
    BovineFormData? originalData,
    bool clearOriginalData = false,
  }) {
    return BovineFormState(
      selectedAptitude: selectedAptitude ?? this.selectedAptitude,
      selectedBreedingSystem: selectedBreedingSystem ?? this.selectedBreedingSystem,
      selectedTags: selectedTags ?? this.selectedTags,
      isActive: isActive ?? this.isActive,
      isInitialized: isInitialized ?? this.isInitialized,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      originalData: clearOriginalData ? null : (originalData ?? this.originalData),
    );
  }
}

/// Provider especializado para gerenciar o estado do formulário de bovino
@riverpod
class BovineFormNotifier extends _$BovineFormNotifier {
  late final BovineFormService _formService;
  
  static final Map<String, TextEditingController> _controllerPool = {};
  
  late TextEditingController _commonNameController;
  late TextEditingController _registrationIdController;
  late TextEditingController _breedController;
  late TextEditingController _originCountryController;
  late TextEditingController _animalTypeController;
  late TextEditingController _originController;
  late TextEditingController _characteristicsController;
  late TextEditingController _purposeController;
  late TextEditingController _tagsController;

  @override
  BovineFormState build() {
    final validationService = LivestockValidationService();
    _formService = BovineFormService(validationService);
    _initializeControllers();
    return const BovineFormState();
  }

  void _initializeControllers() {
    _commonNameController = _getController('commonName');
    _registrationIdController = _getController('registrationId');
    _breedController = _getController('breed');
    _originCountryController = _getController('originCountry');
    _animalTypeController = _getController('animalType');
    _originController = _getController('origin');
    _characteristicsController = _getController('characteristics');
    _purposeController = _getController('purpose');
    _tagsController = _getController('tags');
  }

  TextEditingController _getController(String key) {
    return _controllerPool.putIfAbsent(key, () => TextEditingController());
  }

  void _returnController(String key) {
    final controller = _controllerPool[key];
    controller?.clear();
  }

  // Public getters for controllers
  BovineFormService get formService => _formService;
  TextEditingController get commonNameController => _commonNameController;
  TextEditingController get registrationIdController => _registrationIdController;
  TextEditingController get breedController => _breedController;
  TextEditingController get originCountryController => _originCountryController;
  TextEditingController get animalTypeController => _animalTypeController;
  TextEditingController get originController => _originController;
  TextEditingController get characteristicsController => _characteristicsController;
  TextEditingController get purposeController => _purposeController;
  TextEditingController get tagsController => _tagsController;

  // Convenience getters
  BovineAptitude? get selectedAptitude => state.selectedAptitude;
  BreedingSystem? get selectedBreedingSystem => state.selectedBreedingSystem;
  List<String> get selectedTags => List.unmodifiable(state.selectedTags);
  bool get isActive => state.isActive;
  bool get isInitialized => state.isInitialized;
  bool get hasUnsavedChanges => state.hasUnsavedChanges;

  /// Inicializa o formulário para criação
  void initializeForCreation() {
    _clearForm();
    state = state.copyWith(
      isActive: true,
      selectedAptitude: BovineAptitude.beef,
      selectedBreedingSystem: BreedingSystem.extensive,
      isInitialized: true,
      hasUnsavedChanges: false,
      originalData: _getCurrentFormData(),
    );
    _setupListeners();
  }

  /// Inicializa o formulário para edição
  void initializeForEditing(BovineEntity bovine) {
    _populateForm(bovine);
    state = state.copyWith(
      isInitialized: true,
      hasUnsavedChanges: false,
      originalData: _getCurrentFormData(),
    );
    _setupListeners();
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

    state = state.copyWith(
      selectedAptitude: null,
      selectedBreedingSystem: null,
      selectedTags: [],
      isActive: true,
    );
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

    state = state.copyWith(
      selectedAptitude: bovine.aptitude,
      selectedBreedingSystem: bovine.breedingSystem,
      selectedTags: List.from(bovine.tags),
      isActive: bovine.isActive,
    );
  }

  void _setupListeners() {
    _removeListeners();
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
    final hasChanges = state.originalData != null &&
        _formService.hasFormChanged(currentData, state.originalData!);

    if (hasChanges != state.hasUnsavedChanges) {
      state = state.copyWith(hasUnsavedChanges: hasChanges);
    }
  }

  void updateAptitude(BovineAptitude? aptitude) {
    if (state.selectedAptitude != aptitude) {
      state = state.copyWith(selectedAptitude: aptitude);
      _onFormChanged();
    }
  }

  void updateBreedingSystem(BreedingSystem? system) {
    if (state.selectedBreedingSystem != system) {
      state = state.copyWith(selectedBreedingSystem: system);
      _onFormChanged();
    }
  }

  void updateTags(List<String> tags) {
    if (state.selectedTags.length != tags.length ||
        !state.selectedTags.every(tags.contains)) {
      state = state.copyWith(selectedTags: List.from(tags));
      _onFormChanged();
    }
  }

  void updateActiveStatus(bool isActive) {
    if (state.isActive != isActive) {
      state = state.copyWith(isActive: isActive);
      _onFormChanged();
    }
  }

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
      aptitude: state.selectedAptitude,
      breedingSystem: state.selectedBreedingSystem,
      isActive: state.isActive,
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

  void resetToOriginal() {
    if (state.originalData != null) {
      _populateFormFromData(state.originalData!);
      state = state.copyWith(hasUnsavedChanges: false);
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

    state = state.copyWith(
      selectedAptitude: data.aptitude,
      selectedBreedingSystem: data.breedingSystem,
      selectedTags: _formService.processTags(data.tagsString ?? ''),
      isActive: data.isActive ?? true,
    );
  }

  void markAsSaved() {
    state = state.copyWith(
      originalData: _getCurrentFormData(),
      hasUnsavedChanges: false,
    );
  }

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
    return _formService.isNearCharLimit(currentLength.toString(), maxLength);
  }

  void cleanup() {
    _removeListeners();
    _returnController('commonName');
    _returnController('registrationId');
    _returnController('breed');
    _returnController('originCountry');
    _returnController('animalType');
    _returnController('origin');
    _returnController('characteristics');
    _returnController('purpose');
    _returnController('tags');

    state = state.copyWith(
      isInitialized: false,
      hasUnsavedChanges: false,
      clearOriginalData: true,
    );
  }

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
