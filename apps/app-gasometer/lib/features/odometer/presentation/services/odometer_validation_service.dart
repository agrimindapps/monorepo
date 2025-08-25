import 'package:flutter/foundation.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/services/odometer_validator.dart';
import '../constants/odometer_constants.dart';

/// Service for contextual validation of odometer values with vehicle data
///
/// This service provides advanced validation that considers vehicle context,
/// such as validating against the vehicle's initial and current odometer readings.
class OdometerValidationService {
  final VehiclesProvider _vehiclesProvider;

  OdometerValidationService(this._vehiclesProvider);

  /// Validates odometer value with complete vehicle context
  ///
  /// This method performs comprehensive validation including:
  /// - Basic value validation (non-negative, within limits)
  /// - Vehicle existence validation
  /// - Comparison with vehicle's current odometer
  /// - Historical consistency checks
  Future<OdometerContextValidationResult> validateOdometerWithContext({
    required String vehicleId,
    required double odometerValue,
    String? currentOdometerId, // For editing existing records
  }) async {
    try {
      // Get vehicle data
      final vehicle = await _vehiclesProvider.getVehicleById(vehicleId);
      if (vehicle == null) {
        return OdometerContextValidationResult(
          isValid: false,
          errorMessage: OdometerConstants.errorMessages['carregarVeiculo'],
          errorType: ValidationErrorType.vehicleNotFound,
        );
      }

      // Basic validation first
      final basicValidation = OdometerValidator.validateOdometerWithVehicle(
        odometerValue,
        vehicle,
      );

      if (!basicValidation.isValid) {
        return OdometerContextValidationResult(
          isValid: false,
          errorMessage: basicValidation.errorMessage,
          errorType: ValidationErrorType.valueOutOfRange,
        );
      }

      // Advanced contextual validations
      final contextResult = await _performContextualValidation(
        vehicle: vehicle,
        odometerValue: odometerValue,
        currentOdometerId: currentOdometerId,
      );

      return contextResult;
    } catch (e) {
      debugPrint('Error in validateOdometerWithContext: $e');
      return OdometerContextValidationResult(
        isValid: false,
        errorMessage: OdometerConstants.errorMessages['validacaoOdometro'],
        errorType: ValidationErrorType.systemError,
      );
    }
  }

  /// Performs advanced contextual validation
  Future<OdometerContextValidationResult> _performContextualValidation({
    required VehicleEntity vehicle,
    required double odometerValue,
    String? currentOdometerId,
  }) async {
    // Check if value is significantly lower than current odometer
    // (allows for small corrections but prevents major rollbacks)
    const double maxRollbackKm = 100.0; // Allow up to 100km rollback for corrections
    
    if (vehicle.currentOdometer - odometerValue > maxRollbackKm) {
      return OdometerContextValidationResult(
        isValid: false,
        errorMessage: 'O valor está muito abaixo da quilometragem atual do veículo. '
            'Máximo de ${maxRollbackKm.toInt()} km de diferença permitido para correções.',
        errorType: ValidationErrorType.significantRollback,
      );
    }

    // Check for unrealistic daily increases (more than 2000km per day)
    const double maxDailyIncrease = 2000.0;
    final daysSinceLastUpdate = DateTime.now().difference(vehicle.updatedAt).inDays;
    
    if (daysSinceLastUpdate > 0) {
      final dailyIncrease = (odometerValue - vehicle.currentOdometer) / daysSinceLastUpdate;
      if (dailyIncrease > maxDailyIncrease) {
        return OdometerContextValidationResult(
          isValid: false,
          errorMessage: 'Aumento diário muito alto (${dailyIncrease.toInt()} km/dia). '
              'Máximo recomendado: ${maxDailyIncrease.toInt()} km/dia.',
          errorType: ValidationErrorType.unrealisticIncrease,
          isWarning: true, // This is a warning, not a hard error
        );
      }
    }

    // Check for duplicate values in recent history
    // TODO: Implement when odometer history is available
    // final hasDuplicateInRecent = await _checkForRecentDuplicate(
    //   vehicle.id,
    //   odometerValue,
    //   currentOdometerId,
    // );

    return const OdometerContextValidationResult(isValid: true);
  }

