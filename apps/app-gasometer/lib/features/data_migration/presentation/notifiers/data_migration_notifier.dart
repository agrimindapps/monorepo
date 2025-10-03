import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/gasometer_data_migration_service.dart';
import '../state/data_migration_state.dart';

part 'data_migration_notifier.g.dart';

/// Riverpod provider for GasometerDataMigrationService
@riverpod
GasometerDataMigrationService dataMigrationService(Ref ref) {
  // Get service from GetIt
  return GetIt.I<GasometerDataMigrationService>();
}

/// Notifier that manages the data migration state and operations
///
/// This notifier coordinates the migration process between anonymous and
/// account data, handling conflict detection, user choices, and migration execution.
@riverpod
class DataMigration extends _$DataMigration {
  StreamSubscription<MigrationProgress>? _progressSubscription;

  @override
  DataMigrationState build() {
    // Listen to migration progress stream
    _listenToProgress();

    // Cleanup when disposed
    ref.onDispose(() {
      _progressSubscription?.cancel();
    });

    return DataMigrationState.initial();
  }

  /// Listen to migration progress updates
  void _listenToProgress() {
    final service = ref.read(dataMigrationServiceProvider);

    _progressSubscription = service.migrationProgress.listen(
      (progress) {
        if (state.isMigrating) {
          state = state.copyWith(currentProgress: progress);
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('❌ Progress stream error: $error');
        }
      },
    );
  }

  /// Detect conflicts between anonymous and account data
  Future<bool> detectConflicts({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    // Guard clause: prevent concurrent operations
    if (state.isDetectingConflicts) return false;

    try {
      state = state.copyWith(
        isDetectingConflicts: true,
        conflictResult: null,
        failure: null,
      );

      if (kDebugMode) {
        debugPrint('🔍 Detecting data conflicts...');
      }

      final service = ref.read(dataMigrationServiceProvider);
      final result = await service.detectConflicts(
        anonymousUserId: anonymousUserId,
        accountUserId: accountUserId,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isDetectingConflicts: false,
            failure: failure,
          );

          if (kDebugMode) {
            debugPrint('❌ Conflict detection failed: ${failure.message}');
          }

          return false;
        },
        (conflictResult) {
          state = state.copyWith(
            isDetectingConflicts: false,
            conflictResult: conflictResult,
            failure: null,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ Conflict detection complete: ${conflictResult.hasConflict ? 'Conflict found' : 'No conflicts'}',
            );
          }

          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDetectingConflicts: false,
        failure: UnknownFailure('Erro ao detectar conflitos: $e'),
      );

      if (kDebugMode) {
        debugPrint('❌ Unexpected error in detectConflicts: $e');
      }

      return false;
    }
  }

  /// Execute the user's choice for resolving conflicts
  Future<bool> executeResolution({
    required DataResolutionChoice choice,
    Map<String, dynamic> additionalParams = const {},
  }) async {
    // Guard clauses: ensure preconditions are met
    if (state.conflictResult == null || state.isMigrating) return false;

    try {
      state = state.copyWith(
        isMigrating: true,
        migrationResult: null,
        currentProgress: null,
        failure: null,
      );

      if (kDebugMode) {
        debugPrint('⚡ Executing resolution: ${choice.name}');
      }

      final service = ref.read(dataMigrationServiceProvider);
      final result = await service.executeResolution(
        choice: choice,
        conflictResult: state.conflictResult!,
        additionalParams: additionalParams,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isMigrating: false,
            failure: failure,
          );

          if (kDebugMode) {
            debugPrint('❌ Resolution failed: ${failure.message}');
          }

          return false;
        },
        (migrationResult) {
          state = state.copyWith(
            isMigrating: false,
            migrationResult: migrationResult,
            failure: null,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ Resolution executed: ${migrationResult.success ? 'Success' : 'Failed'}',
            );
          }

          return migrationResult.success;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isMigrating: false,
        failure: UnknownFailure('Erro ao executar resolução: $e'),
      );

      if (kDebugMode) {
        debugPrint('❌ Unexpected error in executeResolution: $e');
      }

      return false;
    }
  }

  /// Cancel ongoing migration operation
  Future<bool> cancelMigration() async {
    // Guard clause: only cancel if migration is in progress
    if (!state.isMigrating) return false;

    try {
      if (kDebugMode) {
        debugPrint('🛑 Canceling migration');
      }

      final service = ref.read(dataMigrationServiceProvider);
      final result = await service.cancelMigration();

      return result.fold(
        (failure) {
          state = state.copyWith(failure: failure);

          if (kDebugMode) {
            debugPrint('❌ Cancel failed: ${failure.message}');
          }

          return false;
        },
        (_) {
          state = state.copyWith(
            isMigrating: false,
            currentProgress: null,
            failure: null,
          );

          if (kDebugMode) {
            debugPrint('✅ Migration canceled successfully');
          }

          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        failure: UnknownFailure('Erro ao cancelar migração: $e'),
      );

      if (kDebugMode) {
        debugPrint('❌ Unexpected error in cancelMigration: $e');
      }

      return false;
    }
  }

  /// Check if migration preconditions are met
  Future<bool> validatePreconditions({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('✅ Validating migration preconditions');
      }

      final service = ref.read(dataMigrationServiceProvider);
      final result = await service.validateMigrationPreconditions(
        anonymousUserId: anonymousUserId,
        accountUserId: accountUserId,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(failure: failure);

          if (kDebugMode) {
            debugPrint('❌ Validation failed: ${failure.message}');
          }

          return false;
        },
        (isValid) {
          state = state.copyWith(failure: null);

          if (kDebugMode) {
            debugPrint('✅ Validation successful: $isValid');
          }

          return isValid;
        },
      );
    } catch (e) {
      state = state.copyWith(
        failure: UnknownFailure('Erro na validação: $e'),
      );

      if (kDebugMode) {
        debugPrint('❌ Unexpected error in validatePreconditions: $e');
      }

      return false;
    }
  }

  /// Reset the migration state
  void resetState() {
    if (kDebugMode) {
      debugPrint('🔄 Resetting migration state');
    }

    state = DataMigrationState.initial();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(failure: null);
  }
}
