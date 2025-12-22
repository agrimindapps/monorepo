part of 'fuel_riverpod_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension FuelRiverpodSync on FuelRiverpod {
  Future<void> _setupConnectivityListener() async {
    final isOnline = await _connectivityService.initialize();

    this.state = AsyncValue.data(
      const FuelState().copyWith(isOnline: isOnline),
    );

    _connectivitySubscription = _connectivityService.addConnectivityListener(
      _onConnectivityChanged,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('🔌 Erro no stream de conectividade: $error');
        }
      },
    );
  }

  void _onConnectivityChanged(bool isOnline) {
    this.state.whenData((FuelState currentState) {
      final wasOnline = currentState.isOnline;
      this.state = AsyncValue.data(currentState.copyWith(isOnline: isOnline));

      if (_connectivityService.hasGoneOnline(wasOnline) &&
          currentState.hasPendingRecords) {
        unawaited(syncPendingRecords());
      }
    });
  }

  Future<List<FuelRecordEntity>> _loadPendingRecords() async {
    final result = await _syncService.loadPendingRecords();
    return result.fold((failure) {
      if (kDebugMode) {
        debugPrint(
          '🚗 Erro ao carregar registros pendentes: ${failure.message}',
        );
      }
      return [];
    }, (records) => records);
  }

  Future<void> syncPendingRecords() async {
    final currentState = this.state.value;
    if (currentState == null ||
        !currentState.isOnline ||
        !currentState.hasPendingRecords) {
      return;
    }

    this.state = AsyncValue.data(currentState.copyWith(isSyncing: true));

    if (kDebugMode) {
      debugPrint(
        '🔌 Sincronizando ${currentState.pendingRecordsCount} registros pendentes...',
      );
    }

    // Delegate sync to FuelSyncService
    final recordsToSync = List<FuelRecordEntity>.from(
      currentState.pendingRecords,
    );
    final syncedIds = <String>[];
    final failedRecords = <FuelRecordEntity>[];

    for (final record in recordsToSync) {
      try {
        final result = await _crudService.addFuel(record);

        result.fold(
          (failure) {
            failedRecords.add(record);
            if (kDebugMode) {
              debugPrint(
                '🔌 Falha ao sincronizar registro: ${failure.message}',
              );
            }
          },
          (syncedRecord) {
            syncedIds.add(syncedRecord.id);
            if (kDebugMode) {
              debugPrint('🔌 Registro sincronizado: ${syncedRecord.id}');
            }
          },
        );
      } catch (e) {
        failedRecords.add(record);
        if (kDebugMode) {
          debugPrint('🔌 Erro ao sincronizar registro: $e');
        }
      }
    }

    // Mark synced records
    if (syncedIds.isNotEmpty) {
      await _syncService.markRecordsAsSynced(syncedIds);
    }

    // Reload pending records
    final updatedPending = await _loadPendingRecords();

    this.state = AsyncValue.data(
      currentState.copyWith(pendingRecords: updatedPending, isSyncing: false),
    );

    if (updatedPending.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔌 Todos os registros foram sincronizados!');
      }
    } else {
      if (kDebugMode) {
        debugPrint('🔌 ${updatedPending.length} registros ainda pendentes');
      }
    }

    await loadFuelRecords();
  }
}
