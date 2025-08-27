import 'package:flutter/foundation.dart';

import '../../../../core/services/input_sanitizer.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/services/odometer_formatter.dart';
import '../../domain/services/odometer_validator.dart';

/// Provider for managing odometer form state
///
/// This provider follows the MVVM pattern and provides reactive state management
/// for the odometer form, handling validation, formatting, and business logic.
class OdometerFormProvider extends ChangeNotifier {
  // ===========================================
  // PRIVATE FIELDS
  // ===========================================

  String _vehicleId = '';
  String _userId = '';
  VehicleEntity? _vehicle;
  double _odometerValue = 0.0;
  DateTime _registrationDate = DateTime.now();
  String _description = '';
  OdometerType _registrationType = OdometerType.other;
  bool _isLoading = false;
  String _error = '';
  OdometerEntity? _currentOdometer;

  // ===========================================
  // CONSTRUCTOR
  // ===========================================

  OdometerFormProvider({String? initialUserId}) {
    if (initialUserId != null) {
      _userId = initialUserId;
    }
  }

  // ===========================================
  // GETTERS
  // ===========================================

  String get vehicleId => _vehicleId;
  VehicleEntity? get vehicle => _vehicle;
  double get odometerValue => _odometerValue;
  DateTime get registrationDate => _registrationDate;
  String get description => _description;
  OdometerType get registrationType => _registrationType;
  bool get isLoading => _isLoading;
  String get error => _error;
  OdometerEntity? get currentOdometer => _currentOdometer;

  // Computed properties
  bool get hasError => _error.isNotEmpty;
  bool get hasVehicle => _vehicle != null;
  String get formattedOdometer => OdometerFormatter.formatOdometer(_odometerValue);
  bool get isEditing => _currentOdometer != null;

  // ===========================================
  // SETTERS
  // ===========================================

  void setVehicleId(String value) {
    if (_vehicleId != value) {
      _vehicleId = value;
      _vehicle = null; // Clear vehicle data when ID changes
      notifyListeners();
    }
  }

  void setUserId(String value) {
    if (_userId != value) {
      _userId = value;
      notifyListeners();
    }
  }

  void setVehicle(VehicleEntity? value) {
    if (_vehicle != value) {
      _vehicle = value;
      if (value != null) {
        _vehicleId = value.id;
      }
      notifyListeners();
    }
  }

  void setOdometerValue(double value) {
    if (_odometerValue != value) {
      _odometerValue = value;
      notifyListeners();
    }
  }

  void setOdometerFromString(String value) {
    final parsedValue = OdometerFormatter.parseOdometer(value);
    setOdometerValue(parsedValue);
  }

  void setRegistrationDate(DateTime value) {
    if (_registrationDate != value) {
      _registrationDate = value;
      notifyListeners();
    }
  }

  void setDescription(String value) {
    // Aplicar sanitização específica para descrições antes de armazenar
    final sanitizedValue = InputSanitizer.sanitizeDescription(value);
    if (_description != sanitizedValue) {
      _description = sanitizedValue;
      notifyListeners();
    }
  }

  void setRegistrationType(OdometerType value) {
    if (_registrationType != value) {
      _registrationType = value;
      notifyListeners();
    }
  }

  void setIsLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setError(String value) {
    if (_error != value) {
      _error = value;
      notifyListeners();
    }
  }

  void clearError() {
    setError('');
  }

  // ===========================================
  // FORM INITIALIZATION
  // ===========================================

  /// Initializes form for new odometer record
  void initializeForNew(String vehicleId) {
    _vehicleId = vehicleId;
    _vehicle = null;
    _odometerValue = 0.0;
    _registrationDate = DateTime.now();
    _description = '';
    _registrationType = OdometerType.other;
    _isLoading = false;
    _error = '';
    _currentOdometer = null;
    notifyListeners();
  }

  /// Initializes form from existing odometer record
  void initializeFromOdometer(OdometerEntity odometer) {
    _currentOdometer = odometer;
    _vehicleId = odometer.vehicleId;
    _vehicle = null; // Will be loaded separately
    _odometerValue = odometer.value;
    _registrationDate = odometer.registrationDate;
    _description = odometer.description;
    _registrationType = odometer.type;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }

