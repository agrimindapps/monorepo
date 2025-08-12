/// Validation-related constants for the odometer registration feature
/// Contains validation rules, constraints, and error messages
class OdometroValidationConstants {
  // Private constructor to prevent instantiation
  OdometroValidationConstants._();

  /// Field validation constraints
  static const FieldConstraints field = FieldConstraints._();

  /// Validation error messages
  static const ValidationMessages messages = ValidationMessages._();

  /// Date validation constraints
  static const DateConstraints date = DateConstraints._();

  /// Input format constraints
  static const InputFormat input = InputFormat._();
}

/// Field-specific validation constraints
class FieldConstraints {
  const FieldConstraints._();

  /// Maximum characters allowed for description (database limit constraint)
  static const int maxDescriptionLength = 255;

  /// Maximum visible lines in description field for better UX
  static const int descriptionMaxLines = 3;

  /// Decimal precision for odometer values (hundredths for high precision)
  static const int decimalPlaces = 2;

  /// Minimum valid odometer value (cannot be negative)
  static const double minOdometer = 0.0;
}

/// Validation error messages in Portuguese (user-facing text)
class ValidationMessages {
  const ValidationMessages._();

  /// Form validation messages
  static const Map<String, String> form = {
    'campoObrigatorio': 'Campo obrigatório',
    'valorInvalido': 'Valor inválido',
    'valorNegativo': 'O valor não pode ser negativo',
    'dataFutura': 'A data de registro não pode ser futura.',
    'erroGenerico': 'Ocorreu um erro ao salvar o odômetro',
  };

  /// Dialog and alert messages
  static const Map<String, String> dialog = {
    'titulo': 'Odômetro',
    'dataInvalida': 'Data inválida',
    'erro': 'Erro',
    'ok': 'OK',
  };
}

/// Date validation constraints and helpers
class DateConstraints {
  const DateConstraints._();

  /// Minimum allowed date - year 2000 (common automotive systems milestone)
  static DateTime get minDate => DateTime(2000);

  /// Maximum allowed date - always current moment (prevents future records)
  static DateTime get maxDate => DateTime.now();

  /// Validates if date is in the future
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}

/// Input format validation constraints
class InputFormat {
  const InputFormat._();

  /// Regular expression pattern for numeric input
  static const String numberPattern = r'[0-9,.]';

  /// Decimal separator used in Brazilian locale
  static const String decimalSeparator = ',';

  /// Dot separator for internal calculations
  static const String dotSeparator = '.';

  /// Compiled regex for performance
  static RegExp get numberRegex => RegExp(numberPattern);

  /// Validates odometer value format and range
  static bool isValidOdometerValue(String value) {
    final cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    final number = double.tryParse(cleanValue);
    return number != null && number >= FieldConstraints.minOdometer;
  }

  /// Validates description length
  static bool isValidDescriptionLength(String description) {
    return description.length <= FieldConstraints.maxDescriptionLength;
  }
}
