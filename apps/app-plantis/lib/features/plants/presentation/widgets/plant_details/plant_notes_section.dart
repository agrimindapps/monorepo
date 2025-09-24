import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/data/models/comentario_model.dart';
import '../../../domain/entities/plant.dart';
import '../../providers/plant_comments_provider.dart';

/// Widget responsável por exibir e gerenciar os comentários/observações da planta
class PlantNotesSection extends StatefulWidget {
  final Plant plant;

  const PlantNotesSection({super.key, required this.plant});

  @override
  State<PlantNotesSection> createState() => _PlantNotesSectionState();
}

class _PlantNotesSectionState extends State<PlantNotesSection> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load comments when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlantCommentsProvider>().loadComments(widget.plant.id);
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
    return Consumer<PlantCommentsProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            // Remove o foco do campo de comentário quando tocar em outros lugares
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddCommentSection(context, provider),
              const SizedBox(height: 24),
              if (provider.isLoading && !provider.hasComments)
                _buildLoadingState(context)
              else if (provider.hasComments)
                _buildCommentsList(context, provider)
              else
                _buildEmptyState(context),
              if (provider.errorMessage != null)
                _buildErrorMessage(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCommentSection(BuildContext context, PlantCommentsProvider provider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
                'Adicionar observação',
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
              // Remove o foco quando tocar fora do campo
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              hintText:
                  'Escreva uma observação sobre ${widget.plant.displayName}...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
              fillColor:
                  theme.brightness == Brightness.dark
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
                onPressed: provider.isLoading ? null : () => _addComment(provider),
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


  Widget _buildCommentsList(BuildContext context, PlantCommentsProvider provider) {
    final theme = Theme.of(context);
    final comments = provider.comments;

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
              'Histórico de observações',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${comments.length} observação${comments.length != 1 ? 'ões' : ''}',
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
            return _buildCommentCard(context, comment, provider);
          },
        ),
      ],
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    ComentarioModel comment,
    PlantCommentsProvider provider,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
          // Header com data e menu
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
                onSelected: (action) => _handleCommentAction(action, comment, provider),
                itemBuilder:
                    (context) => [
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

          // Conteúdo do comentário
          Text(
            comment.conteudo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),

          // Mostrar data de atualização se foi editado
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

  Future<void> _addComment(PlantCommentsProvider provider) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final success = await provider.addComment(widget.plant.id, text);
    
    if (success) {
      _commentController.clear();
      
      // Mostrar confirmação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Observação adicionada com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleCommentAction(String action, ComentarioModel comment, PlantCommentsProvider provider) {
    switch (action) {
      case 'edit':
        _editComment(comment, provider);
        break;
      case 'delete':
        _confirmDeleteComment(comment, provider);
        break;
    }
  }

  void _editComment(ComentarioModel comment, PlantCommentsProvider provider) {
    final editController = TextEditingController(text: comment.conteudo);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar observação'),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Edite sua observação...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              editController.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != comment.conteudo) {
                final success = await provider.updateComment(comment.id, newText);
                
                if (success) {
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Observação atualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } else {
                Navigator.of(context).pop();
              }
              editController.dispose();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(ComentarioModel comment, PlantCommentsProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir observação'),
        content: const Text(
          'Tem certeza que deseja excluir esta observação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await provider.deleteComment(comment.id);
              
              if (success) {
                if (mounted) Navigator.of(context).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Observação excluída'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
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
              'Nenhuma observação ainda',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione a primeira observação sobre ${widget.plant.displayName}',
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

  Widget _buildErrorMessage(BuildContext context, PlantCommentsProvider provider) {
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
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => provider.clearError(),
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
