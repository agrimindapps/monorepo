import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/compare_reports.dart';
import '../../domain/usecases/export_report.dart';
import '../../domain/usecases/generate_custom_report.dart';
import '../../domain/usecases/generate_monthly_report.dart';
import '../../domain/usecases/generate_yearly_report.dart';
import '../../domain/usecases/get_reports_analytics.dart';
import 'reports_state.dart';

part 'reports_notifier.g.dart';

// ============================================================================
// Use Cases Providers (from GetIt)
// ============================================================================

@riverpod
GenerateMonthlyReport generateMonthlyReport(Ref ref) {
  return getIt<GenerateMonthlyReport>();
}

@riverpod
GenerateYearlyReport generateYearlyReport(Ref ref) {
  return getIt<GenerateYearlyReport>();
}

@riverpod
GenerateCustomReport generateCustomReport(Ref ref) {
  return getIt<GenerateCustomReport>();
}

@riverpod
CompareMonthlyReports compareMonthlyReports(Ref ref) {
  return getIt<CompareMonthlyReports>();
}

@riverpod
CompareYearlyReports compareYearlyReports(Ref ref) {
  return getIt<CompareYearlyReports>();
}

@riverpod
GetFuelEfficiencyTrends getFuelEfficiencyTrends(Ref ref) {
  return getIt<GetFuelEfficiencyTrends>();
}

@riverpod
GetCostAnalysis getCostAnalysis(Ref ref) {
  return getIt<GetCostAnalysis>();
}

@riverpod
GetUsagePatterns getUsagePatterns(Ref ref) {
  return getIt<GetUsagePatterns>();
}

@riverpod
ExportReportToCSV exportReportToCSV(Ref ref) {
  return getIt<ExportReportToCSV>();
}

// ============================================================================
// Reports State Notifier
// ============================================================================

@riverpod
class ReportsNotifier extends _$ReportsNotifier {
  @override
  ReportsState build() {
    return const ReportsState();
  }

  // ============================================================================
  // Vehicle Selection
  // ============================================================================

  void setSelectedVehicle(String vehicleId) {
    if (state.selectedVehicleId != vehicleId) {
      state = ReportsState(selectedVehicleId: vehicleId);
    }
  }

  // ============================================================================
  // Generate Reports
  // ============================================================================

