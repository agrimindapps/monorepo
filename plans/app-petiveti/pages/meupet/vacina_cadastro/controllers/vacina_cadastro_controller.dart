// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../repository/vacina_repository.dart';
import '../../../../widgets/success_dialog_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../constants/vaccination_constants.dart';
import '../models/vacina_cadastro_state.dart';
import '../models/vacina_creation_model.dart';
import '../services/form_validation_service.dart';
import '../services/vaccine_creation_service.dart';

class VacinaCadastroController extends GetxController {
  final VacinaRepository _repository;
  final VaccineCreationService _creationService;
  final FormValidationService _validationService;
  final _animalController = Get.find<AnimalPageController>();

  final _state = VacinaCadastroState.empty('').obs;
  
  // Resource management
  Timer? _debounceTimer;
  late final StreamSubscription _stateSubscription;

  VacinaCadastroController({
    VacinaRepository? repository,
    VaccineCreationService? creationService,
    FormValidationService? validationService,
  })  : _repository = repository ?? VacinaRepository(),
        _creationService = creationService ?? VaccineCreationService(),
        _validationService = validationService ?? FormValidationService();

  static Future<VacinaCadastroController> initialize() async {
    await VacinaRepository.initialize();
    final controller = VacinaCadastroController();
    Get.put(controller);
    return controller;
  }

  // State getters
  VacinaCadastroState get state => _state.value;

