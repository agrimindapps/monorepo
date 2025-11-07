import 'package:core/core.dart' show Equatable;

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/odometer_entity.dart';

/// Estado imutável do formulário de odômetro para Riverpod
///
/// Segue o padrão Dart Style Guide: Constructors primeiro, fields depois, methods por último
class OdometerFormState extends Equatable {
  const OdometerFormState({
    this.id = '',
    this.userId = '',
    this.vehicleId = '',
    this.vehicle,
    this.odometerValue = 0.0,
    this.registrationDate,
    this.description = '',
    this.registrationType = OdometerType.trip, // Changed default to trip
    this.currentOdometer,
    this.isLoading = false,
    this.hasChanges = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  /// Estado inicial para novo registro de odômetro
  factory OdometerFormState.initial({
    required String vehicleId,
    required String userId,
  }) {
    return OdometerFormState(
      vehicleId: vehicleId,
      userId: userId,
      registrationDate: DateTime.now(),
      registrationType: OdometerType.trip, // Default to trip type
    );
  }

  /// Estado a partir de odômetro existente (edição)
  factory OdometerFormState.fromOdometer(OdometerEntity odometer) {
    return OdometerFormState(
      id: odometer.id,
      userId: odometer.userId ?? '',
      vehicleId: odometer.vehicleId,
      odometerValue: odometer.value,
      registrationDate: odometer.registrationDate,
      description: odometer.description,
      registrationType: odometer.type,
      currentOdometer: odometer,
    );
  }

  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final double odometerValue;
  final DateTime? registrationDate;
  final String description;
  final OdometerType registrationType;
  final OdometerEntity? currentOdometer;
  final bool isLoading;
  final bool hasChanges;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    vehicle,
    odometerValue,
    registrationDate,
    description,
    registrationType,
    currentOdometer,
    isLoading,
    hasChanges,
    errorMessage,
    fieldErrors,
  ];

  /// Verifica se tem veículo selecionado
  bool get hasVehicle => vehicle != null;

  /// Verifica se está editando (tem odômetro atual)
  bool get isEditing => currentOdometer != null;

  /// Verifica se tem dados mínimos válidos
  bool get hasMinimumData =>
      vehicleId.isNotEmpty && odometerValue > 0 && registrationDate != null;

  /// Verifica se tem erros de validação
  bool get hasErrors => fieldErrors.isNotEmpty;

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit => hasMinimumData && !hasErrors && !isLoading;

  /// Retorna mensagem de erro de um campo específico
  String? getFieldError(String field) => fieldErrors[field];

  /// Verifica se um campo tem erro
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  OdometerFormState copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    VehicleEntity? vehicle,
    double? odometerValue,
    DateTime? registrationDate,
    String? description,
    OdometerType? registrationType,
    OdometerEntity? currentOdometer,
    bool? isLoading,
    bool? hasChanges,
    String? Function()? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return OdometerFormState(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      odometerValue: odometerValue ?? this.odometerValue,
      registrationDate: registrationDate ?? this.registrationDate,
      description: description ?? this.description,
      registrationType: registrationType ?? this.registrationType,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  /// Limpa erro geral
  OdometerFormState clearError() {
    return copyWith(errorMessage: () => null);
  }

  /// Define erro em um campo específico
  OdometerFormState setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors[field] = error;
    return copyWith(fieldErrors: newErrors);
  }

  /// Remove erro de um campo específico
  OdometerFormState clearFieldError(String field) {
    if (!fieldErrors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors.remove(field);
    return copyWith(fieldErrors: newErrors);
  }

  /// Limpa todos os erros de campos
  OdometerFormState clearAllFieldErrors() {
    return copyWith(fieldErrors: const {});
  }

  /// Marca formulário como alterado
  OdometerFormState markAsChanged() {
    return copyWith(hasChanges: true);
  }
}
