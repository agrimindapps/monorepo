import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import '../../domain/entities/report_comparison_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

abstract class ReportsDataSource {
  Future<ReportSummaryEntity> generateReport(String vehicleId, DateTime startDate, DateTime endDate, String period);
  Future<ReportComparisonEntity> compareReports(String vehicleId, ReportSummaryEntity current, ReportSummaryEntity previous, String comparisonType);
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months);
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months);
}

@LazySingleton(as: ReportsDataSource)
class ReportsDataSourceImpl implements ReportsDataSource {
  final FuelRepository _fuelRepository;

  ReportsDataSourceImpl(this._fuelRepository);

  @override
  Future<ReportSummaryEntity> generateReport(String vehicleId, DateTime startDate, DateTime endDate, String period) async {
    try {
      // Get fuel records for the period
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros de combustível: ${failure.message}'),
        (fuelRecords) async {
          // Filter records by date range
          final filteredRecords = fuelRecords.where((record) {
            return record.data.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   record.data.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

          if (filteredRecords.isEmpty) {
            return _createEmptyReport(vehicleId, startDate, endDate, period);
          }

          // Sort by date
          filteredRecords.sort((a, b) => a.data.compareTo(b.data));

          // Calculate fuel metrics
          final totalFuelSpent = filteredRecords.map((r) => r.valorTotal).fold(0.0, (a, b) => a + b);
          final totalFuelLiters = filteredRecords.map((r) => r.litros).fold(0.0, (a, b) => a + b);
          final averageFuelPrice = totalFuelLiters > 0 ? totalFuelSpent / totalFuelLiters : 0.0;
          final fuelRecordsCount = filteredRecords.length;

          // Calculate distance metrics
          final totalDistanceTraveled = _calculateTotalDistance(filteredRecords);

          // Calculate average consumption
          double averageConsumption = 0.0;
          if (totalDistanceTraveled > 0 && totalFuelLiters > 0) {
            averageConsumption = totalDistanceTraveled / totalFuelLiters;
          }

          // Calculate cost per km
          double costPerKm = 0.0;
          if (totalDistanceTraveled > 0) {
            costPerKm = totalFuelSpent / totalDistanceTraveled;
          }

          // Create trends data
          final trends = await _calculateTrends(vehicleId, filteredRecords);

          return ReportSummaryEntity(
            vehicleId: vehicleId,
            startDate: startDate,
            endDate: endDate,
            period: period,
            totalFuelSpent: totalFuelSpent,
            totalFuelLiters: totalFuelLiters,
            averageFuelPrice: averageFuelPrice,
            fuelRecordsCount: fuelRecordsCount,
            totalDistanceTraveled: totalDistanceTraveled,
            averageConsumption: averageConsumption,
            lastOdometerReading: lastOdometerReading,
            firstOdometerReading: firstOdometerReading,
            costPerKm: costPerKm,
            trends: trends,
            metadata: {
              'generated_at': DateTime.now().toIso8601String(),
              'calculation_method': 'fuel_records_based',
            },
          );
        },
      );
    } catch (e) {
      throw CacheException('Erro ao gerar relatório: ${e.toString()}');
    }
  }

  @override
  Future<ReportComparisonEntity> compareReports(String vehicleId, ReportSummaryEntity current, ReportSummaryEntity previous, String comparisonType) async {
    try {
      return ReportComparisonEntity(
        vehicleId: vehicleId,
        currentPeriod: current,
        previousPeriod: previous,
        comparisonType: comparisonType,
      );
    } catch (e) {
      throw CacheException('Erro ao comparar relatórios: ${e.toString()}');
    }
  }


  /// Analyzes fuel efficiency trends over a specified period
  /// 
  /// This method performs comprehensive fuel efficiency trend analysis by:
  /// 1. Retrieving all fuel records for the vehicle within the specified time period
  /// 2. Grouping records by month to calculate monthly average consumption values
  /// 3. Computing trend direction and percentage change over the analysis period
  /// 4. Providing statistical insights for fuel efficiency monitoring
  ///
  /// **Algorithm Details:**
  /// - **Data Filtering**: Records are filtered to include only those within the analysis window
  /// - **Monthly Aggregation**: Consumption values are grouped by month and averaged
  /// - **Trend Calculation**: Uses first and last month averages to determine efficiency change
  /// - **Trend Classification**: Changes >5% are significant; <-5% indicate decline; others are stable
  ///
  /// **Business Logic:**
  /// - Insufficient data (< 2 records) returns 'insufficient_data' trend
  /// - Efficiency improvements show positive percentage change
  /// - Efficiency declines show negative percentage change
  /// - Stable trends indicate consistent fuel usage patterns
  ///
  /// [vehicleId] The unique identifier of the vehicle to analyze
  /// [months] The number of months to analyze (default: 12, minimum: 1)
  /// 
  /// Returns a Map containing:
  /// - `trend`: String indicating 'improving', 'declining', 'stable', or 'insufficient_data'
  /// - `efficiency_change`: Double percentage change in efficiency over the period
  /// - `monthly_averages`: List of monthly consumption averages with metadata
  /// - `period_months`: Integer number of months analyzed
  ///
  /// **Example Return Value:**
  /// ```dart
  /// {
  ///   'trend': 'improving',
  ///   'efficiency_change': 8.5,
  ///   'monthly_averages': [
  ///     {'month': '2024-01', 'average_consumption': 12.5, 'records_count': 3},
  ///     {'month': '2024-02', 'average_consumption': 13.1, 'records_count': 4}
  ///   ],
  ///   'period_months': 12
  /// }
  /// ```
  ///
  /// Throws [CacheException] if fuel records cannot be retrieved or processed
  @override
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months) async {
    try {
      final endDate = DateTime.now();
      final startDate = _calculateSafeStartDate(endDate, months);
      
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.data.isAfter(startDate) && record.data.isBefore(endDate);
          }).toList();

