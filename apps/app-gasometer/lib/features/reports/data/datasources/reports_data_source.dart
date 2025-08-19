import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../fuel/domain/repositories/fuel_repository.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/entities/report_comparison_entity.dart';

abstract class ReportsDataSource {
  Future<ReportSummaryEntity> generateReport(String vehicleId, DateTime startDate, DateTime endDate, String period);
  Future<ReportComparisonEntity> compareReports(String vehicleId, ReportSummaryEntity current, ReportSummaryEntity previous, String comparisonType);
  Future<List<ReportSummaryEntity>> generateFleetReport(List<String> vehicleIds, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months);
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months);
}

@LazySingleton(as: ReportsDataSource)
class ReportsDataSourceImpl implements ReportsDataSource {
  final FuelRepository _fuelRepository;

  ReportsDataSourceImpl(this._fuelRepository, VehicleRepository vehicleRepository);

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
            return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   record.date.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

          if (filteredRecords.isEmpty) {
            return _createEmptyReport(vehicleId, startDate, endDate, period);
          }

          // Sort by date
          filteredRecords.sort((a, b) => a.date.compareTo(b.date));

          // Calculate fuel metrics
          final totalFuelSpent = filteredRecords.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
          final totalFuelLiters = filteredRecords.map((r) => r.liters).fold(0.0, (a, b) => a + b);
          final averageFuelPrice = totalFuelLiters > 0 ? totalFuelSpent / totalFuelLiters : 0.0;
          final fuelRecordsCount = filteredRecords.length;

          // Calculate distance metrics
          final odometerReadings = filteredRecords.map((r) => r.odometer).toList();
          odometerReadings.sort();
          
          final firstOdometerReading = odometerReadings.isNotEmpty ? odometerReadings.first : 0.0;
          final lastOdometerReading = odometerReadings.isNotEmpty ? odometerReadings.last : 0.0;
          final totalDistanceTraveled = lastOdometerReading - firstOdometerReading;

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

  @override
  Future<List<ReportSummaryEntity>> generateFleetReport(List<String> vehicleIds, DateTime startDate, DateTime endDate) async {
    try {
      final List<ReportSummaryEntity> reports = [];
      
      for (final vehicleId in vehicleIds) {
        final report = await generateReport(vehicleId, startDate, endDate, 'fleet');
        reports.add(report);
      }
      
      return reports;
    } catch (e) {
      throw CacheException('Erro ao gerar relatório da frota: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getFuelEfficiencyTrends(String vehicleId, int months) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - months, endDate.day);
      
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.date.isAfter(startDate) && record.date.isBefore(endDate);
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
            final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
            
            if (record.consumption != null && record.consumption! > 0) {
              monthlyData[monthKey] ??= [];
              monthlyData[monthKey]!.add(record.consumption!);
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

          monthlyAverages.sort((a, b) => a['month'].compareTo(b['month']));

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

  @override
  Future<Map<String, dynamic>> getCostAnalysis(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   record.date.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

          if (filteredRecords.isEmpty) {
            return {
              'total_cost': 0.0,
              'average_cost_per_fill': 0.0,
              'cost_breakdown': <String, dynamic>{},
              'price_trends': <Map<String, dynamic>>[],
            };
          }

          filteredRecords.sort((a, b) => a.date.compareTo(b.date));

          final totalCost = filteredRecords.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
          final averageCostPerFill = totalCost / filteredRecords.length;
          
          // Price trend analysis
          final priceTrends = <Map<String, dynamic>>[];
          final monthlyPrices = <String, List<double>>{};
          
          for (final record in filteredRecords) {
            final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
            monthlyPrices[monthKey] ??= [];
            monthlyPrices[monthKey]!.add(record.pricePerLiter);
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

          priceTrends.sort((a, b) => a['month'].compareTo(b['month']));

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

  @override
  Future<Map<String, dynamic>> getUsagePatterns(String vehicleId, int months) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - months, endDate.day);
      
      final fuelRecordsResult = await _fuelRepository.getFuelRecordsByVehicle(vehicleId);
      
      return await fuelRecordsResult.fold(
        (failure) => throw CacheException('Erro ao buscar registros: ${failure.message}'),
        (fuelRecords) async {
          final filteredRecords = fuelRecords.where((record) {
            return record.date.isAfter(startDate) && record.date.isBefore(endDate);
          }).toList();

          if (filteredRecords.length < 2) {
            return {
              'usage_frequency': 'low',
              'average_days_between_fills': 0,
              'monthly_usage': <Map<String, dynamic>>[],
              'usage_trend': 'insufficient_data',
            };
          }

          filteredRecords.sort((a, b) => a.date.compareTo(b.date));

          // Calculate days between fills
          final daysBetween = <int>[];
          for (int i = 1; i < filteredRecords.length; i++) {
            final days = filteredRecords[i].date.difference(filteredRecords[i - 1].date).inDays;
            if (days > 0) daysBetween.add(days);
          }

          final averageDaysBetween = daysBetween.isNotEmpty 
              ? daysBetween.fold(0, (a, b) => a + b) / daysBetween.length
              : 0;

          // Monthly usage patterns
          final monthlyUsage = <String, int>{};
          for (final record in filteredRecords) {
            final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
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

  Future<Map<String, dynamic>> _calculateTrends(String vehicleId, List<dynamic> records) async {
    // Basic trends calculation - can be expanded
    return {
      'fuel_efficiency': 'stable',
      'cost_trend': 'stable',
      'usage_pattern': 'consistent',
    };
  }
}