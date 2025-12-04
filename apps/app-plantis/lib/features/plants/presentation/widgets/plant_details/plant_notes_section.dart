import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/data/models/comentario_model.dart';
import '../../../../../core/providers/comments_providers.dart';
import '../../../domain/entities/plant.dart';

/// Widget responsável por exibir e gerenciar os comentários/observações da planta
class PlantNotesSection extends ConsumerStatefulWidget {
  final Plant plant;

  const PlantNotesSection({super.key, required this.plant});

  @override
  ConsumerState<PlantNotesSection> createState() => _PlantNotesSectionState();
}

class _PlantNotesSectionState extends ConsumerState<PlantNotesSection> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(commentsNotifierProvider.notifier)
            .loadComments(widget.plant.id);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);

    return commentsState.when(
      data: (state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddCommentSection(context, state),
              const SizedBox(height: 24),
              if (state.isLoading && !state.hasComments)
                _buildLoadingState(context)
              else if (state.hasComments)
                _buildCommentsList(context, state)
              else
                _buildEmptyState(context),
              if (state.errorMessage != null)
                _buildErrorMessage(context, state),
            ],
          ),
        );
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => Center(
        child: Text('Erro ao carregar comentários: $error'),
      ),
    );
  }

  Widget _buildAddCommentSection(
    BuildContext context,
    CommentsState state,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Adicionar comentário',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              hintText:
                  'Escreva um comentário sobre ${widget.plant.displayName}...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF1C1C1E)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _commentController.clear();
                },
                child: const Text('Limpar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : _addComment,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(
    BuildContext context,
    CommentsState state,
  ) {
    final theme = Theme.of(context);
    final comments = state.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Histórico de comentários',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${comments.length} ${comments.length == 1 ? 'comentário' : 'comentários'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentCard(context, comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    ComentarioModel comment,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(comment.dataCriacao ?? DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                onSelected: (action) => _handleCommentAction(action, comment),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.conteudo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          if (comment.dataAtualizacao != null &&
              comment.dataAtualizacao != comment.dataCriacao) ...[
            const SizedBox(height: 8),
            Text(
              'Editado em ${_formatDate(comment.dataAtualizacao!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (kDebugMode) {
      print('🔍 Tentando adicionar comentário:');
      print('   Plant ID: ${widget.plant.id}');
      print('   Plant Name: ${widget.plant.displayName}');
      print('   Content Length: ${text.length}');
      print(
          '   Content: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    }

    try {
      final success = await ref
          .read(commentsNotifierProvider.notifier)
          .addComment(widget.plant.id, text);

      if (kDebugMode) {
        print('   Result: ${success ? "✅ Sucesso" : "❌ Falhou"}');
      }

      if (success) {
        _commentController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentário adicionado com sucesso'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          final commentsState = ref.read(commentsNotifierProvider).value;
          final errorMsg = commentsState?.errorMessage ??
              'Erro desconhecido ao adicionar comentário';

          if (kDebugMode) {
            print('   Error Message: $errorMsg');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Exception ao adicionar comentário: $e');
        print('   Stack: $stack');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleCommentAction(
    String action,
    ComentarioModel comment,
  ) {
    switch (action) {
      case 'edit':
        _editComment(comment);
        break;
      case 'delete':
        _confirmDeleteComment(comment);
        break;
    }
  }

  void _editComment(ComentarioModel comment) {
    final editController = TextEditingController(text: comment.conteudo);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editar comentário',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Altere o texto do seu comentário',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // TextField
                TextField(
                  controller: editController,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Digite seu comentário...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        editController.dispose();
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final newText = editController.text.trim();
                        if (newText.isNotEmpty && newText != comment.conteudo) {
                          final success = await ref
                              .read(commentsNotifierProvider.notifier)
                              .updateComment(comment.id, newText);

                          if (!dialogContext.mounted) {
                            editController.dispose();
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          editController.dispose();

                          if (success) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comentário atualizado'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            final commentsState = ref.read(commentsNotifierProvider).value;
                            final errorMsg = commentsState?.errorMessage ??
                                'Não foi possível atualizar o comentário';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $errorMsg'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } else {
                          Navigator.of(dialogContext).pop();
                          editController.dispose();
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Salvar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteComment(ComentarioModel comment) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Excluir comentário',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final success = await ref
                              .read(commentsNotifierProvider.notifier)
                              .deleteComment(comment.id);

                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();

                          if (success) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comentário excluído'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            final commentsState = ref.read(commentsNotifierProvider).value;
                            final errorMsg = commentsState?.errorMessage ??
                                'Não foi possível excluir o comentário';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $errorMsg'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Excluir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando comentários...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum comentário ainda',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione o primeiro comentário sobre ${widget.plant.displayName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    CommentsState state,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(commentsNotifierProvider.notifier).clearError(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes}min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
