import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/schedule_service.dart';
import '../../domain/services/task_recommendation_service.dart';

part 'specialized_tasks_providers.g.dart';

/// ScheduleService Provider (DIP)
@riverpod
IScheduleService scheduleService(Ref ref) {
  return ScheduleService();
}

/// TaskRecommendationService Provider (DIP)
@riverpod
ITaskRecommendationService taskRecommendationService(
  Ref ref,
) {
  return TaskRecommendationService();
}

/// Specialized notifier providers are already available via @riverpod decorators
/// - tasksCrudNotifierProvider
/// - tasksQueryNotifierProvider
/// - tasksScheduleNotifierProvider
/// - tasksRecommendationNotifierProvider
