part of 'fuel_riverpod_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension FuelRiverpodQuery on FuelRiverpod {
  Future<void> loadFuelRecords() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _queryService.loadAllRecords(forceRefresh: true);

      return result.fold(
        (failure) => FuelState(
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
        ),
        (records) {
          if (kDebugMode) {
            debugPrint(
              '🚗 Carregados ${records.length} registros de combustível',
            );
          }

          return FuelState(
            fuelRecords: records,
            isInitialized: true,
            statistics: _calculationService.calculateStatistics(records),
          );
        },
      );
    });
  }

  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: true,
          selectedVehicleId: vehicleId,
          clearError: true,
        ),
      );
    });

    final result = await _queryService.loadRecordsByVehicle(vehicleId);

    state.whenData((currentState) {
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (records) {
          if (kDebugMode) {
            debugPrint(
              '🚗 Carregados ${records.length} registros para veículo $vehicleId',
            );
          }

          state = AsyncValue.data(
            currentState.copyWith(
              fuelRecords: records,
              isLoading: false,
              statistics: _calculationService.calculateStatistics(records),
            ),
          );
        },
      );
    });
  }

  void searchFuelRecords(String query) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query.trim()));

      if (kDebugMode && query.isNotEmpty) {
        debugPrint(
          '🔍 Busca: "$query" - ${currentState.filteredRecords.length} resultados',
        );
      }
    });
  }

  void clearSearch() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(searchQuery: '', clearSearchQuery: true),
      );
    });
  }

  void filterByVehicle(String vehicleId) {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(selectedVehicleId: vehicleId),
      );
    });
  }

  void selectMonth(DateTime month) {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(selectedMonth: month),
      );
    });
  }

  void clearMonthFilter() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(clearMonthFilter: true),
      );
    });
  }

  void clearVehicleFilter() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          selectedVehicleId: null,
          clearVehicleFilter: true,
        ),
      );
    });
  }

  void clearAllFilters() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          selectedVehicleId: null,
          searchQuery: '',
          clearVehicleFilter: true,
          clearSearchQuery: true,
          clearMonthFilter: true,
        ),
      );
    });
    loadFuelRecords();
  }

  FuelRecordEntity? getFuelRecordById(String id) {
    return state.whenData((currentState) {
      try {
        return currentState.fuelRecords.firstWhere((record) => record.id == id);
      } catch (e) {
        return null;
      }
    }).value;
  }
}
