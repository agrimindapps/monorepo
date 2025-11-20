import 'package:core/core.dart' show Equatable;

import '../../domain/entities/odometer_entity.dart';

class OdometerState extends Equatable {
  const OdometerState({
    this.readings = const [],
    this.filteredReadings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedVehicleId,
    this.selectedMonth,
  });

  final List<OdometerEntity> readings;
  final List<OdometerEntity> filteredReadings;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedVehicleId;
  final DateTime? selectedMonth;

  bool get hasData => filteredReadings.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get hasActiveFilters => selectedVehicleId != null || selectedMonth != null;

  OdometerState copyWith({
    List<OdometerEntity>? readings,
    List<OdometerEntity>? filteredReadings,
    bool? isLoading,
    String? errorMessage,
    String? selectedVehicleId,
    DateTime? selectedMonth,
    bool clearError = false,
    bool clearMonth = false,
  }) {
    return OdometerState(
      readings: readings ?? this.readings,
      filteredReadings: filteredReadings ?? this.filteredReadings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
    );
  }

  @override
  List<Object?> get props => [
        readings,
        filteredReadings,
        isLoading,
        errorMessage,
        selectedVehicleId,
        selectedMonth,
      ];
}
