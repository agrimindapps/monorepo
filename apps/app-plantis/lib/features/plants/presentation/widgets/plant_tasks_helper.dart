import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/domain/entities/task.dart' as task_entity;
import '../../../tasks/presentation/notifiers/tasks_notifier.dart';

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
      final tasksAsync = ref.watch(tasksNotifierProvider);
      if (!tasksAsync.hasValue) return 0;

      final tasksState = tasksAsync.value!;
      
      // DEBUG: Log para investigar o problema
      debugPrint('🔍 PlantTasksHelper.getPendingTasksCount - plantId: $plantId');
      debugPrint('🔍 Total de tarefas no state: ${tasksState.allTasks.length}');
      
      final plantTasks = tasksState.allTasks
          .whereType<task_entity.Task>()
          .where((task) {
            final matches = task.plantId == plantId && !task.isDeleted;
            if (task.plantId.isNotEmpty) {
              debugPrint('🔍 Task "${task.title}" plantId: ${task.plantId}, match: $matches, isDeleted: ${task.isDeleted}, status: ${task.status}');
            }
            return matches;
          })
          .toList();
          
      debugPrint('🔍 Tarefas filtradas para planta: ${plantTasks.length}');
      
      final pendingTasks = plantTasks
          .where(
            (task) =>
                task.status == task_entity.TaskStatus.pending ||
                task.status == task_entity.TaskStatus.overdue,
          )
          .length;

      debugPrint('🔍 Tarefas pendentes/atrasadas: $pendingTasks');
      return pendingTasks;
    } catch (e) {
      debugPrint('Erro ao buscar tarefas pendentes para planta $plantId: $e');
      return 0;
    }
  }

  /// Calcula o número de tarefas atrasadas para uma planta específica
  static int getOverdueTasksCount(WidgetRef ref, String plantId) {
    try {
      final tasksAsync = ref.watch(tasksNotifierProvider);
      if (!tasksAsync.hasValue) return 0;

      final tasksState = tasksAsync.value!;
      final overdueTasks = tasksState.allTasks
          .whereType<task_entity.Task>()
          .where(
            (task) =>
                task.plantId == plantId &&
                !task.isDeleted &&
                task.status == task_entity.TaskStatus.overdue,
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
        text: overdueCount == 1 ? '1 atrasada' : '$overdueCount atrasadas',
        color: Colors.red,
        backgroundColor: Colors.red.withValues(alpha: 0.15),
        icon: Icons.error,
        isGoodStatus: false,
      );
    }

    return TaskBadgeInfo(
      count: pendingCount,
      text: '$pendingCount pendente${pendingCount > 1 ? 's' : ''}',
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
