import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/task_entity.dart';
import '../providers/my_day_notifier.dart';

class MyDaySuggestionsBottomSheet extends ConsumerWidget {
  final String userId;

  const MyDaySuggestionsBottomSheet({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(myDaySuggestionsProvider(userId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Text(
                      'Sugestões para Hoje',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(),

              // Content
              Expanded(
                child: suggestionsAsync.when(
                  data: (suggestions) {
                    if (suggestions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tudo em dia!',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma sugestão encontrada.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final task = suggestions[index];
                        return _SuggestionItem(
                          task: task,
                          onAdd: () {
                            ref
                                .read(myDayProvider(userId).notifier)
                                .addTask(task.id, source: 'suggestion');
                                
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tarefa adicionada ao Meu Dia'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Erro ao carregar sugestões: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onAdd;

  const _SuggestionItem({
    required this.task,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          task.isStarred ? Icons.star : Icons.circle_outlined,
          color: task.isStarred ? Colors.amber : Colors.grey,
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: _getDueDateColor(context, task.dueDate!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(context, task.dueDate!),
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: onAdd,
          tooltip: 'Adicionar ao Meu Dia',
        ),
      ),
    );
  }

  Color _getDueDateColor(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isBefore(today)) {
      return Colors.red;
    } else if (taskDate.isAtSameMomentAs(today)) {
      return Colors.blue;
    }
    return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Hoje';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Amanhã';
    } else if (taskDate.isBefore(today)) {
      return 'Atrasada ${DateFormat('dd/MM').format(date)}';
    }
    return DateFormat('EEE, dd MMM').format(date);
  }
}
