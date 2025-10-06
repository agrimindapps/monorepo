import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

class TaskCommentsSection extends ConsumerStatefulWidget {
  final String taskId;

  const TaskCommentsSection({super.key, required this.taskId});

  @override
  ConsumerState<TaskCommentsSection> createState() =>
      _TaskCommentsSectionState();
}

class _TaskCommentsSectionState extends ConsumerState<TaskCommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  final List<TaskComment> _comments = []; // Lista local temporária

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(
        TaskComment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: widget.taskId,
          text: text,
          authorName: ref
              .read(currentUserProvider)
              .when(
                data: (user) => user?.displayName ?? 'Usuário',
                loading: () => 'Usuário',
                error: (_, __) => 'Usuário',
              ),
          createdAt: DateTime.now(),
        ),
      );
    });

    _commentController.clear();

    // Auto scroll para o novo comentário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dos comentários
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Comentários (${_comments.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Lista de comentários
        if (_comments.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum comentário ainda',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Adicione o primeiro comentário abaixo',
                    style: TextStyle(fontSize: 14, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          )
        else
          ..._comments.map((comment) => _buildCommentItem(comment)),

        // Input para novo comentário
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              // Avatar do usuário
              Container(
                margin: const EdgeInsets.all(12),
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
              ),

              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Adicionar comentário...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  onSubmitted: (_) => _addComment(),
                ),
              ),

              // Botão enviar
              IconButton(
                onPressed: _addComment,
                icon: const Icon(Icons.send, color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(TaskComment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do comentário
          Row(
            children: [
              // Avatar
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textOnPrimary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),

              // Nome do autor
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const Spacer(),

              // Data
              Text(
                _formatCommentDate(comment.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Texto do comentário
          Text(
            comment.text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

// Modelo simples para comentário (futuramente mover para entities)
class TaskComment {
  final String id;
  final String taskId;
  final String text;
  final String authorName;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.taskId,
    required this.text,
    required this.authorName,
    required this.createdAt,
  });
}
