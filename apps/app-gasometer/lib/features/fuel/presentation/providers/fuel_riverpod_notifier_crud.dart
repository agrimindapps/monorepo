part of 'fuel_riverpod_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension FuelRiverpodCrud on FuelRiverpod {
  Future<bool> addFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.addFuel(record);

    return result.fold(
      (failure) async {
        final updatedPending = await _loadPendingRecords();
        final updatedRecords = [record, ...currentState.fuelRecords];

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
            pendingRecords: updatedPending,
          ),
        );

        if (kDebugMode) {
          debugPrint(
            '🔌 Registro salvo localmente (Drift), será sincronizado: ${failure.message}',
          );
        }

        return true;
      },
      (addedRecord) async {
        final updatedRecords = [addedRecord, ...currentState.fuelRecords];
        final updatedPending = await _loadPendingRecords();

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
            pendingRecords: updatedPending,
          ),
        );

        if (kDebugMode) {
          debugPrint(
            '🚗 Registro adicionado e sincronizado: ${addedRecord.id}',
          );
        }

        return true;
      },
    );
  }

  Future<bool> updateFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.updateFuel(record);

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
        return false;
      },
      (updatedRecord) {
        final updatedRecords = currentState.fuelRecords.map((r) {
          return r.id == updatedRecord.id ? updatedRecord : r;
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
          ),
        );

        if (kDebugMode) {
          debugPrint('🚗 Registro atualizado: ${updatedRecord.id}');
        }

        return true;
      },
    );
  }

  Future<bool> deleteFuelRecord(String recordId) async {
    if (recordId.isEmpty) return false;

    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.deleteFuel(recordId);

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
        return false;
      },
      (_) {
        final updatedRecords = currentState.fuelRecords
            .where((r) => r.id != recordId)
            .toList();
        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
          ),
        );

        if (kDebugMode) {
          debugPrint('🚗 Registro removido: $recordId');
        }

        return true;
      },
    );
  }

  /// Delete otimístico com suporte a undo
  /// Remove o item da UI imediatamente e executa a deleção em background
  Future<void> deleteOptimistic(String recordId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Encontra o item a ser removido
    final itemToDelete = currentState.fuelRecords.firstWhere(
      (r) => r.id == recordId,
      orElse: () => throw Exception('Item não encontrado'),
    );

    // Guarda no cache para possível restauração
    _deletedCache[recordId] = itemToDelete;

    // Remove otimisticamente da UI
    final updatedRecords = currentState.fuelRecords
        .where((r) => r.id != recordId)
        .toList();
    state = AsyncValue.data(
      currentState.copyWith(
        fuelRecords: updatedRecords,
        statistics: _calculationService.calculateStatistics(updatedRecords),
      ),
    );

    // Executa delete no backend
    final result = await _crudService.deleteFuel(recordId);

    result.fold(
      (failure) {
        // Se falhou, restaura o item na UI
        _restoreFromCache(recordId);
        if (kDebugMode) {
          debugPrint('❌ Falha ao deletar: ${failure.message}');
        }
      },
      (_) {
        // Sucesso - remove do cache após um delay (tempo para undo)
        Future.delayed(const Duration(seconds: 10), () {
          _deletedCache.remove(recordId);
        });
        if (kDebugMode) {
          debugPrint('✅ Registro deletado: $recordId');
        }
      },
    );
  }

  /// Restaura um item deletado (undo)
  Future<void> restoreDeleted(String recordId) async {
    final cachedItem = _deletedCache[recordId];
    if (cachedItem == null) return;

    // Restaura na UI primeiro
    _restoreFromCache(recordId);

    // Re-adiciona no backend
    await _crudService.addFuel(cachedItem);

    // Remove do cache
    _deletedCache.remove(recordId);
  }

  void _restoreFromCache(String recordId) {
    final cachedItem = _deletedCache[recordId];
    if (cachedItem == null) return;

    final currentState = state.value;
    if (currentState == null) return;

    final updatedRecords = [...currentState.fuelRecords, cachedItem];
    // Ordena por data (mais recente primeiro)
    updatedRecords.sort((a, b) => b.date.compareTo(a.date));

    state = AsyncValue.data(
      currentState.copyWith(
        fuelRecords: updatedRecords,
        statistics: _calculationService.calculateStatistics(updatedRecords),
      ),
    );
  }
}