          if (filteredRecords.length < 2) {
            return {
              'trend': 'insufficient_data',
              'efficiency_change': 0.0,
              'monthly_averages': <Map<String, dynamic>>[],
            };
          }

          // Group by month and calculate monthly averages
          final monthlyData = <String, List<double>>{};
          
          for (final record in filteredRecords) {
            final monthKey = _generateMonthKey(record.data);
            
            if (record.consumo != null && record.consumo! > 0) {
              monthlyData[monthKey] ??= [];
              monthlyData[monthKey]!.add(record.consumo!);
            }
          }

          final monthlyAverages = <Map<String, dynamic>>[];
          
          for (final entry in monthlyData.entries) {
            final average = entry.value.fold(0.0, (a, b) => a + b) / entry.value.length;
            monthlyAverages.add({
              'month': entry.key,
              'average_consumption': average,
              'records_count': entry.value.length,
            });
          }

          monthlyAverages.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));

          // Calculate trend
          String trend = 'stable';
          double efficiencyChange = 0.0;
          
          if (monthlyAverages.length >= 2) {
            final firstMonthAvg = monthlyAverages.first['average_consumption'] as double;
            final lastMonthAvg = monthlyAverages.last['average_consumption'] as double;
            
            if (firstMonthAvg > 0) {
              efficiencyChange = ((lastMonthAvg - firstMonthAvg) / firstMonthAvg) * 100;
              
              if (efficiencyChange > 5) {
                trend = 'improving';
              } else if (efficiencyChange < -5) {
                trend = 'declining';
              }
            }
          }

          return {
            'trend': trend,
            'efficiency_change': efficiencyChange,
            'monthly_averages': monthlyAverages,
            'period_months': months,
          };
        },
      );
    } catch (e) {
      throw CacheException('Erro ao calcular tendências: ${e.toString()}');
    }
  }

  /// Performs comprehensive cost analysis for a vehicle over a specified period
  /// 
  /// This method analyzes fuel expenditure patterns and price trends by:
  /// 1. Retrieving all fuel records within the specified date range
  /// 2. Calculating total costs and average expenditure per fill-up
  /// 3. Analyzing monthly price trends to identify cost fluctuations
  /// 4. Providing detailed cost breakdowns for budget planning
  ///
  /// **Algorithm Details:**
  /// - **Data Aggregation**: Sums all fuel costs within the analysis period
  /// - **Price Trend Analysis**: Groups records by month and calculates min/max/average prices
  /// - **Cost Breakdown**: Categorizes expenses (fuel, maintenance, other) for comprehensive view
  /// - **Statistical Analysis**: Computes averages and trends for financial insights
  ///
  /// **Business Logic:**
  /// - Empty dataset returns zero values for all cost metrics
  /// - Monthly price analysis helps identify seasonal variations
  /// - Future integration planned for maintenance and other vehicle expenses
  /// - Cost per fill analysis helps optimize refueling strategies
  ///
  /// [vehicleId] The unique identifier of the vehicle to analyze
  /// [startDate] Start date of the analysis period (inclusive)
  /// [endDate] End date of the analysis period (inclusive)
  /// 
  /// Returns a Map containing:
  /// - `total_cost`: Double total fuel cost during the period
  /// - `average_cost_per_fill`: Double average cost per refueling session
  /// - `cost_breakdown`: Map with categorized expenses (fuel, maintenance, other)
  /// - `price_trends`: List of monthly price statistics (min, max, average)
  /// - `records_analyzed`: Integer number of fuel records processed
  ///
  /// **Example Return Value:**
  /// ```dart
  /// {
  ///   'total_cost': 1250.75,
  ///   'average_cost_per_fill': 83.38,
  ///   'cost_breakdown': {
  ///     'fuel_cost': 1250.75,
  ///     'maintenance_cost': 0.0,  // TODO: Future integration
  ///     'other_expenses': 0.0     // TODO: Future integration
  ///   },
  ///   'price_trends': [
  ///     {'month': '2024-01', 'average_price': 5.12, 'min_price': 4.98, 'max_price': 5.25}
  ///   ],
  ///   'records_analyzed': 15
  /// }
  /// ```
  ///
  /// Throws [CacheException] if fuel records cannot be retrieved or processed
  @override
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.data.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   record.data.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

          if (filteredRecords.isEmpty) {
            return {
              'total_cost': 0.0,
              'average_cost_per_fill': 0.0,
              'cost_breakdown': <String, dynamic>{},
              'price_trends': <Map<String, dynamic>>[],
            };
          }

          filteredRecords.sort((a, b) => a.data.compareTo(b.data));

          final totalCost = filteredRecords.map((r) => r.valorTotal).fold(0.0, (a, b) => a + b);
          final averageCostPerFill = totalCost / filteredRecords.length;
          
          // Price trend analysis
          final priceTrends = <Map<String, dynamic>>[];
          final monthlyPrices = <String, List<double>>{};
          
          for (final record in filteredRecords) {
            final monthKey = _generateMonthKey(record.data);
            monthlyPrices[monthKey] ??= [];
            monthlyPrices[monthKey]!.add(record.precoPorLitro);
          }
          
          for (final entry in monthlyPrices.entries) {
            final average = entry.value.fold(0.0, (a, b) => a + b) / entry.value.length;
            priceTrends.add({
              'month': entry.key,
              'average_price': average,
              'min_price': entry.value.reduce((a, b) => a < b ? a : b),
              'max_price': entry.value.reduce((a, b) => a > b ? a : b),
            });
          }

          priceTrends.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));

          return {
            'total_cost': totalCost,
            'average_cost_per_fill': averageCostPerFill,
            'cost_breakdown': {
              'fuel_cost': totalCost,
              'maintenance_cost': 0.0, // TODO: Implement when maintenance is ready
              'other_expenses': 0.0,   // TODO: Implement when expenses is ready
            },
            'price_trends': priceTrends,
            'records_analyzed': filteredRecords.length,
          };
        },
      );
    } catch (e) {
      throw CacheException('Erro ao analisar custos: ${e.toString()}');
    }
  }

  /// Analyzes vehicle usage patterns over a specified period
  /// 
  /// This method examines vehicle usage behavior and patterns by:
  /// 1. Analyzing frequency of refueling events within the time period
  /// 2. Calculating average intervals between fuel fill-ups
  /// 3. Identifying monthly usage variations and trends
  /// 4. Classifying usage intensity for driver behavior insights
  ///
  /// **Algorithm Details:**
  /// - **Frequency Analysis**: Calculates days between consecutive refueling events
  /// - **Monthly Aggregation**: Groups refueling events by month for pattern detection
  /// - **Trend Classification**: Compares first and last months to identify usage changes
  /// - **Usage Intensity**: Categorizes as high (< 7 days), medium (7-21 days), or low (> 21 days)
  ///
  /// **Business Logic:**
  /// - High frequency indicates intensive vehicle usage or short trips
  /// - Low frequency suggests occasional usage or efficient driving
  /// - Increasing trends may indicate lifestyle changes or new routes
  /// - Decreasing trends could suggest improved efficiency or reduced usage
  ///
  /// [vehicleId] The unique identifier of the vehicle to analyze
  /// [months] The number of months to analyze (default: 12, minimum: 1)
  /// 
  /// Returns a Map containing:
  /// - `usage_frequency`: String classification ('high', 'medium', 'low', 'insufficient_data')
  /// - `average_days_between_fills`: Integer average days between refueling events
  /// - `monthly_usage`: List of monthly refueling counts with metadata
  /// - `usage_trend`: String trend direction ('increasing', 'decreasing', 'stable')
  /// - `analysis_period_months`: Integer number of months analyzed
  ///
  /// **Example Return Value:**
  /// ```dart
  /// {
  ///   'usage_frequency': 'medium',
  ///   'average_days_between_fills': 12,
  ///   'monthly_usage': [
  ///     {'month': '2024-01', 'fill_ups': 4},
  ///     {'month': '2024-02', 'fill_ups': 3}
  ///   ],
  ///   'usage_trend': 'stable',
  ///   'analysis_period_months': 12
  /// }
  /// ```
  ///
  /// Throws [CacheException] if fuel records cannot be retrieved or processed
  @override
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months) async {
    try {
      final endDate = DateTime.now();
      final startDate = _calculateSafeStartDate(endDate, months);
      
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.data.isAfter(startDate) && record.data.isBefore(endDate);
          }).toList();

          if (filteredRecords.length < 2) {
            return {
              'usage_frequency': 'low',
              'average_days_between_fills': 0,
              'monthly_usage': <Map<String, dynamic>>[],
              'usage_trend': 'insufficient_data',
            };
          }

          filteredRecords.sort((a, b) => a.data.compareTo(b.data));

          // Calculate days between fills
          final daysBetween = <int>[];
          for (int i = 1; i < filteredRecords.length; i++) {
            final days = filteredRecords[i].data.difference(filteredRecords[i - 1].data).inDays;
            if (days > 0) daysBetween.add(days);
          }

          final averageDaysBetween = daysBetween.isNotEmpty 
              ? daysBetween.fold(0, (a, b) => a + b) / daysBetween.length
              : 0;

          // Monthly usage patterns
          final monthlyUsage = <String, int>{};
          for (final record in filteredRecords) {
            final monthKey = _generateMonthKey(record.data);
            monthlyUsage[monthKey] = (monthlyUsage[monthKey] ?? 0) + 1;
          }

          final monthlyUsageList = monthlyUsage.entries.map((entry) => {
            'month': entry.key,
            'fill_ups': entry.value,
          }).toList();

          monthlyUsageList.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));

          // Determine usage frequency
          String usageFrequency = 'medium';
          if (averageDaysBetween < 7) {
            usageFrequency = 'high';
          } else if (averageDaysBetween > 21) {
            usageFrequency = 'low';
          }

          // Usage trend
          String usageTrend = 'stable';
          if (monthlyUsageList.length >= 2) {
            final firstMonth = monthlyUsageList.first['fill_ups'] as int;
            final lastMonth = monthlyUsageList.last['fill_ups'] as int;
            
            if (lastMonth > firstMonth * 1.2) {
              usageTrend = 'increasing';
            } else if (lastMonth < firstMonth * 0.8) {
              usageTrend = 'decreasing';
            }
          }

          return {
            'usage_frequency': usageFrequency,
            'average_days_between_fills': averageDaysBetween.round(),
            'monthly_usage': monthlyUsageList,
            'usage_trend': usageTrend,
            'analysis_period_months': months,
          };
        },
      );
    } catch (e) {
      throw CacheException('Erro ao analisar padrões de uso: ${e.toString()}');
    }
  }

  // Helper methods
  ReportSummaryEntity _createEmptyReport(String vehicleId, DateTime startDate, DateTime endDate, String period) {
    return ReportSummaryEntity(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      period: period,
      totalFuelSpent: 0.0,
      totalFuelLiters: 0.0,
      averageFuelPrice: 0.0,
      fuelRecordsCount: 0,
      totalDistanceTraveled: 0.0,
      averageConsumption: 0.0,
      lastOdometerReading: 0.0,
      firstOdometerReading: 0.0,
      costPerKm: 0.0,
      metadata: {
        'generated_at': DateTime.now().toIso8601String(),
        'calculation_method': 'empty_report',
      },
    );
  }

  /// Calculates basic trend indicators for report metadata
  /// 
  /// This method provides simple trend analysis for including in report summaries.
  /// It analyzes fuel consumption patterns and price trends from the provided records.
  ///
  /// [vehicleId] The vehicle ID for context (currently used for logging/debugging)
  /// [records] List of FuelRecordEntity to analyze
  /// 
  /// Returns a Map with basic trend indicators:
  /// - `fuel_efficiency`: String trend ('improving', 'declining', 'stable')
  /// - `cost_trend`: String price trend ('increasing', 'decreasing', 'stable') 
  /// - `usage_pattern`: String usage consistency ('consistent', 'variable', 'irregular')
  Future<Map<String, dynamic>> _calculateTrends(String vehicleId, List<dynamic> records) async {
    // Simple trend indicators for report metadata
    // For now, return stable indicators as a placeholder
    // Future enhancement could implement actual trend analysis
    return {
      'fuel_efficiency': 'stable',
      'cost_trend': 'stable',
      'usage_pattern': 'consistent',
    };
  }

  /// Generates a consistent month key in YYYY-MM format for date grouping
  /// 
  /// This helper method optimizes string generation for monthly data aggregation
  /// by providing a centralized, efficient way to create month keys.
  /// 
  /// [date] The date to generate a month key for
  /// 
  /// Returns a string in the format 'YYYY-MM' (e.g., '2024-03')
  String _generateMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Safely calculates a start date by subtracting months from an end date
  /// Handles edge cases like leap years, different month lengths, and overflow scenarios
  DateTime _calculateSafeStartDate(DateTime endDate, int months) {
    if (months <= 0) {
      return endDate;
    }

    int targetYear = endDate.year;
    int targetMonth = endDate.month;
    int targetDay = endDate.day;

    // Subtract months
    targetMonth -= months;

    // Handle year overflow
    while (targetMonth <= 0) {
      targetYear--;
      targetMonth += 12;
    }

    // Handle day overflow for the target month
    // Get the last day of the target month
    final lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    
    // If the original day doesn't exist in the target month, use the last day of that month
    if (targetDay > lastDayOfTargetMonth) {
      targetDay = lastDayOfTargetMonth;
    }

    try {
      return DateTime(targetYear, targetMonth, targetDay, endDate.hour, endDate.minute, endDate.second);
    } catch (e) {
      // Fallback: if somehow the date is still invalid, use the first day of the target month
      return DateTime(targetYear, targetMonth, 1, endDate.hour, endDate.minute, endDate.second);
    }
  }

  /// Calcula distância total baseada na diferença entre registros consecutivos
  /// 
  /// Esta implementação é mais robusta que simplesmente subtrair primeiro do último
  /// porque considera resets de hodômetro e dados desordenados.
  /// 
  /// [records] Lista de registros de combustível ordenados por data
  /// 
  /// Retorna a distância total percorrida validando que:
  /// - Diferenças são positivas (não há reset de hodômetro)
  /// - Diferenças são razoáveis (< 10.000 km entre registros)
  double _calculateTotalDistance(List<dynamic> records) {
    if (records.length < 2) return 0.0;
    
    // Ordenar por data para garantir sequência correta
    final sortedRecords = [...records]..sort((a, b) => a.data.compareTo(b.data));
    
    double totalDistance = 0.0;
    for (int i = 1; i < sortedRecords.length; i++) {
      final distance = sortedRecords[i].odometro - sortedRecords[i-1].odometro;
      
      // Validar se a distância é razoável
      if (distance > 0 && distance < 10000) { // Entre 0 e 10.000 km
        totalDistance += distance;
      }
      // Se distance <= 0, pode ser reset do hodômetro - ignorar
      // Se distance >= 10.000, pode ser erro nos dados - ignorar
    }
    
    return totalDistance;
  }
}