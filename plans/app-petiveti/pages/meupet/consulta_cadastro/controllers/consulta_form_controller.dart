// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/12_consulta_model.dart';
import '../../../../repository/consulta_repository.dart';
import '../../../../utils/consulta_utils.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/consulta_form_model.dart';
import '../models/consulta_form_state.dart';
import '../services/auto_save_service.dart';
import '../services/consulta_business_service.dart';
import '../services/consulta_form_service.dart';

class ConsultaFormController extends GetxController {
  final _animalController = Get.find<AnimalPageController>();
  final ConsultaRepository _repository;
  final ConsultaFormService _consultaService;
  final ConsultaBusinessService _businessService;
  final AutoSaveService _autoSaveService;

  String? _autoSaveSessionKey;

  final formKey = GlobalKey<FormState>();
  final _formModel = ConsultaFormModel().obs;
  final _formState = const ConsultaFormState().obs;

  // Granular observables for better performance
  final _isLoading = false.obs;
  final _isSubmitting = false.obs;
  final _hasChanges = false.obs;
  final _errorMessage = Rxn<String>();

  ConsultaFormModel get model => _formModel.value;
  ConsultaFormState get state => _formState.value;
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String? get errorMessage => _errorMessage.value;
  bool get isInitialized => state.isInitialized;
  bool get hasChanges => _hasChanges.value;
  bool get isEditing => _originalConsulta != null;

  // Reactive getters for UI
  RxBool get isLoadingReactive => _isLoading;
  RxBool get isSubmittingReactive => _isSubmitting;
  RxBool get hasChangesReactive => _hasChanges;
  Rxn<String> get errorMessageReactive => _errorMessage;

  Consulta? _originalConsulta;

  ConsultaFormController({
    ConsultaRepository? repository,
    ConsultaFormService? consultaService,
    ConsultaBusinessService? businessService,
    AutoSaveService? autoSaveService,
  })  : _repository = repository ?? ConsultaRepository(),
        _consultaService = consultaService ?? ConsultaFormService(),
        _businessService = businessService ?? ConsultaBusinessService(),
        _autoSaveService = autoSaveService ?? AutoSaveService.instance;

  static Future<ConsultaFormController> initialize() async {
    await ConsultaRepository.initialize();
    final controller = ConsultaFormController();
    Get.put(controller, tag: 'consulta_form');
    await controller._initializeController();
    return controller;
  }

  Future<void> _initializeController() async {
    try {
      setLoading(true);
      setInitialized(true);
      setError(null);
    } catch (e) {
      setError('Erro ao inicializar o controlador: $e');
      debugPrint('Erro ao inicializar ConsultaFormController: $e');
    } finally {
      setLoading(false);
    }
  }

  void initializeForm({Consulta? consulta, String? selectedAnimalId}) async {
    _originalConsulta = consulta;

    // Initialize auto-save
    await _autoSaveService.initialize();
    _autoSaveSessionKey = AutoSaveService.generateSessionKey(
      animalId: selectedAnimalId,
      consultaId: consulta?.id,
    );

    // Try to restore auto-saved data if no consulta provided
    if (consulta == null && _autoSaveSessionKey != null) {
      final savedData =
          await _autoSaveService.restoreFormData(_autoSaveSessionKey!);
      if (savedData != null) {
        _formModel.value = savedData;
        setHasChanges(true);
        _showAutoSaveRestoreDialog();
        _startAutoSave();
        clearFieldErrors();
        return;
      }
    }

    if (consulta != null) {
      _formModel.value = ConsultaFormModel.fromConsulta(consulta);
    } else {
      final animalId = selectedAnimalId ?? _animalController.selectedAnimalId;
      _formModel.value = ConsultaFormModel.withAnimalId(animalId);
    }

    setHasChanges(false);
    clearFieldErrors();
    _startAutoSave();
  }

  // Update methods
  void updateAnimalId(String value) {
    _formModel.update((model) {
      model?.animalId = value;
    });
    _validateField('animalId', value);
    setHasChanges(true);
  }

  void updateDataConsulta(DateTime date) {
    _formModel.update((model) {
      model?.dataConsulta = date.millisecondsSinceEpoch;
    });
    _validateField('dataConsulta', date);
    setHasChanges(true);
  }

  void updateVeterinario(String value) {
    _formModel.update((model) {
      model?.veterinario = value.trim();
    });
    _validateField('veterinario', value);
    setHasChanges(true);
  }

  void updateMotivo(String value) {
    _formModel.update((model) {
      model?.motivo = value.trim();
    });
    _validateField('motivo', value);
    setHasChanges(true);
  }

  void updateDiagnostico(String value) {
    _formModel.update((model) {
      model?.diagnostico = value.trim();
    });
    _validateField('diagnostico', value);
    setHasChanges(true);
  }

  void updateObservacoes(String value) {
    _formModel.update((model) {
      model?.observacoes = value.trim();
    });
    _validateField('observacoes', value);
    setHasChanges(true);
  }

  void updateValor(double value) {
    _formModel.update((model) {
      model?.valor = value;
    });
    _validateField('valor', value);
    setHasChanges(true);
  }

