import 'package:flutter/widgets.dart';
import '../interfaces/validation_result.dart';
import '../widgets/validated_form_field.dart';

/// Sistema de validação centralizada para formulários
///
/// Permite validar formulários de forma consistente retornando apenas
/// o primeiro erro encontrado, com suporte para scroll automático
/// para o campo com erro.
///
/// Uso:
/// ```dart
/// final validator = FormValidator();
/// validator.addField('email', _emailController, ValidationType.email, required: true);
/// validator.addField('name', _nameController, ValidationType.length, required: true, minLength: 2);
///
/// final result = await validator.validateAll();
/// if (!result.isValid) {
///   // Exibir erro no header
///   setState(() => _headerError = result.message);
///   // Scroll para campo com erro
///   validator.scrollToFirstError();
/// }
/// ```
class FormValidator {
  final List<FormFieldData> _fields = [];
  final Map<String, GlobalKey> _fieldKeys = {};

  /// Adiciona um campo para validação
  ///
  /// [fieldId] - Identificador único do campo
  /// [controller] - Controller do campo
  /// [validationType] - Tipo de validação predefinida
  /// [required] - Se o campo é obrigatório
  /// [customValidator] - Validador customizado (opcional)
  /// [scrollKey] - Key para scroll automático (opcional)
  /// [minLength], [maxLength] - Validação de comprimento
  /// [minValue], [maxValue] - Validação de valores numéricos
  void addField(
    String fieldId,
    TextEditingController controller,
    ValidationType validationType, {
    bool required = false,
    String? Function(String?)? customValidator,
    GlobalKey? scrollKey,
    int? minLength,
    int? maxLength,
    double? minValue,
    double? maxValue,
    String? label,
    String? pattern,
    double? currentOdometer,
    double? initialOdometer,
    double? tankCapacity,
  }) {
    final key = scrollKey ?? GlobalKey();
    _fieldKeys[fieldId] = key;

    _fields.add(FormFieldData(
      fieldId: fieldId,
      controller: controller,
      validationType: validationType,
      required: required,
      customValidator: customValidator,
      scrollKey: key,
      minLength: minLength,
      maxLength: maxLength,
      minValue: minValue,
      maxValue: maxValue,
      label: label ?? fieldId,
      pattern: pattern,
      currentOdometer: currentOdometer,
      initialOdometer: initialOdometer,
      tankCapacity: tankCapacity,
    ));
  }

  /// Remove um campo da validação
  void removeField(String fieldId) {
    _fields.removeWhere((field) => field.fieldId == fieldId);
    _fieldKeys.remove(fieldId);
  }

  /// Limpa todos os campos
  void clear() {
    _fields.clear();
    _fieldKeys.clear();
  }

  /// Valida todos os campos e retorna o primeiro erro encontrado
  ///
  /// Retorna [ValidationResult.success()] se todos os campos forem válidos,
  /// ou [ValidationResult.error(message)] com a mensagem do primeiro erro.
  Future<ValidationResult> validateAll() async {
    for (final field in _fields) {
      final result = await _validateField(field);
      if (!result.isValid) {
        return ValidationResult.error(result.message);
      }
    }

    return ValidationResult.success();
  }

  /// Valida um campo específico
  Future<ValidationResult> validateField(String fieldId) async {
    final field = _fields.firstWhere(
      (f) => f.fieldId == fieldId,
      orElse: () => throw ArgumentError('Campo "$fieldId" não encontrado'),
    );

    return await _validateField(field);
  }

  /// Retorna a lista de todos os erros (para debugging)
  Future<List<FieldValidationResult>> getAllErrors() async {
    final results = <FieldValidationResult>[];

    for (final field in _fields) {
      final result = await _validateField(field);
      if (!result.isValid) {
        results.add(FieldValidationResult(
          fieldId: field.fieldId,
          label: field.label,
          result: result,
        ));
      }
    }

    return results;
  }

