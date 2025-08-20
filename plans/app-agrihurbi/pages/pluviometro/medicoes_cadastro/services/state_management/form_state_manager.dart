// Flutter imports:
import 'package:flutter/foundation.dart';

/// Resultado de validação para um campo
class FieldValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;

  const FieldValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
  });

  factory FieldValidationResult.valid() {
    return const FieldValidationResult(isValid: true);
  }

  factory FieldValidationResult.invalid(String message) {
    return FieldValidationResult(isValid: false, errorMessage: message);
  }

  factory FieldValidationResult.warning(String message) {
    return FieldValidationResult(isValid: true, warningMessage: message);
  }
}

/// Estado de um campo do formulário
class ManagedFieldState<T> {
  final T value;
  final FieldValidationResult validation;
  final bool hasChanged;
  final bool isFocused;

  const ManagedFieldState({
    required this.value,
    this.validation = const FieldValidationResult(isValid: true),
    this.hasChanged = false,
    this.isFocused = false,
  });

  ManagedFieldState<T> copyWith({
    T? value,
    FieldValidationResult? validation,
    bool? hasChanged,
    bool? isFocused,
  }) {
    return ManagedFieldState<T>(
      value: value ?? this.value,
      validation: validation ?? this.validation,
      hasChanged: hasChanged ?? this.hasChanged,
      isFocused: isFocused ?? this.isFocused,
    );
  }
}

/// Gerenciador de estado para formulários
class FormStateManager extends ChangeNotifier {
  final Map<String, ManagedFieldState> _fields = {};
  final Map<String, dynamic> _initialValues = {};
  bool _isSubmitting = false;

  /// Obtém o estado de um campo
  ManagedFieldState<T> getFieldState<T>(String fieldName) {
    return _fields[fieldName] as ManagedFieldState<T>? ??
        ManagedFieldState<T>(value: _initialValues[fieldName] as T);
  }

  /// Obtém o valor de um campo
  T getFieldValue<T>(String fieldName) {
    return getFieldState<T>(fieldName).value;
  }

  /// Define um valor inicial para um campo
  void setInitialValue<T>(String fieldName, T value) {
    _initialValues[fieldName] = value;
    if (!_fields.containsKey(fieldName)) {
      _fields[fieldName] = ManagedFieldState<T>(value: value);
    }
  }

  /// Atualiza o valor de um campo
  void updateField<T>(
    String fieldName,
    T value, {
    FieldValidationResult? validation,
    bool? isFocused,
  }) {
    final currentState = getFieldState<T>(fieldName);
    final hasChanged = value != _initialValues[fieldName];

    _fields[fieldName] = currentState.copyWith(
      value: value,
      validation: validation,
      hasChanged: hasChanged,
      isFocused: isFocused,
    );

    notifyListeners();
  }

  /// Valida um campo específico
  void validateField<T>(String fieldName, FieldValidationResult validation) {
    final currentState = getFieldState<T>(fieldName);
    _fields[fieldName] = currentState.copyWith(validation: validation);
    notifyListeners();
  }

  /// Define o foco de um campo
  void setFieldFocus(String fieldName, bool isFocused) {
    final currentState = getFieldState(fieldName);
    _fields[fieldName] = currentState.copyWith(isFocused: isFocused);
    notifyListeners();
  }

  /// Verifica se o formulário é válido
  bool get isFormValid {
    return _fields.values.every((field) => field.validation.isValid);
  }

  /// Verifica se o formulário foi modificado
  bool get isFormDirty {
    return _fields.values.any((field) => field.hasChanged);
  }

  /// Verifica se está enviando
  bool get isSubmitting => _isSubmitting;

  /// Define o estado de submissão
  void setSubmitting(bool isSubmitting) {
    _isSubmitting = isSubmitting;
    notifyListeners();
  }

  /// Obtém todos os erros do formulário
  Map<String, String> get formErrors {
    final errors = <String, String>{};
    _fields.forEach((key, field) {
      if (field.validation.errorMessage != null) {
        errors[key] = field.validation.errorMessage!;
      }
    });
    return errors;
  }

  /// Obtém todos os warnings do formulário
  Map<String, String> get formWarnings {
    final warnings = <String, String>{};
    _fields.forEach((key, field) {
      if (field.validation.warningMessage != null) {
        warnings[key] = field.validation.warningMessage!;
      }
    });
    return warnings;
  }

  /// Reset do formulário
  void reset() {
    _fields.clear();
    _isSubmitting = false;
    notifyListeners();
  }

  /// Obtém dados do formulário como Map
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    _fields.forEach((key, field) {
      data[key] = field.value;
    });
    return data;
  }

  @override
  void dispose() {
    _fields.clear();
    _initialValues.clear();
    super.dispose();
  }
}
