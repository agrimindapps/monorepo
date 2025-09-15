import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/providers/base_provider.dart';
import '../../data/services/gasometer_data_migration_service.dart';

/// Provider that manages the data migration state and operations
/// 
/// This provider coordinates the migration process between anonymous and
/// account data, handling conflict detection, user choices, and migration execution.
class DataMigrationProvider extends BaseProvider {
  // Constructor
  DataMigrationProvider(this._migrationService);

  // Dependencies
  final GasometerDataMigrationService _migrationService;

  // State variables
  DataConflictResult? _conflictResult;
  DataMigrationResult? _migrationResult;
  bool _isDetectingConflicts = false;
  bool _isMigrating = false;
  MigrationProgress? _currentProgress;

  // Getters
  DataConflictResult? get conflictResult => _conflictResult;
  DataMigrationResult? get migrationResult => _migrationResult;
  bool get isDetectingConflicts => _isDetectingConflicts;
  bool get isMigrating => _isMigrating;
  MigrationProgress? get currentProgress => _currentProgress;
  bool get hasConflict => _conflictResult?.hasConflict ?? false;

  /// Detect conflicts between anonymous and account data
  Future<bool> detectConflicts({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    // Guard clause: prevent concurrent operations
    if (_isDetectingConflicts) return false;

    return await executeDataOperation<bool>(
      () async {
        _isDetectingConflicts = true;
        _conflictResult = null;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('🔍 Detecting data conflicts...');
        }

        final result = await _migrationService.detectConflicts(
          anonymousUserId: anonymousUserId,
          accountUserId: accountUserId,
        );

        return result.fold(
          (failure) => throw Exception(failure.message),
          (conflictResult) {
            _conflictResult = conflictResult;
            notifyListeners();
            
            if (kDebugMode) {
              debugPrint('✅ Conflict detection complete: ${conflictResult.hasConflict ? 'Conflict found' : 'No conflicts'}');
            }
            
            return true;
          },
        );
      },
      operationName: 'detectConflicts',
      showLoading: false,
    ) ?? false;
  }

  /// Show conflict resolution dialog and handle user choice
  Future<DataResolutionChoice?> showConflictDialog(BuildContext context) async {
    // Guard clause: ensure conflict data is available
    if (_conflictResult == null) return null;

    try {
      if (kDebugMode) {
        debugPrint('📋 Showing conflict dialog');
      }

      // Use standard showDialog as fallback until DataConflictDialog is implemented
      final choice = await showDialog<DataResolutionChoice>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dados Existentes Detectados'),
          content: const Text('Conflito detectado. Escolha uma opção para resolver.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(DataResolutionChoice.keepAccountData),
              child: const Text('Manter Dados da Conta'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(DataResolutionChoice.keepAnonymousData),
              child: const Text('Manter Dados Anônimos'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(DataResolutionChoice.cancel),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (kDebugMode) {
        debugPrint('👤 User choice: ${choice?.name ?? 'No choice'}');
      }

      return choice;

    } catch (e) {
      setState(ProviderState.error, error: UnexpectedError(message: 'Erro ao exibir diálogo de conflito: $e'));
      return null;
    }
  }

  /// Execute the user's choice for resolving conflicts
  Future<bool> executeResolution({
    required DataResolutionChoice choice,
    Map<String, dynamic> additionalParams = const {},
  }) async {
    // Guard clauses: ensure preconditions are met
    if (_conflictResult == null || _isMigrating) return false;

    return await executeDataOperation<bool>(
      () async {
        _isMigrating = true;
        _migrationResult = null;
        _currentProgress = null;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('⚡ Executing resolution: ${choice.name}');
        }

        // Listen to migration progress
        _migrationService.migrationProgress.listen((progress) {
          _currentProgress = progress;
          notifyListeners();
        });

        final result = await _migrationService.executeResolution(
          choice: choice,
          conflictResult: _conflictResult!,
          additionalParams: additionalParams,
        );

        return result.fold(
          (failure) => throw Exception(failure.message),
          (migrationResult) {
            _migrationResult = migrationResult;
            notifyListeners();
            
            if (kDebugMode) {
              debugPrint('✅ Resolution executed: ${migrationResult.success ? 'Success' : 'Failed'}');
            }
            
            return migrationResult.success;
          },
        );
      },
      operationName: 'executeResolution',
      showLoading: false,
    ) ?? false;
  }

  /// Show migration progress dialog
  Future<void> showProgressDialog({
    required BuildContext context,
    required String operationTitle,
    bool allowCancel = false,
  }) async {
    // Guard clause: only show if migration is in progress
    if (!_isMigrating) return;

    try {
      // Use standard showDialog as fallback until MigrationProgressDialog is implemented
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(operationTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_currentProgress?.currentOperation ?? 'Processando...'),
            ],
          ),
          actions: allowCancel ? [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cancelMigration();
              },
              child: const Text('Cancelar'),
            ),
          ] : null,
        ),
      );

    } catch (e) {
      setState(ProviderState.error, error: UnexpectedError(message: 'Erro ao exibir diálogo de progresso: $e'));
    }
  }

  /// Cancel ongoing migration operation
  Future<bool> cancelMigration() async {
    // Guard clause: only cancel if migration is in progress
    if (!_isMigrating) return false;

    return await executeDataOperation<bool>(
      () async {
        if (kDebugMode) {
          debugPrint('🛑 Canceling migration');
        }

        final result = await _migrationService.cancelMigration();
        
        return result.fold(
          (failure) => throw Exception(failure.message),
          (_) {
            _isMigrating = false;
            _currentProgress = null;
            notifyListeners();
            return true;
          },
        );
      },
      operationName: 'cancelMigration',
      showLoading: false,
    ) ?? false;
  }

  /// Check if migration preconditions are met
  Future<bool> validatePreconditions({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    return await executeDataOperation<bool>(
      () async {
        if (kDebugMode) {
          debugPrint('✅ Validating migration preconditions');
        }

        final result = await _migrationService.validateMigrationPreconditions(
          anonymousUserId: anonymousUserId,
          accountUserId: accountUserId,
        );

        return result.fold(
          (failure) => throw Exception(failure.message),
          (isValid) => isValid,
        );
      },
      operationName: 'validatePreconditions',
      showLoading: false,
    ) ?? false;
  }

  /// Reset the migration state
  void resetState() {
    _conflictResult = null;
    _migrationResult = null;
    _currentProgress = null;
    _isDetectingConflicts = false;
    _isMigrating = false;
    clearError();
    setState(ProviderState.initial);
  }

  /// Get user-friendly message for migration result
  String? getMigrationResultMessage() {
    if (_migrationResult == null) return null;
    
    return _migrationResult!.summaryMessage;
  }

  /// Check if there are any warnings in the migration result
  bool get hasWarnings => _migrationResult?.hasWarnings ?? false;

  /// Get warnings from the migration result
  List<String> get warnings => _migrationResult?.warnings ?? [];

  /// Check if migration was successful
  bool get migrationSuccessful => _migrationResult?.success ?? false;

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}