  // Validation methods
  void _validateField(String fieldName, dynamic value) {
    String? error;

    switch (fieldName) {
      case 'animalId':
        error = ConsultaValidators.validateAnimalId(value);
        break;
      case 'veterinario':
        error = ConsultaValidators.validateVeterinario(value);
        break;
      case 'motivo':
        error = ConsultaValidators.validateMotivo(value);
        break;
      case 'diagnostico':
        error = ConsultaValidators.validateDiagnostico(value);
        break;
      case 'observacoes':
        error = ConsultaValidators.validateObservacoes(value);
        break;
      case 'dataConsulta':
        error = ConsultaValidators.validateDataConsulta(value);
        break;
      case 'valor':
        error = _validateValorField(value);
        break;
    }

    setFieldError(fieldName, error);
  }

  String? _validateValorField(dynamic value) {
    // Consultas normalmente não têm campo valor, mas mantendo para compatibilidade
    if (value == null) return null;
    final doubleValue = value is double ? value : double.tryParse(value.toString());
    if (doubleValue == null) return 'Valor inválido';
    if (doubleValue < 0) return 'Valor não pode ser negativo';
    if (doubleValue > 999999.99) return 'Valor muito alto';
    return null;
  }

  /// Public method for field validation (used by widgets)
  void validateField(String fieldName, dynamic value) {
    _validateField(fieldName, value);
  }

  bool validateForm() {
    final errors = ConsultaValidators.validateAllFields(
      animalId: model.animalId,
      veterinario: model.veterinario,
      motivo: model.motivo,
      diagnostico: model.diagnostico,
      dataConsulta: DateTime.fromMillisecondsSinceEpoch(model.dataConsulta),
      observacoes: model.observacoes,
    );

    // Add business rule validation
    final businessErrors =
        _businessService.validateBusinessRules(_createConsultaFromForm());
    businessErrors.forEach((field, error) {
      if (error != null) {
        errors[field] = error;
      }
    });

    _formState.update((state) {
      state?.setFieldErrors(errors);
    });

    return !errors.values.any((error) => error != null);
  }

