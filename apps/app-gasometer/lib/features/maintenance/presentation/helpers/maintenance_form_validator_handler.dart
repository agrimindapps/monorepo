import 'dart:async';

import '../../../../core/validation/input_sanitizer.dart';
import '../../core/constants/maintenance_constants.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../../domain/services/maintenance_validator_service.dart';

/// Callback type for validation result
typedef ValidationResultCallback = void Function(String field, String? error);

/// Callback type for value update
typedef ValueUpdateCallback<T> = void Function(T value);

/// Handler for form validation with debounce support
///
/// Responsibilities:
/// - Debounced validation for text fields
/// - Field-by-field validation
/// - Complete form validation
/// - Type suggestion based on title
class MaintenanceFormValidatorHandler {
  MaintenanceFormValidatorHandler({
    MaintenanceValidatorService? validator,
    MaintenanceFormatterService? formatter,
  })  : _validator = validator ?? MaintenanceValidatorService(),
        _formatter = formatter ?? MaintenanceFormatterService();

  final MaintenanceValidatorService _validator;
  final MaintenanceFormatterService _formatter;

  // Debounce timers
  Timer? _titleDebounceTimer;
  Timer? _descriptionDebounceTimer;
  Timer? _costDebounceTimer;
  Timer? _odometerDebounceTimer;

  /// Validates title with debounce and suggests type
  void validateTitleWithDebounce({
    required String value,
    required ValueUpdateCallback<String> onSanitizedValue,
    required ValueUpdateCallback<MaintenanceType?> onSuggestedType,
    MaintenanceType? currentType,
  }) {
    _titleDebounceTimer?.cancel();
    _titleDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.titleDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitize(value);
        onSanitizedValue(sanitized);

        // Suggest type if title is not empty and current type is default
        if (sanitized.isNotEmpty &&
            currentType == MaintenanceType.preventive) {
          final suggestedType = _validator.suggestTypeFromDescription(
            sanitized,
          );
          if (suggestedType != MaintenanceType.preventive) {
            onSuggestedType(suggestedType);
          }
        }
      },
    );
  }

  /// Validates description with debounce
  void validateDescriptionWithDebounce({
    required String value,
    required ValueUpdateCallback<String> onSanitizedValue,
  }) {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.descriptionDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitizeDescription(value);
        onSanitizedValue(sanitized);
      },
    );
  }

  /// Validates cost with debounce and parses value
  void validateCostWithDebounce({
    required String value,
    required ValueUpdateCallback<double> onParsedValue,
  }) {
    _costDebounceTimer?.cancel();
    _costDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.costDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedAmount(value);
        onParsedValue(parsedValue);
      },
    );
  }

  /// Validates odometer with debounce and parses value
  void validateOdometerWithDebounce({
    required String value,
    required ValueUpdateCallback<double> onParsedValue,
  }) {
    _odometerDebounceTimer?.cancel();
    _odometerDebounceTimer = Timer(
      const Duration(milliseconds: MaintenanceConstants.odometerDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedOdometer(value);
        onParsedValue(parsedValue);
      },
    );
  }

  /// Sanitizes workshop name
  String sanitizeWorkshopName(String value) {
    return InputSanitizer.sanitizeName(value);
  }

  /// Formats and returns phone number
  String formatPhone(String value) {
    return _formatter.formatPhone(value);
  }

  /// Sanitizes workshop address
  String sanitizeWorkshopAddress(String value) {
    return InputSanitizer.sanitize(value);
  }

  /// Parses next odometer value
  double? parseNextOdometer(String value) {
    final parsed = _formatter.parseFormattedOdometer(value);
    return parsed > 0 ? parsed : null;
  }

  /// Sanitizes notes field
  String sanitizeNotes(String value) {
    return InputSanitizer.sanitizeDescription(value);
  }

  /// Validates a specific field
  String? validateField(
    String field,
    String? value, {
    MaintenanceType? type,
    double? currentOdometer,
  }) {
    switch (field) {
      case 'title':
        return _validator.validateTitle(value);
      case 'description':
        return _validator.validateDescription(value);
      case 'cost':
        return _validator.validateCost(value, type: type);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: currentOdometer,
        );
      case 'workshopName':
        return _validator.validateWorkshopName(value);
      case 'workshopPhone':
        return _validator.validatePhone(value);
      case 'workshopAddress':
        return _validator.validateAddress(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Suggests maintenance type based on title/description
  MaintenanceType suggestTypeFromTitle(String title) {
    return _validator.suggestTypeFromDescription(title);
  }

  /// Cancels all debounce timers
  void cancelAllTimers() {
    _titleDebounceTimer?.cancel();
    _descriptionDebounceTimer?.cancel();
    _costDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();
  }

  /// Disposes handler resources
  void dispose() {
    cancelAllTimers();
  }

  /// Access to validator for complete form validation
  MaintenanceValidatorService get validator => _validator;

  /// Access to formatter for parsing values
  MaintenanceFormatterService get formatter => _formatter;
}