  /// Faz scroll para o primeiro campo com erro
  ///
  /// Deve ser chamado após validateAll() retornar erro.
  /// Usa Scrollable.ensureVisible para fazer scroll suave.
  Future<void> scrollToFirstError() async {
    for (final field in _fields) {
      final result = await _validateField(field);
      if (!result.isValid) {
        final context = field.scrollKey.currentContext;
        if (context != null && context.mounted) {
          await Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1, // Scroll para mostrar o campo próximo ao topo
          );
        }
        break;
      }
    }
  }

  /// Obtém a key de scroll de um campo específico
  GlobalKey? getFieldKey(String fieldId) {
    return _fieldKeys[fieldId];
  }

  /// Valida se há campos obrigatórios vazios
  List<String> getEmptyRequiredFields() {
    final emptyFields = <String>[];

    for (final field in _fields) {
      if (field.required && field.controller.text.trim().isEmpty) {
        emptyFields.add(field.label);
      }
    }

    return emptyFields;
  }

  /// Valida um campo individualmente usando o sistema existente
  Future<ValidationResult> _validateField(FormFieldData field) async {
    final text = field.controller.text;

    // Validador customizado tem prioridade
    if (field.customValidator != null) {
      final error = field.customValidator!(text);
      return error != null
          ? ValidationResult.error(error)
          : ValidationResult.success();
    }

    // Usar sistema de validação existente do ValidatedFormField
    final validationService = _ValidationServiceAdapter();

    return validationService.validateByType(
      text,
      field.validationType,
      label: field.label,
      required: field.required,
      minLength: field.minLength,
      maxLength: field.maxLength,
      minValue: field.minValue,
      maxValue: field.maxValue,
      pattern: field.pattern,
      currentOdometer: field.currentOdometer,
      initialOdometer: field.initialOdometer,
      tankCapacity: field.tankCapacity,
    );
  }
}

/// Dados de um campo do formulário
class FormFieldData {

  FormFieldData({
    required this.fieldId,
    required this.controller,
    required this.validationType,
    required this.required,
    this.customValidator,
    required this.scrollKey,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    required this.label,
    this.pattern,
    this.currentOdometer,
    this.initialOdometer,
    this.tankCapacity,
  });
  final String fieldId;
  final TextEditingController controller;
  final ValidationType validationType;
  final bool required;
  final String? Function(String?)? customValidator;
  final GlobalKey scrollKey;
  final int? minLength;
  final int? maxLength;
  final double? minValue;
  final double? maxValue;
  final String label;
  final String? pattern;
  final double? currentOdometer;
  final double? initialOdometer;
  final double? tankCapacity;
}

/// Resultado de validação de um campo específico
class FieldValidationResult {

  FieldValidationResult({
    required this.fieldId,
    required this.label,
    required this.result,
  });
  final String fieldId;
  final String label;
  final ValidationResult result;

  @override
  String toString() {
    return 'FieldValidationResult($label: ${result.message})';
  }
}

/// Adaptador para reutilizar o sistema de validação existente
///
/// Esta classe permite que o FormValidator use as mesmas validações
/// do ValidatedFormField sem duplicar código.
class _ValidationServiceAdapter {
  ValidationResult validateByType(
    String text,
    ValidationType type, {
    required String label,
    required bool required,
    int? minLength,
    int? maxLength,
    double? minValue,
    double? maxValue,
    String? pattern,
    double? currentOdometer,
    double? initialOdometer,
    double? tankCapacity,
  }) {
    // Importar ValidationService do sistema existente
    // Note: Isso será resolvido na implementação real

    switch (type) {
      case ValidationType.none:
        return ValidationResult.success();

      case ValidationType.required:
        return _validateRequired(text, label);

      case ValidationType.email:
        return _validateEmail(text);

      case ValidationType.phone:
        return _validatePhone(text);

      case ValidationType.money:
        return _validateMoney(text, label,
          min: minValue ?? 0.0,
          max: maxValue ?? 999999.99,
          required: required);

      case ValidationType.decimal:
        return _validateDecimal(text, label,
          min: minValue,
          max: maxValue,
          required: required);

      case ValidationType.integer:
        return _validateInteger(text, label,
          min: minValue?.toInt(),
          max: maxValue?.toInt(),
          required: required);

      case ValidationType.licensePlate:
        return _validateLicensePlate(text);

      case ValidationType.chassis:
        return _validateChassis(text);

      case ValidationType.renavam:
        return _validateRenavam(text);

      case ValidationType.odometer:
        return _validateOdometer(text,
          currentOdometer: currentOdometer,
          initialOdometer: initialOdometer,
          required: required);

      case ValidationType.fuelLiters:
        return _validateFuelLiters(text,
          tankCapacity: tankCapacity,
          required: required);

      case ValidationType.fuelPrice:
        return _validateFuelPrice(text, required: required);

      case ValidationType.length:
        return _validateLength(text, label,
          minLength: minLength ?? 0,
          maxLength: maxLength ?? 255);

      case ValidationType.custom:
        return ValidationResult.success(); // Handled by customValidator
    }
  }

