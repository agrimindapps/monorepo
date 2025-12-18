import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Serviço simplificado de Analytics para Taskolist
class AnalyticsService {
  final FirebaseAnalyticsService _analyticsService;

  AnalyticsService(this._analyticsService);

  // Events do Meu Dia
  Future<void> logMyDayTaskAdded({
    required String taskId,
    required String source, // 'manual', 'suggestion', 'task_list'
  }) async {
    await _logEvent('my_day_task_added', {
      'task_id': taskId,
      'source': source,
    });
  }

  Future<void> logMyDayTaskRemoved({required String taskId}) async {
    await _logEvent('my_day_task_removed', {'task_id': taskId});
  }

  Future<void> logMyDayCleared({required int taskCount}) async {
    await _logEvent('my_day_cleared', {'task_count': taskCount});
  }

  Future<void> logMyDaySuggestionsViewed({required int suggestionCount}) async {
    await _logEvent('my_day_suggestions_viewed', {
      'suggestion_count': suggestionCount,
    });
  }

  Future<void> logMyDayRefreshed() async {
    await _logEvent('my_day_refreshed', {});
  }

  // Helper privado
  Future<void> _logEvent(String eventName, Map<String, dynamic> params) async {
    final result = await _analyticsService.logEvent(
      eventName,
      parameters: params,
    );

    result.fold(
      (failure) => developer.log(
        'Analytics error: ${failure.message}',
        name: 'AnalyticsService',
      ),
      (_) => developer.log(
        'Analytics event logged: $eventName',
        name: 'AnalyticsService',
      ),
    );
  }
}

@riverpod
AnalyticsService analyticsService(Ref ref) {
  final firebaseAnalyticsService = ref.watch(analyticsServiceProvider);
  return AnalyticsService(firebaseAnalyticsService as FirebaseAnalyticsService);
}
