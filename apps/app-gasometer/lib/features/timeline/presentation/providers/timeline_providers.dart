import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../maintenance/presentation/notifiers/unified_maintenance_notifier.dart';
import '../../../odometer/presentation/providers/odometer_providers.dart';
import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../domain/models/timeline_entry.dart';

part 'timeline_providers.g.dart';

/// Limite máximo de registros a exibir na timeline
const int _timelineLimit = 50;

/// Timeline provider - combines all records from fuel, maintenance, expenses, and odometer
@riverpod
Future<List<TimelineEntry>> timeline(Ref ref) async {
  try {
    final entries = <TimelineEntry>[];

    // Fetch fuel records
    final fuelResult = await ref.watch(deps.getAllFuelRecordsProvider).call();
    fuelResult.fold(
      (failure) => null,
      (fuelRecords) {
        for (final record in fuelRecords) {
          entries.add(TimelineEntry.fuel(record));
        }
      },
    );

    // Fetch maintenance records
    final maintenanceUseCase = ref.watch(getAllMaintenanceRecordsProvider);
    final maintenanceResult = await maintenanceUseCase.call(const NoParams());
    maintenanceResult.fold(
      (failure) => null,
      (maintenanceRecords) {
        for (final record in maintenanceRecords) {
          entries.add(TimelineEntry.maintenance(record));
        }
      },
    );

    // Fetch expense records
    final expensesUseCase = ref.watch(getAllExpensesProvider);
    final expensesResult = await expensesUseCase.call(const NoParams());
    expensesResult.fold(
      (failure) => null,
      (expenseRecords) {
        for (final record in expenseRecords) {
          entries.add(TimelineEntry.expense(record));
        }
      },
    );

    // Fetch odometer records
    final odometerUseCase = ref.watch(getAllOdometerReadingsProvider);
    final odometerResult = await odometerUseCase.call(const NoParams());
    odometerResult.fold(
      (failure) => null,
      (odometerRecords) {
        for (final record in odometerRecords) {
          entries.add(TimelineEntry.odometer(record));
        }
      },
    );

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    // Apply limit
    if (entries.length > _timelineLimit) {
      return entries.take(_timelineLimit).toList();
    }

    return entries;
  } catch (e) {
    // Return empty list on error
    return [];
  }
}

/// Filtered timeline by vehicle
@riverpod
Future<List<TimelineEntry>> filteredTimeline(
  Ref ref, {
  String? vehicleId,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final allEntries = await ref.watch(timelineProvider.future);

  final filtered = allEntries.where((entry) {
    // Filter by vehicle
    if (vehicleId != null && entry.vehicleId != vehicleId) {
      return false;
    }

    // Filter by date range
    if (startDate != null && entry.date.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && entry.date.isAfter(endDate)) {
      return false;
    }

    return true;
  }).toList();

  // Apply limit after filtering
  if (filtered.length > _timelineLimit) {
    return filtered.take(_timelineLimit).toList();
  }

  return filtered;
}
