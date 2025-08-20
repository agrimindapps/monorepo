// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../repository/despesa_repository.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../config/despesa_config.dart';
import '../models/despesa_form_model.dart';
import '../models/despesa_form_state.dart';
import '../services/despesa_error_handler.dart';
import '../services/despesa_form_service.dart';
import '../utils/despesa_form_validators.dart';

class DespesaFormController extends GetxController {
  final DespesaRepository _repository;
  final _animalController = Get.find<AnimalPageController>();
  final DespesaFormService _formService;

  final formKey = GlobalKey<FormState>();
  final formModel = DespesaFormModel().obs;
  final formState = const DespesaFormState().obs;

  // Granular observables for better performance
  final _isLoading = false.obs;
  final _isSubmitting = false.obs;
  final _hasChanges = false.obs;
  final _errorMessage = Rxn<String>();

  DespesaVet? _originalDespesa;

  // Getters for granular observables (replace existing formState getters)
  bool get isLoadingGranular => _isLoading.value;
  bool get isSubmittingGranular => _isSubmitting.value;
  bool get hasChangesGranular => _hasChanges.value;
  String? get errorMessageGranular => _errorMessage.value;

  // Reactive getters for UI
  RxBool get isLoadingReactive => _isLoading;
  RxBool get isSubmittingReactive => _isSubmitting;
  RxBool get hasChangesReactive => _hasChanges;
  Rxn<String> get errorMessageReactive => _errorMessage;

  DespesaFormController({
    DespesaRepository? repository,
    DespesaFormService? formService,
  })  : _repository = repository ?? DespesaRepository(),
        _formService = formService ?? DespesaFormService();

  // Lazy initialization - don't use Get.put directly
  static Future<DespesaFormController> initialize({String? tag}) async {
    await DespesaRepository.initialize();
    final controller = DespesaFormController();
    Get.put(controller, tag: tag);
    return controller;
  }

  // Factory method for better dependency injection
  static DespesaFormController create({String? tag}) {
    return Get.put(DespesaFormController(), tag: tag);
  }

  void initializeForm({DespesaVet? despesa, String? selectedAnimalId}) {
    _originalDespesa = despesa;

    if (despesa != null) {
      formModel.value = DespesaFormModel.fromDespesa(despesa);
    } else {
      final animalId = selectedAnimalId ?? _animalController.selectedAnimalId;
      formModel.value = DespesaFormModel.withAnimalId(animalId);
    }

    _clearErrors();
  }

  void updateAnimalId(String value) {
    formModel.update((model) {
      model?.animalId = value;
    });
    _validateField('animalId');
  }

  void updateDataDespesa(DateTime date) {
    formModel.update((model) {
      model?.dataDespesa = date.millisecondsSinceEpoch;
    });
    _validateField('dataDespesa');
  }

  void updateTipo(String value) {
    formModel.update((model) {
      model?.tipo = value;
    });
    _validateField('tipo');
  }

  void updateDescricao(String value) {
    formModel.update((model) {
      model?.descricao = DespesaFormValidators.sanitizeDescricao(value);
    });
    _validateField('descricao');
  }

  void updateValor(double value) {
    formModel.update((model) {
      model?.valor = value;
    });
    _validateField('valor');
  }

  String? validateValor(double? value) {
    return DespesaFormValidators.validateValor(value);
  }

  String? validateTipo(String? value) {
    return DespesaFormValidators.validateTipo(value);
  }

  String? validateDescricao(String? value) {
    return DespesaFormValidators.validateDescricao(value);
  }

  String? validateAnimalId(String? value) {
    return DespesaFormValidators.validateAnimalId(value);
  }

  String? validateDataDespesa(DateTime? value) {
    return DespesaFormValidators.validateDataDespesa(value);
  }

