import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../features/tasks/domain/task_entity.dart';
import '../../features/tasks/domain/update_task.dart';
import '../providers/core_providers.dart';
import '../providers/service_providers.dart';
import 'navigation_service.dart' as local_nav;

/// Serviço para gerenciar ações de notificações
class NotificationActionsService {
  static late ProviderContainer _container;
  
  static void initialize(ProviderContainer container) {
    _container = container;
  }
  
  /// Executa ação baseada no actionId e payload da notificação
  static Future<void> executeNotificationAction(String actionId, String? payload) async {
    final context = local_nav.NavigationService.navigatorKey.currentContext;
    
    try {
      debugPrint('🔔 Executing notification action: $actionId, payload: $payload');
      
      if (payload != null && (payload.startsWith('task_reminder:') || payload.startsWith('task_deadline:'))) {
        final taskId = payload.split(':')[1];
        
        switch (actionId) {
          case 'mark_done':
            await _markTaskAsDone(taskId, context);
            break;
          case 'snooze_1h':
            await _snoozeTaskFor1Hour(taskId, context);
            break;
          case 'extend_deadline':
            await _openExtendDeadlineDialog(taskId, context);
            break;
          default:
            debugPrint('⚠️ Unknown action ID: $actionId');
        }
      } else {
        debugPrint('⚠️ Invalid payload for notification action: $payload');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error executing notification action: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Erro ao executar ação: $e');
      }
    }
  }
  
  /// Marca tarefa como concluída
  static Future<void> _markTaskAsDone(String taskId, BuildContext? context) async {
    try {
      final updateTaskUseCase = _container.read(updateTaskUseCaseProvider);
      final tasksFuture = _container.read(tasksProvider.future);
      
      try {
        final tasks = await tasksFuture;
        final task = tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => throw local_nav.TaskNotFoundException(taskId),
        );
        final updatedTask = task.copyWith(
          status: TaskStatus.completed,
          updatedAt: DateTime.now(),
        );
        
        final result = await updateTaskUseCase(UpdateTaskParams(task: updatedTask));
        
        result.fold(
          (failure) {
            debugPrint('❌ Failed to mark task as done: $failure');
            if (context != null && context.mounted) {
              _showErrorSnackBar(context, 'Erro ao marcar tarefa como concluída');
            }
          },
          (success) {
            debugPrint('✅ Task marked as done successfully: $taskId');
            if (context != null && context.mounted) {
              _showSuccessSnackBar(context, '✅ Tarefa "${task.title}" concluída!');
            }
            _cancelTaskNotifications(taskId);
          },
        );
      } catch (error) {
        debugPrint('❌ Error loading tasks for task $taskId: $error');
        if (context != null && context.mounted) {
          _showErrorSnackBar(context, 'Erro ao carregar tarefas');
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking task as done: $e');
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Tarefa não encontrada');
      }
    }
  }
  
  /// Adia lembrete por 1 hora
  static Future<void> _snoozeTaskFor1Hour(String taskId, BuildContext? context) async {
    try {
      final notificationService = _container.read(taskManagerNotificationServiceProvider);
      await notificationService.cancelNotification(taskId.hashCode);
      final newReminderTime = DateTime.now().add(const Duration(hours: 1));
      
      await notificationService.scheduleTaskReminder(
        taskId: taskId,
        taskTitle: 'Lembrete reagendado',
        reminderTime: newReminderTime,
        description: 'Sua tarefa aguarda atenção',
      );
      
      debugPrint('🔔 Task reminder snoozed for 1 hour: $taskId');
      
      if (context != null && context.mounted) {
        _showSuccessSnackBar(
          context, 
          '⏰ Lembrete adiado por 1 hora (${_formatTime(newReminderTime)})'
        );
      }
    } catch (e) {
      debugPrint('❌ Error snoozing task: $e');
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Erro ao adiar lembrete');
      }
    }
  }
  
  /// Abre dialog para estender deadline (navega para task detail)
  static Future<void> _openExtendDeadlineDialog(String taskId, BuildContext? context) async {
    try {
      debugPrint('📅 Opening extend deadline dialog for task: $taskId');
      await local_nav.NavigationService.navigateFromNotification('task_deadline:$taskId');
      
      if (context != null && context.mounted) {
        _showInfoSnackBar(context, '📅 Abrindo opções de prazo...');
      }
    } catch (e) {
      debugPrint('❌ Error opening extend deadline dialog: $e');
      if (context != null && context.mounted) {
        _showErrorSnackBar(context, 'Erro ao abrir opções de prazo');
      }
    }
  }
  
  /// Cancela todas as notificações relacionadas a uma tarefa
  static Future<void> _cancelTaskNotifications(String taskId) async {
    try {
      final notificationService = _container.read(taskManagerNotificationServiceProvider);
      await notificationService.cancelNotification(taskId.hashCode);
      await notificationService.cancelNotification('${taskId}_deadline'.hashCode);
      
      debugPrint('🔕 Cancelled notifications for task: $taskId');
    } catch (e) {
      debugPrint('❌ Error cancelling task notifications: $e');
    }
  }
  
  /// Helper para mostrar SnackBar de sucesso
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  /// Helper para mostrar SnackBar de erro
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  /// Helper para mostrar SnackBar informativa
  static void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Helper para formatar hora
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

