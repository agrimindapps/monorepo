// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/vacina_form_model.dart';

/// Mixin for managing form state and validation
mixin FormStateMixin<T extends StatefulWidget> on State<T> {
  // Form controllers
  late TextEditingController nomeVacinaController;
  late TextEditingController observacoesController;

  // Focus nodes
  late FocusNode nomeVacinaFocusNode;
  late FocusNode dataAplicacaoFocusNode;
  late FocusNode proximaDoseFocusNode;
  late FocusNode observacoesFocusNode;

  // Form validation state
  VacinaFormModel _formModel = const VacinaFormModel();

  // Getters
  VacinaFormModel get formModel => _formModel;
  bool get formValid => _formModel.isFormValid;
  bool get isSubmitting => _formModel.isSubmitting;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _setupListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    _disposeFocusNodes();
    super.dispose();
  }

  /// Initialize text controllers
  void _initializeControllers() {
    nomeVacinaController = TextEditingController();
    observacoesController = TextEditingController();
  }

  /// Initialize focus nodes
  void _initializeFocusNodes() {
    nomeVacinaFocusNode = FocusNode();
    dataAplicacaoFocusNode = FocusNode();
    proximaDoseFocusNode = FocusNode();
    observacoesFocusNode = FocusNode();
  }

  /// Setup controller listeners
  void _setupListeners() {
    nomeVacinaController.addListener(_onNomeVacinaChanged);
    observacoesController.addListener(_onObservacoesChanged);

    // Setup focus listeners for validation
    nomeVacinaFocusNode.addListener(() => _onFieldFocusChanged('nomeVacina'));
    observacoesFocusNode.addListener(() => _onFieldFocusChanged('observacoes'));
  }

  /// Dispose controllers
  void _disposeControllers() {
    nomeVacinaController.dispose();
    observacoesController.dispose();
  }

  /// Dispose focus nodes
  void _disposeFocusNodes() {
    nomeVacinaFocusNode.dispose();
    dataAplicacaoFocusNode.dispose();
    proximaDoseFocusNode.dispose();
    observacoesFocusNode.dispose();
  }

  /// Handle vaccine name changes
  void _onNomeVacinaChanged() {
    _validateField('nomeVacina', nomeVacinaController.text);
  }

  /// Handle observations changes
  void _onObservacoesChanged() {
    _validateField('observacoes', observacoesController.text);
  }

  /// Handle field focus changes
  void _onFieldFocusChanged(String fieldName) {
    if (!_getFocusNode(fieldName).hasFocus) {
      _markFieldTouched(fieldName);
    }
  }

  /// Get focus node for field
  FocusNode _getFocusNode(String fieldName) {
    switch (fieldName) {
      case 'nomeVacina':
        return nomeVacinaFocusNode;
      case 'dataAplicacao':
        return dataAplicacaoFocusNode;
      case 'proximaDose':
        return proximaDoseFocusNode;
      case 'observacoes':
        return observacoesFocusNode;
      default:
        throw ArgumentError('Unknown field: $fieldName');
    }
  }

  /// Update form model state
  void updateFormModel(VacinaFormModel newModel) {
    setState(() {
      _formModel = newModel;
    });
  }

  /// Validate specific field
  void _validateField(String fieldName, String? value) {
    final updatedModel = _formModel.validateField(fieldName, value);
    updateFormModel(updatedModel);
  }

  /// Mark field as touched
  void _markFieldTouched(String fieldName) {
    final updatedModel = _formModel.markFieldTouched(fieldName);
    updateFormModel(updatedModel);
  }

  /// Clear all form errors
  void clearFormErrors() {
    updateFormModel(_formModel.clearAllErrors());
  }

  /// Set form error for specific field
  void setFieldError(String fieldName, String? error) {
    final updatedModel = _formModel.setFieldError(fieldName, error);
    updateFormModel(updatedModel);
  }

  /// Set form submitting state
  void setSubmitting(bool isSubmitting) {
    final updatedModel = _formModel.copyWith(isSubmitting: isSubmitting);
    updateFormModel(updatedModel);
  }

  /// Reset form to initial state
  void resetForm() {
    nomeVacinaController.clear();
    observacoesController.clear();
    updateFormModel(const VacinaFormModel());
    _clearAllFocus();
  }

  /// Clear focus from all fields
  void _clearAllFocus() {
    nomeVacinaFocusNode.unfocus();
    dataAplicacaoFocusNode.unfocus();
    proximaDoseFocusNode.unfocus();
    observacoesFocusNode.unfocus();
  }

  /// Focus on next field
  void focusNextField(String currentField) {
    switch (currentField) {
      case 'nomeVacina':
        dataAplicacaoFocusNode.requestFocus();
        break;
      case 'dataAplicacao':
        proximaDoseFocusNode.requestFocus();
        break;
      case 'proximaDose':
        observacoesFocusNode.requestFocus();
        break;
      case 'observacoes':
        _clearAllFocus();
        break;
    }
  }

  /// Check if field has error and is touched
  bool shouldShowFieldError(String fieldName) {
    return _formModel.shouldShowError(fieldName);
  }

  /// Get error message for field
  String? getFieldError(String fieldName) {
    return _formModel.getFieldError(fieldName);
  }

  /// Validate all form fields at once
  void validateFormFields(Map<String, String?> fieldValues) {
    var updatedModel = _formModel;

    fieldValues.forEach((fieldName, value) {
      updatedModel = updatedModel.validateField(fieldName, value);
      updatedModel = updatedModel.markFieldTouched(fieldName);
    });

    updateFormModel(updatedModel);
  }

  /// Pre-fill form with existing data
  void populateForm({
    String? nomeVacina,
    String? observacoes,
  }) {
    if (nomeVacina != null) {
      nomeVacinaController.text = nomeVacina;
    }
    if (observacoes != null) {
      observacoesController.text = observacoes;
    }

    // Validate pre-filled data
    validateFormFields({
      'nomeVacina': nomeVacina ?? '',
      'observacoes': observacoes ?? '',
    });
  }
}
