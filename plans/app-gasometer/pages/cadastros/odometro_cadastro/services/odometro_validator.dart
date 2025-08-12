// Project imports:
import '../models/odometro_constants.dart';
import 'odometro_formatter.dart';

/// Centralized validation service for odometer form fields
///
/// This class provides a single source of truth for all validation logic,
/// ensuring consistency across the application and eliminating duplication.
class OdometroValidator {
  /// Validates odometer value input
  ///
  /// Returns null if valid, error message string if invalid
  static String? validateOdometer(String? value) {
    if (value?.isEmpty ?? true) {
      return OdometroConstants.validationMessages['campoObrigatorio'];
    }

    if (!OdometroConstants.isValidOdometerValue(value!)) {
      return OdometroConstants.validationMessages['valorInvalido'];
    }

    final numericValue = OdometroFormatter.parseOdometer(value);
    if (numericValue < OdometroConstants.minOdometer) {
      return OdometroConstants.validationMessages['valorNegativo'];
    }

    return null;
  }

  /// Validates description field
  ///
  /// Returns null if valid, error message string if invalid
  static String? validateDescription(String? value) {
    if (value != null && !OdometroConstants.isValidDescriptionLength(value)) {
      return 'Descrição muito longa (máximo ${OdometroConstants.maxDescriptionLength} caracteres)';
    }
    return null;
  }

  /// Validates vehicle ID
  ///
  /// Returns true if valid, false if invalid
  static bool validateVehicleId(String? idVeiculo) {
    return idVeiculo?.isNotEmpty ?? false;
  }

  /// Validates date is not in the future
  ///
  /// Returns true if valid, false if invalid
  static bool validateDate(DateTime date) {
    return !OdometroConstants.isFutureDate(date);
  }

  /// Validates odometer numeric value against constraints
  ///
  /// Returns true if valid, false if invalid
  static bool validateOdometerValue(double value) {
    return value >= OdometroConstants.minOdometer;
  }

  /// Comprehensive validation of all form fields
  ///
  /// Returns true if entire form is valid, false otherwise
  static bool validateForm({
    required String idVeiculo,
    required double odometro,
    required DateTime dataRegistro,
    required String descricao,
  }) {
    return validateVehicleId(idVeiculo) &&
        validateOdometerValue(odometro) &&
        validateDate(dataRegistro) &&
        validateDescription(descricao) == null;
  }

  /// Validates form data for submission
  ///
  /// Returns map with validation results and error messages
  static Map<String, dynamic> validateForSubmission({
    required String idVeiculo,
    required String odometerText,
    required DateTime dataRegistro,
    required String descricao,
  }) {
    final Map<String, String> errors = {};
    bool isValid = true;

    // Validate vehicle ID
    if (!validateVehicleId(idVeiculo)) {
      errors['idVeiculo'] = 'Veículo é obrigatório';
      isValid = false;
    }

    // Validate odometer
    final odometerError = validateOdometer(odometerText);
    if (odometerError != null) {
      errors['odometro'] = odometerError;
      isValid = false;
    }

    // Validate date
    if (!validateDate(dataRegistro)) {
      errors['dataRegistro'] =
          OdometroConstants.validationMessages['dataFutura']!;
      isValid = false;
    }

    // Validate description
    final descriptionError = validateDescription(descricao);
    if (descriptionError != null) {
      errors['descricao'] = descriptionError;
      isValid = false;
    }

    return {
      'isValid': isValid,
      'errors': errors,
    };
  }
}
