// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/task_model.dart';
import '../widgets/task_widget.dart';

class ReorderableTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task task) onTaskTap;
  final Function(String taskId, bool completed) onCompletedChanged;
  final Function(String taskId, bool starred) onStarToggle;
  final Function(int oldIndex, int newIndex) onReorder;
  final bool isReorderMode;

  const ReorderableTaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onCompletedChanged,
    required this.onStarToggle,
    required this.onReorder,
    this.isReorderMode = false,
  });

  @override
  State<ReorderableTaskList> createState() => _ReorderableTaskListState();
}

class _ReorderableTaskListState extends State<ReorderableTaskList> {
  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma tarefa encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C2C2C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione uma nova tarefa acima.',
              style: TextStyle(color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (widget.isReorderMode) {
      return _buildReorderableList();
    } else {
      return _buildRegularList();
    }
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      onReorder: widget.onReorder,
      itemCount: widget.tasks.length,
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF3A5998),
                width: 2,
              ),
            ),
            child: child,
          ),
        );
      },
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return Container(
          key: ValueKey(task.id),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.drag_handle,
                  color: Color(0xFF999999),
                  size: 20,
                ),
              ),
              // Task widget with custom styling for drag mode
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Checkbox circular simples
                        GestureDetector(
                          onTap: () => widget.onCompletedChanged(
                              task.id, !task.isCompleted),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: task.isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFDDDDDD),
                                width: 1.5,
                              ),
                              color: task.isCompleted
                                  ? const Color(0xFF4CAF50)
                                  : Colors.transparent,
                            ),
                            child: task.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Conteúdo da tarefa
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título da tarefa
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: task.isCompleted
                                      ? const Color(0xFF999999)
                                      : const Color(0xFF333333),
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Indicadores (comentários e se é subtarefa)
                              if (_hasIndicators(task))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _buildIndicators(task),
                                ),
                            ],
                          ),
                        ),

                        // Botão de favorito
                        GestureDetector(
                          onTap: () =>
                              widget.onStarToggle(task.id, !task.isStarred),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              task.isStarred ? Icons.star : Icons.star_outline,
                              color: task.isStarred
                                  ? const Color(0xFFFFB84D)
                                  : const Color(0xFFCCCCCC),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegularList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        return TaskWidget(
          task: task,
          onTap: () => widget.onTaskTap(task),
          onCompletedChanged: (value) =>
              widget.onCompletedChanged(task.id, value ?? false),
          onStarToggle: () => widget.onStarToggle(task.id, !task.isStarred),
        );
      },
    );
  }

  // Verificar se tem indicadores para mostrar
  bool _hasIndicators(Task task) {
    return task.comments.isNotEmpty || task.parentTaskId != null;
  }

  // Construir indicadores
  Widget _buildIndicators(Task task) {
    List<Widget> indicators = [];

    // Indicador se é subtarefa
    if (task.parentTaskId != null) {
      indicators.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.subdirectory_arrow_right,
              size: 14,
              color: task.isCompleted
                  ? const Color(0xFF999999)
                  : const Color(0xFF666666),
            ),
            const SizedBox(width: 4),
            Text(
              'Subtarefa',
              style: TextStyle(
                fontSize: 12,
                color: task.isCompleted
                    ? const Color(0xFF999999)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    // Indicador de comentários
    if (task.comments.isNotEmpty) {
      if (indicators.isNotEmpty) {
        indicators.add(const SizedBox(width: 12));
      }

      indicators.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: task.isCompleted
                  ? const Color(0xFF999999)
                  : const Color(0xFF666666),
            ),
            const SizedBox(width: 4),
            Text(
              '${task.comments.length}',
              style: TextStyle(
                fontSize: 12,
                color: task.isCompleted
                    ? const Color(0xFF999999)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: indicators,
    );
  }
}
