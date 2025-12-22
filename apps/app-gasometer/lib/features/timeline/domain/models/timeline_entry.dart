import 'package:flutter/material.dart';

import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../odometer/domain/entities/odometer_entity.dart';

/// Sealed class representing a timeline entry (can be fuel, maintenance, expense, or odometer)
sealed class TimelineEntry {
  const TimelineEntry();

  /// Get the date of this entry
  DateTime get date;

  /// Get the vehicle ID associated with this entry
  String get vehicleId;

  /// Get the odometer reading (if available)
  double? get odometer;

  /// Get the entry ID
  String get id;

  /// Get the type name for display
  String get typeName;

  /// Get the icon for this entry type
  IconData get icon;

  /// Get the color for this entry type
  Color get color;

  /// Get the title/description for this entry
  String get title;

  /// Get the subtitle with additional info
  String? get subtitle;

  /// Get the amount/cost if applicable
  double? get amount;

  /// Factory constructors for each type
  factory TimelineEntry.fuel(FuelRecordEntity fuel) = FuelTimelineEntry;
  factory TimelineEntry.maintenance(MaintenanceEntity maintenance) =
      MaintenanceTimelineEntry;
  factory TimelineEntry.expense(ExpenseEntity expense) = ExpenseTimelineEntry;
  factory TimelineEntry.odometer(OdometerEntity odometer) =
      OdometerTimelineEntry;

  /// Pattern matching helper
  T when<T>({
    required T Function(FuelTimelineEntry) fuel,
    required T Function(MaintenanceTimelineEntry) maintenance,
    required T Function(ExpenseTimelineEntry) expense,
    required T Function(OdometerTimelineEntry) odometer,
  }) {
    return switch (this) {
      FuelTimelineEntry() => fuel(this as FuelTimelineEntry),
      MaintenanceTimelineEntry() =>
        maintenance(this as MaintenanceTimelineEntry),
      ExpenseTimelineEntry() => expense(this as ExpenseTimelineEntry),
      OdometerTimelineEntry() => odometer(this as OdometerTimelineEntry),
    };
  }
}

/// Fuel supply timeline entry
final class FuelTimelineEntry extends TimelineEntry {
  const FuelTimelineEntry(this.fuel);

  final FuelRecordEntity fuel;

  @override
  DateTime get date => fuel.date;

  @override
  String get vehicleId => fuel.vehicleId;

  @override
  double? get odometer => fuel.odometer;

  @override
  String get id => fuel.id;

  @override
  String get typeName => 'Abastecimento';

  @override
  IconData get icon => Icons.local_gas_station;

  @override
  Color get color => Colors.green;

  @override
  String get title =>
      '${fuel.liters.toStringAsFixed(2)}L - ${fuel.fuelType.displayName}';

  @override
  String? get subtitle => fuel.gasStationName;

  @override
  double? get amount => fuel.totalPrice;
}

/// Maintenance timeline entry
final class MaintenanceTimelineEntry extends TimelineEntry {
  const MaintenanceTimelineEntry(this.maintenance);

  final MaintenanceEntity maintenance;

  @override
  DateTime get date => maintenance.serviceDate;

  @override
  String get vehicleId => maintenance.vehicleId;

  @override
  double? get odometer => maintenance.odometer;

  @override
  String get id => maintenance.id;

  @override
  String get typeName => 'Manutenção';

  @override
  IconData get icon => Icons.build;

  @override
  Color get color => Color(maintenance.type.colorValue);

  @override
  String get title => maintenance.title;

  @override
  String? get subtitle => maintenance.workshopName;

  @override
  double? get amount => maintenance.cost;
}

/// Expense timeline entry
final class ExpenseTimelineEntry extends TimelineEntry {
  const ExpenseTimelineEntry(this.expense);

  final ExpenseEntity expense;

  @override
  DateTime get date => expense.date;

  @override
  String get vehicleId => expense.vehicleId;

  @override
  double? get odometer => expense.odometer;

  @override
  String get id => expense.id;

  @override
  String get typeName => 'Despesa';

  @override
  IconData get icon => Icons.attach_money;

  @override
  Color get color => Colors.red;

  @override
  String get title => expense.description;

  @override
  String? get subtitle => expense.type.displayName;

  @override
  double? get amount => expense.amount;
}

/// Odometer reading timeline entry
final class OdometerTimelineEntry extends TimelineEntry {
  const OdometerTimelineEntry(this.odometerReading);

  final OdometerEntity odometerReading;

  @override
  DateTime get date => odometerReading.registrationDate;

  @override
  String get vehicleId => odometerReading.vehicleId;

  @override
  double? get odometer => odometerReading.value;

  @override
  String get id => odometerReading.id;

  @override
  String get typeName => 'Odômetro';

  @override
  IconData get icon => Icons.speed;

  @override
  Color get color => Colors.blue;

  @override
  String get title =>
      '${odometerReading.value.toStringAsFixed(0)} km';

  @override
  String? get subtitle => odometerReading.type.displayName;

  @override
  double? get amount => null;
}