  /// Validates a complete odometer form with full context
  Future<FormContextValidationResult> validateFormWithContext({
    required String vehicleId,
    required double odometerValue,
    required DateTime registrationDate,
    required String description,
    required OdometerType type,
    String? currentOdometerId,
  }) async {
    final errors = <String, String>{};
    final warnings = <String, String>{};

    // Basic form validation
    final basicFormValidation = OdometerValidator.validateForSubmission(
      vehicleId: vehicleId,
      odometerText: odometerValue.toString(),
      registrationDate: registrationDate,
      description: description,
      type: type,
    );

    errors.addAll(basicFormValidation.errors);

    // Contextual odometer validation
    if (errors['odometer'] == null) {
      final contextValidation = await validateOdometerWithContext(
        vehicleId: vehicleId,
        odometerValue: odometerValue,
        currentOdometerId: currentOdometerId,
      );

      if (!contextValidation.isValid) {
        if (contextValidation.isWarning) {
          warnings['odometer'] = contextValidation.errorMessage!;
        } else {
          errors['odometer'] = contextValidation.errorMessage!;
        }
      }
    }

    // Date validation (more comprehensive)
    final dateValidation = _validateRegistrationDate(registrationDate);
    if (dateValidation != null) {
      errors['registrationDate'] = dateValidation;
    }

    return FormContextValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      hasWarnings: warnings.isNotEmpty,
    );
  }

  /// Validates registration date with business rules
  String? _validateRegistrationDate(DateTime date) {
    final now = DateTime.now();
    
    // Check for future dates
    if (date.isAfter(now)) {
      return OdometerConstants.validationMessages['dataFutura']!;
    }

    // Check for dates too far in the past (more than 5 years)
    final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 5));
    if (date.isBefore(fiveYearsAgo)) {
      return 'Data muito antiga. Registros anteriores a 5 anos não são permitidos.';
    }

    // Check for dates in the far future (more than 1 hour ahead, accounting for timezone issues)
    final oneHourFromNow = now.add(const Duration(hours: 1));
    if (date.isAfter(oneHourFromNow)) {
      return 'Data/hora parece estar no futuro. Verifique o horário do dispositivo.';
    }

    return null;
  }

  /// Gets validation suggestions based on current context
  Future<List<ValidationSuggestion>> getValidationSuggestions({
    required String vehicleId,
    required double odometerValue,
  }) async {
    final suggestions = <ValidationSuggestion>[];
    
    try {
      final vehicle = await _vehiclesProvider.getVehicleById(vehicleId);
      if (vehicle == null) return suggestions;

      // Suggest typical values based on vehicle age
      if (odometerValue == 0) {
        final vehicleAge = DateTime.now().year - vehicle.year;
        const typicalKmPerYear = 15000.0;
        final suggestedValue = vehicleAge * typicalKmPerYear;
        
        suggestions.add(ValidationSuggestion(
          type: SuggestionType.typicalValue,
          message: 'Valor típico para um veículo de ${vehicle.year}: '
              '~${suggestedValue.toInt()} km (${typicalKmPerYear.toInt()} km/ano)',
          suggestedValue: suggestedValue,
        ));
      }

      // Suggest current vehicle odometer if significantly different
      if ((odometerValue - vehicle.currentOdometer).abs() > 1000) {
        suggestions.add(ValidationSuggestion(
          type: SuggestionType.currentValue,
          message: 'Quilometragem atual do veículo: ${vehicle.currentOdometer.toInt()} km',
          suggestedValue: vehicle.currentOdometer,
        ));
      }

    } catch (e) {
      debugPrint('Error getting validation suggestions: $e');
    }

    return suggestions;
  }
}

/// Result of contextual validation with detailed error information
class OdometerContextValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationErrorType? errorType;
  final bool isWarning;

  const OdometerContextValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorType,
    this.isWarning = false,
  });
}

/// Result of complete form validation with context
class FormContextValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, String> warnings;
  final bool hasWarnings;

  const FormContextValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.hasWarnings,
  });
}

/// Types of validation errors for better error handling
enum ValidationErrorType {
  vehicleNotFound,
  valueOutOfRange,
  significantRollback,
  unrealisticIncrease,
  systemError,
}

/// Validation suggestion for user guidance
class ValidationSuggestion {
  final SuggestionType type;
  final String message;
  final double? suggestedValue;

  const ValidationSuggestion({
    required this.type,
    required this.message,
    this.suggestedValue,
  });
}

/// Types of validation suggestions
enum SuggestionType {
  typicalValue,
  currentValue,
  correction,
}