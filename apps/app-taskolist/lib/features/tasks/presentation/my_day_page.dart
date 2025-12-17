import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/auth_providers.dart';
import '../domain/my_day_task_entity.dart';
import 'providers/my_day_notifier.dart';

class MyDayPage extends ConsumerStatefulWidget {
  const MyDayPage({super.key});

  @override
  ConsumerState<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends ConsumerState<MyDayPage> {
  bool _showSuggestions = false;

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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
          if (_showSuggestions) {
            return _buildSuggestionsView(context, userId);
          }

          if (myDayTasks.isEmpty) {
            return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 80,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'Meu Dia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma tarefa para hoje',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _showSuggestions = true);
            },
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myDayTasks.length + 1,
      itemBuilder: (context, index) {
        if (index == myDayTasks.length) {
          return Padding(
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
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    MyDayTaskEntity myDayTask,
    String userId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: false,
          shape: const CircleBorder(),
          onChanged: (value) async {
            // TODO: Toggle task completion
          },
        ),
        title: Text(
          'Task ID: ${myDayTask.taskId}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Adicionada: ${_formatTime(myDayTask.addedAt)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () async {
            await ref
                .read(myDayProvider(userId).notifier)
                .removeTask(myDayTask.taskId);
          },
        ),
        onTap: () {
          // TODO: Abrir detalhes da tarefa
        },
      ),
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

  Widget _buildSuggestionsView(BuildContext context, String userId) {
    final suggestionsAsync = ref.watch(myDaySuggestionsProvider(userId));

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                const SizedBox(height: 16),
                const Text(
                  'Sem sugestões no momento',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _showSuggestions = false),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sugestões para Meu Dia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showSuggestions = false),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final task = suggestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.blue[400],
                      ),
                      title: Text(task.title),
                      subtitle: task.description != null
                          ? Text(
                              task.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          await ref
                              .read(myDayProvider(userId).notifier)
                              .addTask(task.id);
                          setState(() => _showSuggestions = false);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  void _showAddTaskDialog(BuildContext context, String userId) {
    // TODO: Implementar dialog para adicionar tarefas
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
      ),
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
                setState(() => _showSuggestions = true);
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
