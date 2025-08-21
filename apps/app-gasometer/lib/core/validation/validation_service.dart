import 'dart:async';
import '../interfaces/validation_result.dart';

/// Serviço central de validação unificado para todo o app
/// 
/// Responsável por:
/// - Validações síncronas e assíncronas
/// - Formatação e sanitização de dados
/// - Validações contextuais baseadas em dependências
/// - Padronização de mensagens de erro
/// - Validações de segurança (XSS, injection)
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Cache para validações complexas
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, ValidationResult> _validationCache = {};

  /// Limpa todos os timers de debounce
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _validationCache.clear();
  }

  /// Sanitiza entrada para prevenir XSS e injection
  String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\\&%$#@!*()[\]{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\-\.\,À-ÿ]'), '');
  }

  /// Valida email
  ValidationResult validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success();
    }

    final sanitized = sanitizeInput(value);
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    
    if (!emailRegex.hasMatch(sanitized)) {
      return ValidationResult.error('Email inválido');
    }

    return ValidationResult.success();
  }

  /// Valida campos obrigatórios
  ValidationResult validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('$fieldName é obrigatório');
    }
    return ValidationResult.success();
  }

  /// Valida comprimento de texto
  ValidationResult validateLength(String? value, String fieldName, {
    int minLength = 0,
    int maxLength = 255,
  }) {
    if (value == null) return ValidationResult.success();
    
    final sanitized = sanitizeInput(value);
    
    if (sanitized.length < minLength) {
      return ValidationResult.error(
        '$fieldName deve ter pelo menos $minLength caracteres'
      );
    }
    
    if (sanitized.length > maxLength) {
      return ValidationResult.error(
        '$fieldName deve ter no máximo $maxLength caracteres'
      );
    }
    
    return ValidationResult.success();
  }

  /// Valida números decimais
  ValidationResult validateDecimal(String? value, String fieldName, {
    double? min,
    double? max,
    bool required = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required 
          ? ValidationResult.error('$fieldName é obrigatório')
          : ValidationResult.success();
    }

    final cleanValue = value.replaceAll(',', '.').replaceAll(RegExp(r'[^\d\.]'), '');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return ValidationResult.error('$fieldName deve ser um número válido');
    }

    if (min != null && number < min) {
      return ValidationResult.error('$fieldName deve ser pelo menos $min');
    }

    if (max != null && number > max) {
      return ValidationResult.error('$fieldName deve ser no máximo $max');
    }

    return ValidationResult.success();
  }

  /// Valida números inteiros
  ValidationResult validateInteger(String? value, String fieldName, {
    int? min,
    int? max,
    bool required = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required 
          ? ValidationResult.error('$fieldName é obrigatório')
          : ValidationResult.success();
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    final number = int.tryParse(cleanValue);

    if (number == null) {
      return ValidationResult.error('$fieldName deve ser um número inteiro válido');
    }

    if (min != null && number < min) {
      return ValidationResult.error('$fieldName deve ser pelo menos $min');
    }

    if (max != null && number > max) {
      return ValidationResult.error('$fieldName deve ser no máximo $max');
    }

    return ValidationResult.success();
  }

  /// Valida datas
  ValidationResult validateDate(DateTime? date, String fieldName, {
    DateTime? minDate,
    DateTime? maxDate,
    bool allowFuture = false,
    bool required = false,
  }) {
    if (date == null) {
      return required 
          ? ValidationResult.error('$fieldName é obrigatório')
          : ValidationResult.success();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (!allowFuture && selectedDate.isAfter(today)) {
      return ValidationResult.error('$fieldName não pode ser futura');
    }

    if (minDate != null && selectedDate.isBefore(minDate)) {
      return ValidationResult.error(
        '$fieldName não pode ser anterior a ${_formatDate(minDate)}'
      );
    }

    if (maxDate != null && selectedDate.isAfter(maxDate)) {
      return ValidationResult.error(
        '$fieldName não pode ser posterior a ${_formatDate(maxDate)}'
      );
    }

    return ValidationResult.success();
  }

  /// Valida valores monetários
  ValidationResult validateMoney(String? value, String fieldName, {
    double min = 0.0,
    double max = 999999.99,
    bool required = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required 
          ? ValidationResult.error('$fieldName é obrigatório')
          : ValidationResult.success();
    }

    // Remove formatação monetária
    final cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d\.]'), '');

    final amount = double.tryParse(cleanValue);

    if (amount == null) {
      return ValidationResult.error('$fieldName deve ser um valor válido');
    }

    if (amount < min) {
      return ValidationResult.error(
        '$fieldName deve ser pelo menos R\$ ${min.toStringAsFixed(2)}'
      );
    }

    if (amount > max) {
      return ValidationResult.error(
        '$fieldName deve ser no máximo R\$ ${max.toStringAsFixed(2)}'
      );
    }

    return ValidationResult.success();
  }

  /// Valida telefone brasileiro
  ValidationResult validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(); // Opcional por padrão
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 11) {
      return ValidationResult.error('Telefone deve ter 10 ou 11 dígitos');
    }

    if (cleaned.length == 11 && !cleaned.startsWith(RegExp(r'[1-9][1-9]9'))) {
      return ValidationResult.error('Formato de celular inválido');
    }
    
    if (cleaned.length == 10 && !cleaned.startsWith(RegExp(r'[1-9][1-9]'))) {
      return ValidationResult.error('Formato de telefone inválido');
    }

    return ValidationResult.success();
  }

  /// Validação com debounce para performance
  Future<ValidationResult> validateWithDebounce(
    String key,
    String? value,
    ValidationResult Function() validator, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    // Cancela timer anterior se existir
    _debounceTimers[key]?.cancel();

    final completer = Completer<ValidationResult>();

    _debounceTimers[key] = Timer(delay, () {
      try {
        final result = validator();
        _validationCache[key] = result;
        completer.complete(result);
      } catch (e) {
        completer.complete(ValidationResult.error('Erro na validação: $e'));
      }
    });

    return completer.future;
  }

  /// Combina múltiplas validações
  ValidationResult combineValidations(List<ValidationResult> results) {
    for (var result in results) {
      if (!result.isValid) {
        return result;
      }
    }
    return ValidationResult.success();
  }

  /// Formatar data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  /// Validações específicas para o contexto automotivo

  /// Valida placa de veículo (Brasil)
  ValidationResult validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.error('Placa é obrigatória');
    }

    final cleanValue = sanitizeInput(value.replaceAll(RegExp(r'[^A-Z0-9]'), ''));
    
    // Placa Mercosul: ABC1D23
    final mercosulRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');
    // Placa antiga: ABC1234
    final antigaRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    
    if (!mercosulRegex.hasMatch(cleanValue) && !antigaRegex.hasMatch(cleanValue)) {
      return ValidationResult.error('Formato de placa inválido. Use ABC1234 ou ABC1D23');
    }
    
    return ValidationResult.success();
  }

  /// Valida chassi de veículo
  ValidationResult validateChassis(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success(); // Opcional
    }

    final cleanValue = sanitizeInput(value.replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), ''));
    
    if (cleanValue.length != 17) {
      return ValidationResult.error('Chassi deve ter 17 caracteres');
    }
    
    // Chassi não pode conter I, O, Q
    if (RegExp(r'[IOQ]').hasMatch(cleanValue)) {
      return ValidationResult.error('Chassi não pode conter as letras I, O ou Q');
    }
    
    return ValidationResult.success();
  }

  /// Valida RENAVAM
  ValidationResult validateRenavam(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.success(); // Opcional
    }

    final cleanValue = sanitizeInput(value.trim());
    
    if (cleanValue.length != 11) {
      return ValidationResult.error('RENAVAM deve ter 11 dígitos');
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return ValidationResult.error('RENAVAM deve conter apenas números');
    }
    
    return ValidationResult.success();
  }

  /// Valida odômetro com contexto
  ValidationResult validateOdometer(String? value, {
    double? currentOdometer,
    double? initialOdometer,
    double? maxAllowedDifference = 50000,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required 
          ? ValidationResult.error('Odômetro é obrigatório')
          : ValidationResult.success();
    }

    final cleanValue = value.replaceAll(',', '.');
    final odometer = double.tryParse(cleanValue);
    
    if (odometer == null || odometer < 0) {
      return ValidationResult.error('Odômetro deve ser um número válido não negativo');
    }
    
    if (odometer > 9999999) {
      return ValidationResult.error('Valor do odômetro muito alto');
    }

    // Validação contextual com odômetro inicial
    if (initialOdometer != null && odometer < initialOdometer) {
      return ValidationResult.error(
        'Odômetro não pode ser menor que o inicial (${initialOdometer.toStringAsFixed(0)} km)'
      );
    }

    // Validação contextual com odômetro atual
    if (currentOdometer != null) {
      if (odometer < currentOdometer - 1000) {
        return ValidationResult.error('Odômetro muito abaixo do atual');
      }
      
      if (maxAllowedDifference != null && 
          (odometer - currentOdometer).abs() > maxAllowedDifference) {
        return ValidationResult.warning(
          'Diferença muito grande no odômetro (${(odometer - currentOdometer).abs().toStringAsFixed(0)} km)'
        );
      }
    }
    
    return ValidationResult.success();
  }

  /// Valida quantidade de litros de combustível
  ValidationResult validateFuelLiters(String? value, {
    double? tankCapacity,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required 
          ? ValidationResult.error('Quantidade de litros é obrigatória')
          : ValidationResult.success();
    }

    final cleanValue = value.replaceAll(',', '.');
    final liters = double.tryParse(cleanValue);

    if (liters == null || liters <= 0) {
      return ValidationResult.error('Quantidade deve ser maior que zero');
    }

    if (liters > 999.999) {
      return ValidationResult.error('Quantidade muito alta');
    }

    // Validação contextual com capacidade do tanque
    if (tankCapacity != null && liters > tankCapacity * 1.1) {
      return ValidationResult.warning(
        'Quantidade excede capacidade do tanque (${tankCapacity.toStringAsFixed(0)}L)'
      );
    }

    return ValidationResult.success();
  }

  /// Valida preço por litro de combustível
  ValidationResult validateFuelPrice(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required 
          ? ValidationResult.error('Preço por litro é obrigatório')
          : ValidationResult.success();
    }

    final cleanValue = value.replaceAll(',', '.');
    final price = double.tryParse(cleanValue);

    if (price == null || price <= 0) {
      return ValidationResult.error('Preço deve ser maior que zero');
    }

    if (price < 0.1) {
      return ValidationResult.error('Preço muito baixo (mínimo R\$ 0,10)');
    }

    if (price > 9.999) {
      return ValidationResult.error('Preço muito alto');
    }

    return ValidationResult.success();
  }

  /// Validação de formulário completo
  Map<String, ValidationResult> validateForm(Map<String, dynamic> formData) {
    final results = <String, ValidationResult>{};
    
    for (var entry in formData.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Aplica validações baseadas no nome do campo
      if (key.contains('email')) {
        results[key] = validateEmail(value?.toString());
      } else if (key.contains('placa') || key.contains('plate')) {
        results[key] = validateLicensePlate(value?.toString());
      } else if (key.contains('chassi') || key.contains('chassis')) {
        results[key] = validateChassis(value?.toString());
      } else if (key.contains('renavam')) {
        results[key] = validateRenavam(value?.toString());
      } else if (key.contains('odometer') || key.contains('odometro')) {
        results[key] = validateOdometer(value?.toString());
      } else if (key.contains('phone') || key.contains('telefone')) {
        results[key] = validatePhone(value?.toString());
      } else if (key.contains('price') || key.contains('preco')) {
        results[key] = validateFuelPrice(value?.toString());
      } else if (key.contains('liters') || key.contains('litros')) {
        results[key] = validateFuelLiters(value?.toString());
      } else if (key.contains('cost') || key.contains('custo')) {
        results[key] = validateMoney(value?.toString(), 'Custo', required: true);
      }
    }
    
    return results;
  }

  /// Verifica se formulário tem erros
  bool hasErrors(Map<String, ValidationResult> results) {
    return results.values.any((result) => !result.isValid);
  }

  /// Obtém lista de mensagens de erro
  List<String> getErrorMessages(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid)
        .map((result) => result.message)
        .where((message) => message.isNotEmpty)
        .toList();
  }

  /// Obtém lista de avisos
  List<String> getWarningMessages(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => result.isWarning)
        .map((result) => result.message)
        .where((message) => message.isNotEmpty)
        .toList();
  }
}

