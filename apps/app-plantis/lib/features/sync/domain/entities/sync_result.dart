import 'package:core/core.dart';

/// Represents the result of a sync operation.
///
/// Contains detailed information about what happened during sync:
/// - When the sync occurred
/// - How many items were successfully processed
/// - Which items had conflicts requiring resolution
/// - How many errors occurred
///
/// This entity is immutable and uses Equatable for value comparison.
/// Factory constructors provide convenient ways to create common result types.
class PlantisSyncResult extends Equatable {
  /// Timestamp when the sync operation completed
  final DateTime timestamp;

  /// Total number of items successfully processed
  final int itemsProcessed;

  /// List of IDs for items that had conflicts during sync
  final List<String> itemsWithConflicts;

  /// Number of errors encountered during sync
  final int errorCount;

  const PlantisSyncResult({
    required this.timestamp,
    required this.itemsProcessed,
    required this.itemsWithConflicts,
    required this.errorCount,
  });

  /// Creates a successful sync result with no conflicts or errors
  ///
  /// [itemsProcessed] - Number of items successfully synced
  factory PlantisSyncResult.success({int itemsProcessed = 0}) {
    return PlantisSyncResult(
      timestamp: DateTime.now(),
      itemsProcessed: itemsProcessed,
      itemsWithConflicts: const [],
      errorCount: 0,
    );
  }

  /// Creates a sync result with conflicts that need resolution
  ///
  /// [itemsProcessed] - Number of items successfully synced
  /// [conflictIds] - List of item IDs that have conflicts
  factory PlantisSyncResult.withConflicts(
    List<String> conflictIds, {
    int itemsProcessed = 0,
  }) {
    return PlantisSyncResult(
      timestamp: DateTime.now(),
      itemsProcessed: itemsProcessed,
      itemsWithConflicts: List<String>.from(conflictIds),
      errorCount: 0,
    );
  }

  /// Creates a sync result indicating errors occurred
  ///
  /// [errorCount] - Number of errors encountered
  /// [itemsProcessed] - Number of items successfully synced despite errors
  factory PlantisSyncResult.withError({
    required int errorCount,
    int itemsProcessed = 0,
  }) {
    return PlantisSyncResult(
      timestamp: DateTime.now(),
      itemsProcessed: itemsProcessed,
      itemsWithConflicts: const [],
      errorCount: errorCount,
    );
  }

  /// Creates a sync result with both conflicts and errors
  ///
  /// [conflictIds] - List of item IDs that have conflicts
  /// [errorCount] - Number of errors encountered
  /// [itemsProcessed] - Number of items successfully synced
  factory PlantisSyncResult.withConflictsAndErrors({
    required List<String> conflictIds,
    required int errorCount,
    int itemsProcessed = 0,
  }) {
    return PlantisSyncResult(
      timestamp: DateTime.now(),
      itemsProcessed: itemsProcessed,
      itemsWithConflicts: List<String>.from(conflictIds),
      errorCount: errorCount,
    );
  }

  /// Computed properties for status checking
  bool get hasConflicts => itemsWithConflicts.isNotEmpty;
  bool get hasErrors => errorCount > 0;
  bool get isClean => !hasConflicts && !hasErrors;
  bool get isSuccess => isClean && itemsProcessed > 0;

  /// Number of items with conflicts
  int get conflictCount => itemsWithConflicts.length;

  /// Total items affected (processed + conflicts + errors)
  int get totalItemsAffected => itemsProcessed + conflictCount + errorCount;

  @override
  List<Object?> get props => [
    timestamp,
    itemsProcessed,
    itemsWithConflicts,
    errorCount,
  ];

  @override
  String toString() {
    return 'PlantisSyncResult('
        'timestamp: $timestamp, '
        'processed: $itemsProcessed, '
        'conflicts: $conflictCount, '
        'errors: $errorCount'
        ')';
  }
}
