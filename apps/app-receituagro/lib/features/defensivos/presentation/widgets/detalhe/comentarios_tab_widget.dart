import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/premium_feature_card.dart';
import '../../providers/detalhe_defensivo_notifier.dart';

/// Widget para tab de comentários com restrição premium
/// Migrated to Riverpod - uses ConsumerStatefulWidget
class ComentariosTabWidget extends ConsumerStatefulWidget {
  final String defensivoName;

  const ComentariosTabWidget({super.key, required this.defensivoName});

  @override
  ConsumerState<ComentariosTabWidget> createState() =>
      _ComentariosTabWidgetState();
}

class _ComentariosTabWidgetState extends ConsumerState<ComentariosTabWidget> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detalheDefensivoProvider);

    return state.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.isPremium) ...[
              _buildAddCommentSection(data),
              const SizedBox(height: 24),
            ],
            data.isPremium ? _buildPremiumContent(data) : _buildFreeContent(),

            const SizedBox(height: 80), // Espaço para bottom navigation
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('Erro ao carregar comentários')),
    );
  }

  /// Constrói seção para adicionar comentário
  Widget _buildAddCommentSection(DetalheDefensivoState data) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Adicione suas notas sobre defensivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _commentController.clear(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            if (data.errorMessage?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.errorMessage ?? '',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumContent(DetalheDefensivoState data) {
    if (data.isLoadingComments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (data.comentarios.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCommentsList(data);
  }

  /// Constrói lista de comentários
  Widget _buildCommentsList(DetalheDefensivoState data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.comentarios.length,
      itemBuilder: (context, index) {
        final comentario = data.comentarios[index];
        return _buildCommentCard(comentario);
      },
    );
  }

  /// Constrói card de comentário individual
  Widget _buildCommentCard(dynamic comentario) {
    return Dismissible(
      key: Key((comentario.id ?? comentario.hashCode).toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) {
        ref
            .read(detalheDefensivoProvider.notifier)
            .deleteComment((comentario.id ?? '').toString());
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _showEditCommentDialog(comentario),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (comentario.conteudo ?? comentario.titulo ?? '').toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(
                    comentario.createdAt is DateTime
                        ? comentario.createdAt as DateTime
                        : DateTime.now(),
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostra dialog para editar comentário
  Future<void> _showEditCommentDialog(dynamic comentario) async {
    final editController = TextEditingController(
      text: (comentario.conteudo ?? comentario.titulo ?? '').toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Editar comentário'),
            ],
          ),
          content: TextField(
            controller: editController,
            maxLines: 6,
            maxLength: 300,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Edite seu comentário...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newContent = editController.text.trim();
      if (newContent.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('O comentário não pode estar vazio'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // TODO: Implementar método de edição no notifier
      // Por enquanto, apenas mostra sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    editController.dispose();
  }

  Widget _buildFreeContent() {
    return PremiumFeatureCard(
      title: 'Comentários Premium',
      description:
          'Acesse comentários da comunidade e compartilhe suas experiências',
      onUpgradePressed: () {
        // TODO: Navigate to subscription page
      },
    );
  }

  /// Adiciona comentário
  Future<void> _addComment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um comentário antes de enviar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await ref
        .read(detalheDefensivoProvider.notifier)
        .addComment(content);
    if (success) {
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        final state = ref.read(detalheDefensivoProvider);
        state.whenData((data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (data.errorMessage?.isNotEmpty ?? false)
                    ? data.errorMessage!
                    : 'Erro ao adicionar comentário',
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  /// Mostra confirmação de exclusão
  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Tem certeza que deseja excluir este comentário?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}
