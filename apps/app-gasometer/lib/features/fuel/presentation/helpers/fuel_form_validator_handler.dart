import 'dart:async';

import '../../../../core/validation/input_sanitizer.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../core/constants/fuel_constants.dart';
import '../../domain/services/fuel_formatter_service.dart';
import '../../domain/services/fuel_validator_service.dart';

/// Callback type for value update
typedef ValueUpdateCallback<T> = void Function(T value);

/// Handler for form validation with debounce support
///
/// Responsibilities:
/// - Debounced validation for text fields
/// - Field-by-field validation
/// - Complete form validation
/// - Value sanitization
class FuelFormValidatorHandler {
  FuelFormValidatorHandler({
    FuelValidatorService? validator,
    FuelFormatterService? formatter,
  })  : _validator = validator ?? FuelValidatorService(),
        _formatter = formatter ?? FuelFormatterService();

  final FuelValidatorService _validator;
  final FuelFormatterService _formatter;

  // Debounce timers
  Timer? _litersDebounceTimer;
  Timer? _priceDebounceTimer;
  Timer? _odometerDebounceTimer;

  /// Validates liters with debounce and parses value
  void validateLitersWithDebounce({
    required String value,
    required ValueUpdateCallback<double> onParsedValue,
  }) {
    _litersDebounceTimer?.cancel();
    _litersDebounceTimer = Timer(
      const Duration(milliseconds: FuelConstants.litersDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedValue(value);
        onParsedValue(parsedValue);
      },
    );
  }

  /// Validates price per liter with debounce and parses value
  void validatePriceWithDebounce({
    required String value,
    required ValueUpdateCallback<double> onParsedValue,
  }) {
    _priceDebounceTimer?.cancel();
    _priceDebounceTimer = Timer(
      const Duration(milliseconds: FuelConstants.priceDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedValue(value);
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
      const Duration(milliseconds: FuelConstants.odometerDebounceMs),
      () {
        final parsedValue = _formatter.parseFormattedValue(value);
        onParsedValue(parsedValue);
      },
    );
  }

  /// Sanitizes gas station name
  String sanitizeGasStationName(String value) {
    return InputSanitizer.sanitizeName(value);
  }

  /// Sanitizes gas station brand
  String sanitizeGasStationBrand(String value) {
    return InputSanitizer.sanitizeName(value);
  }

  /// Sanitizes notes field
  String sanitizeNotes(String value) {
    return InputSanitizer.sanitizeDescription(value);
  }

  /// Validates a specific field
  String? validateField(
    String field,
    String? value, {
    double? tankCapacity,
    double? currentOdometer,
    double? lastRecordOdometer,
  }) {
    switch (field) {
      case 'liters':
        return _validator.validateLiters(value, tankCapacity: tankCapacity);
      case 'pricePerLiter':
        return _validator.validatePricePerLiter(value);
      case 'odometer':
        return _validator.validateOdometer(
          value,
          currentOdometer: currentOdometer,
          lastRecordOdometer: lastRecordOdometer,
        );
      case 'gasStationName':
        return _validator.validateGasStationName(value);
      case 'notes':
        return _validator.validateNotes(value);
      default:
        return null;
    }
  }

  /// Validates complete form and returns errors map
  Map<String, String> validateCompleteForm({
    required String? liters,
    required String? pricePerLiter,
    required String? odometer,
    required FuelType? fuelType,
    required DateTime? date,
    String? gasStationName,
    String? notes,
    VehicleEntity? vehicle,
    double? lastRecordOdometer,
  }) {
    return _validator.validateCompleteForm(
      liters: liters,
      pricePerLiter: pricePerLiter,
      odometer: odometer,
      fuelType: fuelType,
      date: date,
      gasStationName: gasStationName,
      notes: notes,
      vehicle: vehicle,
      lastRecordOdometer: lastRecordOdometer,
    );
  }

  /// Cancels all debounce timers
  void cancelAllTimers() {
    _litersDebounceTimer?.cancel();
    _priceDebounceTimer?.cancel();
    _odometerDebounceTimer?.cancel();
  }

  /// Disposes handler resources
  void dispose() {
    cancelAllTimers();
  }

  /// Access to validator for direct validation
  FuelValidatorService get validator => _validator;

  /// Access to formatter for parsing values
  FuelFormatterService get formatter => _formatter;
}