  String get animalId => state.animalId;
  String get nomeVacina => state.nomeVacina;
  int get dataAplicacao => state.dataAplicacao;
  int get proximaDose => state.proximaDose;
  String? get observacoes => state.observacoes;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get hasError => state.hasError;
  bool get isValid => state.isFormValid;
  bool get canSubmit => state.canSubmit && state.isFormValid;
  DateTime get dataAplicacaoDate => state.dataAplicacaoDate;
  DateTime get proximaDoseDate => state.proximaDoseDate;
  String get selectedAnimalId => _animalController.selectedAnimalId;
  bool get isEditing => state.isEditing;
  String get formTitle => state.formTitle;
  String get submitButtonText => state.submitButtonText;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    // Use debounced validation to prevent excessive calls
    _stateSubscription = _state.listen((_) => _debouncedValidateForm());
  }

  void initializeForm({VacinaVet? vacina, required String selectedAnimalId}) {
    if (vacina != null) {
      _state.value = VacinaCadastroState.fromVacina(vacina);
    } else {
      _state.value = VacinaCadastroState.empty(selectedAnimalId);
    }

    // Initial validation
    _validateForm();
  }

  /// Debounced validation to prevent excessive validation calls
  void _debouncedValidateForm() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: VaccinationConstants.validationDebounceMs), () {
      _validateForm();
    });
  }

  // Field update methods
  void updateNomeVacina(String value) {
    _updateState(state.copyWith(nomeVacina: value));
    _touchField(VaccinationConstants.fieldNomeVacina);
  }

  void updateDataAplicacao(DateTime date) {
    final timestamp = date.millisecondsSinceEpoch;
    _updateState(state.copyWith(dataAplicacao: timestamp));

    // Auto-update next dose if it's before the new application date
    if (state.proximaDose < timestamp) {
      final suggestedNextDose =
          VacinaCreationModel.suggestNextDoseDate(state.nomeVacina, timestamp);
      _updateState(state.copyWith(proximaDose: suggestedNextDose));
    }

    _touchField(VaccinationConstants.fieldDataAplicacao);
  }

  void updateProximaDose(DateTime date) {
    _updateState(state.copyWith(proximaDose: date.millisecondsSinceEpoch));
    _touchField(VaccinationConstants.fieldProximaDose);
  }

  void updateObservacoes(String? value) {
    _updateState(state.copyWith(observacoes: value));
    _touchField(VaccinationConstants.fieldObservacoes);
  }

  // Form interaction methods
  void _touchField(String fieldName) {
    _updateState(state.touchField(fieldName));
    _validateField(fieldName);
  }

  void _validateField(String fieldName) {
    String? error;

    switch (fieldName) {
      case VaccinationConstants.fieldNomeVacina:
        error = _validationService.validateVaccineName(state.nomeVacina);
        break;
      case VaccinationConstants.fieldDataAplicacao:
        error = _validationService.validateApplicationDate(state.dataAplicacao);
        break;
      case VaccinationConstants.fieldProximaDose:
        error = _validationService.validateNextDoseDate(
            state.proximaDose, state.dataAplicacao);
        break;
      case VaccinationConstants.fieldObservacoes:
        error = _validationService.validateObservations(state.observacoes);
        break;
    }

    _updateState(state.setFieldError(fieldName, error));
  }

  void _validateForm() {
    final errors = <String, String?>{};

    errors['nomeVacina'] = _validationService.validateVaccineName(state.nomeVacina);
    errors['dataAplicacao'] = _validationService.validateApplicationDate(state.dataAplicacao);
    errors['proximaDose'] = _validationService.validateNextDoseDate(state.proximaDose, state.dataAplicacao);
    errors['observacoes'] = _validationService.validateObservations(state.observacoes);

    _updateState(state.setFieldErrors(errors));
  }

  // Business logic methods
  Future<bool> submitForm([BuildContext? context]) async {
    if (!canSubmit) {
      _validateForm(); // Show all validation errors
      return false;
    }

    try {
      _updateState(state.copyWith(isLoading: true, errorMessage: null));

      bool success;
      if (isEditing) {
        success = await _updateExistingVaccine();
      } else {
        success = await _createNewVaccine();
      }

      if (success) {
        _updateState(state.copyWith(isLoading: false));
        if (context != null && context.mounted) {
          await _showSuccessMessage(context);
        }
        return true;
      } else {
        _updateState(state.copyWith(
          isLoading: false,
          errorMessage: VaccinationConstants.errorSaveFailure,
        ));
        return false;
      }
    } catch (e) {
      _updateState(state.copyWith(
        isLoading: false,
        errorMessage: _creationService.getErrorMessage(e),
      ));
      debugPrint('Erro ao submeter formulário: $e');
      return false;
    }
  }

  Future<bool> _createNewVaccine() async {
    final vacina = _creationService.createVaccineFromFormData(
      animalId: state.animalId,
      nomeVacina: state.nomeVacina,
      dataAplicacao: state.dataAplicacao,
      proximaDose: state.proximaDose,
      observacoes: state.observacoes,
    );

    final result = await _repository.addVacina(vacina);
    return result;
  }

  Future<bool> _updateExistingVaccine() async {
    if (state.vacinaIdBeingEdited == null) return false;

    // Get existing vaccine from repository
    final existingVaccines = await _repository.getVacinas(state.animalId);
    final existingVaccine = existingVaccines
        .firstWhereOrNull((v) => v.id == state.vacinaIdBeingEdited);

    if (existingVaccine == null) return false;

    final updatedVacina = _creationService.updateVaccineFromFormData(
      existingVaccine: existingVaccine,
      nomeVacina: state.nomeVacina,
      dataAplicacao: state.dataAplicacao,
      proximaDose: state.proximaDose,
      observacoes: state.observacoes,
    );

    return await _repository.updateVacina(updatedVacina);
  }

  Future<void> _showSuccessMessage(BuildContext context) async {
    final message = isEditing
        ? VaccinationConstants.successVaccineUpdated
        : VaccinationConstants.successVaccineSaved;

    await SuccessDialog.show(
      context: context,
      title: 'Sucesso',
      message: message,
    );
  }

  // Suggestion methods
  void suggestNextDoseFromVaccineName() {
    if (state.nomeVacina.isNotEmpty) {
      final suggestedDate = VacinaCreationModel.suggestNextDoseDate(
        state.nomeVacina,
        state.dataAplicacao,
      );
      _updateState(state.copyWith(proximaDose: suggestedDate));
    }
  }

  // Validation helper methods
  String? getFieldError(String fieldName) {
    return state.getFieldError(fieldName);
  }

  bool shouldShowFieldError(String fieldName) {
    return state.shouldShowFieldError(fieldName);
  }

  // State management helpers
  void _updateState(VacinaCadastroState newState) {
    _state.value = newState;
  }

  void clearError() {
    _updateState(state.copyWith(errorMessage: null));
  }

  void resetForm() {
    _state.value = VacinaCadastroState.empty(selectedAnimalId);
  }

  @override
  void onClose() {
    // Clean up resources to prevent memory leaks
    _debounceTimer?.cancel();
    _stateSubscription.cancel();
    super.onClose();
  }
}
