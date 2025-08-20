// Flutter imports:
import 'package:flutter/foundation.dart';

/// Gerenciador de estado para formulários
class FormStateManager extends ChangeNotifier {
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, String?> _fieldErrors = {};
  final Map<String, bool> _fieldValidating = {};
  final Map<String, bool> _fieldTouched = {};

  // ValueNotifiers para otimização de rebuilds
  final Map<String, ValueNotifier<String>> _fieldNotifiers = {};
  final ValueNotifier<bool> _submittingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasChangesNotifier = ValueNotifier<bool>(false);

  bool _isSubmitting = false;
  bool _hasChanges = false;

  /// Obtém valor de um campo
  T? getFieldValue<T>(String fieldName) {
    return _fieldValues[fieldName] as T?;
  }

  /// Define valor de um campo
  void setFieldValue<T>(String fieldName, T value) {
    final oldValue = _fieldValues[fieldName];
    if (oldValue != value) {
      _fieldValues[fieldName] = value;
      _hasChanges = true;
      _hasChangesNotifier.value = true;
      _clearFieldError(fieldName);

      // Atualiza ValueNotifier específico do campo
      final notifier = _getFieldNotifier(fieldName);
      notifier.value = value?.toString() ?? '';

      notifyListeners();
    }
  }

  /// Obtém erro de um campo
  String? getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  /// Define erro de um campo
  void setFieldError(String fieldName, String? error) {
    if (_fieldErrors[fieldName] != error) {
      _fieldErrors[fieldName] = error;
      notifyListeners();
    }
  }

  /// Limpa erro de um campo
  void _clearFieldError(String fieldName) {
    if (_fieldErrors[fieldName] != null) {
      _fieldErrors[fieldName] = null;
      notifyListeners();
    }
  }

  /// Verifica se campo está sendo validado
  bool isFieldValidating(String fieldName) {
    return _fieldValidating[fieldName] ?? false;
  }

  /// Define status de validação de um campo
  void setFieldValidating(String fieldName, bool validating) {
    if (_fieldValidating[fieldName] != validating) {
      _fieldValidating[fieldName] = validating;
      notifyListeners();
    }
  }

  /// Verifica se campo foi tocado
  bool isFieldTouched(String fieldName) {
    return _fieldTouched[fieldName] ?? false;
  }

  /// Marca campo como tocado
  void setFieldTouched(String fieldName, bool touched) {
    if (_fieldTouched[fieldName] != touched) {
      _fieldTouched[fieldName] = touched;
      notifyListeners();
    }
  }

  /// Verifica se está enviando
  bool get isSubmitting => _isSubmitting;

  /// Define status de envio
  void setSubmitting(bool submitting) {
    if (_isSubmitting != submitting) {
      _isSubmitting = submitting;
      _submittingNotifier.value = submitting;
      notifyListeners();
    }
  }

  /// Verifica se formulário tem mudanças
  bool get hasChanges => _hasChanges;

  /// Marca formulário como salvo
  void markAsSaved() {
    _hasChanges = false;
    _hasChangesNotifier.value = false;
    notifyListeners();
  }

  /// Verifica se formulário é válido
  bool get isValid => _fieldErrors.values.every((error) => error == null);

  /// Verifica se algum campo está sendo validado
  bool get isValidating =>
      _fieldValidating.values.any((validating) => validating);

  /// Obtém todos os valores dos campos
  Map<String, dynamic> get allValues => Map.from(_fieldValues);

  /// Obtém todos os erros dos campos
  Map<String, String?> get allErrors => Map.from(_fieldErrors);

  /// Valida um campo específico
  Future<void> validateField(
    String fieldName,
    String? Function(dynamic) validator,
  ) async {
    setFieldValidating(fieldName, true);

    try {
      final value = _fieldValues[fieldName];
      final error = validator(value);
      setFieldError(fieldName, error);
    } finally {
      setFieldValidating(fieldName, false);
    }
  }

  /// Valida todos os campos
  Future<bool> validateAll(
      Map<String, String? Function(dynamic)> validators) async {
    final futures = validators.entries.map((entry) async {
      await validateField(entry.key, entry.value);
    });

    await Future.wait(futures);
    return isValid;
  }

  /// Reseta o formulário
  void reset() {
    _fieldValues.clear();
    _fieldErrors.clear();
    _fieldValidating.clear();
    _fieldTouched.clear();
    _isSubmitting = false;
    _hasChanges = false;

    // Reseta ValueNotifiers
    _submittingNotifier.value = false;
    _hasChangesNotifier.value = false;
    for (final notifier in _fieldNotifiers.values) {
      notifier.value = '';
    }

    notifyListeners();
  }

  /// Reseta apenas os erros
  void resetErrors() {
    _fieldErrors.clear();
    notifyListeners();
  }

  /// Preenche formulário com dados
  void populate(Map<String, dynamic> data) {
    _fieldValues.clear();
    _fieldValues.addAll(data);
    _hasChanges = false;
    _hasChangesNotifier.value = false;

    // Atualiza ValueNotifiers dos campos
    for (final entry in data.entries) {
      final notifier = _getFieldNotifier(entry.key);
      notifier.value = entry.value?.toString() ?? '';
    }

    resetErrors();
  }

  /// Obtém estatísticas do formulário
  FormStats get stats => FormStats(
        totalFields: _fieldValues.length,
        validFields: _fieldErrors.values.where((error) => error == null).length,
        touchedFields: _fieldTouched.values.where((touched) => touched).length,
        validatingFields:
            _fieldValidating.values.where((validating) => validating).length,
      );

  /// Obtém ValueNotifier de um campo específico
  ValueNotifier<String> getFieldNotifier(String fieldName) {
    return _getFieldNotifier(fieldName);
  }

  /// Obtém ValueNotifier do status de submissão
  ValueNotifier<bool> getSubmittingNotifier() {
    return _submittingNotifier;
  }

  /// Obtém ValueNotifier do status de mudanças
  ValueNotifier<bool> getHasChangesNotifier() {
    return _hasChangesNotifier;
  }

  /// Obtém ou cria ValueNotifier para um campo
  ValueNotifier<String> _getFieldNotifier(String fieldName) {
    if (!_fieldNotifiers.containsKey(fieldName)) {
      final currentValue = _fieldValues[fieldName]?.toString() ?? '';
      _fieldNotifiers[fieldName] = ValueNotifier<String>(currentValue);
    }
    return _fieldNotifiers[fieldName]!;
  }

  @override
  void dispose() {
    _fieldValues.clear();
    _fieldErrors.clear();
    _fieldValidating.clear();
    _fieldTouched.clear();

    // Dispose ValueNotifiers
    for (final notifier in _fieldNotifiers.values) {
      notifier.dispose();
    }
    _fieldNotifiers.clear();
    _submittingNotifier.dispose();
    _hasChangesNotifier.dispose();

    super.dispose();
  }
}

/// Estatísticas do formulário
class FormStats {
  final int totalFields;
  final int validFields;
  final int touchedFields;
  final int validatingFields;

  FormStats({
    required this.totalFields,
    required this.validFields,
    required this.touchedFields,
    required this.validatingFields,
  });

  int get invalidFields => totalFields - validFields;
  double get validationProgress =>
      totalFields > 0 ? validFields / totalFields : 0.0;

  @override
  String toString() {
    return 'FormStats(total: $totalFields, valid: $validFields, touched: $touchedFields, validating: $validatingFields)';
  }
}
