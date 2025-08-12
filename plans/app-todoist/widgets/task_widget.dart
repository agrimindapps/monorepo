// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/task_model.dart';

/// Widget para exibição de uma tarefa individual
/// Suporta ações como completar, favoritar, editar e deletar
class TaskWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCompletedChanged;
  final VoidCallback? onStarToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isDragMode;

  // Widgets constantes para performance
  static const Widget _indicatorSpacer = SizedBox(width: 12);
  static const Widget _contentSpacer = SizedBox(width: 12);
  static const Widget _actionSpacer = SizedBox(width: 8);
  static const Widget _verticalSpacer = SizedBox(width: 4);

  const TaskWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onCompletedChanged,
    this.onStarToggle,
    this.onDelete,
    this.onEdit,
    this.isDragMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Checkbox circular simples
              GestureDetector(
                onTap: () => onCompletedChanged?.call(!task.isCompleted),
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

              _contentSpacer,

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

                    // Indicadores (subtarefas e comentários)
                    if (_hasIndicators())
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _buildIndicators(),
                      ),
                  ],
                ),
              ),

              // Botão de favorito
              GestureDetector(
                onTap: onStarToggle,
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
    );
  }

  // Verificar se tem indicadores para mostrar
  bool _hasIndicators() {
    return _hasComments() || _isSubtask();
  }

  // Verificar se é uma subtarefa
  bool _isSubtask() {
    return task.parentTaskId != null;
  }

  // Verificar se tem comentários
  bool _hasComments() {
    return task.comments.isNotEmpty;
  }

  // Construir indicadores
  Widget _buildIndicators() {
    List<Widget> indicators = [];

    // Indicador se é subtarefa
    if (_isSubtask()) {
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
            _verticalSpacer,
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
    if (_hasComments()) {
      if (indicators.isNotEmpty) {
        indicators.add(_indicatorSpacer);
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
            _verticalSpacer,
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
