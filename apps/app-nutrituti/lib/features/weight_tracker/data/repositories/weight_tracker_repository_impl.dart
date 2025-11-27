import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/weight_achievement_entity.dart';
import '../../domain/entities/weight_goal_entity.dart';
import '../../domain/entities/weight_milestone_entity.dart';
import '../../domain/entities/weight_record_entity.dart';
import '../../domain/entities/weight_reminder_entity.dart';
import '../../domain/entities/weight_statistics_entity.dart';
import '../../domain/repositories/i_weight_tracker_repository.dart';
import '../datasources/weight_tracker_local_datasource.dart';

/// Repository implementation for Weight Tracker 2.0
class WeightTrackerRepositoryImpl implements IWeightTrackerRepository {
  final WeightTrackerLocalDatasource _localDatasource;
  final Logger _logger;

  WeightTrackerRepositoryImpl(this._localDatasource, this._logger);

  // ==================== RECORDS ====================

  @override
  Future<Either<Failure, WeightRecordEntity>> addWeightRecord({
    required double weightKg,
    String? note,
    WeightTimeOfDay timeOfDay = WeightTimeOfDay.morning,
  }) async {
    try {
      // Validate weight range
      if (weightKg < 30 || weightKg > 300) {
        return const Left(ValidationFailure('Peso deve estar entre 30 e 300 kg'));
      }

      final record = await _localDatasource.addRecord(
        weightKg: weightKg,
        note: note,
        timeOfDay: timeOfDay,
      );

      // Check achievements
      await checkAndUnlockAchievements();

      _logger.d('Weight record added: ${record.weightKg}kg');
      return Right(record);
    } catch (e) {
      _logger.e('Error adding weight record: $e');
      return Left(CacheFailure('Erro ao adicionar registro: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> getAllRecords() async {
    try {
      final records = await _localDatasource.getAllRecords();
      return Right(records);
    } catch (e) {
      _logger.e('Error getting all records: $e');
      return Left(CacheFailure('Erro ao buscar registros: $e'));
    }
  }

  @override
  Future<Either<Failure, WeightRecordEntity?>> getLatestRecord() async {
    try {
      final record = await _localDatasource.getLatestRecord();
      return Right(record);
    } catch (e) {
      _logger.e('Error getting latest record: $e');
      return Left(CacheFailure('Erro ao buscar último registro: $e'));
    }
  }

  @override
  Stream<Either<Failure, WeightRecordEntity?>> watchLatestRecord() {
    return _localDatasource.watchLatestRecord().map((record) => Right(record));
  }

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> getRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final records = await _localDatasource.getRecordsByDateRange(
        startDate,
        endDate,
      );
      return Right(records);
    } catch (e) {
      _logger.e('Error getting records by range: $e');
      return Left(CacheFailure('Erro ao buscar registros: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WeightRecordEntity>>> getLast30DaysRecords() async {
    try {
      final records = await _localDatasource.getLast30DaysRecords();
      return Right(records);
    } catch (e) {
      _logger.e('Error getting last 30 days records: $e');
      return Left(CacheFailure('Erro ao buscar registros: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WeightRecordEntity>>> watchLast30DaysRecords() {
    return _localDatasource.watchLast30DaysRecords().map((records) => Right(records));
  }

  @override
  Future<Either<Failure, WeightRecordEntity>> updateRecord(
    WeightRecordEntity record,
  ) async {
    try {
      if (record.weightKg < 30 || record.weightKg > 300) {
        return const Left(ValidationFailure('Peso deve estar entre 30 e 300 kg'));
      }

      final updated = await _localDatasource.updateRecord(record);
      return Right(updated);
    } catch (e) {
      _logger.e('Error updating record: $e');
      return Left(CacheFailure('Erro ao atualizar registro: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecord(String id) async {
    try {
      await _localDatasource.deleteRecord(id);
      return const Right(unit);
    } catch (e) {
      _logger.e('Error deleting record: $e');
      return Left(CacheFailure('Erro ao deletar registro: $e'));
    }
  }

  // ==================== GOALS ====================

  @override
  Future<Either<Failure, WeightGoalEntity>> getCurrentGoal() async {
    try {
      final goal = await _localDatasource.getCurrentGoal();
      return Right(goal);
    } catch (e) {
      _logger.e('Error getting goal: $e');
      return Left(CacheFailure('Erro ao buscar meta: $e'));
    }
  }

  @override
  Stream<Either<Failure, WeightGoalEntity>> watchCurrentGoal() {
    return _localDatasource.watchCurrentGoal().map((goal) => Right(goal));
  }

  @override
  Future<Either<Failure, WeightGoalEntity>> upsertGoal(
    WeightGoalEntity goal,
  ) async {
    try {
      final result = await _localDatasource.upsertGoal(goal);

      // Generate milestones when goal is set
      await _localDatasource.generateMilestonesFromGoal(
        goal.initialWeight,
        goal.targetWeight,
      );

      return Right(result);
    } catch (e) {
      _logger.e('Error updating goal: $e');
      return Left(CacheFailure('Erro ao atualizar meta: $e'));
    }
  }

  // ==================== MILESTONES ====================

  @override
  Future<Either<Failure, List<WeightMilestoneEntity>>> getMilestones() async {
    try {
      final milestones = await _localDatasource.getAllMilestones();
      return Right(milestones);
    } catch (e) {
      _logger.e('Error getting milestones: $e');
      return Left(CacheFailure('Erro ao buscar marcos: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WeightMilestoneEntity>>> watchMilestones() {
    return _localDatasource
        .watchAllMilestones()
        .map((milestones) => Right(milestones));
  }

  @override
  Future<Either<Failure, Unit>> generateMilestones() async {
    try {
      final goal = await _localDatasource.getCurrentGoal();
      await _localDatasource.generateMilestonesFromGoal(
        goal.initialWeight,
        goal.targetWeight,
      );
      return const Right(unit);
    } catch (e) {
      _logger.e('Error generating milestones: $e');
      return Left(CacheFailure('Erro ao gerar marcos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WeightMilestoneEntity>>> checkMilestoneAchievements(
    double currentWeight,
  ) async {
    try {
      final goal = await _localDatasource.getCurrentGoal();
      final milestones = await _localDatasource.getAllMilestones();

      for (final milestone in milestones) {
        if (milestone.isAchieved) continue;

        bool achieved = false;
        if (goal.isLosingWeight) {
          achieved = currentWeight <= milestone.targetWeight;
        } else {
          achieved = currentWeight >= milestone.targetWeight;
        }

        if (achieved) {
          await _localDatasource.achieveMilestone(milestone.id);
        }
      }

      final updated = await _localDatasource.getAllMilestones();
      return Right(updated);
    } catch (e) {
      _logger.e('Error checking milestones: $e');
      return Left(CacheFailure('Erro ao verificar marcos: $e'));
    }
  }

  // ==================== ACHIEVEMENTS ====================

  @override
  Future<Either<Failure, List<WeightAchievementEntity>>> getAchievements() async {
    try {
      final achievements = await _localDatasource.getAllAchievements();
      return Right(achievements);
    } catch (e) {
      _logger.e('Error getting achievements: $e');
      return Left(CacheFailure('Erro ao buscar conquistas: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WeightAchievementEntity>>> watchAchievements() {
    return _localDatasource
        .watchAllAchievements()
        .map((achievements) => Right(achievements));
  }

  @override
  Future<Either<Failure, List<WeightAchievementEntity>>> checkAndUnlockAchievements() async {
    try {
      // Fetch current data
      final totalRecords = await _localDatasource.getTotalRecordsCount();
      final consecutiveDays = await _localDatasource.getConsecutiveDays();
      final morningCount = await _localDatasource.getMorningWeighCount();
      final goal = await _localDatasource.getCurrentGoal();
      final latestRecord = await _localDatasource.getLatestRecord();
      final firstRecord = await _localDatasource.getFirstRecord();

      // First weigh achievement
      if (totalRecords >= 1) {
        await _localDatasource.unlockAchievement(
          WeightAchievementType.firstWeigh.value,
        );
        await _localDatasource.updateAchievementProgress(
          WeightAchievementType.firstWeigh.value,
          1,
        );
      }

      // Consistent (7 days)
      await _localDatasource.updateAchievementProgress(
        WeightAchievementType.consistent7.value,
        consecutiveDays,
      );
      if (consecutiveDays >= 7) {
        await _localDatasource.unlockAchievement(
          WeightAchievementType.consistent7.value,
        );
      }

      // Month complete (30 records)
      await _localDatasource.updateAchievementProgress(
        WeightAchievementType.monthComplete.value,
        totalRecords,
      );
      if (totalRecords >= 30) {
        await _localDatasource.unlockAchievement(
          WeightAchievementType.monthComplete.value,
        );
      }

      // Morning weigh (7 mornings)
      await _localDatasource.updateAchievementProgress(
        WeightAchievementType.earlyRiser.value,
        morningCount,
      );
      if (morningCount >= 7) {
        await _localDatasource.unlockAchievement(
          WeightAchievementType.earlyRiser.value,
        );
      }

      // Weight loss achievements
      if (latestRecord != null && firstRecord != null) {
        final weightLost = firstRecord.weightKg - latestRecord.weightKg;

        // Lost 2kg
        await _localDatasource.updateAchievementProgress(
          WeightAchievementType.lost2kg.value,
          (weightLost * 10).round(), // Progress in 0.1kg increments
        );
        if (weightLost >= 2) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.lost2kg.value,
          );
        }

        // Lost 5kg
        await _localDatasource.updateAchievementProgress(
          WeightAchievementType.lost5kg.value,
          (weightLost * 10).round(),
        );
        if (weightLost >= 5) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.lost5kg.value,
          );
        }

        // Lost 10kg
        await _localDatasource.updateAchievementProgress(
          WeightAchievementType.lost10kg.value,
          (weightLost * 10).round(),
        );
        if (weightLost >= 10) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.lost10kg.value,
          );
        }

        // Healthy BMI
        final currentBmi = goal.calculateBmi(latestRecord.weightKg);
        if (currentBmi >= 18.5 && currentBmi <= 24.9) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.healthyBmi.value,
          );
          await _localDatasource.updateAchievementProgress(
            WeightAchievementType.healthyBmi.value,
            1,
          );
        }

        // Goal reached
        final isGoalReached = goal.isLosingWeight
            ? latestRecord.weightKg <= goal.targetWeight
            : latestRecord.weightKg >= goal.targetWeight;
        if (isGoalReached) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.goalReached.value,
          );
          await _localDatasource.updateAchievementProgress(
            WeightAchievementType.goalReached.value,
            1,
          );
        }

        // Halfway
        final progress = goal.calculateProgress(latestRecord.weightKg);
        await _localDatasource.updateAchievementProgress(
          WeightAchievementType.halfway.value,
          progress.round(),
        );
        if (progress >= 50) {
          await _localDatasource.unlockAchievement(
            WeightAchievementType.halfway.value,
          );
        }
      }

      final updatedAchievements = await _localDatasource.getAllAchievements();
      return Right(updatedAchievements);
    } catch (e) {
      _logger.e('Error checking achievements: $e');
      return Left(CacheFailure('Erro ao verificar conquistas: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> initializeAchievements() async {
    try {
      await _localDatasource.initializeAchievements();
      return const Right(unit);
    } catch (e) {
      _logger.e('Error initializing achievements: $e');
      return Left(CacheFailure('Erro ao inicializar conquistas: $e'));
    }
  }

  // ==================== REMINDERS ====================

  @override
  Future<Either<Failure, WeightReminderEntity>> getReminderSettings() async {
    try {
      final settings = await _localDatasource.getReminderSettings();
      return Right(settings);
    } catch (e) {
      _logger.e('Error getting reminder settings: $e');
      return Left(CacheFailure('Erro ao buscar lembretes: $e'));
    }
  }

  @override
  Stream<Either<Failure, WeightReminderEntity>> watchReminderSettings() {
    return _localDatasource
        .watchReminderSettings()
        .map((settings) => Right(settings));
  }

  @override
  Future<Either<Failure, WeightReminderEntity>> updateReminderSettings(
    WeightReminderEntity settings,
  ) async {
    try {
      await _localDatasource.upsertReminderSettings(settings);
      return Right(settings);
    } catch (e) {
      _logger.e('Error updating reminder settings: $e');
      return Left(CacheFailure('Erro ao atualizar lembretes: $e'));
    }
  }

  // ==================== STATISTICS ====================

  @override
  Future<Either<Failure, WeightStatisticsEntity>> getStatistics() async {
    try {
      final totalRecords = await _localDatasource.getTotalRecordsCount();
      final consecutiveDays = await _localDatasource.getConsecutiveDays();
      final minWeight = await _localDatasource.getMinWeight();
      final maxWeight = await _localDatasource.getMaxWeight();
      final weeklyAvg = await _localDatasource.getAverageWeight(7);
      final monthlyAvg = await _localDatasource.getAverageWeight(30);
      final weeklyData = await _localDatasource.getWeeklyData();
      final monthlyData = await _localDatasource.getMonthlyData();
      final goal = await _localDatasource.getCurrentGoal();
      final latestRecord = await _localDatasource.getLatestRecord();
      final firstRecord = await _localDatasource.getFirstRecord();

      double? weeklyChange;
      double? totalChange;
      double? currentBmi;
      BmiCategory? bmiCategory;
      double? progressPercentage;
      WeightTrend trend = WeightTrend.stable;
      int? estimatedDays;

      if (latestRecord != null) {
        currentBmi = goal.calculateBmi(latestRecord.weightKg);
        bmiCategory = goal.getBmiCategory(latestRecord.weightKg);
        progressPercentage = goal.calculateProgress(latestRecord.weightKg);

        if (firstRecord != null) {
          totalChange = latestRecord.weightKg - firstRecord.weightKg;
        }

        // Calculate weekly change
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final weekAgoRecords = await _localDatasource.getRecordsByDateRange(
          weekAgo.subtract(const Duration(days: 1)),
          weekAgo.add(const Duration(days: 1)),
        );
        if (weekAgoRecords.isNotEmpty) {
          weeklyChange = latestRecord.weightKg - weekAgoRecords.first.weightKg;

          // Determine trend
          if (weeklyChange.abs() < 0.3) {
            trend = WeightTrend.stable;
          } else if (weeklyChange < 0) {
            trend = WeightTrend.losing;
          } else {
            trend = WeightTrend.gaining;
          }

          // Calculate estimated days to goal
          if (weeklyChange != 0) {
            final avgDailyChange = weeklyChange / 7;
            estimatedDays = goal.calculateEstimatedDays(
              latestRecord.weightKg,
              avgDailyChange,
            );
          }
        }
      }

      return Right(WeightStatisticsEntity(
        currentWeight: latestRecord?.weightKg,
        initialWeight: firstRecord?.weightKg,
        targetWeight: goal.targetWeight,
        minWeight: minWeight,
        maxWeight: maxWeight,
        weeklyAverage: weeklyAvg,
        monthlyAverage: monthlyAvg,
        weeklyChange: weeklyChange,
        totalChange: totalChange,
        totalRecordsCount: totalRecords,
        daysTracked: monthlyData.length,
        consecutiveDays: consecutiveDays,
        currentBmi: currentBmi,
        bmiCategory: bmiCategory,
        trend: trend,
        estimatedDaysToGoal: estimatedDays,
        progressPercentage: progressPercentage,
        weeklyData: weeklyData,
        monthlyData: monthlyData,
      ));
    } catch (e) {
      _logger.e('Error getting statistics: $e');
      return Left(CacheFailure('Erro ao buscar estatísticas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getWeeklyChartData() async {
    try {
      final data = await _localDatasource.getWeeklyData();
      return Right(data);
    } catch (e) {
      _logger.e('Error getting weekly chart data: $e');
      return Left(CacheFailure('Erro ao buscar dados do gráfico: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapEntry<DateTime, double>>>> getMonthlyChartData() async {
    try {
      final data = await _localDatasource.getMonthlyData();
      return Right(data);
    } catch (e) {
      _logger.e('Error getting monthly chart data: $e');
      return Left(CacheFailure('Erro ao buscar dados do gráfico: $e'));
    }
  }
}
