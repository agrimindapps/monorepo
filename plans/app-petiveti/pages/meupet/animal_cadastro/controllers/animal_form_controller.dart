// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../constants/animal_form_constants.dart';
import '../models/animal_form_model.dart';
import '../models/animal_form_state.dart';
import '../services/animal_creation_service.dart';
import '../services/animal_validation_service.dart';

class AnimalFormController extends GetxController {
  final AnimalCreationService _creationService;

  final formKey = GlobalKey<FormState>();
  final formModel = AnimalFormModel().obs;
  final formState = AnimalFormState.initial().obs;

  Animal? _originalAnimal;

  AnimalFormController({AnimalCreationService? creationService})
      : _creationService = creationService ?? AnimalCreationService();

  static Future<AnimalFormController> initialize() async {
    final controller = AnimalFormController();
    Get.put(controller);
    return controller;
  }

  @override
  void onInit() {
    super.onInit();
    _logOperation('AnimalFormController initialized');
  }

  @override
  void onClose() {
    _logOperation('AnimalFormController disposed');
    // Clean up any resources if needed
    super.onClose();
  }

  /// Initializes the form with data from an existing animal or creates a new form.
  ///
  /// This method is called when the form is first displayed to set up the initial
  /// state. If an [animal] is provided, the form is populated with its data for
  /// editing. If null, a new blank form is created for adding a new animal.
  ///
  /// [animal] The animal to edit, or null to create a new one
  void initializeForm(Animal? animal) {
    _originalAnimal = animal;
    if (animal != null) {
      formModel.value = AnimalFormModel.fromAnimal(animal);
      formState.value = AnimalFormState.editing();
    } else {
      formModel.value = AnimalFormModel();
      formState.value = AnimalFormState.ready();
    }
  }

  void updateNome(String value) {
    formModel.update((model) {
      model?.nome = value.trim();
    });
    _trackFormChanges();
  }

  void updateEspecie(String value) {
    formModel.update((model) {
      model?.especie = value;
      model?.raca = '';
    });
    _trackFormChanges();
  }

  void updateRaca(String value) {
    formModel.update((model) {
      model?.raca = value.trim();
    });
    _trackFormChanges();
  }

  void updateDataNascimento(int timestamp) {
    formModel.update((model) {
      model?.dataNascimento = timestamp;
    });
    _trackFormChanges();
  }

  void updateSexo(String value) {
    formModel.update((model) {
      model?.sexo = value;
    });
    _trackFormChanges();
  }

  void updateCor(String value) {
    formModel.update((model) {
      model?.cor = value.trim();
    });
    _trackFormChanges();
  }

  void updatePesoAtual(double value) {
    formModel.update((model) {
      model?.pesoAtual = value;
    });
    _trackFormChanges();
  }

  void updateObservacoes(String? value) {
    formModel.update((model) {
      model?.observacoes = value?.isEmpty ?? true ? null : value;
    });
    _trackFormChanges();
  }

  void updateFoto(String? value) {
    formModel.update((model) {
      model?.foto = value?.isEmpty ?? true ? null : value;
    });
    _trackFormChanges();
  }

  /// Validates the animal's name field using the validation service.
  String? validateNome(String? value) {
    return AnimalValidationService.validateNome(value);
  }

  String? validateRaca(String? value) {
    return AnimalValidationService.validateRaca(value);
  }

  String? validateCor(String? value) {
    return AnimalValidationService.validateCor(value);
  }

  /// Validates the animal's current weight field using the validation service.
  String? validatePesoAtual(String? value) {
    if (value?.isEmpty ?? true) return AnimalFormConstants.requiredFieldMessage;
    
    final peso = AnimalValidationService.parseWeight(value);
    if (peso == null) return AnimalFormConstants.invalidNumberMessage;
    
    return AnimalValidationService.validatePesoAtual(peso, formModel.value.especie);
  }

  /// Parses a weight string to a double value using the validation service.
  double parseWeight(String value) {
    return AnimalValidationService.parseWeight(value) ?? 0.0;
  }

  /// Handles complete form submission flow with enhanced state management
  /// Returns: true if successful, false if validation fails or error occurs
  Future<bool> submitForm() async {
    try {
      // Clear previous error
      formState.value = formState.value.clearAllErrors();

      // Set validating state
      formState.value = formState.value.setValidating(true);

      // Validation
      if (!_validateForm()) {
        formState.value = formState.value.setError('Por favor, corrija os erros no formulário');
        return false;
      }

      // Save form data
      _saveFormData();

      // Set loading state
      formState.value = formState.value.setLoading(true);

      // Use creation service to handle the animal creation/update
      final success = await _persistAnimalUsingService();

      if (success) {
        // Set success state
        formState.value = formState.value.setSuccess(
            'Animal ${_isUpdating ? 'atualizado' : 'criado'} com sucesso!');
        _logOperation(
            'Animal ${_isUpdating ? 'updated' : 'created'} successfully');
        return true;
      } else {
        formState.value = formState.value.setError('Falha ao salvar o animal. Tente novamente.');
        return false;
      }
    } catch (e) {
      // Handle and log error
      formState.value = formState.value.setError('Erro inesperado: ${e.toString()}');
      _handleError('Error saving animal', e);
      return false;
    } finally {
      // Reset to idle if not success or error
      if (formState.value.isSubmitting || formState.value.isValidating) {
        formState.value = formState.value.setSubmissionState(FormSubmissionState.idle);
      }
    }
  }

  /// Retries form submission after an error
  Future<bool> retrySubmission() async {
    return await submitForm();
  }

  /// Gets whether the form is currently in a loading state
  bool get isFormLoading => formState.value.isLoading;

  /// Gets whether the form has an error
  bool get hasError => formState.value.hasError;

  /// Gets whether the form submission was successful
  bool get isFormSuccess => formState.value.isSuccess;

  /// Gets the current error message
  String get errorMessage => formState.value.errorMessage ?? '';

  /// Gets whether the form is loading (backward compatibility)
  bool get isLoading => formState.value.isLoading;

  /// Validates the form
  bool _validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Saves form data
  void _saveFormData() {
    formKey.currentState?.save();
  }

  /// Uses the creation service to persist animal data
  Future<bool> _persistAnimalUsingService() async {
    try {
      if (_isUpdating) {
        await _creationService.updateAnimal(_originalAnimal!.id, formModel.value);
      } else {
        await _creationService.createAnimalWithValidation(formModel.value);
      }
      return true;
    } catch (e) {
      debugPrint('Error persisting animal: $e');
      return false;
    }
  }

  /// Tracks form field changes
  void _trackFormChanges() {
    if (!formState.value.hasChanges) {
      formState.value = formState.value.setHasChanges(true);
    }
  }

  /// Checks if this is an update operation
  bool get _isUpdating => _originalAnimal != null;

  /// Logs operation for debugging (centralized logging)
  void _logOperation(String message) {
    // TODO: Replace with proper logging service
    debugPrint(message);
  }

  /// Handles errors with proper logging
  void _handleError(String context, dynamic error) {
    // TODO: Replace with proper error handling service
    debugPrint('$context: $error');
  }

  /// Gets the species options with icons from centralized constants
  Map<String, IconData> get especiesOptions =>
      AnimalFormConstants.speciesOptions;

  /// Gets the sex options from centralized constants
  List<String> get sexoOptions => AnimalFormConstants.sexOptions;

  /// Gets the species-to-emoji mapping from centralized constants
  Map<String, String> getEspeciesWithIcons() {
    return AnimalFormConstants.speciesEmojis;
  }

  // Removed duplicate parsePeso method - use parseWeight instead
}
