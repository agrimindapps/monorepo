import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/auth_providers.dart';
import '../../domain/my_day_task_entity.dart';
import '../../domain/task_entity.dart';
import '../../providers/task_providers.dart';
import '../providers/my_day_notifier.dart';
import '../providers/task_notifier.dart';
import '../../../../shared/widgets/entry_animation_widget.dart';

import '../widgets/my_day_suggestions_bottom_sheet.dart';

class MyDayPage extends ConsumerStatefulWidget {
  const MyDayPage({super.key});

  @override
  ConsumerState<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends ConsumerState<MyDayPage> {
  // _showSuggestions state removed as we use BottomSheet now

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.value?.id ?? 'anonymous';

    final myDayTasksAsync = ref.watch(myDayStreamProvider(userId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meu Dia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMMM', 'pt_BR').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context, userId);
            },
          ),
        ],
      ),
      body: myDayTasksAsync.when(
        data: (myDayTasks) {
          if (myDayTasks.isEmpty) {
            return _buildEmptyState(context, userId);
          }

          return _buildTasksList(context, myDayTasks, userId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myDayStreamProvider(userId)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: myDayTasksAsync.maybeWhen(
        data: (tasks) => tasks.isEmpty
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddTaskDialog(context, userId),
                child: const Icon(Icons.add),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 80, color: Colors.blue[300]),
          const SizedBox(height: 24),
          const Text(
            'Meu Dia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma tarefa para hoje',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showSuggestionsSheet(context, userId),
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Ver sugestões'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    List<MyDayTaskEntity> myDayTasks,
    String userId,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myDayStreamProvider(userId));
        // Aguardar um pouco para dar feedback visual
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: myDayTasks.length + 1,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                elevation: 4,
                color: Colors.transparent,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (int oldIndex, int newIndex) async {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          if (oldIndex >= myDayTasks.length || newIndex >= myDayTasks.length) {
            // Cannot reorder the "Add task" button
            return;
          }

          final item = myDayTasks.removeAt(oldIndex);
          myDayTasks.insert(newIndex, item);

          // Update order in backend
          // Note: MyDayTaskEntity doesn't strictly have a 'position' field visible here
          // but we should ideally update the task entity position.
          // For now, we'll just handle the UI reorder since the backend support
          // for arbitrary my-day reordering might need specific implementation
        },
        itemBuilder: (context, index) {
          if (index == myDayTasks.length) {
            return Padding(
              key: const ValueKey('add_task_button'),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton.icon(
                onPressed: () => _showAddTaskDialog(context, userId),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar tarefa'),
              ),
            );
          }

          final myDayTask = myDayTasks[index];
          return _buildTaskCard(context, myDayTask, userId);
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    MyDayTaskEntity myDayTask,
    String userId,
  ) {
    final taskAsync = ref.watch(getTaskByIdProvider(myDayTask.taskId));

    return taskAsync.when(
      data: (task) {
        if (task == null) {
          return const SizedBox.shrink(); // Task não encontrada
        }

        return Container(
          key: Key(myDayTask.taskId),
          margin: const EdgeInsets.only(bottom: 12),
          child: EntryAnimationWidget(
            child: Dismissible(
              key: ValueKey('dismiss_${myDayTask.taskId}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                await ref
                    .read(myDayProvider(userId).notifier)
                    .removeTask(myDayTask.taskId);
                HapticFeedback.mediumImpact();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Removida do Meu Dia'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Checkbox(
                    value: task.status == TaskStatus.completed,
                    shape: const CircleBorder(),
                    onChanged: (value) async {
                      HapticFeedback.lightImpact();
                      final newStatus = value == true
                          ? TaskStatus.completed
                          : TaskStatus.pending;
                      final updatedTask = task.copyWith(
                        status: newStatus,
                        updatedAt: DateTime.now(),
                      );
                      await ref
                          .read(taskProvider.notifier)
                          .updateTask(updatedTask);
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle:
                      task.description != null && task.description!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                size: 14,
                                color: Colors.orange[300],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Adicionada: ${_formatTime(myDayTask.addedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () async {
                      await ref
                          .read(myDayProvider(userId).notifier)
                          .removeTask(myDayTask.taskId);
                      HapticFeedback.mediumImpact();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removida do Meu Dia'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    // TODO: Abrir detalhes da tarefa
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Carregando...'),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }

  void _showSuggestionsSheet(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MyDaySuggestionsBottomSheet(userId: userId),
    );
  }

  void _showAddTaskDialog(BuildContext context, String userId) {
    // TODO: Implementar dialog para adicionar tarefas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showOptionsMenu(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('Ver sugestões'),
              onTap: () {
                Navigator.pop(context);
                _showSuggestionsSheet(context, userId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Limpar Meu Dia'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(myDayProvider(userId).notifier).clearAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Atualizar'),
              onTap: () {
                Navigator.pop(context);
                ref.invalidate(myDayStreamProvider(userId));
              },
            ),
          ],
        ),
      ),
    );
  }
}