  // Form submission
  Future<void> saveConsulta() async {
    if (!validateForm()) {
      setError('Por favor, corrija os erros antes de salvar.');
      return;
    }

    try {
      setSubmitting(true);
      setError(null);

      final consulta = _createConsultaFromForm();
      final result = await _consultaService.saveConsulta(
        consulta: consulta,
        originalConsulta: _originalConsulta,
        repository: _repository,
      );

      if (result) {
        setSuccess(isEditing
            ? 'Consulta atualizada com sucesso!'
            : 'Consulta salva com sucesso!');
        setHasChanges(false);

        // Clear auto-saved data after successful save
        clearAutoSavedData();

        // Navigate back after successful save
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: consulta);
      } else {
        throw Exception('Falha ao salvar consulta');
      }
    } catch (e) {
      setError('Erro ao salvar consulta: $e');
      debugPrint('Erro ao salvar consulta: $e');
    } finally {
      setSubmitting(false);
    }
  }

  Future<void> deleteConsulta() async {
    if (_originalConsulta == null) return;

    try {
      setLoading(true);
      final result = await _consultaService.deleteConsulta(
        consulta: _originalConsulta!,
        repository: _repository,
      );

      if (result) {
        Get.back(result: {'deleted': true, 'consulta': _originalConsulta});
      } else {
        throw Exception('Falha ao excluir consulta');
      }
    } catch (e) {
      setError('Erro ao excluir consulta: $e');
      debugPrint('Erro ao excluir consulta: $e');
    } finally {
      setLoading(false);
    }
  }

  void duplicateConsulta() {
    if (_originalConsulta == null) return;

    // Reset form with same data but as new consultation
    _originalConsulta = null;
    _formModel.update((model) {
      model?.diagnostico = '${model.diagnostico} (Cópia)';
      model?.observacoes = '${model.observacoes ?? ''}\n\n[Consulta duplicada]';
    });

    setHasChanges(true);
    Get.snackbar(
      'Duplicação',
      'Consulta duplicada. Modifique os dados e salve.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Consulta _createConsultaFromForm() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Consulta(
      id: _originalConsulta?.id ?? const Uuid().v4(),
      createdAt: _originalConsulta?.createdAt ?? now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: _originalConsulta != null ? _originalConsulta!.version + 1 : 1,
      lastSyncAt: _originalConsulta?.lastSyncAt,
      animalId: model.animalId,
      dataConsulta: model.dataConsulta,
      veterinario: model.veterinario,
      motivo: model.motivo,
      diagnostico: model.diagnostico,
      valor: model.valor,
      observacoes:
          model.observacoes?.isEmpty == true ? null : model.observacoes,
    );
  }

  // State management methods
  void setLoading(bool loading) {
    _formState.update((state) {
      state?.setLoading(loading);
    });
  }

  void setSubmitting(bool submitting) {
    _formState.update((state) {
      state?.setSubmitting(submitting);
    });
  }

  void setError(String? error) {
    _formState.update((state) {
      state?.setError(error);
    });
  }

  void setSuccess(String message) {
    _formState.update((state) {
      state?.setSuccess(message);
    });
  }

  void setInitialized(bool initialized) {
    _formState.update((state) {
      state?.setInitialized(initialized);
    });
  }

  void setHasChanges(bool changes) {
    _formState.update((state) {
      state?.setHasChanges(changes);
    });

    // Trigger manual save when changes are made
    if (changes && _autoSaveSessionKey != null) {
      _triggerManualSave();
    }
  }

  void setFieldError(String fieldName, String? error) {
    _formState.update((state) {
      state?.setFieldError(fieldName, error);
    });
  }

  void clearFieldError(String fieldName) {
    _formState.update((state) {
      state?.clearFieldError(fieldName);
    });
  }

  void clearFieldErrors() {
    _formState.update((state) {
      state?.clearAllErrors();
    });
  }

  void clearError() {
    _formState.update((state) {
      state?.clearError();
    });
  }

  void resetForm({String? selectedAnimalId}) {
    _formModel.update((model) {
      model?.reset(selectedAnimalId: selectedAnimalId);
    });
    _originalConsulta = null;
    _formState.update((state) {
      state?.reset();
    });
  }

  // UI helper methods
  String getPageTitle() {
    return isEditing ? 'Editar Consulta' : 'Nova Consulta';
  }

  String getSaveButtonText() {
    return isEditing ? 'Atualizar' : 'Salvar';
  }

  bool canDelete() {
    return isEditing && _originalConsulta != null;
  }

  bool canDuplicate() {
    return isEditing && _originalConsulta != null;
  }

  bool canSave() {
    return state.canSubmit && model.isValid;
  }

  String? getFieldError(String fieldName) {
    return state.getFieldError(fieldName);
  }

  List<String> getAvailableMotivos() {
    return ConsultaUtils.getAvailableMotivos();
  }

  String? generateMotivoSuggestion(String motivo) {
    return _businessService.suggestDiagnostico(motivo);
  }

  /// Get business recommendations for the current consulta
  List<String> getBusinessRecommendations() {
    final consulta = _createConsultaFromForm();
    return _businessService.generateRecommendations(consulta);
  }

  /// Check if current consulta can be duplicated
  bool canDuplicateConsulta() {
    if (_originalConsulta == null) return false;
    return _businessService.canDuplicateConsulta(_originalConsulta!);
  }

  /// Get audit message for changes made
  String getAuditMessage() {
    if (_originalConsulta == null) return 'Nova consulta criada';
    final updatedConsulta = _createConsultaFromForm();
    return _businessService.generateAuditMessage(
        _originalConsulta!, updatedConsulta);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    try {
      // Stop auto-save
      _autoSaveService.stopAutoSave();

      // Cancel any pending async operations
      _cancelPendingOperations();

      // Clear reactive subscriptions
      _clearSubscriptions();

      // Dispose form key
      _disposeFormKey();

      // Clear models and state
      _clearModelsAndState();

      debugPrint('ConsultaFormController disposed successfully');
    } catch (e) {
      debugPrint('Error disposing ConsultaFormController: $e');
    } finally {
      super.onClose();
    }
  }

  void _cancelPendingOperations() {
    // If there are any timers or future operations, cancel them here
    // This prevents memory leaks from incomplete async operations
  }

  void _clearSubscriptions() {
    // Clear GetX reactive subscriptions
    _formModel.close();
    _formState.close();
    _isLoading.close();
    _isSubmitting.close();
    _hasChanges.close();
    _errorMessage.close();
  }

  void _disposeFormKey() {
    // Clear the form key reference
    // Note: FormState disposal is handled by Flutter framework
  }

  void _clearModelsAndState() {
    // Reset models to their initial state to clear references
    _formModel.value = ConsultaFormModel();
    _formState.value = const ConsultaFormState();
    _originalConsulta = null;
  }

  /// Start auto-save functionality
  void _startAutoSave() {
    if (_autoSaveSessionKey == null) return;

    _autoSaveService.startAutoSave(
        _autoSaveSessionKey!, () => _formModel.value);
  }

  /// Trigger manual save
  void _triggerManualSave() {
    if (_autoSaveSessionKey == null) return;

    _autoSaveService.saveFormData(_autoSaveSessionKey!, _formModel.value);
  }

  /// Show dialog when auto-saved data is restored
  void _showAutoSaveRestoreDialog() {
    Get.snackbar(
      'Dados Restaurados',
      'Dados não salvos foram restaurados automaticamente',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.restore, color: Colors.white),
    );
  }

  /// Clear auto-saved data
  void clearAutoSavedData() {
    if (_autoSaveSessionKey != null) {
      _autoSaveService.clearSavedData(_autoSaveSessionKey!);
    }
  }

  /// Check if auto-saved data exists
  Future<bool> hasAutoSavedData() async {
    if (_autoSaveSessionKey == null) return false;
    return await _autoSaveService.hasSavedData(_autoSaveSessionKey!);
  }

  /// Dispose resources when the controller is no longer needed
  @override
  void dispose() {
    onClose();
    super.dispose();
  }
}
