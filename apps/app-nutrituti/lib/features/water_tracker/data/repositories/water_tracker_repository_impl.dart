import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/water_achievement_entity.dart';
import '../../domain/entities/water_custom_cup_entity.dart';
import '../../domain/entities/water_daily_progress_entity.dart';
import '../../domain/entities/water_goal_entity.dart';
import '../../domain/entities/water_record_entity.dart';
import '../../domain/entities/water_reminder_entity.dart';
import '../../domain/entities/water_statistics_entity.dart';
import '../../domain/entities/water_streak_entity.dart';
import '../../domain/repositories/i_water_tracker_repository.dart';
import '../datasources/water_tracker_local_datasource.dart';

/// Repository implementation for Water Tracker 2.0
class WaterTrackerRepositoryImpl implements IWaterTrackerRepository {
  final WaterTrackerLocalDatasource _localDatasource;
  final Logger _logger;

  WaterTrackerRepositoryImpl(this._localDatasource, this._logger);

  // ==================== RECORDS ====================

  @override
  Future<Either<Failure, WaterRecordEntity>> addWaterRecord({
    required int amountMl,
    String? note,
    String? cupType,
  }) async {
    try {
      final record = await _localDatasource.addRecord(
        amountMl: amountMl,
        note: note,
        cupType: cupType,
      );
      
      // Update daily progress
      await _updateTodayProgress();
      
      // Check achievements
      await checkAndUnlockAchievements();
      
      _logger.d('Water record added: ${record.amountMl}ml');
      return Right(record);
    } catch (e) {
      _logger.e('Error adding water record: $e');
      return Left(CacheFailure('Erro ao adicionar registro: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterRecordEntity>>> getTodayRecords() async {
    try {
      final records = await _localDatasource.getTodayRecords();
      return Right(records);
    } catch (e) {
      _logger.e('Error getting today records: $e');
      return Left(CacheFailure('Erro ao buscar registros: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WaterRecordEntity>>> watchTodayRecords() {
    return _localDatasource.watchTodayRecords().map(
      (records) => Right(records),
    );
  }

  @override
  Future<Either<Failure, List<WaterRecordEntity>>> getRecordsByDateRange({
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
  Future<Either<Failure, Unit>> deleteRecord(String id) async {
    try {
      await _localDatasource.deleteRecord(id);
      await _updateTodayProgress();
      return const Right(unit);
    } catch (e) {
      _logger.e('Error deleting record: $e');
      return Left(CacheFailure('Erro ao deletar registro: $e'));
    }
  }

  // ==================== GOALS ====================

  @override
  Future<Either<Failure, WaterGoalEntity>> getCurrentGoal() async {
    try {
      final goal = await _localDatasource.getCurrentGoal();
      return Right(goal);
    } catch (e) {
      _logger.e('Error getting goal: $e');
      return Left(CacheFailure('Erro ao buscar meta: $e'));
    }
  }

  @override
  Stream<Either<Failure, WaterGoalEntity>> watchCurrentGoal() {
    return _localDatasource.watchCurrentGoal().map((goal) => Right(goal));
  }

  @override
  Future<Either<Failure, WaterGoalEntity>> updateDailyGoal(int goalMl) async {
    try {
      final currentGoal = await _localDatasource.getCurrentGoal();
      final updatedGoal = currentGoal.copyWith(
        dailyGoalMl: goalMl,
        useCalculatedGoal: false,
        updatedAt: DateTime.now(),
      );
      final result = await _localDatasource.upsertGoal(updatedGoal);
      return Right(result);
    } catch (e) {
      _logger.e('Error updating goal: $e');
      return Left(CacheFailure('Erro ao atualizar meta: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterGoalEntity>> updateGoalByWeight(
    double weightKg,
  ) async {
    try {
      final calculatedGoal = WaterGoalEntity.calculateFromWeight(weightKg);
      final currentGoal = await _localDatasource.getCurrentGoal();
      final updatedGoal = currentGoal.copyWith(
        weightKg: weightKg,
        calculatedGoalMl: calculatedGoal,
        useCalculatedGoal: true,
        updatedAt: DateTime.now(),
      );
      final result = await _localDatasource.upsertGoal(updatedGoal);
      return Right(result);
    } catch (e) {
      _logger.e('Error updating goal by weight: $e');
      return Left(CacheFailure('Erro ao calcular meta: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterGoalEntity>> setActivityAdjustment(
    int adjustmentMl,
  ) async {
    try {
      final currentGoal = await _localDatasource.getCurrentGoal();
      final updatedGoal = currentGoal.copyWith(
        activityAdjustmentMl: adjustmentMl,
        updatedAt: DateTime.now(),
      );
      final result = await _localDatasource.upsertGoal(updatedGoal);
      return Right(result);
    } catch (e) {
      _logger.e('Error setting activity adjustment: $e');
      return Left(CacheFailure('Erro ao ajustar meta: $e'));
    }
  }

  // ==================== STREAKS ====================

  @override
  Future<Either<Failure, WaterStreakEntity>> getCurrentStreak() async {
    try {
      final streak = await _localDatasource.getCurrentStreak();
      return Right(streak);
    } catch (e) {
      _logger.e('Error getting streak: $e');
      return Left(CacheFailure('Erro ao buscar sequência: $e'));
    }
  }

  @override
  Stream<Either<Failure, WaterStreakEntity>> watchCurrentStreak() {
    return _localDatasource.watchCurrentStreak().map((streak) => Right(streak));
  }

  @override
  Future<Either<Failure, WaterStreakEntity>> updateStreakOnGoalAchieved() async {
    try {
      await _localDatasource.incrementStreak();
      final streak = await _localDatasource.getCurrentStreak();
      _logger.d('Streak updated: ${streak.currentStreak} days');
      return Right(streak);
    } catch (e) {
      _logger.e('Error updating streak: $e');
      return Left(CacheFailure('Erro ao atualizar sequência: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterStreakEntity>> checkAndUpdateStreakStatus() async {
    try {
      final streak = await _localDatasource.getCurrentStreak();
      
      if (streak.isBroken && streak.currentStreak > 0) {
        await _localDatasource.resetStreak();
        final updated = await _localDatasource.getCurrentStreak();
        _logger.d('Streak reset due to broken streak');
        return Right(updated);
      }
      
      return Right(streak);
    } catch (e) {
      _logger.e('Error checking streak status: $e');
      return Left(CacheFailure('Erro ao verificar sequência: $e'));
    }
  }

  // ==================== CUSTOM CUPS ====================

  @override
  Future<Either<Failure, List<WaterCustomCupEntity>>> getCustomCups() async {
    try {
      final cups = await _localDatasource.getAllCustomCups();
      return Right(cups);
    } catch (e) {
      _logger.e('Error getting custom cups: $e');
      return Left(CacheFailure('Erro ao buscar copos: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WaterCustomCupEntity>>> watchCustomCups() {
    return _localDatasource.watchAllCustomCups().map((cups) => Right(cups));
  }

  @override
  Future<Either<Failure, WaterCustomCupEntity>> addCustomCup({
    required String name,
    required int amountMl,
    String? iconName,
  }) async {
    try {
      final cup = await _localDatasource.addCustomCup(
        name: name,
        amountMl: amountMl,
        iconName: iconName,
      );
      return Right(cup);
    } catch (e) {
      _logger.e('Error adding custom cup: $e');
      return Left(CacheFailure('Erro ao adicionar copo: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterCustomCupEntity>> updateCustomCup(
    WaterCustomCupEntity cup,
  ) async {
    try {
      await _localDatasource.updateCustomCup(cup);
      return Right(cup);
    } catch (e) {
      _logger.e('Error updating custom cup: $e');
      return Left(CacheFailure('Erro ao atualizar copo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomCup(String id) async {
    try {
      await _localDatasource.deleteCustomCup(id);
      return const Right(unit);
    } catch (e) {
      _logger.e('Error deleting custom cup: $e');
      return Left(CacheFailure('Erro ao deletar copo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> initializeDefaultCups() async {
    try {
      await _localDatasource.initializeDefaultCups();
      return const Right(unit);
    } catch (e) {
      _logger.e('Error initializing default cups: $e');
      return Left(CacheFailure('Erro ao inicializar copos: $e'));
    }
  }

  // ==================== REMINDERS ====================

  @override
  Future<Either<Failure, WaterReminderEntity>> getReminderSettings() async {
    try {
      final settings = await _localDatasource.getReminderSettings();
      return Right(settings);
    } catch (e) {
      _logger.e('Error getting reminder settings: $e');
      return Left(CacheFailure('Erro ao buscar lembretes: $e'));
    }
  }

  @override
  Stream<Either<Failure, WaterReminderEntity>> watchReminderSettings() {
    return _localDatasource
        .watchReminderSettings()
        .map((settings) => Right(settings));
  }

  @override
  Future<Either<Failure, WaterReminderEntity>> updateReminderSettings(
    WaterReminderEntity settings,
  ) async {
    try {
      await _localDatasource.upsertReminderSettings(settings);
      return Right(settings);
    } catch (e) {
      _logger.e('Error updating reminder settings: $e');
      return Left(CacheFailure('Erro ao atualizar lembretes: $e'));
    }
  }

  // ==================== ACHIEVEMENTS ====================

  @override
  Future<Either<Failure, List<WaterAchievementEntity>>> getAchievements() async {
    try {
      final achievements = await _localDatasource.getAllAchievements();
      return Right(achievements);
    } catch (e) {
      _logger.e('Error getting achievements: $e');
      return Left(CacheFailure('Erro ao buscar conquistas: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<WaterAchievementEntity>>> watchAchievements() {
    return _localDatasource
        .watchAllAchievements()
        .map((achievements) => Right(achievements));
  }

  @override
  Future<Either<Failure, List<WaterAchievementEntity>>> checkAndUnlockAchievements() async {
    try {
      // Fetch current data
      final totalRecords = await _localDatasource.getTotalRecordsCount();
      final daysTracked = await _localDatasource.getDaysWithRecords();
      final streak = await _localDatasource.getCurrentStreak();
      final todayTotal = await _localDatasource.getTodayTotal();
      final goal = await _localDatasource.getCurrentGoal();

      // Check first drop achievement
      if (totalRecords >= 1) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.firstDrop.value,
        );
        await _localDatasource.updateAchievementProgress(
          WaterAchievementType.firstDrop.value,
          1,
        );
      }

      // Check consistent achievement (50 records)
      await _localDatasource.updateAchievementProgress(
        WaterAchievementType.consistent.value,
        totalRecords,
      );
      if (totalRecords >= 50) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.consistent.value,
        );
      }

      // Check master achievement (100 days)
      await _localDatasource.updateAchievementProgress(
        WaterAchievementType.master.value,
        daysTracked,
      );
      if (daysTracked >= 100) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.master.value,
        );
      }

      // Check perfect week (7 day streak)
      await _localDatasource.updateAchievementProgress(
        WaterAchievementType.perfectWeek.value,
        streak.currentStreak,
      );
      if (streak.currentStreak >= 7) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.perfectWeek.value,
        );
      }

      // Check hydrated month (30 day streak)
      await _localDatasource.updateAchievementProgress(
        WaterAchievementType.hydratedMonth.value,
        streak.currentStreak,
      );
      if (streak.currentStreak >= 30) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.hydratedMonth.value,
        );
      }

      // Check super hydrated (150% of goal)
      final superHydratedTarget = (goal.effectiveGoalMl * 1.5).round();
      final superHydratedProgress =
          ((todayTotal / superHydratedTarget) * 150).round().clamp(0, 150);
      await _localDatasource.updateAchievementProgress(
        WaterAchievementType.superHydrated.value,
        superHydratedProgress,
      );
      if (todayTotal >= superHydratedTarget) {
        await _localDatasource.unlockAchievement(
          WaterAchievementType.superHydrated.value,
        );
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

  // ==================== DAILY PROGRESS ====================

  @override
  Future<Either<Failure, WaterDailyProgressEntity>> getTodayProgress() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var progress = await _localDatasource.getDailyProgress(today);
      
      if (progress == null) {
        final goal = await _localDatasource.getCurrentGoal();
        progress = WaterDailyProgressEntity.empty(today, goal.effectiveGoalMl);
      }
      
      return Right(progress);
    } catch (e) {
      _logger.e('Error getting today progress: $e');
      return Left(CacheFailure('Erro ao buscar progresso: $e'));
    }
  }

  @override
  Stream<Either<Failure, WaterDailyProgressEntity>> watchTodayProgress() {
    return _localDatasource.watchTodayProgress().asyncMap((progress) async {
      if (progress != null) {
        return Right(progress);
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final goal = await _localDatasource.getCurrentGoal();
      return Right(WaterDailyProgressEntity.empty(today, goal.effectiveGoalMl));
    });
  }

  @override
  Future<Either<Failure, List<WaterDailyProgressEntity>>> getProgressRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final progressList = await _localDatasource.getProgressRange(
        startDate,
        endDate,
      );
      return Right(progressList);
    } catch (e) {
      _logger.e('Error getting progress range: $e');
      return Left(CacheFailure('Erro ao buscar progresso: $e'));
    }
  }

  // ==================== STATISTICS ====================

  @override
  Future<Either<Failure, WaterStatisticsEntity>> getStatistics() async {
    try {
      final totalRecords = await _localDatasource.getTotalRecordsCount();
      final daysTracked = await _localDatasource.getDaysWithRecords();
      final weeklyAverage = await _localDatasource.getAverageDaily(7);
      final monthlyAverage = await _localDatasource.getAverageDaily(30);
      final streak = await _localDatasource.getCurrentStreak();
      final weeklyData = await _localDatasource.getWeeklyData();

      // Calculate week over week change
      final thisWeekAvg = await _localDatasource.getAverageDaily(7);
      final lastWeekAvg = await _getLastWeekAverage();
      final weekOverWeekChange = lastWeekAvg > 0
          ? ((thisWeekAvg - lastWeekAvg) / lastWeekAvg * 100)
          : 0.0;

      // Get days with goal achieved
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final progressList = await _localDatasource.getProgressRange(
        monthStart,
        now,
      );
      final daysGoalAchieved =
          progressList.where((p) => p.goalAchieved).length;

      return Right(WaterStatisticsEntity(
        weeklyAverageMl: weeklyAverage,
        monthlyAverageMl: monthlyAverage,
        totalRecordsCount: totalRecords,
        totalDaysTracked: daysTracked,
        daysGoalAchieved: daysGoalAchieved,
        currentStreak: streak.currentStreak,
        bestStreak: streak.bestStreak,
        weeklyData: weeklyData,
        weekOverWeekChange: weekOverWeekChange,
      ));
    } catch (e) {
      _logger.e('Error getting statistics: $e');
      return Left(CacheFailure('Erro ao buscar estatísticas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapEntry<DateTime, int>>>> getWeeklyChartData() async {
    try {
      final data = await _localDatasource.getWeeklyData();
      return Right(data);
    } catch (e) {
      _logger.e('Error getting weekly chart data: $e');
      return Left(CacheFailure('Erro ao buscar dados do gráfico: $e'));
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<void> _updateTodayProgress() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final records = await _localDatasource.getTodayRecords();
    final goal = await _localDatasource.getCurrentGoal();
    
    final totalMl = records.fold<int>(0, (sum, r) => sum + r.amountMl);
    final goalAchieved = totalMl >= goal.effectiveGoalMl;
    
    final firstRecordTime = records.isNotEmpty
        ? records.map((r) => r.timestamp).reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    final lastRecordTime = records.isNotEmpty
        ? records.map((r) => r.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    final progress = WaterDailyProgressEntity(
      id: 'progress_${today.toIso8601String().split('T')[0]}',
      date: today,
      totalMl: totalMl,
      goalMl: goal.effectiveGoalMl,
      goalAchieved: goalAchieved,
      recordCount: records.length,
      firstRecordTime: firstRecordTime,
      lastRecordTime: lastRecordTime,
      updatedAt: now,
    );

    await _localDatasource.updateDailyProgress(progress);

    // Update streak if goal was just achieved
    if (goalAchieved) {
      final streak = await _localDatasource.getCurrentStreak();
      final lastDate = streak.lastRecordDate;
      
      if (lastDate == null || 
          DateTime(lastDate.year, lastDate.month, lastDate.day) != today) {
        await updateStreakOnGoalAchieved();
      }
    }
  }

  Future<double> _getLastWeekAverage() async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day - 7);
    final start = DateTime(now.year, now.month, now.day - 14);
    final records = await _localDatasource.getRecordsByDateRange(start, end);
    if (records.isEmpty) return 0;
    final total = records.fold<int>(0, (sum, r) => sum + r.amountMl);
    return total / 7;
  }
}
