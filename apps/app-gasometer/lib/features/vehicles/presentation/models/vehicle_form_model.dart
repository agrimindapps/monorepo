import 'package:core/core.dart' show Equatable;

import '../../../../core/validation/input_sanitizer.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Reactive model for vehicle form
class VehicleFormModel extends Equatable {
  const VehicleFormModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.type,
    required this.supportedFuels,
    required this.currentOdometer,
    required this.chassis,
    required this.renavam,
    this.imagePath,
    this.isLoading = false,
    this.hasChanges = false,
    this.errors = const {},
    this.lastError,
  });

  /// Creates initial model for new vehicle
  factory VehicleFormModel.initial(String userId) {
    return VehicleFormModel(
      id: '',
      userId: userId,
      name: '',
      brand: '',
      model: '',
      year: DateTime.now().year,
      color: '',
      licensePlate: '',
      type: VehicleType.car,
      supportedFuels: const [FuelType.gasoline],
      currentOdometer: 0.0,
      chassis: '',
      renavam: '',
      imagePath: null,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  /// Creates model from existing entity for editing
  factory VehicleFormModel.fromVehicleEntity(VehicleEntity vehicle) {
    return VehicleFormModel(
      id: vehicle.id,
      userId: vehicle.userId ?? '',
      name: vehicle.name,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      color: vehicle.color,
      licensePlate: vehicle.licensePlate,
      type: vehicle.type,
      supportedFuels: vehicle.supportedFuels,
      currentOdometer: vehicle.currentOdometer,
      chassis: vehicle.metadata['chassi'] as String? ?? '',
      renavam: vehicle.metadata['renavam'] as String? ?? '',
      imagePath: vehicle.metadata['foto'] as String?,
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  final String id;
  final String userId;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final VehicleType type;
  final List<FuelType> supportedFuels;
  final double currentOdometer;
  final String chassis;
  final String renavam;
  final String? imagePath;
  final bool isLoading;
  final bool hasChanges;
  final Map<String, String> errors;
  final String? lastError;

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    brand,
    model,
    year,
    color,
    licensePlate,
    type,
    supportedFuels,
    currentOdometer,
    chassis,
    renavam,
    imagePath,
    isLoading,
    hasChanges,
    errors,
    lastError,
  ];

  /// Creates new instance with updated values
  VehicleFormModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    VehicleType? type,
    List<FuelType>? supportedFuels,
    double? currentOdometer,
    String? chassis,
    String? renavam,
    String? imagePath,
    bool? isLoading,
    bool? hasChanges,
    Map<String, String>? errors,
    String? lastError,
    bool clearImage = false,
    bool clearLastError = false,
  }) {
    return VehicleFormModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      supportedFuels: supportedFuels ?? this.supportedFuels,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      chassis: chassis ?? this.chassis,
      renavam: renavam ?? this.renavam,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errors: errors ?? this.errors,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  /// Checks if model has minimum valid data
  bool get hasMinimumData =>
      userId.isNotEmpty &&
      brand.trim().isNotEmpty &&
      model.trim().isNotEmpty &&
      year > 1900 &&
      color.trim().isNotEmpty &&
      licensePlate.trim().isNotEmpty &&
      currentOdometer >= 0;

  /// Checks if there are validation errors
  bool get hasErrors => errors.isNotEmpty;

  /// Checks if form is ready to submit
  bool get canSubmit => hasMinimumData && !hasErrors && !isLoading;

  /// Checks if this is an edit (has ID)
  bool get isEditing => id.isNotEmpty;

  /// Checks if has vehicle image
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// Checks if vehicle is a car
  bool get isCar => type == VehicleType.car;

  /// Checks if vehicle is a motorcycle
  bool get isMotorcycle => type == VehicleType.motorcycle;

  /// Checks if vehicle is a truck
  bool get isTruck => type == VehicleType.truck;

  /// Checks if vehicle supports multiple fuels
  bool get isFlexFuel => supportedFuels.length > 1;

  /// Checks if vehicle has high mileage (>= 100,000 km)
  bool get hasHighMileage => currentOdometer >= 100000.0;

  /// Checks if has chassis number
  bool get hasChassis => chassis.trim().isNotEmpty;

  /// Checks if has Renavam number
  bool get hasRenavam => renavam.trim().isNotEmpty;

  /// Returns error message for specific field
  String? getFieldError(String field) => errors[field];

  /// Checks if specific field has error
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Adds error for specific field
  VehicleFormModel setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = error;
    return copyWith(errors: newErrors);
  }

  /// Removes error from specific field
  VehicleFormModel clearFieldError(String field) {
    if (!errors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return copyWith(errors: newErrors);
  }

  /// Clears all errors
  VehicleFormModel clearAllErrors() {
    return copyWith(errors: const {});
  }

  /// Marks form as having changes
  VehicleFormModel markAsChanged() {
    return copyWith(hasChanges: true);
  }

  /// Validates all fields and returns error map
  Map<String, String> validate() {
    final validationErrors = <String, String>{};
    if (brand.trim().isEmpty) {
      validationErrors['brand'] = 'Marca é obrigatória';
    } else if (brand.trim().length < 2) {
      validationErrors['brand'] = 'Marca muito curta (mínimo 2 caracteres)';
    } else if (brand.trim().length > 50) {
      validationErrors['brand'] = 'Marca muito longa (máximo 50 caracteres)';
    }
    if (model.trim().isEmpty) {
      validationErrors['model'] = 'Modelo é obrigatório';
    } else if (model.trim().length < 2) {
      validationErrors['model'] = 'Modelo muito curto (mínimo 2 caracteres)';
    } else if (model.trim().length > 50) {
      validationErrors['model'] = 'Modelo muito longo (máximo 50 caracteres)';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900) {
      validationErrors['year'] = 'Ano inválido';
    } else if (year > currentYear + 1) {
      validationErrors['year'] = 'Ano não pode ser futuro';
    }
    if (color.trim().isEmpty) {
      validationErrors['color'] = 'Cor é obrigatória';
    } else if (color.trim().length < 3) {
      validationErrors['color'] = 'Cor muito curta';
    } else if (color.trim().length > 30) {
      validationErrors['color'] = 'Cor muito longa';
    }
    if (licensePlate.trim().isEmpty) {
      validationErrors['licensePlate'] = 'Placa é obrigatória';
    } else {
      final cleanPlate =
          licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
      if (cleanPlate.length != 7) {
        validationErrors['licensePlate'] = 'Placa deve ter 7 caracteres';
      } else {
        final isOldFormat = RegExp(r'^[A-Z]{3}\d{4}$').hasMatch(cleanPlate);
        final isMercosulFormat = RegExp(
          r'^[A-Z]{3}\d[A-Z]\d{2}$',
        ).hasMatch(cleanPlate);

        if (!isOldFormat && !isMercosulFormat) {
          validationErrors['licensePlate'] = 'Formato de placa inválido';
        }
      }
    }
    if (currentOdometer < 0) {
      validationErrors['currentOdometer'] = 'Odômetro não pode ser negativo';
    } else if (currentOdometer > 9999999) {
      validationErrors['currentOdometer'] = 'Valor muito alto';
    }
    if (chassis.trim().isNotEmpty) {
      final cleanChassis =
          chassis.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
      if (cleanChassis.length != 17) {
        validationErrors['chassis'] = 'Chassi deve ter 17 caracteres';
      }
    }
    if (renavam.trim().isNotEmpty) {
      final cleanRenavam = renavam.replaceAll(RegExp(r'\D'), '');
      if (cleanRenavam.length != 11) {
        validationErrors['renavam'] = 'Renavam deve ter 11 dígitos';
      }
    }
    if (supportedFuels.isEmpty) {
      validationErrors['supportedFuels'] =
          'Selecione pelo menos um tipo de combustível';
    }

    return validationErrors;
  }

  /// Converts to VehicleEntity for persistence
  /// Applies sanitization to all text fields for security
  VehicleEntity toVehicleEntity() {
    final now = DateTime.now();
    final sanitizedBrand = InputSanitizer.sanitizeName(brand);
    final sanitizedModel = InputSanitizer.sanitizeName(model);
    final sanitizedColor = InputSanitizer.sanitizeName(color);
    final sanitizedLicensePlate =
        InputSanitizer.sanitize(licensePlate).toUpperCase();
    final sanitizedChassis =
        chassis.trim().isEmpty
            ? ''
            : InputSanitizer.sanitize(chassis).toUpperCase();
    final sanitizedRenavam =
        renavam.trim().isEmpty ? '' : InputSanitizer.sanitizeNumeric(renavam);
    final finalName =
        name.trim().isEmpty
            ? '$sanitizedBrand $sanitizedModel'
            : InputSanitizer.sanitizeName(name);

    return VehicleEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      userId: userId,
      name: finalName,
      brand: sanitizedBrand,
      model: sanitizedModel,
      year: year,
      color: sanitizedColor,
      licensePlate: sanitizedLicensePlate,
      type: type,
      supportedFuels: supportedFuels,
      currentOdometer: currentOdometer,
      createdAt: id.isEmpty ? now : null,
      updatedAt: now,
      metadata: {
        'chassi': sanitizedChassis,
        'renavam': sanitizedRenavam,
        if (imagePath != null) 'foto': imagePath,
        'odometroInicial': currentOdometer,
      },
    );
  }

  /// Resets form to initial state
  VehicleFormModel reset() {
    return VehicleFormModel.initial(userId);
  }

  /// Creates clean copy without changes or errors
  VehicleFormModel clean() {
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
    'hasImage': hasImage,
    'isCar': isCar,
    'isMotorcycle': isMotorcycle,
    'isTruck': isTruck,
    'isFlexFuel': isFlexFuel,
    'hasHighMileage': hasHighMileage,
    'hasChassis': hasChassis,
    'hasRenavam': hasRenavam,
    'errorCount': errors.length,
  };
}
