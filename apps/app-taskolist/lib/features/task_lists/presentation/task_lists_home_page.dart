import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/task_list_colors.dart';
import '../../tasks/presentation/providers/task_notifier.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../tasks/domain/task_list_entity.dart';
import '../providers/task_list_providers.dart';
import 'create_edit_task_list_page.dart';
import 'task_list_detail_page.dart';

class TaskListsHomePage extends ConsumerWidget {
  const TaskListsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListsAsync = ref.watch(taskListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Listas'), elevation: 0),
      body: taskListsAsync.when(
        data: (taskLists) {
          if (taskLists.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.list_alt_outlined,
              title: 'Nenhuma lista criada',
              message: 'Crie listas personalizadas para organizar suas tarefas',
              actionLabel: 'Criar primeira lista',
              onAction: () => _navigateToCreate(context),
            );
          }

          final activeLists = taskLists
              .where((list) => !list.isArchived)
              .toList();
          final archivedLists = taskLists
              .where((list) => list.isArchived)
              .toList();

          return CustomScrollView(
            slivers: [
              if (activeLists.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TaskListCard(
                        taskList: activeLists[index],
                        onTap: () =>
                            _navigateToDetail(context, activeLists[index]),
                        onEdit: () =>
                            _navigateToEdit(context, activeLists[index]),
                        onArchive: () => _archiveList(ref, activeLists[index]),
                        onDelete: () =>
                            _deleteList(context, ref, activeLists[index]),
                      ),
                      childCount: activeLists.length,
                    ),
                  ),
                ),
              ],
              if (archivedLists.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Arquivadas',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Opacity(
                        opacity: 0.6,
                        child: _TaskListCard(
                          taskList: archivedLists[index],
                          onTap: () =>
                              _navigateToDetail(context, archivedLists[index]),
                          onEdit: () =>
                              _navigateToEdit(context, archivedLists[index]),
                          onUnarchive: () =>
                              _unarchiveList(ref, archivedLists[index]),
                          onDelete: () =>
                              _deleteList(context, ref, archivedLists[index]),
                        ),
                      ),
                      childCount: archivedLists.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar listas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CreateEditTaskListPage(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, TaskListEntity taskList) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CreateEditTaskListPage(taskList: taskList),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, TaskListEntity taskList) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TaskListDetailPage(taskList: taskList),
      ),
    );
  }

  Future<void> _archiveList(WidgetRef ref, TaskListEntity taskList) async {
    final updated = taskList.copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
    await ref.read(updateTaskListProvider.notifier).call(updated);
  }

  Future<void> _unarchiveList(WidgetRef ref, TaskListEntity taskList) async {
    final updated = taskList.copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
    await ref.read(updateTaskListProvider.notifier).call(updated);
  }

  Future<void> _deleteList(
    BuildContext context,
    WidgetRef ref,
    TaskListEntity taskList,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir lista?'),
        content: Text(
          'Tem certeza que deseja excluir "${taskList.title}"? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteTaskListProvider.notifier).call(taskList.id);
    }
  }
}

class _TaskListCard extends ConsumerWidget {
  final TaskListEntity taskList;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback onDelete;

  const _TaskListCard({
    required this.taskList,
    required this.onTap,
    required this.onEdit,
    this.onArchive,
    this.onUnarchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(
      tasksStreamProvider(TasksStreamParams(listId: taskList.id)),
    );
    final taskCount = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((task) => task.listId == taskList.id).length,
      orElse: () => 0,
    );

    final completedCount = tasksAsync.maybeWhen(
      data: (tasks) => tasks
          .where((task) => task.listId == taskList.id && task.isCompleted)
          .length,
      orElse: () => 0,
    );

    final color = TaskListColors.fromHex(taskList.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskList.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (taskList.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            taskList.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => <PopupMenuEntry<int>>[
                      PopupMenuItem<int>(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      if (onArchive != null)
                        PopupMenuItem<int>(
                          onTap: onArchive,
                          child: const Row(
                            children: [
                              Icon(Icons.archive_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Arquivar'),
                            ],
                          ),
                        ),
                      if (onUnarchive != null)
                        PopupMenuItem<int>(
                          onTap: onUnarchive,
                          child: const Row(
                            children: [
                              Icon(Icons.unarchive_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Desarquivar'),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem<int>(
                        onTap: onDelete,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$completedCount de $taskCount tarefas concluídas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (taskList.isShared) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${taskList.memberIds.length + 1} membros',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (taskCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completedCount / taskCount,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
