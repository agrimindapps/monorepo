import 'package:dartz/dartz.dart';

import '../entities/rain_gauge_entity.dart';
import '../failures/weather_failures.dart';
import '../repositories/weather_repository.dart';

/// Use case for retrieving rain gauge information and measurements
/// Provides various filtering and monitoring capabilities
class GetRainGauges {
  final WeatherRepository _repository;

  const GetRainGauges(this._repository);

  /// Get all rain gauges
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> call() async {
    try {
      return await _repository.getAllRainGauges();
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauge by ID
  Future<Either<WeatherFailure, RainGaugeEntity>> byId(String id) async {
    try {
      if (id.trim().isEmpty) {
        return const Left(RainGaugeFailure('Rain gauge ID cannot be empty'));
      }

      return await _repository.getRainGaugeById(id);
    } catch (e) {
      return Left(RainGaugeNotFoundFailure(id));
    }
  }

  /// Get rain gauges by location
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> byLocation(String locationId) async {
    try {
      if (locationId.trim().isEmpty) {
        return const Left(RainGaugeFailure('Location ID cannot be empty'));
      }

      return await _repository.getRainGaugesByLocation(locationId);
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get all active rain gauges
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> active() async {
    try {
      return await _repository.getActiveRainGauges();
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get operational rain gauges (active and working properly)
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> operational() async {
    try {
      final result = await _repository.getActiveRainGauges();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final operational = gauges.where((gauge) => gauge.isOperational).toList();
          return Right(operational);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges requiring maintenance
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> needingMaintenance() async {
    try {
      return await _repository.getRainGaugesNeedingMaintenance();
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges by status
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> byStatus(String status) async {
    try {
      if (status.trim().isEmpty) {
        return const Left(RainGaugeFailure('Status cannot be empty'));
      }

      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final filtered = gauges.where((gauge) => 
            gauge.status.toLowerCase() == status.toLowerCase()
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges with low battery
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> withLowBattery() async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final lowBattery = gauges.where((gauge) => gauge.isLowBattery).toList();
          return Right(lowBattery);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges with weak signal
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> withWeakSignal() async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final weakSignal = gauges.where((gauge) => gauge.isWeakSignal).toList();
          return Right(weakSignal);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges by maintenance priority
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> byMaintenancePriority(String priority) async {
    try {
      if (priority.trim().isEmpty) {
        return const Left(RainGaugeFailure('Priority cannot be empty'));
      }

      final validPriorities = ['critical', 'high', 'medium', 'low', 'none'];
      if (!validPriorities.contains(priority.toLowerCase())) {
        return Left(RainGaugeFailure('Invalid priority. Must be one of: ${validPriorities.join(', ')}'));
      }

      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final filtered = gauges.where((gauge) => 
            gauge.maintenancePriority.toLowerCase() == priority.toLowerCase()
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges with high rainfall accumulation
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> withHighRainfall({
    double dailyThreshold = 50.0,
    double weeklyThreshold = 150.0,
    double monthlyThreshold = 500.0,
  }) async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final highRainfall = gauges.where((gauge) => 
            gauge.dailyAccumulation >= dailyThreshold ||
            gauge.weeklyAccumulation >= weeklyThreshold ||
            gauge.monthlyAccumulation >= monthlyThreshold
          ).toList();
          return Right(highRainfall);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get recently installed rain gauges
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> recentlyInstalled(int days) async {
    try {
      if (days <= 0) {
        return const Left(RainGaugeFailure('Days must be a positive number'));
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final recent = gauges.where((gauge) => 
            gauge.installationDate.isAfter(cutoffDate)
          ).toList();
          return Right(recent);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges by device model
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> byDeviceModel(String model) async {
    try {
      if (model.trim().isEmpty) {
        return const Left(RainGaugeFailure('Device model cannot be empty'));
      }

      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final filtered = gauges.where((gauge) => 
            gauge.deviceModel.toLowerCase().contains(model.toLowerCase())
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges with valid readings
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> withValidReadings() async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final valid = gauges.where((gauge) => gauge.hasValidReadings).toList();
          return Right(valid);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges with data quality issues
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> withDataQualityIssues({
    double qualityThreshold = 0.8,
  }) async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final issues = gauges.where((gauge) => 
            gauge.dataQuality < qualityThreshold
          ).toList();
          return Right(issues);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges by rainfall intensity
  Future<Either<WeatherFailure, List<RainGaugeEntity>>> byRainfallIntensity(String intensity) async {
    try {
      if (intensity.trim().isEmpty) {
        return const Left(RainGaugeFailure('Intensity cannot be empty'));
      }

      final validIntensities = ['no_rain', 'light', 'moderate', 'heavy', 'very_heavy'];
      if (!validIntensities.contains(intensity.toLowerCase())) {
        return Left(RainGaugeFailure('Invalid intensity. Must be one of: ${validIntensities.join(', ')}'));
      }

      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final filtered = gauges.where((gauge) => 
            gauge.rainfallIntensity.toLowerCase() == intensity.toLowerCase()
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges summary statistics
  Future<Either<WeatherFailure, Map<String, dynamic>>> getSummaryStatistics() async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final summary = _calculateSummaryStatistics(gauges);
          return Right(summary);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Get rain gauges health report
  Future<Either<WeatherFailure, Map<String, dynamic>>> getHealthReport() async {
    try {
      final result = await call();
      
      return result.fold(
        (failure) => Left(failure),
        (gauges) {
          final report = _generateHealthReport(gauges);
          return Right(report);
        },
      );
    } catch (e) {
      return Left(RainGaugeFetchFailure(e.toString()));
    }
  }

  /// Calculate summary statistics for rain gauges
  Map<String, dynamic> _calculateSummaryStatistics(List<RainGaugeEntity> gauges) {
    if (gauges.isEmpty) {
      return {
        'total_gauges': 0,
        'active_gauges': 0,
        'operational_gauges': 0,
        'total_daily_rainfall': 0.0,
        'total_monthly_rainfall': 0.0,
        'avg_data_quality': 0.0,
        'maintenance_needed': 0,
      };
    }

    final active = gauges.where((g) => (g.isActive as bool?) == true).length;
    final operational = gauges.where((g) => (g.isOperational as bool?) == true).length;
    final totalDaily = gauges.map((g) => g.dailyAccumulation).reduce((a, b) => a + b);
    final totalMonthly = gauges.map((g) => g.monthlyAccumulation).reduce((a, b) => a + b);
    final avgQuality = gauges.map((g) => g.dataQuality).reduce((a, b) => a + b) / gauges.length;
    final maintenanceNeeded = gauges.where((g) => g.needsMaintenance).length;

    return {
      'total_gauges': gauges.length,
      'active_gauges': active,
      'operational_gauges': operational,
      'total_daily_rainfall': double.parse(totalDaily.toStringAsFixed(2)),
      'total_monthly_rainfall': double.parse(totalMonthly.toStringAsFixed(2)),
      'avg_data_quality': double.parse(avgQuality.toStringAsFixed(3)),
      'maintenance_needed': maintenanceNeeded,
      'operational_percentage': double.parse(((operational / gauges.length) * 100).toStringAsFixed(1)),
    };
  }

  /// Generate health report for rain gauges
  Map<String, dynamic> _generateHealthReport(List<RainGaugeEntity> gauges) {
    final summary = _calculateSummaryStatistics(gauges);
    
    final statusCounts = <String, int>{};
    final priorityCounts = <String, int>{};
    final deviceModelCounts = <String, int>{};

    for (final gauge in gauges) {
      statusCounts[gauge.status] = (statusCounts[gauge.status] ?? 0) + 1;
      priorityCounts[gauge.maintenancePriority] = (priorityCounts[gauge.maintenancePriority] ?? 0) + 1;
      deviceModelCounts[gauge.deviceModel] = (deviceModelCounts[gauge.deviceModel] ?? 0) + 1;
    }

    final issues = <String>[];
    
    if (((summary['operational_percentage'] as num?) ?? 0) < 80) {
      issues.add('Low operational percentage: ${summary['operational_percentage']}%');
    }
    
    if (((summary['maintenance_needed'] as num?) ?? 0) > 0) {
      issues.add('${summary['maintenance_needed']} gauges need maintenance');
    }

    final lowBattery = gauges.where((g) => (g.isLowBattery as bool?) == true).length;
    if (lowBattery > 0) {
      issues.add('$lowBattery gauges have low battery');
    }

    final weakSignal = gauges.where((g) => (g.isWeakSignal as bool?) == true).length;
    if (weakSignal > 0) {
      issues.add('$weakSignal gauges have weak signal');
    }

    return {
      'summary': summary,
      'status_distribution': statusCounts,
      'maintenance_priority_distribution': priorityCounts,
      'device_model_distribution': deviceModelCounts,
      'health_issues': issues,
      'overall_health': _calculateOverallHealth(gauges),
      'recommendations': _generateRecommendations(gauges, issues),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Calculate overall health score (0-100)
  int _calculateOverallHealth(List<RainGaugeEntity> gauges) {
    if (gauges.isEmpty) return 0;

    int score = 100;
    
    final operationalPercentage = gauges.where((g) => (g.isOperational as bool?) == true).length / gauges.length;
    if (operationalPercentage < 0.9) score -= 20;
    if (operationalPercentage < 0.7) score -= 20;
    
    final maintenanceNeeded = gauges.where((g) => (g.needsMaintenance as bool?) == true).length / gauges.length;
    if (maintenanceNeeded > 0.1) score -= 15;
    if (maintenanceNeeded > 0.2) score -= 15;
    
    final lowBatteryPercentage = gauges.where((g) => (g.isLowBattery as bool?) == true).length / gauges.length;
    if (lowBatteryPercentage > 0.1) score -= 10;
    
    final avgQuality = gauges.map((g) => g.dataQuality).reduce((a, b) => a + b) / gauges.length;
    if (avgQuality < 0.8) score -= 10;
    if (avgQuality < 0.6) score -= 10;

    return score.clamp(0, 100);
  }

  /// Generate recommendations based on gauge status
  List<String> _generateRecommendations(List<RainGaugeEntity> gauges, List<String> issues) {
    final recommendations = <String>[];

    if (issues.any((issue) => issue.contains('operational percentage'))) {
      recommendations.add('Schedule immediate maintenance for non-operational gauges');
    }

    if (issues.any((issue) => issue.contains('low battery'))) {
      recommendations.add('Replace batteries in affected gauges');
    }

    if (issues.any((issue) => issue.contains('weak signal'))) {
      recommendations.add('Check communication equipment and positioning');
    }

    final criticalMaintenance = gauges.where((g) => g.maintenancePriority == 'critical').length;
    if (criticalMaintenance > 0) {
      recommendations.add('Address $criticalMaintenance critical maintenance issues immediately');
    }

    final oldGauges = gauges.where((g) => g.daysSinceLastMaintenance > 365).length;
    if (oldGauges > 0) {
      recommendations.add('Schedule annual maintenance for $oldGauges gauges overdue');
    }

    return recommendations;
  }
}
