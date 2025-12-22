import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart' as deps;
import '../../domain/models/timeline_entry.dart';

part 'timeline_providers.g.dart';

/// Timeline provider - combines all records from fuel, maintenance, expenses, and odometer
/// TODO: Implement full data fetching logic with proper entity conversions
@riverpod
Future<List<TimelineEntry>> timeline(Ref ref) async {
  try {
    final entries = <TimelineEntry>[];

    // Fetch fuel records (this works)
    final fuelResult = await ref.watch(deps.getAllFuelRecordsProvider).call();
    fuelResult.fold(
      (failure) => null,
      (fuelRecords) {
        for (final record in fuelRecords) {
          entries.add(TimelineEntry.fuel(record));
        }
      },
    );

    // TODO: Add maintenance, expenses, and odometer when entity conversion is implemented
    // For now, showing only fuel records to demonstrate the UI

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));

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

  return allEntries.where((entry) {
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
}
