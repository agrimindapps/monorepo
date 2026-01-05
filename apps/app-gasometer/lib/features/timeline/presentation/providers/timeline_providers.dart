import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../activities/domain/usecases/get_recent_params.dart';
import '../../../activities/presentation/providers/activities_providers.dart';
import '../../domain/models/timeline_entry.dart';

part 'timeline_providers.g.dart';

/// Limite máximo de registros a exibir na timeline
const int _timelineLimit = 50;

/// Timeline provider - combines all records from fuel, maintenance, expenses, and odometer
/// Uses the same use cases as activities page for consistency
@riverpod
Future<List<TimelineEntry>> timeline(Ref ref) async {
  try {
    final entries = <TimelineEntry>[];

    // Use a higher limit for timeline (50 instead of 3)
    const params = GetRecentParams(vehicleId: '', limit: _timelineLimit);

    // Fetch fuel records
    final fuelUseCase = ref.watch(getRecentFuelRecordsProvider);
    final fuelResult = await fuelUseCase(params);
    fuelResult.fold(
      (failure) => SecureLogger.warning(
        'Failed to load fuel records: ${failure.message}',
      ),
      (fuelRecords) {
        for (final record in fuelRecords) {
          entries.add(TimelineEntry.fuel(record));
        }
      },
    );

    // Fetch maintenance records
    final maintenanceUseCase = ref.watch(getRecentMaintenanceRecordsProvider);
    final maintenanceResult = await maintenanceUseCase(params);
    maintenanceResult.fold(
      (failure) => SecureLogger.warning(
        'Failed to load maintenance records: ${failure.message}',
      ),
      (maintenanceRecords) {
        for (final record in maintenanceRecords) {
          entries.add(TimelineEntry.maintenance(record));
        }
      },
    );

    // Fetch expense records
    final expensesUseCase = ref.watch(getRecentExpensesProvider);
    final expensesResult = await expensesUseCase(params);
    expensesResult.fold(
      (failure) =>
          SecureLogger.warning('Failed to load expenses: ${failure.message}'),
      (expenseRecords) {
        for (final record in expenseRecords) {
          entries.add(TimelineEntry.expense(record));
        }
      },
    );

    // Fetch odometer records
    final odometerUseCase = ref.watch(getRecentOdometerRecordsProvider);
    final odometerResult = await odometerUseCase(params);
    odometerResult.fold(
      (failure) => SecureLogger.warning(
        'Failed to load odometer records: ${failure.message}',
      ),
      (odometerRecords) {
        for (final record in odometerRecords) {
          entries.add(TimelineEntry.odometer(record));
        }
      },
    );

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    SecureLogger.info('Timeline loaded ${entries.length} total entries');
    return entries;
  } catch (e) {
    SecureLogger.error('Error loading timeline: $e');
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
  if (vehicleId == null || vehicleId.isEmpty) {
    return ref.watch(timelineProvider.future);
  }

  try {
    final entries = <TimelineEntry>[];

    // Use vehicle-specific params
    final params = GetRecentParams(vehicleId: vehicleId, limit: _timelineLimit);

    // Fetch fuel records for vehicle
    final fuelUseCase = ref.watch(getRecentFuelRecordsProvider);
    final fuelResult = await fuelUseCase(params);
    fuelResult.fold((failure) => null, (fuelRecords) {
      for (final record in fuelRecords) {
        entries.add(TimelineEntry.fuel(record));
      }
    });

    // Fetch maintenance records for vehicle
    final maintenanceUseCase = ref.watch(getRecentMaintenanceRecordsProvider);
    final maintenanceResult = await maintenanceUseCase(params);
    maintenanceResult.fold((failure) => null, (maintenanceRecords) {
      for (final record in maintenanceRecords) {
        entries.add(TimelineEntry.maintenance(record));
      }
    });

    // Fetch expense records for vehicle
    final expensesUseCase = ref.watch(getRecentExpensesProvider);
    final expensesResult = await expensesUseCase(params);
    expensesResult.fold((failure) => null, (expenseRecords) {
      for (final record in expenseRecords) {
        entries.add(TimelineEntry.expense(record));
      }
    });

    // Fetch odometer records for vehicle
    final odometerUseCase = ref.watch(getRecentOdometerRecordsProvider);
    final odometerResult = await odometerUseCase(params);
    odometerResult.fold((failure) => null, (odometerRecords) {
      for (final record in odometerRecords) {
        entries.add(TimelineEntry.odometer(record));
      }
    });

    // Apply date filters if provided
    var filtered = entries;
    if (startDate != null || endDate != null) {
      filtered = entries.where((entry) {
        if (startDate != null && entry.date.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && entry.date.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    SecureLogger.info(
      'Filtered timeline for vehicle $vehicleId: ${filtered.length} entries',
    );
    return filtered;
  } catch (e) {
    SecureLogger.error('Error loading filtered timeline: $e');
    return [];
  }
}
