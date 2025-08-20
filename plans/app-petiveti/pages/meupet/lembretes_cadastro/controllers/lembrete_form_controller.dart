// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../../../../repository/lembrete_repository.dart';
import '../../../../services/pet_notification_manager.dart';
import '../config/lembrete_form_config.dart';
import '../models/lembrete_form_model.dart';
import '../models/lembrete_form_state.dart';
import '../services/lembrete_form_service.dart';
import '../utils/lembrete_exceptions.dart';
import '../utils/lembrete_form_validators.dart';

class LembreteFormController extends GetxController {
  final LembreteFormService _formService;

  final formKey = GlobalKey<FormState>();
  final formModel = LembreteFormModel().obs;
  final formState = const LembreteFormState().obs;

  LembreteVet? _originalLembrete;
  
  // Debounce timer para otimização de performance
  Timer? _validationDebounceTimer;

  LembreteFormController({
    LembreteFormService? formService,
  }) : _formService = formService ?? LembreteFormService();

  static Future<LembreteFormController> initialize() async {
    final controller = LembreteFormController();
    Get.put(controller, tag: 'lembrete_form');
    return controller;
  }

  Future<void> initializeController() async {
    try {
      // Usar métodos específicos do estado que são mais eficientes
      formState.value = formState.value.setLoading(true);
      formState.value = formState.value.setInitialized(true);
    } catch (e) {
      formState.value = formState.value.setError('Erro ao inicializar controller: $e');
      debugPrint('Erro ao inicializar controller: $e');
    } finally {
      formState.value = formState.value.setLoading(false);
    }
  }

  void initializeForm({LembreteVet? lembrete, String? selectedAnimalId}) {
    _originalLembrete = lembrete;

    if (lembrete != null) {
      formModel.value = LembreteFormModel.fromLembrete(lembrete);
    } else {
      formModel.value = LembreteFormModel.withAnimalId(selectedAnimalId ?? '');
    }

    _clearErrors();
  }

  void updateTitulo(String value) {
    formModel.update((model) {
      model?.titulo = LembreteFormValidators.sanitizeTitulo(value);
    });
    _validateFieldWithDebounce('titulo');
  }

  void updateDescricao(String value) {
    formModel.update((model) {
      model?.descricao = LembreteFormValidators.sanitizeDescricao(value);
    });
    _validateFieldWithDebounce('descricao');
  }

