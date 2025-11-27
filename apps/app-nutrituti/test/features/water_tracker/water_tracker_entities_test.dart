import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:app_nutrituti/features/water_tracker/domain/entities/water_goal_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_streak_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_record_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_daily_progress_entity.dart';
import 'package:app_nutrituti/features/water_tracker/domain/entities/water_achievement_entity.dart';

void main() {
  group('WaterGoalEntity', () {
    test('should calculate goal from weight correctly', () {
      // Average person (70kg) should need ~2275ml (32.5ml * 70)
      final goal = WaterGoalEntity.calculateFromWeight(70.0);
      expect(goal, closeTo(2275, 50));
    });

    test('should calculate goal with activity adjustment', () {
      final goal = WaterGoalEntity.calculateFromWeight(70.0, activeDay: true);
      // Active day should be 20% more
      expect(goal, greaterThan(2275));
    });

    test('effectiveGoalMl should return calculated goal when useCalculatedGoal is true', () {
      final goal = WaterGoalEntity(
        id: 'test',
        dailyGoalMl: 2000,
        calculatedGoalMl: 2500,
        useCalculatedGoal: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.effectiveGoalMl, equals(2500));
    });

    test('effectiveGoalMl should return manual goal when useCalculatedGoal is false', () {
      final goal = WaterGoalEntity(
        id: 'test',
        dailyGoalMl: 2000,
        calculatedGoalMl: 2500,
        useCalculatedGoal: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.effectiveGoalMl, equals(2000));
    });

    test('effectiveGoalMl should include activity adjustment', () {
      final goal = WaterGoalEntity(
        id: 'test',
        dailyGoalMl: 2000,
        activityAdjustmentMl: 500,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(goal.effectiveGoalMl, equals(2500));
    });
  });

  group('WaterStreakEntity', () {
    test('isAtRisk should return true when last record was yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      final streak = WaterStreakEntity(
        id: 'test',
        currentStreak: 5,
        lastRecordDate: yesterday,
        updatedAt: now,
      );

      expect(streak.isAtRisk, isTrue);
    });

    test('isBroken should return true when last record was more than 1 day ago', () {
      final now = DateTime.now();
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);
      
      final streak = WaterStreakEntity(
        id: 'test',
        currentStreak: 5,
        lastRecordDate: twoDaysAgo,
        updatedAt: now,
      );

      expect(streak.isBroken, isTrue);
    });

    test('daysToNextMilestone should calculate correctly', () {
      final streak = WaterStreakEntity(
        id: 'test',
        currentStreak: 5,
        updatedAt: DateTime.now(),
      );

      // Next milestone from 5 is 7
      expect(streak.daysToNextMilestone, equals(2));
    });
  });

  group('WaterDailyProgressEntity', () {
    test('progressPercentage should calculate correctly', () {
      final progress = WaterDailyProgressEntity(
        id: 'test',
        date: DateTime.now(),
        totalMl: 1500,
        goalMl: 2000,
        updatedAt: DateTime.now(),
      );

      expect(progress.progressPercentage, equals(75.0));
    });

    test('remainingMl should return correct value', () {
      final progress = WaterDailyProgressEntity(
        id: 'test',
        date: DateTime.now(),
        totalMl: 1500,
        goalMl: 2000,
        updatedAt: DateTime.now(),
      );

      expect(progress.remainingMl, equals(500));
    });

    test('remainingMl should return 0 when goal exceeded', () {
      final progress = WaterDailyProgressEntity(
        id: 'test',
        date: DateTime.now(),
        totalMl: 2500,
        goalMl: 2000,
        updatedAt: DateTime.now(),
      );

      expect(progress.remainingMl, equals(0));
      expect(progress.goalExceeded, isTrue);
    });
  });

  group('WaterAchievementEntity', () {
    test('progressPercentage should calculate correctly', () {
      final achievement = WaterAchievementEntity(
        id: 'test',
        type: WaterAchievementType.perfectWeek,
        title: 'Test',
        description: 'Test description',
        currentProgress: 3,
        requiredValue: 7,
      );

      expect(achievement.progressPercentage, closeTo(42.86, 0.1));
    });

    test('remainingToUnlock should return correct value', () {
      final achievement = WaterAchievementEntity(
        id: 'test',
        type: WaterAchievementType.perfectWeek,
        title: 'Test',
        description: 'Test description',
        currentProgress: 3,
        requiredValue: 7,
      );

      expect(achievement.remainingToUnlock, equals(4));
    });

    test('progressPercentage should return 100 when unlocked', () {
      final achievement = WaterAchievementEntity(
        id: 'test',
        type: WaterAchievementType.perfectWeek,
        title: 'Test',
        description: 'Test description',
        isUnlocked: true,
      );

      expect(achievement.progressPercentage, equals(100.0));
    });
  });

  group('WaterRecordEntity', () {
    test('should create record with correct values', () {
      final timestamp = DateTime.now();
      final record = WaterRecordEntity(
        id: 'record-1',
        amountMl: 250,
        timestamp: timestamp,
        note: 'Morning glass',
      );

      expect(record.id, equals('record-1'));
      expect(record.amountMl, equals(250));
      expect(record.timestamp, equals(timestamp));
      expect(record.note, equals('Morning glass'));
    });

    test('copyWith should create new instance with updated values', () {
      final original = WaterRecordEntity(
        id: 'record-1',
        amountMl: 250,
        timestamp: DateTime.now(),
      );

      final copied = original.copyWith(amountMl: 500);

      expect(copied.id, equals(original.id));
      expect(copied.amountMl, equals(500));
      expect(copied.timestamp, equals(original.timestamp));
    });
  });
}