  // Implementações das validações (baseadas no sistema existente)

  ValidationResult _validateRequired(String text, String label) {
    if (text.trim().isEmpty) {
      return ValidationResult.error('$label é obrigatório');
    }
    return ValidationResult.success();
  }

  ValidationResult _validateEmail(String text) {
    if (text.isEmpty) return ValidationResult.success();

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(text)) {
      return ValidationResult.error('Email inválido');
    }
    return ValidationResult.success();
  }

  ValidationResult _validatePhone(String text) {
    if (text.isEmpty) return ValidationResult.success();

    final phoneRegex = RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(text)) {
      return ValidationResult.error('Telefone inválido');
    }
    return ValidationResult.success();
  }

  ValidationResult _validateMoney(String text, String label, {
    required double min,
    required double max,
    required bool required,
  }) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('$label é obrigatório')
          : ValidationResult.success();
    }

    final cleanText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalizedText = cleanText.replaceAll(',', '.');
    final value = double.tryParse(normalizedText);

    if (value == null) {
      return ValidationResult.error('$label deve ser um valor válido');
    }

    if (value < min) {
      return ValidationResult.error('$label deve ser maior que R\$ ${min.toStringAsFixed(2)}');
    }

    if (value > max) {
      return ValidationResult.error('$label deve ser menor que R\$ ${max.toStringAsFixed(2)}');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateDecimal(String text, String label, {
    double? min,
    double? max,
    required bool required,
  }) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('$label é obrigatório')
          : ValidationResult.success();
    }

    final cleanText = text.replaceAll(',', '.');
    final value = double.tryParse(cleanText);

    if (value == null) {
      return ValidationResult.error('$label deve ser um número válido');
    }

    if (min != null && value < min) {
      return ValidationResult.error('$label deve ser maior que $min');
    }

    if (max != null && value > max) {
      return ValidationResult.error('$label deve ser menor que $max');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateInteger(String text, String label, {
    int? min,
    int? max,
    required bool required,
  }) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('$label é obrigatório')
          : ValidationResult.success();
    }

    final value = int.tryParse(text);

    if (value == null) {
      return ValidationResult.error('$label deve ser um número inteiro válido');
    }

    if (min != null && value < min) {
      return ValidationResult.error('$label deve ser maior que $min');
    }

    if (max != null && value > max) {
      return ValidationResult.error('$label deve ser menor que $max');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateLicensePlate(String text) {
    if (text.isEmpty) return ValidationResult.success();

    // Formato brasileiro: ABC1234 ou ABC1D23 (Mercosul)
    final oldFormatRegex = RegExp(r'^[A-Z]{3}\d{4}$');
    final mercosulFormatRegex = RegExp(r'^[A-Z]{3}\d[A-Z]\d{2}$');

    if (!oldFormatRegex.hasMatch(text) && !mercosulFormatRegex.hasMatch(text)) {
      return ValidationResult.error('Placa inválida (use ABC1234 ou ABC1D23)');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateChassis(String text) {
    if (text.isEmpty) return ValidationResult.success();

    if (text.length != 17) {
      return ValidationResult.error('Chassi deve ter 17 caracteres');
    }

    // Chassi não pode conter I, O, Q
    final invalidChars = RegExp(r'[IOQ]');
    if (invalidChars.hasMatch(text)) {
      return ValidationResult.error('Chassi não pode conter as letras I, O ou Q');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateRenavam(String text) {
    if (text.isEmpty) return ValidationResult.success();

    if (text.length != 11) {
      return ValidationResult.error('Renavam deve ter 11 dígitos');
    }

    // Validação básica de dígito verificador
    final digits = text.split('').map(int.parse).toList();
    final sequence = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * sequence[i];
    }

    final mod = sum % 11;
    final expectedDigit = mod < 2 ? 0 : 11 - mod;

    if (digits[10] != expectedDigit) {
      return ValidationResult.error('Renavam inválido');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateOdometer(String text, {
    double? currentOdometer,
    double? initialOdometer,
    required bool required,
  }) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('Odômetro é obrigatório')
          : ValidationResult.success();
    }

    final cleanText = text.replaceAll(',', '.');
    final value = double.tryParse(cleanText);

    if (value == null) {
      return ValidationResult.error('Odômetro deve ser um número válido');
    }

    if (value < 0) {
      return ValidationResult.error('Odômetro não pode ser negativo');
    }

    if (currentOdometer != null && value < currentOdometer) {
      return ValidationResult.error('Odômetro não pode ser menor que o atual (${currentOdometer.toStringAsFixed(0)} km)');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateFuelLiters(String text, {
    double? tankCapacity,
    required bool required,
  }) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('Litros é obrigatório')
          : ValidationResult.success();
    }

    final cleanText = text.replaceAll(',', '.');
    final value = double.tryParse(cleanText);

    if (value == null) {
      return ValidationResult.error('Litros deve ser um número válido');
    }

    if (value <= 0) {
      return ValidationResult.error('Litros deve ser maior que zero');
    }

    if (tankCapacity != null && value > tankCapacity) {
      return ValidationResult.error('Litros não pode exceder a capacidade do tanque (${tankCapacity.toStringAsFixed(0)}L)');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateFuelPrice(String text, {required bool required}) {
    if (text.isEmpty) {
      return required
          ? ValidationResult.error('Preço é obrigatório')
          : ValidationResult.success();
    }

    final cleanText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalizedText = cleanText.replaceAll(',', '.');
    final value = double.tryParse(normalizedText);

    if (value == null) {
      return ValidationResult.error('Preço deve ser um valor válido');
    }

    if (value <= 0) {
      return ValidationResult.error('Preço deve ser maior que zero');
    }

    if (value > 50.0) {
      return ValidationResult.error('Preço muito alto (máximo R\$ 50,00)');
    }

    return ValidationResult.success();
  }

  ValidationResult _validateLength(String text, String label, {
    required int minLength,
    required int maxLength,
  }) {
    final length = text.trim().length;

    if (length < minLength) {
      return ValidationResult.error('$label deve ter pelo menos $minLength caracteres');
    }

    if (length > maxLength) {
      return ValidationResult.error('$label deve ter no máximo $maxLength caracteres');
    }

    return ValidationResult.success();
  }
}

/// Extensões para facilitar uso do FormValidator
extension FormValidatorExtensions on FormValidator {
  /// Adiciona múltiplos campos de uma vez
  void addFields(List<FormFieldConfig> configs) {
    for (final config in configs) {
      addField(
        config.fieldId,
        config.controller,
        config.validationType,
        required: config.required,
        customValidator: config.customValidator,
        scrollKey: config.scrollKey,
        minLength: config.minLength,
        maxLength: config.maxLength,
        minValue: config.minValue,
        maxValue: config.maxValue,
        label: config.label,
        pattern: config.pattern,
        currentOdometer: config.currentOdometer,
        initialOdometer: config.initialOdometer,
        tankCapacity: config.tankCapacity,
      );
    }
  }

  /// Valida apenas campos obrigatórios
  Future<ValidationResult> validateRequiredOnly() async {
    for (final field in _fields) {
      if (field.required) {
        final result = await _validateField(field);
        if (!result.isValid) {
          return ValidationResult.error(result.message);
        }
      }
    }

    return ValidationResult.success();
  }
}

/// Configuração para adicionar um campo
class FormFieldConfig {

  FormFieldConfig({
    required this.fieldId,
    required this.controller,
    required this.validationType,
    this.required = false,
    this.customValidator,
    this.scrollKey,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.label,
    this.pattern,
    this.currentOdometer,
    this.initialOdometer,
    this.tankCapacity,
  });
  final String fieldId;
  final TextEditingController controller;
  final ValidationType validationType;
  final bool required;
  final String? Function(String?)? customValidator;
  final GlobalKey? scrollKey;
  final int? minLength;
  final int? maxLength;
  final double? minValue;
  final double? maxValue;
  final String? label;
  final String? pattern;
  final double? currentOdometer;
  final double? initialOdometer;
  final double? tankCapacity;
}