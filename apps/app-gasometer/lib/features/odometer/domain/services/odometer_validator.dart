import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../entities/odometer_entity.dart';
import 'odometer_formatter.dart';

/// Centralized validation service for odometer form fields
///
/// This class provides a single source of truth for all validation logic,
/// ensuring consistency across the application and eliminating duplication.
class OdometerValidator {
  /// Minimum allowed odometer value
  static const double minOdometer = 0.0;

  /// Maximum allowed odometer value (999,999 km)
  static const double maxOdometer = 999999.0;

  /// Maximum description length
  static const int maxDescriptionLength = 255;

  /// Validates odometer value input
  ///
  /// Returns null if valid, error message string if invalid
  static String? validateOdometer(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Campo obrigatório';
    }

    if (!OdometerFormatter.isValidOdometerFormat(value!)) {
      return 'Formato inválido';
    }

    final numericValue = OdometerFormatter.parseOdometer(value);
    if (numericValue < minOdometer) {
      return 'O valor não pode ser negativo';
    }

    if (numericValue > maxOdometer) {
      return 'Valor máximo excedido (${OdometerFormatter.formatOdometerWithUnit(maxOdometer)})';
    }

    return null;
  }

  /// Validates description field
  ///
  /// Returns null if valid, error message string if invalid
  static String? validateDescription(String? value) {
    if (value != null && value.length > maxDescriptionLength) {
      return 'Descrição muito longa (máximo $maxDescriptionLength caracteres)';
    }
    return null;
  }

  /// Validates vehicle ID
  ///
  /// Returns true if valid, false if invalid
  static bool validateVehicleId(String? vehicleId) {
    return vehicleId?.isNotEmpty ?? false;
  }

  /// Validates date is not in the future
  ///
  /// Returns true if valid, false if invalid
  static bool validateDate(DateTime date) {
    return !date.isAfter(DateTime.now());
  }

  /// Validates odometer numeric value against constraints
  ///
  /// Returns true if valid, false if invalid
  static bool validateOdometerValue(double value) {
    return value >= minOdometer && value <= maxOdometer;
  }

  /// Validates odometer value against vehicle's initial odometer
  ///
  /// Returns validation result with error message if invalid
  static OdometerValidationResult validateOdometerWithVehicle(
    double odometerValue,
    VehicleEntity vehicle,
  ) {
    if (odometerValue < minOdometer) {
      return const OdometerValidationResult(
        isValid: false,
        errorMessage: 'O valor não pode ser negativo',
      );
    }

    if (odometerValue > maxOdometer) {
      return OdometerValidationResult(
        isValid: false,
        errorMessage:
            'Valor máximo excedido (${OdometerFormatter.formatOdometerWithUnit(maxOdometer)})',
      );
    }
    // REMOVIDO: Validação que bloqueava lançamentos retroativos
    // Agora permite registrar odômetro menor que o atual
    // if (odometerValue < vehicle.currentOdometer) {
    //   return OdometerValidationResult(
    //     isValid: false,
    //     errorMessage:
    //         'O valor não pode ser menor que a quilometragem atual do veículo...',
    //   );
    // }

    return const OdometerValidationResult(isValid: true);
  }

  /// Validates registration type
  ///
  /// Returns true if valid, false if invalid
  static bool validateRegistrationType(OdometerType? type) {
    return type != null;
  }

  /// Comprehensive validation of all form fields
  ///
  /// Returns true if entire form is valid, false otherwise
  static bool validateForm({
    required String vehicleId,
    required double odometer,
    required DateTime registrationDate,
    required String description,
    required OdometerType type,
  }) {
    return validateVehicleId(vehicleId) &&
        validateOdometerValue(odometer) &&
        validateDate(registrationDate) &&
        validateDescription(description) == null &&
        validateRegistrationType(type);
  }

  /// Validates form data for submission
  ///
  /// Returns map with validation results and error messages
  static FormValidationResult validateForSubmission({
    required String vehicleId,
    required String odometerText,
    required DateTime registrationDate,
    required String description,
    required OdometerType? type,
  }) {
    final Map<String, String> errors = {};
    bool isValid = true;
    if (!validateVehicleId(vehicleId)) {
      errors['vehicleId'] = 'Veículo é obrigatório';
      isValid = false;
    }
    final odometerError = validateOdometer(odometerText);
    if (odometerError != null) {
      errors['odometerValue'] =
          odometerError; // Changed from 'odometer' to 'odometerValue'
      isValid = false;
    }
    if (!validateDate(registrationDate)) {
      errors['registrationDate'] = 'A data de registro não pode ser futura';
      isValid = false;
    }
    final descriptionError = validateDescription(description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
      isValid = false;
    }
    if (!validateRegistrationType(type)) {
      errors['registrationType'] =
          'Tipo de registro é obrigatório'; // Changed from 'type' to 'registrationType'
      isValid = false;
    }

    return FormValidationResult(isValid: isValid, errors: errors);
  }
}

/// Result of odometer validation with vehicle context
class OdometerValidationResult {
  const OdometerValidationResult({required this.isValid, this.errorMessage});
  final bool isValid;
  final String? errorMessage;
}

/// Result of complete form validation
class FormValidationResult {
  const FormValidationResult({required this.isValid, required this.errors});
  final bool isValid;
  final Map<String, String> errors;
}