  Future<bool> submitForm() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    return await DespesaErrorHandler.executeWithRetry(
      () async {
        _isLoading.value = true;
        _isSubmitting.value = true;
        formKey.currentState!.save();

      if (!_isFormValid()) {
        _errorMessage.value = DespesaConfig.msgErrorValidation;
        return false;
      }

      final despesa = _createDespesaFromForm();
      final result = await _formService.saveDespesa(
        despesa: despesa,
        originalDespesa: _originalDespesa,
        repository: _repository,
      );

      if (!result) {
        throw Exception(DespesaConfig.msgErrorSave);
      }

      _errorMessage.value = null; // Clear error on success

        return true;
      },
      context: 'submitForm',
      maxAttempts: 2,
    ).catchError((error) {
      if (error is DespesaErrorException) {
        _errorMessage.value = error.errorResult.userMessage;
      } else {
        final errorResult = DespesaErrorHandler.handleError(error, context: 'submitForm');
        _errorMessage.value = errorResult.userMessage;
      }
      return false;
    }).whenComplete(() {
      _isLoading.value = false;
      _isSubmitting.value = false;
    });
  }

  bool _isFormValid() {
    return DespesaFormValidators.isFormValid(
      animalId: formModel.value.animalId,
      tipo: formModel.value.tipo,
      descricao: formModel.value.descricao,
      valor: formModel.value.valor,
      dataDespesa:
          DateTime.fromMillisecondsSinceEpoch(formModel.value.dataDespesa),
    );
  }

  void _validateField(String fieldName) {
    final errors = Map<String, String?>.from(formState.value.fieldErrors);

    switch (fieldName) {
      case 'animalId':
        errors['animalId'] = validateAnimalId(formModel.value.animalId);
        break;
      case 'tipo':
        errors['tipo'] = validateTipo(formModel.value.tipo);
        break;
      case 'descricao':
        errors['descricao'] = validateDescricao(formModel.value.descricao);
        break;
      case 'valor':
        errors['valor'] = validateValor(formModel.value.valor);
        break;
      case 'dataDespesa':
        errors['dataDespesa'] = validateDataDespesa(
            DateTime.fromMillisecondsSinceEpoch(formModel.value.dataDespesa));
        break;
    }

    formState.value = formState.value.copyWith(fieldErrors: errors);
  }

  void _clearErrors() {
    formState.value = formState.value.copyWith(
      errorMessage: null,
      successMessage: null,
      fieldErrors: {},
    );
  }

  DespesaVet _createDespesaFromForm() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return DespesaVet(
      id: _originalDespesa?.id ?? const Uuid().v4(),
      createdAt:
          _originalDespesa?.createdAt ?? now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: _originalDespesa != null ? _originalDespesa!.version + 1 : 1,
      lastSyncAt: _originalDespesa?.lastSyncAt,
      animalId: formModel.value.animalId,
      dataDespesa: formModel.value.dataDespesa,
      tipo: formModel.value.tipo,
      descricao: formModel.value.descricao,
      valor: formModel.value.valor,
    );
  }

  // Getters - use granular observables for better performance
  List<String> get tiposDespesaOptions => formModel.value.tiposDespesaOptions;
  DateTime get dataDateTime => formModel.value.dataDateTime;
  String get valorFormatted => formModel.value.valorFormatted;
  bool get isValid => formModel.value.isValid;
  bool get isLoading => _isLoading.value; // Use granular observable
  String? get errorMessage => _errorMessage.value; // Use granular observable
  String? get successMessage => formState.value.successMessage;
  Map<String, String?> get fieldErrors => formState.value.fieldErrors;

  String getFormTitle() {
    return _originalDespesa == null ? DespesaConfig.formTitleNew : DespesaConfig.formTitleEdit;
  }

  String getSubmitButtonText() {
    return _originalDespesa == null ? DespesaConfig.buttonTextSave : DespesaConfig.buttonTextUpdate;
  }

  void resetForm({String? selectedAnimalId}) {
    formModel.update((model) {
      model?.reset(selectedAnimalId: selectedAnimalId);
    });
    _originalDespesa = null;
    _clearErrors();
  }

  Future<DespesaVet?> getDespesaById(String id) async {
    return await _repository.getDespesaById(id);
  }

  Future<bool> deleteDespesa(DespesaVet despesa) async {
    try {
      formState.value = formState.value.copyWith(isLoading: true);
      final result = await _formService.deleteDespesa(
        despesa: despesa,
        repository: _repository,
      );
      return result;
    } catch (e) {
      formState.value = formState.value.copyWith(
        errorMessage: '${DespesaConfig.msgErrorDelete}: $e',
      );
      debugPrint('Error deleting despesa: $e');
      return false;
    } finally {
      formState.value = formState.value.copyWith(isLoading: false);
    }
  }

  Future<bool> deleteCurrentDespesa() async {
    if (_originalDespesa == null) {
      formState.value = formState.value.copyWith(
        errorMessage: 'Nenhuma despesa para excluir',
      );
      return false;
    }
    return await deleteDespesa(_originalDespesa!);
  }

  bool canSubmit() {
    return !isLoading &&
        isValid &&
        fieldErrors.values.every((error) => error == null);
  }

  void clearMessages() {
    formState.value = formState.value.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  String formatValor(double valor) {
    return DespesaConfig.formatCurrency(valor);
  }

  double parseValor(String valorString) {
    try {
      final cleanValue = valorString
          .replaceAll(DespesaConfig.currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll(DespesaConfig.decimalSeparator, '.');
      return double.parse(cleanValue);
    } catch (e) {
      return DespesaConfig.defaultValor;
    }
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    final validation = DespesaFormValidators.validateAllFields(
      animalId: formModel.value.animalId,
      tipo: formModel.value.tipo,
      descricao: formModel.value.descricao,
      valor: formModel.value.valor,
      dataDespesa:
          DateTime.fromMillisecondsSinceEpoch(formModel.value.dataDespesa),
    );

    validation.forEach((field, error) {
      if (error != null) {
        errors.add('$field: $error');
      }
    });

    return errors;
  }

  @override
  void onClose() {
    try {
      // Dispose of reactive values
      _isLoading.close();
      _isSubmitting.close();
      _hasChanges.close();
      _errorMessage.close();

      // Clear any pending operations
      debugPrint('DespesaFormController disposed successfully');
    } catch (e) {
      debugPrint('Error disposing DespesaFormController: $e');
    } finally {
      super.onClose();
    }
  }
}
