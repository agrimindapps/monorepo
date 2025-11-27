import 'dart:async';

import '../../../../core/validation/input_sanitizer.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/services/expense_formatter_service.dart';
import '../../domain/services/expense_validation_service.dart';

/// Callback type for value update
typedef ValueUpdateCallback<T> = void Function(T value);

/// Handler for form validation with debounce support
///
/// Responsibilities:
/// - Debounced validation for text fields
/// - Field-by-field validation
/// - Complete form validation
/// - Type suggestion based on description
class ExpenseFormValidatorHandler {
  ExpenseFormValidatorHandler({
    ExpenseValidationService? validator,
    ExpenseFormatterService? formatter,
  })  : _validator = validator ?? const ExpenseValidationService(),
        _formatter = formatter ?? ExpenseFormatterService();

  final ExpenseValidationService _validator;
  final ExpenseFormatterService _formatter;

  // Debounce timers
  Timer? _descriptionDebounceTimer;
  Timer? _amountDebounceTimer;
  Timer? _odometerDebounceTimer;

  /// Validates description with debounce and suggests type
  void validateDescriptionWithDebounce({
    required String value,
    required ValueUpdateCallback<String> onSanitizedValue,
    required ValueUpdateCallback<ExpenseType?> onSuggestedType,
    ExpenseType? currentType,
  }) {
    _descriptionDebounceTimer?.cancel();
    _descriptionDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.descriptionDebounceMs),
      () {
        final sanitized = InputSanitizer.sanitizeDescription(value);
        onSanitizedValue(sanitized);

        // Suggest type if description is not empty and current type is default
        if (sanitized.isNotEmpty && currentType == ExpenseType.other) {
          final suggestedType = _validator.suggestCategoryFromDescription(
            sanitized,
          );
          if (suggestedType != ExpenseType.other) {
            onSuggestedType(suggestedType);
          }
        }
      },
    );
  }

  /// Validates amount with debounce and parses value
  void validateAmountWithDebounce({
    required String value,
    required ValueUpdateCallback<double> onParsedValue,
  }) {
    _amountDebounceTimer?.cancel();
    _amountDebounceTimer = Timer(
      const Duration(milliseconds: ExpenseConstants.amountDebounceMs),
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
      const Duration(milliseconds: ExpenseConstants.odometerDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedOdometer(value);
        onParsedValue(parsedValue);
      },
    );
  }

  /// Sanitizes location field
  String sanitizeLocation(String value) {
    return InputSanitizer.sanitize(value);
  }

  /// Sanitizes notes field
  String sanitizeNotes(String value) {
    return InputSanitizer.sanitizeDescription(value);
  }

  /// Validates a specific field
  String? validateField(
    String field,
    String? value, {
    ExpenseType? expenseType,
    double? currentOdometer,
  }) {
    switch (field) {
      case 'description':
        return _validator.validateDescription(value);
      case 'amount':
        return _validator.validateAmount(value, expenseType: expenseType);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: currentOdometer,
        );
      case 'location':
        return _validator.validateLocation(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Suggests expense type based on description
  ExpenseType suggestTypeFromDescription(String description) {
    return _validator.suggestCategoryFromDescription(description);
  }

  /// Cancels all debounce timers
  void cancelAllTimers() {
    _descriptionDebounceTimer?.cancel();
    _amountDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();
  }

  /// Disposes handler resources
  void dispose() {
    cancelAllTimers();
  }

  /// Access to validator for complete form validation
  ExpenseValidationService get validator => _validator;

  /// Access to formatter for parsing values
  ExpenseFormatterService get formatter => _formatter;
}
