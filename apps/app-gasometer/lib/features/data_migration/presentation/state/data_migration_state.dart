import 'package:core/core.dart';

/// State for data migration operations
///
/// Manages conflict detection, migration progress, and resolution results
class DataMigrationState {
  const DataMigrationState({
    // Conflict detection state
    this.conflictResult,
    this.isDetectingConflicts = false,

    // Migration execution state
    this.migrationResult,
    this.isMigrating = false,
    this.currentProgress,

    // Error state
    this.failure,
  });

  /// Initial state
  factory DataMigrationState.initial() => const DataMigrationState();

  final DataConflictResult? conflictResult;
  final bool isDetectingConflicts;
  final DataMigrationResult? migrationResult;
  final bool isMigrating;
  final MigrationProgress? currentProgress;
  final Failure? failure;

  /// Computed properties
  bool get hasConflict => conflictResult?.hasConflict ?? false;

  bool get hasWarnings => migrationResult?.hasWarnings ?? false;

  List<String> get warnings => migrationResult?.warnings ?? [];

  bool get migrationSuccessful => migrationResult?.success ?? false;

  bool get hasError => failure != null;

  bool get isLoading => isDetectingConflicts || isMigrating;

  String? get errorMessage => failure?.message;

  String? get migrationResultMessage => migrationResult?.summaryMessage;

  /// CopyWith method for immutable updates
  DataMigrationState copyWith({
    DataConflictResult? conflictResult,
    bool? isDetectingConflicts,
    DataMigrationResult? migrationResult,
    bool? isMigrating,
    MigrationProgress? currentProgress,
    Failure? failure,
  }) {
    return DataMigrationState(
      conflictResult: conflictResult ?? this.conflictResult,
      isDetectingConflicts: isDetectingConflicts ?? this.isDetectingConflicts,
      migrationResult: migrationResult ?? this.migrationResult,
      isMigrating: isMigrating ?? this.isMigrating,
      currentProgress: currentProgress ?? this.currentProgress,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataMigrationState &&
          runtimeType == other.runtimeType &&
          conflictResult == other.conflictResult &&
          isDetectingConflicts == other.isDetectingConflicts &&
          migrationResult == other.migrationResult &&
          isMigrating == other.isMigrating &&
          currentProgress == other.currentProgress &&
          failure == other.failure;

  @override
  int get hashCode =>
      conflictResult.hashCode ^
      isDetectingConflicts.hashCode ^
      migrationResult.hashCode ^
      isMigrating.hashCode ^
      currentProgress.hashCode ^
      failure.hashCode;
}
