import 'package:equatable/equatable.dart';

import '../../../../core/services/input_sanitizer.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/odometer_entity.dart';

/// Reactive model for odometer reading form
class OdometerFormModel extends Equatable {
  const OdometerFormModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.vehicle,
    required this.value,
    required this.registrationDate,
    required this.description,
    required this.type,
    this.isLoading = false,
    this.hasChanges = false,
    this.errors = const {},
    this.lastError,
  });

  /// Creates initial model for new reading
  factory OdometerFormModel.initial(String vehicleId, String userId) {
    return OdometerFormModel(
      id: '',
      userId: userId,
      vehicleId: vehicleId,
      vehicle: null,
      value: 0.0,
      registrationDate: DateTime.now(),
      description: '',
      type: OdometerType.other,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  /// Creates model from existing entity for editing
  factory OdometerFormModel.fromOdometerEntity(OdometerEntity reading) {
    return OdometerFormModel(
      id: reading.id,
      userId: reading.userId,
      vehicleId: reading.vehicleId,
      vehicle: null, // Will be loaded separately
      value: reading.value,
      registrationDate: reading.registrationDate,
      description: reading.description,
      type: reading.type,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final double value;
  final DateTime registrationDate;
  final String description;
  final OdometerType type;
  final bool isLoading;
  final bool hasChanges;
  final Map<String, String> errors;
  final String? lastError;

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        vehicle,
        value,
        registrationDate,
        description,
        type,
        isLoading,
        hasChanges,
        errors,
        lastError,
      ];

  /// Creates new instance with updated values
  OdometerFormModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    VehicleEntity? vehicle,
    double? value,
    DateTime? registrationDate,
    String? description,
    OdometerType? type,
    bool? isLoading,
    bool? hasChanges,
    Map<String, String>? errors,
    String? lastError,
    bool clearLastError = false,
  }) {
    return OdometerFormModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      value: value ?? this.value,
      registrationDate: registrationDate ?? this.registrationDate,
      description: description ?? this.description,
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errors: errors ?? this.errors,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  /// Checks if model has minimum valid data
  bool get hasMinimumData =>
      vehicleId.isNotEmpty &&
      value > 0 &&
      description.trim().isNotEmpty;

  /// Checks if there are validation errors
  bool get hasErrors => errors.isNotEmpty;

  /// Checks if form is ready to submit
  bool get canSubmit =>
      hasMinimumData &&
      !hasErrors &&
      !isLoading;

  /// Checks if this is an edit (has ID)
  bool get isEditing => id.isNotEmpty;

  /// Checks if this is a high mileage reading
  bool get isHighMileage => value >= 100000.0;

  /// Checks if reading is for a trip
  bool get isTrip => type == OdometerType.trip;

  /// Checks if reading is for maintenance
  bool get isMaintenanceRelated => type == OdometerType.maintenance;

  /// Returns error message for specific field
  String? getFieldError(String field) => errors[field];

  /// Checks if specific field has error
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Adds error for specific field
  OdometerFormModel setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = error;
    return copyWith(errors: newErrors);
  }

  /// Removes error from specific field
  OdometerFormModel clearFieldError(String field) {
    if (!errors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return copyWith(errors: newErrors);
  }

  /// Clears all errors
  OdometerFormModel clearAllErrors() {
    return copyWith(errors: const {});
  }

  /// Marks form as having changes
  OdometerFormModel markAsChanged() {
    return copyWith(hasChanges: true);
  }

  /// Validates all fields and returns error map
  Map<String, String> validate() {
    final validationErrors = <String, String>{};

    // Validate vehicle
    if (vehicleId.isEmpty) {
      validationErrors['vehicleId'] = 'Veículo é obrigatório';
    }

    // Validate odometer value
    if (value <= 0) {
      validationErrors['value'] = 'Valor do odômetro deve ser maior que zero';
    } else if (value > 9999999) {
      validationErrors['value'] = 'Valor do odômetro muito alto';
    }

    // Validate description
    if (description.trim().isEmpty) {
      validationErrors['description'] = 'Descrição é obrigatória';
    } else if (description.trim().length < 3) {
      validationErrors['description'] = 'Descrição muito curta (mínimo 3 caracteres)';
    } else if (description.trim().length > 100) {
      validationErrors['description'] = 'Descrição muito longa (máximo 100 caracteres)';
    }

    // Validate registration date
    final now = DateTime.now();
    if (registrationDate.isAfter(now)) {
      validationErrors['registrationDate'] = 'Data não pode ser futura';
    }

    // Check if date is too old (more than 10 years)
    final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
    if (registrationDate.isBefore(tenYearsAgo)) {
      validationErrors['registrationDate'] = 'Data muito antiga (mais de 10 anos)';
    }

    return validationErrors;
  }

  /// Converts to OdometerEntity for persistence
  /// Applies sanitization to all text fields for security
  OdometerEntity toOdometerEntity() {
    final now = DateTime.now();

    // Sanitize all text fields before persistence
    final sanitizedDescription = InputSanitizer.sanitizeDescription(description);

    return OdometerEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      userId: userId,
      vehicleId: vehicleId,
      value: value,
      registrationDate: registrationDate,
      description: sanitizedDescription,
      type: type,
      createdAt: id.isEmpty ? now : DateTime.fromMillisecondsSinceEpoch(int.tryParse(id) ?? now.millisecondsSinceEpoch),
      updatedAt: now,
      metadata: const {},
    );
  }

  /// Resets form to initial state
  OdometerFormModel reset() {
    return OdometerFormModel.initial(vehicleId, userId).copyWith(
      vehicle: vehicle,
    );
  }

  /// Creates clean copy without changes or errors
  OdometerFormModel clean() {
    return copyWith(
      hasChanges: false,
      errors: const {},
      lastError: null,
      clearLastError: true,
    );
  }

  /// Form statistics for debugging
  Map<String, dynamic> get stats => {
    'isValid': canSubmit,
    'hasErrors': hasErrors,
    'hasChanges': hasChanges,
    'isEditing': isEditing,
    'isHighMileage': isHighMileage,
    'isTrip': isTrip,
    'isMaintenanceRelated': isMaintenanceRelated,
    'errorCount': errors.length,
  };
}
