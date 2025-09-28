import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/compare_reports.dart';
import '../../domain/usecases/export_report.dart';
import '../../domain/usecases/generate_custom_report.dart';
import '../../domain/usecases/generate_monthly_report.dart';
import '../../domain/usecases/generate_yearly_report.dart';
import '../../domain/usecases/get_reports_analytics.dart';

@injectable
class ReportsProvider extends ChangeNotifier {

  ReportsProvider({
    required GenerateMonthlyReport generateMonthlyReport,
    required GenerateYearlyReport generateYearlyReport,
    required GenerateCustomReport generateCustomReport,
    required CompareMonthlyReports compareMonthlyReports,
    required CompareYearlyReports compareYearlyReports,
    required GetFuelEfficiencyTrends getFuelEfficiencyTrends,
    required GetCostAnalysis getCostAnalysis,
    required GetUsagePatterns getUsagePatterns,
    required ExportReportToCSV exportReportToCSV,
  })  : _generateMonthlyReport = generateMonthlyReport,
        _generateYearlyReport = generateYearlyReport,
        _generateCustomReport = generateCustomReport,
        _compareMonthlyReports = compareMonthlyReports,
        _compareYearlyReports = compareYearlyReports,
        _getFuelEfficiencyTrends = getFuelEfficiencyTrends,
        _getCostAnalysis = getCostAnalysis,
        _getUsagePatterns = getUsagePatterns,
        _exportReportToCSV = exportReportToCSV;
  final GenerateMonthlyReport _generateMonthlyReport;
  final GenerateYearlyReport _generateYearlyReport;
  final GenerateCustomReport _generateCustomReport;
  final CompareMonthlyReports _compareMonthlyReports;
  final CompareYearlyReports _compareYearlyReports;
  final GetFuelEfficiencyTrends _getFuelEfficiencyTrends;
  final GetCostAnalysis _getCostAnalysis;
  final GetUsagePatterns _getUsagePatterns;
  final ExportReportToCSV _exportReportToCSV;

  // Current data
  ReportSummaryEntity? _currentMonthReport;
  ReportSummaryEntity? _currentYearReport;
  ReportSummaryEntity? _customReport;
  ReportComparisonEntity? _monthlyComparison;
  ReportComparisonEntity? _yearlyComparison;
  
  // Analytics data
  Map<String, dynamic>? _efficiencyTrends;
  Map<String, dynamic>? _costAnalysis;
  Map<String, dynamic>? _usagePatterns;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedVehicleId = '';

  // Getters
  ReportSummaryEntity? get currentMonthReport => _currentMonthReport;
  ReportSummaryEntity? get currentYearReport => _currentYearReport;
  ReportSummaryEntity? get customReport => _customReport;
  ReportComparisonEntity? get monthlyComparison => _monthlyComparison;
  ReportComparisonEntity? get yearlyComparison => _yearlyComparison;
  
  Map<String, dynamic>? get efficiencyTrends => _efficiencyTrends;
  Map<String, dynamic>? get costAnalysis => _costAnalysis;
  Map<String, dynamic>? get usagePatterns => _usagePatterns;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedVehicleId => _selectedVehicleId;
  
  bool get hasError => _errorMessage != null;
  bool get hasCurrentMonthData => _currentMonthReport?.hasData == true;
  bool get hasCurrentYearData => _currentYearReport?.hasData == true;
  bool get hasCustomData => _customReport?.hasData == true;
  bool get hasAnalytics => _efficiencyTrends != null || _costAnalysis != null || _usagePatterns != null;

  // Set selected vehicle
  void setSelectedVehicle(String vehicleId) {
    if (_selectedVehicleId != vehicleId) {
      _selectedVehicleId = vehicleId;
      _clearAllData();
      notifyListeners();
    }
  }

