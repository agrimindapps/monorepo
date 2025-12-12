part of 'fuel_riverpod_notifier.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

extension FuelRiverpodAnalytics on FuelRiverpod {
  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    final currentState = state.value;
    if (currentState == null) return;

    try {
      final consumptionResult = await _getAverageConsumption(
        GetAverageConsumptionParams(vehicleId: vehicleId),
      );

      double averageConsumption = 0.0;
      consumptionResult.fold(
        (failure) =>
            debugPrint('Erro ao carregar consumo médio: ${failure.message}'),
        (consumption) => averageConsumption = consumption,
      );
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final totalSpentResult = await _getTotalSpent(
        GetTotalSpentParams(vehicleId: vehicleId, startDate: thirtyDaysAgo),
      );

      double totalSpent = 0.0;
      totalSpentResult.fold(
        (failure) =>
            debugPrint('Erro ao carregar total gasto: ${failure.message}'),
        (total) => totalSpent = total,
      );
      final recentResult = await _getRecentFuelRecords(
        GetRecentFuelRecordsParams(vehicleId: vehicleId, limit: 5),
      );

      List<FuelRecordEntity> recentRecords = [];
      recentResult.fold(
        (failure) => debugPrint(
          'Erro ao carregar registros recentes: ${failure.message}',
        ),
        (records) => recentRecords = records,
      );
      final analytics = FuelAnalytics(
        vehicleId: vehicleId,
        averageConsumption: averageConsumption,
        totalSpent: totalSpent,
        recentRecords: recentRecords,
        period: 30,
      );

      final updatedAnalyticsCache = Map<String, FuelAnalytics>.from(
        currentState.analytics,
      );
      updatedAnalyticsCache[vehicleId] = analytics;

      state = AsyncValue.data(
        currentState.copyWith(analytics: updatedAnalyticsCache),
      );

      if (kDebugMode) {
        debugPrint('🚗 Analytics carregados para veículo $vehicleId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar analytics: $e');
      }
    }
  }

  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    return state.whenData((currentState) {
          return _calculationService.calculateTotalSpentInRange(
            currentState.fuelRecords,
            startDate,
            endDate,
          );
        }).value ??
        0.0;
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    return state.whenData((currentState) {
          return _calculationService.calculateTotalLitersInRange(
            currentState.fuelRecords,
            startDate,
            endDate,
          );
        }).value ??
        0.0;
  }
}
