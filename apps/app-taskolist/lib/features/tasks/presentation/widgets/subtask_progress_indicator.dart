import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tasks/presentation/providers/task_notifier.dart';

/// Widget compacto para exibir progresso de subtarefas em TaskCard
class SubtaskProgressBadge extends ConsumerWidget {
  final String taskId;
  final bool showBar;

  const SubtaskProgressBadge({
    super.key,
    required this.taskId,
    this.showBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(subtaskProgressProvider(taskId));

    return progressAsync.when(
      data: (progress) {
        if (!progress.hasSubtasks) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              progress.isFullyCompleted
                  ? Icons.check_circle
                  : Icons.checklist_rounded,
              size: 14,
              color: progress.isFullyCompleted ? Colors.green : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              progress.formattedCount,
              style: TextStyle(
                fontSize: 12,
                color: progress.isFullyCompleted ? Colors.green : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showBar) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.isFullyCompleted ? Colors.green : Colors.blue,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Widget detalhado de progresso para TaskDetailPage
class SubtaskProgressHeader extends ConsumerWidget {
  final String taskId;

  const SubtaskProgressHeader({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(subtaskProgressProvider(taskId));

    return progressAsync.when(
      data: (progress) {
        if (!progress.hasSubtasks) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      progress.isFullyCompleted
                          ? Icons.check_circle
                          : Icons.checklist_rounded,
                      color: progress.isFullyCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Subtarefas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      progress.formattedLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: progress.isFullyCompleted
                            ? Colors.green
                            : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.isFullyCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.progressPercent}% concluído',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