  /// Resets form to initial state
  void resetForm() {
    _vehicleId = '';
    _vehicle = null;
    _odometerValue = 0.0;
    _registrationDate = DateTime.now();
    _description = '';
    _registrationType = OdometerType.other;
    _isLoading = false;
    _error = '';
    _currentOdometer = null;
    notifyListeners();
  }

  // ===========================================
  // DATE AND TIME MANIPULATION
  // ===========================================

  void setDate(DateTime date) {
    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      _registrationDate.hour,
      _registrationDate.minute,
    );
    setRegistrationDate(newDateTime);
  }

  void setTime(int hour, int minute) {
    final newDateTime = DateTime(
      _registrationDate.year,
      _registrationDate.month,
      _registrationDate.day,
      hour,
      minute,
    );
    setRegistrationDate(newDateTime);
  }

  // ===========================================
  // VALIDATION METHODS
  // ===========================================

  String? validateOdometer(String? value) {
    return OdometerValidator.validateOdometer(value);
  }

  String? validateDescription(String? value) {
    return OdometerValidator.validateDescription(value);
  }

  bool validateDate() {
    return OdometerValidator.validateDate(_registrationDate);
  }

  /// Validates odometer value with vehicle context
  OdometerValidationResult? validateOdometerWithVehicle() {
    if (_vehicle == null) return null;
    
    return OdometerValidator.validateOdometerWithVehicle(
      _odometerValue,
      _vehicle!,
    );
  }

  /// Comprehensive validation for form submission
  FormValidationResult validateForSubmission() {
    return OdometerValidator.validateForSubmission(
      vehicleId: _vehicleId,
      odometerText: _odometerValue.toString(),
      registrationDate: _registrationDate,
      description: _description,
      type: _registrationType,
    );
  }

  /// Checks if the entire form is valid
  bool get isFormValid {
    return OdometerValidator.validateForm(
      vehicleId: _vehicleId,
      odometer: _odometerValue,
      registrationDate: _registrationDate,
      description: _description,
      type: _registrationType,
    );
  }

  // ===========================================
  // DATA CONVERSION
  // ===========================================

  /// Creates OdometerEntity from current form data
  /// Aplica sanitização final antes da persistência
  OdometerEntity toOdometerEntity({
    String? id,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    
    // Aplicar sanitização final na descrição antes da persistência
    final sanitizedDescription = InputSanitizer.sanitizeDescription(_description);
    
    return OdometerEntity(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      vehicleId: _vehicleId,
      userId: _userId,
      value: _odometerValue,
      registrationDate: _registrationDate,
      description: sanitizedDescription,
      type: _registrationType,
      createdAt: createdAt ?? now,
      updatedAt: now,
      metadata: const {
        'source': 'mobile_app',
        'version': '1.0.0',
      },
    );
  }

  /// Converts form data to Map for debugging or serialization
  Map<String, dynamic> toMap() {
    return {
      'vehicleId': _vehicleId,
      'odometerValue': _odometerValue,
      'registrationDate': _registrationDate.millisecondsSinceEpoch,
      'description': _description,
      'registrationType': _registrationType.name,
      'isLoading': _isLoading,
      'error': _error,
      'hasVehicle': hasVehicle,
      'isEditing': isEditing,
    };
  }

  /// Loads data from Map
  void fromMap(Map<String, dynamic> map) {
    _vehicleId = map['vehicleId']?.toString() ?? '';
    _odometerValue = (map['odometerValue'] as num? ?? 0.0).toDouble();
    _registrationDate = DateTime.fromMillisecondsSinceEpoch(
      (map['registrationDate'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
    _description = map['description']?.toString() ?? '';
    _registrationType = OdometerType.fromString(
      map['registrationType']?.toString() ?? 'other',
    );
    _isLoading = map['isLoading'] as bool? ?? false;
    _error = map['error']?.toString() ?? '';
    notifyListeners();
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  /// Clears the odometer value
  void clearOdometer() {
    setOdometerValue(0.0);
  }

  /// Gets available registration types
  List<OdometerType> get availableTypes => OdometerType.allTypes;

  /// Gets display names for registration types
  List<String> get typeDisplayNames => OdometerType.displayNames;

  /// Debug information
  @override
  String toString() {
    return 'OdometerFormProvider('
        'vehicleId: $_vehicleId, '
        'odometerValue: $_odometerValue, '
        'type: $_registrationType, '
        'isLoading: $_isLoading, '
        'hasError: $hasError'
        ')';
  }
}