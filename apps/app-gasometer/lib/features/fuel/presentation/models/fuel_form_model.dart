import 'package:core/core.dart' show Equatable;

import '../../../../core/validation/input_sanitizer.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/fuel_record_entity.dart';

/// Model reativo para o formulário de abastecimento
class FuelFormModel extends Equatable {
  const FuelFormModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.vehicle,
    required this.fuelType,
    required this.liters,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.odometer,
    required this.date,
    required this.gasStationName,
    required this.gasStationBrand,
    required this.fullTank,
    required this.notes,
    this.isLoading = false,
    this.hasChanges = false,
    this.errors = const {},
    this.lastError,
  });

  /// Cria modelo inicial para novo abastecimento
  factory FuelFormModel.initial(String vehicleId, String userId) {
    return FuelFormModel(
      id: '',
      userId: userId,
      vehicleId: vehicleId,
      vehicle: null,
      fuelType: FuelType.gasoline,
      liters: 0.0,
      pricePerLiter: 0.0,
      totalPrice: 0.0,
      odometer: 0.0,
      date: DateTime.now(),
      gasStationName: '',
      gasStationBrand: '',
      fullTank: true,
      notes: '',
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  /// Cria modelo a partir de um registro existente para edição
  factory FuelFormModel.fromFuelRecord(FuelRecordEntity record) {
    return FuelFormModel(
      id: record.id,
      userId: record.userId ?? '',
      vehicleId: record.vehicleId,
      vehicle: null, // Será carregado separadamente
      fuelType: record.fuelType,
      liters: record.liters,
      pricePerLiter: record.pricePerLiter,
      totalPrice: record.totalPrice,
      odometer: record.odometer,
      date: record.date,
      gasStationName: record.gasStationName ?? '',
      gasStationBrand: record.gasStationBrand ?? '',
      fullTank: record.fullTank,
      notes: record.notes ?? '',
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
  final FuelType fuelType;
  final double liters;
  final double pricePerLiter;
  final double totalPrice;
  final double odometer;
  final DateTime date;
  final String gasStationName;
  final String gasStationBrand;
  final bool fullTank;
  final String notes;
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
    fuelType,
    liters,
    pricePerLiter,
    totalPrice,
    odometer,
    date,
    gasStationName,
    gasStationBrand,
    fullTank,
    notes,
    isLoading,
    hasChanges,
    errors,
    lastError,
  ];

  /// Cria nova instância com valores atualizados
  FuelFormModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    VehicleEntity? vehicle,
    FuelType? fuelType,
    double? liters,
    double? pricePerLiter,
    double? totalPrice,
    double? odometer,
    DateTime? date,
    String? gasStationName,
    String? gasStationBrand,
    bool? fullTank,
    String? notes,
    bool? isLoading,
    bool? hasChanges,
    Map<String, String>? errors,
    String? lastError,
    bool clearLastError = false,
  }) {
    return FuelFormModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      fuelType: fuelType ?? this.fuelType,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      odometer: odometer ?? this.odometer,
      date: date ?? this.date,
      gasStationName: gasStationName ?? this.gasStationName,
      gasStationBrand: gasStationBrand ?? this.gasStationBrand,
      fullTank: fullTank ?? this.fullTank,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errors: errors ?? this.errors,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  /// Verifica se o modelo tem dados válidos mínimos
  bool get hasMinimumData =>
      vehicleId.isNotEmpty && liters > 0 && pricePerLiter > 0 && odometer >= 0;

  /// Verifica se há erros de validação
  bool get hasErrors => errors.isNotEmpty;

  /// Verifica se o formulário está pronto para ser submetido
  bool get canSubmit => hasMinimumData && !hasErrors && !isLoading;

  /// Calcula o valor total baseado em litros e preço por litro
  double get calculatedTotalPrice => liters * pricePerLiter;

  /// Verifica se o valor total está correto (diferença menor que 1 centavo)
  bool get isTotalPriceCorrect =>
      (calculatedTotalPrice - totalPrice).abs() <= 0.01;

  /// Retorna mensagem de erro para um campo específico
  String? getFieldError(String field) => errors[field];

  /// Verifica se um campo específico tem erro
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Adiciona erro para um campo específico
  FuelFormModel setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = error;
    return copyWith(errors: newErrors);
  }

  /// Remove erro de um campo específico
  FuelFormModel clearFieldError(String field) {
    if (!errors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return copyWith(errors: newErrors);
  }

  /// Limpa todos os erros
  FuelFormModel clearAllErrors() {
    return copyWith(errors: const {});
  }

  /// Marca o formulário como tendo alterações
  FuelFormModel markAsChanged() {
    return copyWith(hasChanges: true);
  }

  /// Converte para FuelRecordEntity para persistência
  /// Aplica sanitização em todos os campos de texto para segurança
  FuelRecordEntity toFuelRecord() {
    final now = DateTime.now();
    final sanitizedGasStationName =
        gasStationName.isEmpty
            ? null
            : InputSanitizer.sanitizeName(gasStationName);

    final sanitizedGasStationBrand =
        gasStationBrand.isEmpty
            ? null
            : InputSanitizer.sanitizeName(gasStationBrand);

    final sanitizedNotes =
        notes.isEmpty ? null : InputSanitizer.sanitizeDescription(notes);

    return FuelRecordEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      userId: userId,
      vehicleId: vehicleId,
      fuelType: fuelType,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalPrice: totalPrice,
      odometer: odometer,
      date: date,
      gasStationName: sanitizedGasStationName,
      gasStationBrand: sanitizedGasStationBrand,
      fullTank: fullTank,
      notes: sanitizedNotes,
      createdAt:
          id.isEmpty
              ? now
              : DateTime.fromMillisecondsSinceEpoch(
                int.tryParse(id) ?? now.millisecondsSinceEpoch,
              ),
      updatedAt: now,
    );
  }
}
