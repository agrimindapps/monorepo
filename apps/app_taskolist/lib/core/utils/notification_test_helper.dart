import 'package:flutter/foundation.dart';
import '../../infrastructure/services/notification_service.dart';

/// Helper para testar workflows de notificação em desenvolvimento
class NotificationTestHelper {
  static const String _testTaskId = 'test_task_123';
  static const String _testTaskTitle = 'Tarefa de Teste';
  
  /// Testa notificação de lembrete com ações
  static Future<void> testTaskReminderNotification(
    TaskManagerNotificationService notificationService
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Testing task reminder notification...');
      
      final success = await notificationService.scheduleTaskReminder(
        taskId: _testTaskId,
        taskTitle: 'Lembrete de Teste',
        reminderTime: DateTime.now().add(const Duration(seconds: 10)),
        description: _testTaskTitle,
      );
      
      if (success) {
        debugPrint('✅ Task reminder notification scheduled successfully');
      } else {
        debugPrint('❌ Failed to schedule task reminder notification');
      }
    }
  }
  
  /// Testa notificação de deadline com ações
  static Future<void> testTaskDeadlineNotification(
    TaskManagerNotificationService notificationService
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Testing task deadline notification...');
      
      final success = await notificationService.scheduleTaskDeadlineAlert(
        taskId: _testTaskId,
        taskTitle: 'Prazo Vencendo!',
        deadline: DateTime.now().add(const Duration(seconds: 15)),
        alertBefore: const Duration(seconds: 0), // Imediato para teste
      );
      
      if (success) {
        debugPrint('✅ Task deadline notification scheduled successfully');
      } else {
        debugPrint('❌ Failed to schedule task deadline notification');
      }
    }
  }
  
  /// Testa cancelamento de notificações
  static Future<void> testCancelNotifications(
    TaskManagerNotificationService notificationService
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Testing notification cancellation...');
      
      await notificationService.cancelTaskNotifications(_testTaskId);
      debugPrint('✅ Test notifications cancelled');
    }
  }
  
  /// Executa todos os testes de notificação
  static Future<void> runAllTests(
    TaskManagerNotificationService notificationService
  ) async {
    if (kDebugMode) {
      debugPrint('🧪 Running all notification tests...');
      
      // Testar lembrete (10 segundos)
      await testTaskReminderNotification(notificationService);
      
      // Aguardar um pouco
      await Future.delayed(const Duration(seconds: 2));
      
      // Testar deadline (15 segundos)  
      await testTaskDeadlineNotification(notificationService);
      
      debugPrint('🧪 All notification tests scheduled. Check notifications in 10-15 seconds.');
      debugPrint('🔔 Test actions available:');
      debugPrint('   • Tap notification → Should navigate to task');
      debugPrint('   • Mark Done → Should complete task');
      debugPrint('   • Snooze 1h → Should reschedule');
      debugPrint('   • Extend → Should open task details');
      
      // Agendar cancelamento após 30 segundos para limpeza
      Future.delayed(const Duration(seconds: 30), () {
        testCancelNotifications(notificationService);
      });
    }
  }
  
  /// Mostra estatísticas de notificação para debug
  static Future<void> showNotificationStats(
    TaskManagerNotificationService notificationService
  ) async {
    if (kDebugMode) {
      try {
        final stats = await notificationService.getNotificationStats();
        
        debugPrint('📊 Notification Stats:');
        debugPrint('   • Total notifications: ${stats.totalNotifications}');
        debugPrint('   • Unread: ${stats.unreadNotifications}');
        debugPrint('   • Task reminders: ${stats.taskReminders}');
        debugPrint('   • Task deadlines: ${stats.taskDeadlines}');
        debugPrint('   • Enabled: ${stats.areNotificationsEnabled}');
      } catch (e) {
        debugPrint('❌ Error getting notification stats: $e');
      }
    }
  }
}