  // Generate current month report
  Future<void> generateCurrentMonthReport({String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final currentMonth = DateTime.now();
    final result = await _generateMonthlyReport(
      GenerateMonthlyReportParams(vehicleId: id, month: currentMonth),
    );

    result.fold(
      (failure) => _handleError(failure),
      (report) {
        _currentMonthReport = report;
        if (kDebugMode) {
          debugPrint('[REPORTS] Monthly report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Generate current year report
  Future<void> generateCurrentYearReport({String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final currentYear = DateTime.now().year;
    final result = await _generateYearlyReport(
      GenerateYearlyReportParams(vehicleId: id, year: currentYear),
    );

    result.fold(
      (failure) => _handleError(failure),
      (report) {
        _currentYearReport = report;
        if (kDebugMode) {
          debugPrint('[REPORTS] Yearly report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Generate custom report
  Future<void> generateCustomReport(DateTime startDate, DateTime endDate, {String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final result = await _generateCustomReport(
      GenerateCustomReportParams(
        vehicleId: id,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) => _handleError(failure),
      (report) {
        _customReport = report;
        if (kDebugMode) {
          debugPrint('[REPORTS] Custom report generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Compare current month with previous
  Future<void> compareCurrentMonthWithPrevious({String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    final result = await _compareMonthlyReports(
      CompareMonthlyReportsParams(
        vehicleId: id,
        currentMonth: currentMonth,
        previousMonth: previousMonth,
      ),
    );

    result.fold(
      (failure) => _handleError(failure),
      (comparison) {
        _monthlyComparison = comparison;
        if (kDebugMode) {
          debugPrint('[REPORTS] Monthly comparison generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Compare current year with previous
  Future<void> compareCurrentYearWithPrevious({String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final currentYear = DateTime.now().year;
    final previousYear = currentYear - 1;

    final result = await _compareYearlyReports(
      CompareYearlyReportsParams(
        vehicleId: id,
        currentYear: currentYear,
        previousYear: previousYear,
      ),
    );

    result.fold(
      (failure) => _handleError(failure),
      (comparison) {
        _yearlyComparison = comparison;
        if (kDebugMode) {
          debugPrint('[REPORTS] Yearly comparison generated for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Load efficiency trends
  Future<void> loadEfficiencyTrends({int months = 12, String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final result = await _getFuelEfficiencyTrends(
      GetFuelEfficiencyTrendsParams(vehicleId: id, months: months),
    );

    result.fold(
      (failure) => _handleError(failure),
      (trends) {
        _efficiencyTrends = trends;
        if (kDebugMode) {
          debugPrint('[REPORTS] Efficiency trends loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Load cost analysis
  Future<void> loadCostAnalysis({DateTime? startDate, DateTime? endDate, String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final end = endDate ?? DateTime.now();
    final start = startDate ?? DateTime(end.year, 1, 1); // Default to year start

    final result = await _getCostAnalysis(
      GetCostAnalysisParams(
        vehicleId: id,
        startDate: start,
        endDate: end,
      ),
    );

    result.fold(
      (failure) => _handleError(failure),
      (analysis) {
        _costAnalysis = analysis;
        if (kDebugMode) {
          debugPrint('[REPORTS] Cost analysis loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Load usage patterns
  Future<void> loadUsagePatterns({int months = 12, String? vehicleId}) async {
    final id = vehicleId ?? _selectedVehicleId;
    if (id.isEmpty) return;

    _setLoading(true);
    _clearError();

    final result = await _getUsagePatterns(
      GetUsagePatternsParams(vehicleId: id, months: months),
    );

    result.fold(
      (failure) => _handleError(failure),
      (patterns) {
        _usagePatterns = patterns;
        if (kDebugMode) {
          debugPrint('[REPORTS] Usage patterns loaded for vehicle ${id.substring(0, 8)}...');
        }
      },
    );

    _setLoading(false);
  }

  // Load all reports for vehicle
  Future<void> loadAllReportsForVehicle(String vehicleId) async {
    setSelectedVehicle(vehicleId);

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

  // Export current month report
  Future<String?> exportCurrentMonthToCSV() async {
    if (_currentMonthReport == null) return null;

    _setLoading(true);
    _clearError();

    final result = await _exportReportToCSV(
      ExportReportToCSVParams(report: _currentMonthReport!),
    );

    String? csvContent;
    result.fold(
      (failure) => _handleError(failure),
      (content) {
        csvContent = content;
        debugPrint('[REPORTS] Report exported to CSV');
      },
    );

    _setLoading(false);
    return csvContent;
  }

  // Utility methods
  void clearError() {
    _clearError();
  }

  void clearAllData() {
    _clearAllData();
  }

  // Get formatted data for UI
  Map<String, String> getCurrentMonthStats() {
    if (_currentMonthReport == null || !_currentMonthReport!.hasData) {
      return {
        'fuel_spent': 'R\$ 0,00',
        'fuel_liters': '0,0L',
        'distance': '0 km',
        'consumption': '0,0 km/L',
      };
    }

    return {
      'fuel_spent': _currentMonthReport!.formattedTotalFuelSpent,
      'fuel_liters': _currentMonthReport!.formattedTotalFuelLiters,
      'distance': _currentMonthReport!.formattedTotalDistance,
      'consumption': _currentMonthReport!.formattedAverageConsumption,
    };
  }

  Map<String, String> getCurrentYearStats() {
    if (_currentYearReport == null || !_currentYearReport!.hasData) {
      return {
        'fuel_spent': 'R\$ 0,00',
        'fuel_liters': '0,0L',
        'distance': '0 km',
        'consumption': '0,0 km/L',
      };
    }

    return {
      'fuel_spent': _currentYearReport!.formattedTotalFuelSpent,
      'fuel_liters': _currentYearReport!.formattedTotalFuelLiters,
      'distance': _currentYearReport!.formattedTotalDistance,
      'consumption': _currentYearReport!.formattedAverageConsumption,
    };
  }

  Map<String, String> getMonthlyComparisons() {
    if (_monthlyComparison == null) {
      return {
        'fuel_spent': 'R\$ 0,00',
        'fuel_liters': '0,0L',
        'distance': '0 km',
        'fuel_spent_growth': '0%',
        'distance_growth': '0%',
      };
    }

    return {
      'fuel_spent': _monthlyComparison!.previousPeriod.formattedTotalFuelSpent,
      'fuel_liters': _monthlyComparison!.previousPeriod.formattedTotalFuelLiters,
      'distance': _monthlyComparison!.previousPeriod.formattedTotalDistance,
      'fuel_spent_growth': _monthlyComparison!.formattedFuelSpentGrowth,
      'distance_growth': _monthlyComparison!.formattedDistanceGrowth,
    };
  }

  Map<String, String> getYearlyComparisons() {
    if (_yearlyComparison == null) {
      return {
        'fuel_spent': 'R\$ 0,00',
        'fuel_liters': '0,0L',
        'distance': '0 km',
        'fuel_spent_growth': '0%',
        'distance_growth': '0%',
      };
    }

    return {
      'fuel_spent': _yearlyComparison!.previousPeriod.formattedTotalFuelSpent,
      'fuel_liters': _yearlyComparison!.previousPeriod.formattedTotalFuelLiters,
      'distance': _yearlyComparison!.previousPeriod.formattedTotalDistance,
      'fuel_spent_growth': _yearlyComparison!.formattedFuelSpentGrowth,
      'distance_growth': _yearlyComparison!.formattedDistanceGrowth,
    };
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _handleError(Failure failure) {
    _errorMessage = _mapFailureToMessage(failure);
    debugPrint('[REPORTS] Error in ReportsProvider: $_errorMessage');
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    // General failures
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is CacheFailure) {
      return 'Erro no armazenamento local. Tente reiniciar o app.';
    } else if (failure is UnexpectedFailure) {
      return 'Erro inesperado: ${failure.message}';
    }
    // Authentication failures
    else if (failure is AuthenticationFailure) {
      return 'Erro de autenticação. Faça login novamente.';
    } else if (failure is AuthorizationFailure) {
      return 'Acesso negado. Verifique suas permissões.';
    }
    // Vehicle specific failures
    else if (failure is VehicleNotFoundFailure) {
      return 'Veículo não encontrado.';
    } else if (failure is DuplicateVehicleFailure) {
      return 'Veículo duplicado encontrado.';
    }
    // Fuel specific failures
    else if (failure is InvalidFuelDataFailure) {
      return 'Dados de combustível inválidos.';
    }
    // Maintenance specific failures
    else if (failure is MaintenanceNotFoundFailure) {
      return 'Manutenção não encontrada.';
    }
    // Sync failures
    else if (failure is SyncFailure) {
      return 'Erro de sincronização. Tente novamente.';
    } else if (failure is OfflineFailure) {
      return 'Sem conexão. Algumas funcionalidades podem não estar disponíveis.';
    }
    // Default case
    else {
      return 'Erro inesperado: ${failure.message}';
    }
  }

  void _clearAllData() {
    _currentMonthReport = null;
    _currentYearReport = null;
    _customReport = null;
    _monthlyComparison = null;
    _yearlyComparison = null;
    _efficiencyTrends = null;
    _costAnalysis = null;
    _usagePatterns = null;
    _clearError();
    notifyListeners();
  }
}