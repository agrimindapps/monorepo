/// Exemplo de uso do sistema de notificações do Plantis
///
/// Este arquivo demonstra como usar o sistema de notificações implementado
/// no app Plantis para diferentes cenários.
library;

import 'package:flutter/foundation.dart';

import '../core/di/injection_container.dart' as di;
import '../core/services/notification_manager.dart';

class NotificationsUsageExample {
  /// Exemplo 1: Inicializar o sistema de notificações no app
  ///
  /// Chame este método no main() ou na inicialização do app
  static Future<void> initializeNotifications() async {
    // Inicializar DI primeiro
    await di.init();

    // Obter o NotificationManager
    final notificationManager = di.sl<NotificationManager>();

    // Inicializar o sistema completo de notificações
    final success = await notificationManager.initialize();

    if (success) {
      debugPrint('✅ Sistema de notificações inicializado com sucesso');
    } else {
      debugPrint('❌ Falha na inicialização das notificações');
    }
  }

  /// Exemplo 2: Agendar notificação para uma nova tarefa
  ///
  /// Use quando o usuário criar uma nova tarefa
  static Future<void> scheduleNewTaskNotification() async {
    final notificationManager = di.sl<NotificationManager>();

    await notificationManager.scheduleTaskReminder(
      taskId: 'task_123',
      taskName: 'Regar',
      plantName: 'Rosa do Deserto',
      taskDescription: 'Regar moderadamente, evitando encharcar',
      plantId: 'plant_456',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    );

    debugPrint('📅 Notificação de tarefa agendada para 3 dias');
  }

  /// Exemplo 3: Notificar quando uma nova planta é adicionada
  ///
  /// Use no provider/controller após adicionar uma planta
  static Future<void> notifyNewPlantAdded() async {
    final notificationManager = di.sl<NotificationManager>();

    await notificationManager.showNewPlantNotification(
      plantName: 'Suculenta Jade',
      plantType: 'Suculenta',
    );

    debugPrint('🌱 Notificação de nova planta enviada');
  }

  /// Exemplo 4: Verificar permissões e solicitar se necessário
  ///
  /// Use na tela de configurações ou primeira execução
  static Future<void> checkAndRequestPermissions() async {
    final notificationManager = di.sl<NotificationManager>();

    // Verificar se já tem permissão
    final hasPermission = await notificationManager.areNotificationsEnabled();

    if (!hasPermission) {
      debugPrint('🔔 Solicitando permissão para notificações...');

      // Solicitar permissão
      final granted = await notificationManager.requestPermissions();

      if (granted) {
        debugPrint('✅ Permissão concedida');
      } else {
        debugPrint('❌ Permissão negada - mostrando opção para abrir configurações');

        // Opcionalmente abrir configurações do sistema
        await notificationManager.openNotificationSettings();
      }
    } else {
      debugPrint('✅ Permissões já concedidas');
    }
  }

  /// Exemplo 5: Cancelar notificações de uma tarefa concluída
  ///
  /// Use quando o usuário marcar uma tarefa como concluída
  static Future<void> cancelTaskNotifications() async {
    final notificationManager = di.sl<NotificationManager>();

    // Cancelar notificações específicas da tarefa
    await notificationManager.cancelTaskNotifications('task_123');

    debugPrint('🚫 Notificações da tarefa canceladas');
  }

  /// Exemplo 6: Verificar tarefas atrasadas periodicamente
  ///
  /// Use em um timer ou background task
  static Future<void> checkOverdueTasksPeriodically() async {
    final notificationManager = di.sl<NotificationManager>();

    // Verificar e notificar tarefas atrasadas
    await notificationManager.checkOverdueTasks();

    debugPrint('🔍 Verificação de tarefas atrasadas executada');
  }

  /// Exemplo 7: Configurar lembretes diários
  ///
  /// Use nas configurações do usuário
  static Future<void> setupDailyReminders() async {
    final notificationManager = di.sl<NotificationManager>();

    // Programar lembretes diários de cuidados
    await notificationManager.scheduleDailyCareReminders();

    debugPrint('📅 Lembretes diários configurados');
  }

  /// Exemplo 8: Listar notificações pendentes (debug/configurações)
  ///
  /// Use para mostrar ao usuário quais notificações estão agendadas
  static Future<void> listPendingNotifications() async {
    final notificationManager = di.sl<NotificationManager>();

    final pendingNotifications =
        await notificationManager.getPendingNotifications();

    debugPrint('📋 Notificações pendentes: ${pendingNotifications.length}');
    for (final notification in pendingNotifications) {
      debugPrint('  - ID: ${notification.id}, Título: ${notification.title}');
    }
  }

  /// Exemplo 9: Usar no Provider/Controller de Tarefas
  ///
  /// Integração com a lógica de negócio
  static Future<void> integrateWithTaskProvider() async {
    final notificationManager = di.sl<NotificationManager>();

    // Exemplo: Quando usuário criar tarefa no provider
    // final newTask = await tasksRepository.createTask(...);

    // Agendar notificação para a nova tarefa
    await notificationManager.scheduleTaskReminder(
      taskId: 'newTask.id',
      taskName: 'newTask.name',
      plantName: 'newTask.plant.name',
      taskDescription: 'newTask.description',
      plantId: 'newTask.plant.id',
      dueDate: DateTime.parse('newTask.dueDate'),
    );

    debugPrint('🔗 Notificação integrada com provider de tarefas');
  }

  /// Exemplo 10: Uso em configurações avançadas
  ///
  /// Para usuários que querem controle total
  static Future<void> advancedNotificationManagement() async {
    final notificationManager = di.sl<NotificationManager>();

    // Verificar se uma notificação específica existe
    final isScheduled = await notificationManager.isNotificationScheduled(
      'task_123',
    );
    debugPrint('📋 Tarefa 123 tem notificação agendada: $isScheduled');

    // Cancelar todas as notificações (reset)
    if (isScheduled) {
      await notificationManager.cancelAllNotifications();
      debugPrint('🚫 Todas as notificações canceladas');

      // Reconfigurar do zero
      await notificationManager.scheduleDailyCareReminders();
      debugPrint('🔄 Sistema reconfigurado');
    }
  }
}

/// Como usar estes exemplos:
///
/// 1. No main.dart:
///    await NotificationsUsageExample.initializeNotifications();
///
/// 2. No TaskProvider quando criar tarefa:
///    await NotificationsUsageExample.scheduleNewTaskNotification();
///
/// 3. No PlantProvider quando adicionar planta:
///    await NotificationsUsageExample.notifyNewPlantAdded();
///
/// 4. Na tela de configurações:
///    await NotificationsUsageExample.checkAndRequestPermissions();
///
/// 5. Em timer/background service:
///    Timer.periodic(Duration(hours: 6), (_) {
///      NotificationsUsageExample.checkOverdueTasksPeriodically();
///    });
