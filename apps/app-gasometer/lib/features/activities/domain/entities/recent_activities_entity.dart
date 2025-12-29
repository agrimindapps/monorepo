import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../odometer/domain/entities/odometer_entity.dart';

/// Entity that aggregates recent records from all activity categories
class RecentActivitiesEntity with EquatableMixin {
  const RecentActivitiesEntity({
    required this.fuelRecords,
    required this.maintenanceRecords,
    required this.expenses,
    required this.odometerRecords,
    required this.vehicleId,
  });

  /// Empty state constructor
  const RecentActivitiesEntity.empty()
      : fuelRecords = const [],
        maintenanceRecords = const [],
        expenses = const [],
        odometerRecords = const [],
        vehicleId = '';

  final List<FuelRecordEntity> fuelRecords;
  final List<MaintenanceEntity> maintenanceRecords;
  final List<ExpenseEntity> expenses;
  final List<OdometerEntity> odometerRecords;
  final String vehicleId;

  /// Computed properties for empty states
  bool get hasFuelRecords => fuelRecords.isNotEmpty;
  bool get hasMaintenanceRecords => maintenanceRecords.isNotEmpty;
  bool get hasExpenses => expenses.isNotEmpty;
  bool get hasOdometerRecords => odometerRecords.isNotEmpty;
  bool get hasAnyRecords =>
      hasFuelRecords || hasMaintenanceRecords || hasExpenses || hasOdometerRecords;

  /// Total count of all records
  int get totalRecordsCount =>
      fuelRecords.length +
      maintenanceRecords.length +
      expenses.length +
      odometerRecords.length;

  @override
  List<Object?> get props => [
        fuelRecords,
        maintenanceRecords,
        expenses,
        odometerRecords,
        vehicleId,
      ];

  RecentActivitiesEntity copyWith({
    List<FuelRecordEntity>? fuelRecords,
    List<MaintenanceEntity>? maintenanceRecords,
    List<ExpenseEntity>? expenses,
    List<OdometerEntity>? odometerRecords,
    String? vehicleId,
  }) {
    return RecentActivitiesEntity(
      fuelRecords: fuelRecords ?? this.fuelRecords,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      expenses: expenses ?? this.expenses,
      odometerRecords: odometerRecords ?? this.odometerRecords,
      vehicleId: vehicleId ?? this.vehicleId,
    );
  }
}