/// Extension para facilitar validações em widgets
extension ValidationServiceExtension on ValidationService {
  /// Valida campo com múltiplas regras
  ValidationResult validateField(String? value, String fieldName, {
    bool required = false,
    int? minLength,
    int? maxLength,
    double? minValue,
    double? maxValue,
    String? pattern,
    bool isEmail = false,
    bool isPhone = false,
    bool isMoney = false,
    bool isPlate = false,
    bool isChassis = false,
    bool isRenavam = false,
  }) {
    final validations = <ValidationResult>[];

    // Validação obrigatória
    if (required) {
      validations.add(validateRequired(value, fieldName));
    }

    // Se campo está vazio e não é obrigatório, retorna sucesso
    if ((value == null || value.isEmpty) && !required) {
      return ValidationResult.success();
    }

    // Validações de comprimento
    if (minLength != null || maxLength != null) {
      validations.add(validateLength(
        value, 
        fieldName,
        minLength: minLength ?? 0,
        maxLength: maxLength ?? 255,
      ));
    }

    // Validações específicas
    if (isEmail) {
      validations.add(validateEmail(value));
    } else if (isPhone) {
      validations.add(validatePhone(value));
    } else if (isMoney) {
      validations.add(validateMoney(
        value, 
        fieldName, 
        min: minValue ?? 0.0,
        max: maxValue ?? 999999.99,
        required: required,
      ));
    } else if (isPlate) {
      validations.add(validateLicensePlate(value));
    } else if (isChassis) {
      validations.add(validateChassis(value));
    } else if (isRenavam) {
      validations.add(validateRenavam(value));
    }

    // Validação por padrão regex
    if (pattern != null && value != null && value.isNotEmpty) {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        validations.add(ValidationResult.error('$fieldName tem formato inválido'));
      }
    }

    return combineValidations(validations);
  }
}