  void _validateFieldWithDebounce(String fieldName) {
    _validationDebounceTimer?.cancel();
    _validationDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateField(fieldName);
    });
  }

  void updateDataLembrete(DateTime date) {
    formModel.update((model) {
      model?.dataLembrete = DateTime(
        date.year,
        date.month,
        date.day,
        model.dataLembrete.hour,
        model.dataLembrete.minute,
      );
    });
    _validateField('data');
  }

  void updateHoraLembrete(TimeOfDay time) {
    formModel.update((model) {
      model?.horaLembrete = time;
    });
    _validateField('hora');
  }

  void updateTipo(String value) {
    formModel.update((model) {
      model?.tipo = value;
    });
  }

  void updateRepetir(String value) {
    formModel.update((model) {
      model?.repetir = value;
    });
  }

  void updateConcluido(bool value) {
    formModel.update((model) {
      model?.concluido = value;
    });
  }

  void updateAnimalId(String value) {
    formModel.update((model) {
      model?.animalId = value;
    });
  }

  String? validateTitulo(String? value) {
    return LembreteFormValidators.validateTitulo(value);
  }

  String? validateDescricao(String? value) {
    return LembreteFormValidators.validateDescricao(value);
  }

  String? validateData(DateTime? date) {
    return LembreteFormValidators.validateDataHora(date != null
        ? DateTime(
            date.year,
            date.month,
            date.day,
            formModel.value.horaLembrete.hour,
            formModel.value.horaLembrete.minute)
        : null);
  }

  String? validateHora(TimeOfDay? time) {
    if (time == null) return 'Selecione um horário';

    final combinedDateTime = DateTime(
      formModel.value.dataLembrete.year,
      formModel.value.dataLembrete.month,
      formModel.value.dataLembrete.day,
      time.hour,
      time.minute,
    );

    return LembreteFormValidators.validateDataHora(combinedDateTime);
  }

  Future<bool> submitForm() async {
    try {
      // Validação inicial
      if (!_validateFormStructure()) {
        return false;
      }

      formState.value = formState.value.setSubmitting(true);
      formKey.currentState!.save();

      // Validação de dados
      if (!_isFormValid()) {
        formState.value = formState.value.setError('Por favor, corrija os erros no formulário');
        return false;
      }

      // Sanitização dos dados
      final lembrete = _createSanitizedLembrete();
      
      // Tentativa de salvamento
      final result = await _saveWithRetry(lembrete);

      if (result) {
        formState.value = formState.value.setSuccess('Lembrete salvo com sucesso!');
        return true;
      } else {
        formState.value = formState.value.setError('Falha ao salvar. Tente novamente.');
        return false;
      }
    } on ValidationException catch (e) {
      formState.value = formState.value.setError('Dados inválidos: ${e.message}');
      return false;
    } on NetworkException catch (e) {
      formState.value = formState.value.setError('Erro de conexão: ${e.message}');
      return false;
    } on PermissionException catch (e) {
      formState.value = formState.value.setError('Sem permissão: ${e.message}');
      return false;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      formState.value = formState.value.setError(errorMessage);
      debugPrint('Erro ao salvar lembrete: $e');
      return false;
    } finally {
      formState.value = formState.value.setSubmitting(false);
    }
  }

  bool _validateFormStructure() {
    if (formKey.currentState == null) {
      formState.value = formState.value.setError('Formulário não inicializado');
      return false;
    }
    
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    return true;
  }

  LembreteVet _createSanitizedLembrete() {
    final lembrete = _createLembreteFromForm();
    return _formService.sanitizeLembreteData(lembrete);
  }

  Future<bool> _saveWithRetry(LembreteVet lembrete, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await _formService.saveLembrete(
          lembrete: lembrete,
          originalLembrete: _originalLembrete,
          repository: LembreteRepository(),
          notificationManager: PetNotificationManager(),
        );
        
        if (result) return true;
        
        if (attempt == maxRetries) {
          return false;
        }
        
        // Delay progressivo entre tentativas
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        
        // Para erros críticos, não tentar novamente
        if (e is ValidationException || e is PermissionException) {
          rethrow;
        }
        
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    
    return false;
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    } else if (error.toString().contains('permission')) {
      return 'Sem permissão para salvar. Verifique as configurações do app.';
    } else if (error.toString().contains('storage')) {
      return 'Erro de armazenamento. Verifique o espaço disponível.';
    } else {
      return 'Erro inesperado. Tente novamente ou contate o suporte.';
    }
  }

  bool _isFormValid() {
    return LembreteFormValidators.isFormValid(
      titulo: formModel.value.titulo,
      descricao: formModel.value.descricao,
      animalId: formModel.value.animalId,
      dataHora: formModel.value.combinedDateTime,
    );
  }

  void _validateField(String fieldName) {
    final errors = Map<String, String?>.from(formState.value.fieldErrors);

    switch (fieldName) {
      case 'titulo':
        errors['titulo'] = validateTitulo(formModel.value.titulo);
        break;
      case 'descricao':
        errors['descricao'] = validateDescricao(formModel.value.descricao);
        break;
      case 'data':
      case 'hora':
        errors['dataHora'] = validateData(formModel.value.dataLembrete) ??
            validateHora(formModel.value.horaLembrete);
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

  List<String> get tiposOptions => LembreteFormConfig.tiposValidos;
  List<String> get repeticoesOptions => LembreteFormConfig.repeticoesValidas;

  bool get isValid => formModel.value.isValid;

  bool get isLoading => formState.value.isLoading;
  bool get isInitialized => formState.value.isInitialized;
  String? get errorMessage => formState.value.errorMessage;
  String? get successMessage => formState.value.successMessage;
  Map<String, String?> get fieldErrors => formState.value.fieldErrors;

  String getFormTitle() {
    return _originalLembrete == null ? 'Novo Lembrete' : 'Editar Lembrete';
  }

  String getSubmitButtonText() {
    return _originalLembrete == null ? 'Criar Lembrete' : 'Atualizar Lembrete';
  }

  void resetForm({String? selectedAnimalId}) {
    formModel.update((model) {
      model?.reset(selectedAnimalId: selectedAnimalId);
    });
    _originalLembrete = null;
    _clearErrors();
  }

  LembreteVet _createLembreteFromForm() {
    final DateTime combinedDateTime = DateTime(
      formModel.value.dataLembrete.year,
      formModel.value.dataLembrete.month,
      formModel.value.dataLembrete.day,
      formModel.value.horaLembrete.hour,
      formModel.value.horaLembrete.minute,
    );

    return LembreteVet(
      id: _originalLembrete?.id ?? const Uuid().v4(),
      createdAt:
          _originalLembrete?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: false,
      needsSync: _originalLembrete?.needsSync ?? true,
      version: _originalLembrete == null ? 1 : (_originalLembrete?.version ?? 0) + 1,
      lastSyncAt: _originalLembrete?.lastSyncAt,
      animalId: formModel.value.animalId,
      titulo: formModel.value.titulo,
      descricao: formModel.value.descricao,
      dataHora: combinedDateTime.millisecondsSinceEpoch,
      tipo: formModel.value.tipo,
      repetir: formModel.value.repetir,
      concluido: formModel.value.concluido,
    );
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

  @override
  void onInit() {
    super.onInit();
    initializeController();
  }

  @override
  void onClose() {
    _validationDebounceTimer?.cancel();
    super.onClose();
  }
}
