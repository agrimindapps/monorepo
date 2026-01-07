import '../interfaces/validation_result.dart';

/// Estados de validação para feedback visual consistente
enum ValidationStatus {
  initial, // Campo ainda não foi validado
  validating, // Validação em progresso (debounce)
  valid, // Campo válido
  warning, // Campo válido mas com aviso
  error, // Campo inválido
}

/// Tipos de validação unificados para o sistema de formulários
enum UnifiedValidationType {
  text, // Texto simples
  email, // Email
  number, // Número inteiro
  decimal, // Número decimal
  currency, // Valor monetário
  odometer, // Odômetro do veículo
  licensePlate, // Placa do veículo
  chassi, // Chassi do veículo
  renavam, // RENAVAM do veículo
}

/// Resultado de validação unificado que estende o ValidationResult existente
class UnifiedValidationResult {
  const UnifiedValidationResult({
    required this.status,
    this.message,
    this.metadata,
  });

  factory UnifiedValidationResult.initial() =>
      const UnifiedValidationResult(status: ValidationStatus.initial);

  factory UnifiedValidationResult.validating() =>
      const UnifiedValidationResult(status: ValidationStatus.validating);

  factory UnifiedValidationResult.valid([String? message]) =>
      UnifiedValidationResult(status: ValidationStatus.valid, message: message);

  factory UnifiedValidationResult.warning(String message) =>
      UnifiedValidationResult(
        status: ValidationStatus.warning,
        message: message,
      );

  factory UnifiedValidationResult.error(String message) =>
      UnifiedValidationResult(status: ValidationStatus.error, message: message);

  final ValidationStatus status;
  final String? message;
  final Map<String, dynamic>? metadata;

  bool get isValid =>
      status == ValidationStatus.valid || status == ValidationStatus.warning;
  bool get hasError => status == ValidationStatus.error;
  bool get hasWarning => status == ValidationStatus.warning;

  /// Converte para ValidationResult legado para compatibilidade
  ValidationResult toValidationResult() {
    switch (status) {
      case ValidationStatus.valid:
        return ValidationRight();
      case ValidationStatus.warning:
        return ValidationResult.warning(message ?? '');
      case ValidationStatus.error:
        return ValidationLeft(message ?? '');
      default:
        return ValidationRight();
    }
  }
}

/// Helper functions for legacy compatibility
UnifiedValidationResult UnifiedValidationLeft(String message) =>
    UnifiedValidationResult.error(message);

/// Interface para validadores unificados
abstract class UnifiedValidator {
  UnifiedValidationResult validate(String value, {bool required = false});
}

/// Sistema de validadores unificado
abstract class UnifiedValidators {
  static UnifiedValidator getValidator(
    UnifiedValidationType type, {
    Map<String, dynamic>? context,
  }) {
    switch (type) {
      case UnifiedValidationType.text:
        return TextValidator();
      case UnifiedValidationType.email:
        return EmailValidator();
      case UnifiedValidationType.number:
        return NumberValidator();
      case UnifiedValidationType.decimal:
        return DecimalValidator();
      case UnifiedValidationType.currency:
        return CurrencyValidator();
      case UnifiedValidationType.odometer:
        return OdometerValidator(context);
      case UnifiedValidationType.licensePlate:
        return LicensePlateValidator();
      case UnifiedValidationType.chassi:
        return ChassiValidator();
      case UnifiedValidationType.renavam:
        return RenavamValidator();
    }
  }
}

