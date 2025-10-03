import 'package:equatable/equatable.dart';

import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

/// Immutable state for Reports feature (Riverpod)
class ReportsState extends Equatable {
  const ReportsState({
    this.currentMonthReport,
    this.currentYearReport,
    this.customReport,
    this.monthlyComparison,
    this.yearlyComparison,
    this.efficiencyTrends,
    this.costAnalysis,
    this.usagePatterns,
    this.isLoading = false,
    this.errorMessage,
    this.selectedVehicleId = '',
  });

  // Current reports
  final ReportSummaryEntity? currentMonthReport;
  final ReportSummaryEntity? currentYearReport;
  final ReportSummaryEntity? customReport;

  // Comparisons
  final ReportComparisonEntity? monthlyComparison;
  final ReportComparisonEntity? yearlyComparison;

  // Analytics data
  final Map<String, dynamic>? efficiencyTrends;
  final Map<String, dynamic>? costAnalysis;
  final Map<String, dynamic>? usagePatterns;

  // State flags
  final bool isLoading;
  final String? errorMessage;
  final String selectedVehicleId;

  @override
  List<Object?> get props => [
        currentMonthReport,
        currentYearReport,
        customReport,
        monthlyComparison,
        yearlyComparison,
        efficiencyTrends,
        costAnalysis,
        usagePatterns,
        isLoading,
        errorMessage,
        selectedVehicleId,
      ];

  ReportsState copyWith({
    ReportSummaryEntity? currentMonthReport,
    ReportSummaryEntity? currentYearReport,
    ReportSummaryEntity? customReport,
    ReportComparisonEntity? monthlyComparison,
    ReportComparisonEntity? yearlyComparison,
    Map<String, dynamic>? efficiencyTrends,
    Map<String, dynamic>? costAnalysis,
    Map<String, dynamic>? usagePatterns,
    bool? isLoading,
    String? errorMessage,
    String? selectedVehicleId,
  }) {
    return ReportsState(
      currentMonthReport: currentMonthReport ?? this.currentMonthReport,
      currentYearReport: currentYearReport ?? this.currentYearReport,
      customReport: customReport ?? this.customReport,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      yearlyComparison: yearlyComparison ?? this.yearlyComparison,
      efficiencyTrends: efficiencyTrends ?? this.efficiencyTrends,
      costAnalysis: costAnalysis ?? this.costAnalysis,
      usagePatterns: usagePatterns ?? this.usagePatterns,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
    );
  }
}
