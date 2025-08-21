import 'package:flutter/material.dart';
import '../providers/tasks_provider.dart';

class EmptyTasksWidget extends StatelessWidget {
  final TasksFilterType filterType;
  final VoidCallback onAddTask;

  const EmptyTasksWidget({
    super.key,
    required this.filterType,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyStateInfo = _getEmptyStateInfo();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyStateInfo.icon,
                color: theme.colorScheme.primary,
                size: 60,
              ),
            ),

            const SizedBox(height: 24),

            // Título
            Text(
              emptyStateInfo.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Descrição
            Text(
              emptyStateInfo.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            if (emptyStateInfo.showAddButton) ...[
              const SizedBox(height: 32),

              // Botão de ação
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Nova Tarefa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateInfo _getEmptyStateInfo() {
    switch (filterType) {
      case TasksFilterType.all:
        return _EmptyStateInfo(
          icon: Icons.task_alt,
          title: 'Nenhuma tarefa encontrada',
          description:
              'Você ainda não possui tarefas cadastradas.\nComece adicionando uma nova tarefa para suas plantas!',
          showAddButton: true,
        );

      case TasksFilterType.today:
        return _EmptyStateInfo(
          icon: Icons.today,
          title: 'Nenhuma tarefa para hoje',
          description:
              'Que ótimo! Você não tem tarefas agendadas para hoje.\nSuas plantas estão sendo bem cuidadas!',
          showAddButton: false,
        );

      case TasksFilterType.overdue:
        return _EmptyStateInfo(
          icon: Icons.check_circle,
          title: 'Nenhuma tarefa atrasada',
          description:
              'Parabéns! Você está em dia com todos os cuidados.\nSuas plantas agradecem!',
          showAddButton: false,
        );

      case TasksFilterType.upcoming:
        return _EmptyStateInfo(
          icon: Icons.schedule,
          title: 'Nenhuma tarefa próxima',
          description:
              'Não há tarefas agendadas para os próximos dias.\nTalvez seja hora de planejar novos cuidados?',
          showAddButton: true,
        );

      case TasksFilterType.completed:
        return _EmptyStateInfo(
          icon: Icons.history,
          title: 'Nenhuma tarefa concluída',
          description:
              'Você ainda não concluiu nenhuma tarefa.\nComece completando algumas tarefas pendentes!',
          showAddButton: false,
        );

      case TasksFilterType.byPlant:
        return _EmptyStateInfo(
          icon: Icons.local_florist,
          title: 'Nenhuma tarefa para esta planta',
          description:
              'Esta planta não possui tarefas cadastradas.\nQue tal adicionar alguns cuidados?',
          showAddButton: true,
        );
    }
  }
}

class _EmptyStateInfo {
  final IconData icon;
  final String title;
  final String description;
  final bool showAddButton;

  _EmptyStateInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.showAddButton,
  });
}
