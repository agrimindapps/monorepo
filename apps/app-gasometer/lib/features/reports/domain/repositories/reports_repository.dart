import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/report_comparison_entity.dart';
import '../entities/report_summary_entity.dart';

abstract class ReportsRepository {
  // Generate reports
  Future<Either<Failure, ReportSummaryEntity>> generateMonthlyReport(String vehicleId, DateTime month);
  Future<Either<Failure, ReportSummaryEntity>> generateYearlyReport(String vehicleId, int year);
  Future<Either<Failure, ReportSummaryEntity>> generateCustomReport(String vehicleId, DateTime startDate, DateTime endDate);
  
  // Compare reports
  Future<Either<Failure, ReportComparisonEntity>> compareMonthlyReports(String vehicleId, DateTime currentMonth, DateTime previousMonth);
  Future<Either<Failure, ReportComparisonEntity>> compareYearlyReports(String vehicleId, int currentYear, int previousYear);
  
  // Analytics insights
  Future<Either<Failure, Map<String, dynamic>>> getFuelEfficiencyTrends(String vehicleId, int months);
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate);
  Future<Either<Failure, Map<String, dynamic>>> getUsagePatterns(String vehicleId, int months);
  
  // Export reports
  Future<Either<Failure, String>> exportReportToCSV(ReportSummaryEntity report);
  Future<Either<Failure, String>> exportReportToPDF(ReportSummaryEntity report);
}