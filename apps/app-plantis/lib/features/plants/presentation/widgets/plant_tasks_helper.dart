import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/riverpod_providers/tasks_providers.dart';
import '../../../tasks/domain/entities/task.dart' as task_entity;

/// Helper unificado para calcular e exibir informações de tarefas pendentes
/// tanto no PlantCard quanto no PlantListTile.
///
/// Este helper encapsula toda a lógica de:
/// - Busca de tarefas por planta
/// - Cálculo de tarefas pendentes
/// - Determinação de cores e ícones
/// - Geração de texto apropriado
class PlantTasksHelper {
  /// Calcula o número de tarefas pendentes para uma planta específica
  static int getPendingTasksCount(WidgetRef ref, String plantId) {
    try {
      // BUGFIX: Usar watch() em vez de read() para observar mudanças
      final tasksAsync = ref.watch(tasksProvider);

      // Se ainda está carregando ou tem erro, retorna 0
      if (!tasksAsync.hasValue) return 0;

      final tasksState = tasksAsync.value!;

      // Busca todas as tarefas da planta
      final plantTasks =
          tasksState.allTasks
              .where((task) => task.plantId == plantId)
              .toList();

      // Conta apenas as tarefas pendentes
      final pendingTasks =
          plantTasks
              .where((task) => task.status == task_entity.TaskStatus.pending)
              .length;

      return pendingTasks;
    } catch (e) {
      // Se ocorrer erro, retorna 0
      debugPrint('Erro ao buscar tarefas pendentes para planta $plantId: $e');
      return 0;
    }
  }

  /// Calcula o número de tarefas atrasadas para uma planta específica
  static int getOverdueTasksCount(WidgetRef ref, String plantId) {
    try {
      // BUGFIX: Usar watch() em vez de read() para observar mudanças
      final tasksAsync = ref.watch(tasksProvider);

      // Se ainda está carregando ou tem erro, retorna 0
      if (!tasksAsync.hasValue) return 0;

      final tasksState = tasksAsync.value!;

      // Busca tarefas da planta que estão atrasadas
      final overdueTasks =
          tasksState.allTasks
              .where(
                (task) =>
                    task.plantId == plantId &&
                    task.status == task_entity.TaskStatus.pending &&
                    task.isOverdue,
              )
              .length;

      return overdueTasks;
    } catch (e) {
      debugPrint('Erro ao buscar tarefas atrasadas para planta $plantId: $e');
      return 0;
    }
  }

  /// Obtém informações de status das tarefas para exibição no badge
  static TaskBadgeInfo getTaskBadgeInfo(WidgetRef ref, String plantId) {
    final pendingCount = getPendingTasksCount(ref, plantId);
    final overdueCount = getOverdueTasksCount(ref, plantId);

    if (pendingCount == 0) {
      return TaskBadgeInfo(
        count: 0,
        text: 'Sem tarefas',
        color: Colors.green,
        backgroundColor: Colors.green.withValues(alpha: 0.15),
        icon: Icons.check_circle,
        isGoodStatus: true,
      );
    }

    if (overdueCount > 0) {
      return TaskBadgeInfo(
        count: pendingCount,
        text:
            overdueCount == 1
                ? '1 tarefa atrasada'
                : '$overdueCount tarefas atrasadas',
        color: Colors.red,
        backgroundColor: Colors.red.withValues(alpha: 0.15),
        icon: Icons.error,
        isGoodStatus: false,
      );
    }

    return TaskBadgeInfo(
      count: pendingCount,
      text:
          pendingCount == 1
              ? '1 tarefa pendente'
              : '$pendingCount tarefas pendentes',
      color: const Color(0xFFFF9500), // Laranja
      backgroundColor: const Color(0xFFFF9500).withValues(alpha: 0.15),
      icon: Icons.schedule,
      isGoodStatus: false,
    );
  }

  /// Verifica se deve mostrar o badge (oculta quando tem 0 tarefas)
  static bool shouldShowBadge(
    WidgetRef ref,
    String plantId, {
    bool hideWhenEmpty = false,
  }) {
    final pendingCount = getPendingTasksCount(ref, plantId);

    if (hideWhenEmpty) {
      return pendingCount > 0;
    }

    return true; // Sempre mostra badge (mesmo com "Sem tarefas")
  }

  /// Widget builder para o badge unificado
  static Widget buildTaskBadge(
    WidgetRef ref,
    String plantId, {
    bool hideWhenEmpty = false,
  }) {
    if (!shouldShowBadge(ref, plantId, hideWhenEmpty: hideWhenEmpty)) {
      return const SizedBox.shrink();
    }

    final badgeInfo = getTaskBadgeInfo(ref, plantId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeInfo.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeInfo.icon, color: badgeInfo.color, size: 14),
          const SizedBox(width: 6),
          Text(
            badgeInfo.text,
            style: TextStyle(
              color: badgeInfo.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Classe para encapsular informações do badge de tarefas
class TaskBadgeInfo {
  final int count;
  final String text;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final bool isGoodStatus;

  const TaskBadgeInfo({
    required this.count,
    required this.text,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.isGoodStatus,
  });
}