/// Validador de texto simples
class TextValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Campo obrigatório')
          : UnifiedValidationResult.initial();
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de email
class EmailValidator implements UnifiedValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Email é obrigatório')
          : UnifiedValidationResult.initial();
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return UnifiedValidationLeft('Email inválido');
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de números inteiros
class NumberValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Número é obrigatório')
          : UnifiedValidationResult.initial();
    }

    final number = int.tryParse(value.replaceAll(RegExp(r'[^\d-]'), ''));
    if (number == null) {
      return UnifiedValidationLeft('Deve ser um número válido');
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de números decimais
class DecimalValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Número é obrigatório')
          : UnifiedValidationResult.initial();
    }

    final cleanValue = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.-]'), '');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return UnifiedValidationLeft('Deve ser um número válido');
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de valores monetários
class CurrencyValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Valor é obrigatório')
          : UnifiedValidationResult.initial();
    }
    final cleanValue = value
        .replaceAll(RegExp(r'[R\$\s]'), '')
        .replaceAll(',', '.');

    final number = double.tryParse(cleanValue);
    if (number == null) {
      return UnifiedValidationLeft('Valor monetário inválido');
    }

    if (number < 0) {
      return UnifiedValidationLeft('Valor não pode ser negativo');
    }

    if (number > 999999.99) {
      return UnifiedValidationResult.warning(
        'Valor muito alto. Confirme se está correto.',
      );
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de odômetro com contexto automotivo
class OdometerValidator implements UnifiedValidator {
  OdometerValidator(this.context);

  final Map<String, dynamic>? context;

  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    if (value.trim().isEmpty) {
      return required
          ? UnifiedValidationLeft('Odômetro é obrigatório')
          : UnifiedValidationResult.initial();
    }
    final cleanValue = value
        .replaceAll('km', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    final number = double.tryParse(cleanValue);
    if (number == null) {
      return UnifiedValidationLeft('Odômetro deve ser um número válido');
    }

    if (number < 0) {
      return UnifiedValidationLeft('Odômetro não pode ser negativo');
    }

    if (number > 999999) {
      return UnifiedValidationResult.warning(
        'Odômetro muito alto. Confirme o valor.',
      );
    }
    if (context != null && context!['lastOdometer'] != null) {
      final lastOdometer = context!['lastOdometer'] as double;
      if (number < lastOdometer) {
        return UnifiedValidationLeft(
          'Odômetro atual (${number.toStringAsFixed(0)} km) deve ser maior que o último registrado (${lastOdometer.toStringAsFixed(0)} km)',
        );
      }
      final difference = number - lastOdometer;
      if (difference > 5000) {
        return UnifiedValidationResult.warning(
          'Diferença de ${difference.toStringAsFixed(0)} km desde o último registro. Confirme se está correto.',
        );
      }
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de placa de veículo (formato antigo e Mercosul)
class LicensePlateValidator implements UnifiedValidator {
  static final RegExp _oldFormat = RegExp(r'^[A-Z]{3}[0-9]{4}$');
  static final RegExp _newFormat = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    final cleanValue = value.trim().toUpperCase().replaceAll('-', '');

    if (cleanValue.isEmpty) {
      return required
          ? UnifiedValidationLeft('Placa é obrigatória')
          : UnifiedValidationResult.initial();
    }

    if (cleanValue.length < 7) {
      return UnifiedValidationLeft('Placa deve ter 7 caracteres');
    }

    if (cleanValue.length > 7) {
      return UnifiedValidationLeft('Placa deve ter apenas 7 caracteres');
    }
    if (_oldFormat.hasMatch(cleanValue) || _newFormat.hasMatch(cleanValue)) {
      return UnifiedValidationResult.valid();
    }

    return UnifiedValidationLeft(
      'Placa deve seguir o padrão ABC1234 ou ABC1A23',
    );
  }
}

/// Validador de chassi do veículo
class ChassiValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    final cleanValue = value.trim().toUpperCase();

    if (cleanValue.isEmpty) {
      return required
          ? UnifiedValidationLeft('Chassi é obrigatório')
          : UnifiedValidationResult.initial();
    }

    if (cleanValue.length != 17) {
      return UnifiedValidationLeft('Chassi deve ter 17 caracteres');
    }
    final validChars = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
    if (!validChars.hasMatch(cleanValue)) {
      return UnifiedValidationLeft(
        'Chassi contém caracteres inválidos. Não deve conter I, O ou Q',
      );
    }

    return UnifiedValidationResult.valid();
  }
}

/// Validador de RENAVAM
class RenavamValidator implements UnifiedValidator {
  @override
  UnifiedValidationResult validate(String value, {bool required = false}) {
    final cleanValue = value.trim().replaceAll(RegExp(r'[^\d]'), '');

    if (cleanValue.isEmpty) {
      return required
          ? UnifiedValidationLeft('RENAVAM é obrigatório')
          : UnifiedValidationResult.initial();
    }

    if (cleanValue.length < 9 || cleanValue.length > 11) {
      return UnifiedValidationLeft('RENAVAM deve ter entre 9 e 11 dígitos');
    }
    if (!_isValidRenavam(cleanValue)) {
      return UnifiedValidationLeft('RENAVAM inválido');
    }

    return UnifiedValidationResult.valid();
  }

  bool _isValidRenavam(String renavam) {
    if (renavam.length < 9) return false;
    final digits = renavam.substring(0, renavam.length - 1);
    final checkDigit = int.parse(renavam[renavam.length - 1]);
    final sequence = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum = 0;
    for (int i = 0; i < digits.length; i++) {
      sum += int.parse(digits[i]) * sequence[i % sequence.length];
    }

    final remainder = sum % 11;
    final calculatedDigit = remainder == 0 || remainder == 1
        ? 0
        : 11 - remainder;

    return calculatedDigit == checkDigit;
  }
}