  Future<void> generateCurrentMonthReport({String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final currentMonth = DateTime.now();
    final result = await ref.read(generateMonthlyReportProvider)(
      GenerateMonthlyReportParams(vehicleId: id, month: currentMonth),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error generating monthly report: ${failure.message}');
      },
      (report) {
        state = state.copyWith(
          currentMonthReport: report,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Monthly report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  Future<void> generateCurrentYearReport({String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final currentYear = DateTime.now().year;
    final result = await ref.read(generateYearlyReportProvider)(
      GenerateYearlyReportParams(vehicleId: id, year: currentYear),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error generating yearly report: ${failure.message}');
      },
      (report) {
        state = state.copyWith(
          currentYearReport: report,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Yearly report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  Future<void> generateCustomReport(
    DateTime startDate,
    DateTime endDate, {
    String? vehicleId,
  }) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(generateCustomReportProvider)(
      GenerateCustomReportParams(
        vehicleId: id,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error generating custom report: ${failure.message}');
      },
      (report) {
        state = state.copyWith(
          customReport: report,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Custom report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  // ============================================================================
  // Compare Reports
  // ============================================================================

  Future<void> compareCurrentMonthWithPrevious({String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    final result = await ref.read(compareMonthlyReportsProvider)(
      CompareMonthlyReportsParams(
        vehicleId: id,
        currentMonth: currentMonth,
        previousMonth: previousMonth,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error comparing monthly reports: ${failure.message}');
      },
      (comparison) {
        state = state.copyWith(
          monthlyComparison: comparison,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Monthly comparison generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  Future<void> compareCurrentYearWithPrevious({String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final currentYear = DateTime.now().year;
    final previousYear = currentYear - 1;

    final result = await ref.read(compareYearlyReportsProvider)(
      CompareYearlyReportsParams(
        vehicleId: id,
        currentYear: currentYear,
        previousYear: previousYear,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error comparing yearly reports: ${failure.message}');
      },
      (comparison) {
        state = state.copyWith(
          yearlyComparison: comparison,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Yearly comparison generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  // ============================================================================
  // Load Analytics
  // ============================================================================

  Future<void> loadEfficiencyTrends({int months = 12, String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(getFuelEfficiencyTrendsProvider)(
      GetFuelEfficiencyTrendsParams(vehicleId: id, months: months),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error loading efficiency trends: ${failure.message}');
      },
      (trends) {
        state = state.copyWith(
          efficiencyTrends: trends,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Efficiency trends loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  Future<void> loadCostAnalysis({
    DateTime? startDate,
    DateTime? endDate,
    String? vehicleId,
  }) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final end = endDate ?? DateTime.now();
    final start = startDate ?? DateTime(end.year, 1, 1); // Default to year start

    final result = await ref.read(getCostAnalysisProvider)(
      GetCostAnalysisParams(
        vehicleId: id,
        startDate: start,
        endDate: end,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error loading cost analysis: ${failure.message}');
      },
      (analysis) {
        state = state.copyWith(
          costAnalysis: analysis,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Cost analysis loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  Future<void> loadUsagePatterns({int months = 12, String? vehicleId}) async {
    final id = vehicleId ?? state.selectedVehicleId;
    if (id.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(getUsagePatternsProvider)(
      GetUsagePatternsParams(vehicleId: id, months: months),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error loading usage patterns: ${failure.message}');
      },
      (patterns) {
        state = state.copyWith(
          usagePatterns: patterns,
          isLoading: false,
          errorMessage: null,
        );
        if (kDebugMode) {
          debugPrint('[REPORTS] Usage patterns loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );
  }

  // ============================================================================
  // Load All Reports
  // ============================================================================

  Future<void> loadAllReportsForVehicle(String vehicleId) async {
    setSelectedVehicle(vehicleId);

    // Load main reports in parallel
    await Future.wait([
      generateCurrentMonthReport(vehicleId: vehicleId),
      generateCurrentYearReport(vehicleId: vehicleId),
      compareCurrentMonthWithPrevious(vehicleId: vehicleId),
      compareCurrentYearWithPrevious(vehicleId: vehicleId),
    ]);

    // Load analytics separately to avoid overloading
    await Future.wait([
      loadEfficiencyTrends(vehicleId: vehicleId),
      loadCostAnalysis(vehicleId: vehicleId),
      loadUsagePatterns(vehicleId: vehicleId),
    ]);
  }

  // ============================================================================
  // Export Report
  // ============================================================================

  Future<String?> exportCurrentMonthToCSV() async {
    if (state.currentMonthReport == null) return null;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(exportReportToCSVProvider)(
      ExportReportToCSVParams(report: state.currentMonthReport!),
    );

    String? csvContent;
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        debugPrint('[REPORTS] Error exporting report: ${failure.message}');
      },
      (content) {
        csvContent = content;
        state = state.copyWith(isLoading: false, errorMessage: null);
        debugPrint('[REPORTS] Report exported to CSV');
      },
    );

    return csvContent;
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void clearAllData() {
    state = ReportsState(selectedVehicleId: state.selectedVehicleId);
  }

  // ============================================================================
  // Private Helpers
  // ============================================================================

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is CacheFailure) {
      return 'Erro no armazenamento local. Tente reiniciar o app.';
    } else if (failure is AuthenticationFailure) {
      return 'Erro de autenticação. Faça login novamente.';
    } else if (failure is UnexpectedFailure) {
      return 'Erro inesperado: ${failure.message}';
    } else {
      return 'Erro inesperado: ${failure.message}';
    }
  }
}

// ============================================================================
// Derived State Providers (Computed Values)
// ============================================================================

@riverpod
bool hasError(Ref ref) {
  final state = ref.watch(reportsNotifierProvider);
  return state.errorMessage != null;
}

@riverpod
bool hasCurrentMonthData(Ref ref) {
  final state = ref.watch(reportsNotifierProvider);
  return state.currentMonthReport?.hasData == true;
}

@riverpod
bool hasCurrentYearData(Ref ref) {
  final state = ref.watch(reportsNotifierProvider);
  return state.currentYearReport?.hasData == true;
}

@riverpod
bool hasCustomData(Ref ref) {
  final state = ref.watch(reportsNotifierProvider);
  return state.customReport?.hasData == true;
}

@riverpod
bool hasAnalytics(Ref ref) {
  final state = ref.watch(reportsNotifierProvider);
  return state.efficiencyTrends != null ||
      state.costAnalysis != null ||
      state.usagePatterns != null;
}

// ============================================================================
// UI Helpers - Formatted Stats
// ============================================================================

@riverpod
Map<String, String> currentMonthStats(Ref ref) {
  final report = ref.watch(
    reportsNotifierProvider.select((s) => s.currentMonthReport),
  );

  if (report == null || !report.hasData) {
    return {
      'fuel_spent': 'R\$ 0,00',
      'fuel_liters': '0,0L',
      'distance': '0 km',
      'consumption': '0,0 km/L',
    };
  }

  return {
    'fuel_spent': report.formattedTotalFuelSpent,
    'fuel_liters': report.formattedTotalFuelLiters,
    'distance': report.formattedTotalDistance,
    'consumption': report.formattedAverageConsumption,
  };
}

@riverpod
Map<String, String> currentYearStats(Ref ref) {
  final report = ref.watch(
    reportsNotifierProvider.select((s) => s.currentYearReport),
  );

  if (report == null || !report.hasData) {
    return {
      'fuel_spent': 'R\$ 0,00',
      'fuel_liters': '0,0L',
      'distance': '0 km',
      'consumption': '0,0 km/L',
    };
  }

  return {
    'fuel_spent': report.formattedTotalFuelSpent,
    'fuel_liters': report.formattedTotalFuelLiters,
    'distance': report.formattedTotalDistance,
    'consumption': report.formattedAverageConsumption,
  };
}

@riverpod
Map<String, String> monthlyComparisons(Ref ref) {
  final comparison = ref.watch(
    reportsNotifierProvider.select((s) => s.monthlyComparison),
  );

  if (comparison == null) {
    return {
      'fuel_spent': 'R\$ 0,00',
      'fuel_liters': '0,0L',
      'distance': '0 km',
      'fuel_spent_growth': '0%',
      'distance_growth': '0%',
    };
  }

  return {
    'fuel_spent': comparison.previousPeriod.formattedTotalFuelSpent,
    'fuel_liters': comparison.previousPeriod.formattedTotalFuelLiters,
    'distance': comparison.previousPeriod.formattedTotalDistance,
    'fuel_spent_growth': comparison.formattedFuelSpentGrowth,
    'distance_growth': comparison.formattedDistanceGrowth,
  };
}

@riverpod
Map<String, String> yearlyComparisons(Ref ref) {
  final comparison = ref.watch(
    reportsNotifierProvider.select((s) => s.yearlyComparison),
  );

  if (comparison == null) {
    return {
      'fuel_spent': 'R\$ 0,00',
      'fuel_liters': '0,0L',
      'distance': '0 km',
      'fuel_spent_growth': '0%',
      'distance_growth': '0%',
    };
  }

  return {
    'fuel_spent': comparison.previousPeriod.formattedTotalFuelSpent,
    'fuel_liters': comparison.previousPeriod.formattedTotalFuelLiters,
    'distance': comparison.previousPeriod.formattedTotalDistance,
    'fuel_spent_growth': comparison.formattedFuelSpentGrowth,
    'distance_growth': comparison.formattedDistanceGrowth,
  };
}
