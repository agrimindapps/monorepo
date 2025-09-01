import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detalhe_defensivo_provider.dart';
import '../../../comentarios/models/comentario_model.dart';

/// Widget para tab de comentários com restrição premium
/// Responsabilidade única: gerenciar comentários e acesso premium
class ComentariosTabWidget extends StatefulWidget {
  final String defensivoName;

  const ComentariosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  State<ComentariosTabWidget> createState() => _ComentariosTabWidgetState();
}

class _ComentariosTabWidgetState extends State<ComentariosTabWidget> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        // Para usuários free, mostra apenas o card premium centralizado
        if (!provider.isPremium) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildPremiumRestrictionCard(context),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Espaço para bottom navigation
            ],
          );
        }

        // Para usuários premium, mostra campo de comentário + lista
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add new comment section
              _buildAddCommentSection(context, provider),
              const SizedBox(height: 24),

              // Comments list
              if (provider.isLoadingComments)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.comentarios.isNotEmpty)
                _buildCommentsList(provider),

              const SizedBox(height: 80), // Espaço para bottom navigation
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumRestrictionCard(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, size: 48, color: Color(0xFFFF9800)),
          const SizedBox(height: 16),
          const Text(
            'Comentários não disponíveis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Este recurso está disponível apenas para assinantes do app.',
            style: TextStyle(fontSize: 16, color: Color(0xFFBF360C)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final provider = context.read<DetalheDefensivoProvider>();
                // Navegar para premium através do service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecionando para plano premium...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Desbloquear Agora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection(BuildContext context, DetalheDefensivoProvider provider) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.comment_outlined,
                  color: Color(0xFF4CAF50),
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
                hintText: 'Compartilhe sua experiência sobre este defensivo...',
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
                  onPressed: () {
                    _commentController.clear();
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addComment(provider),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(DetalheDefensivoProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.comentarios.length,
      itemBuilder: (context, index) {
        final comentario = provider.comentarios[index];
        return _buildCommentCard(comentario, provider);
      },
    );
  }

  Widget _buildCommentCard(ComentarioModel comentario, DetalheDefensivoProvider provider) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(comentario.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        _deleteComment(comentario.id, provider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anônimo',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(comentario.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comentario.conteudo,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addComment(DetalheDefensivoProvider provider) async {
    final content = _commentController.text.trim();

    if (!provider.isValidContent(content)) {
      _showMessage(
        context,
        provider.getValidationErrorMessage(),
        isError: true,
      );
      return;
    }

    if (!provider.canAddComentario(provider.comentarios.length)) {
      _showMessage(
        context,
        'Limite de comentários atingido. Assine o plano premium para mais.',
        color: Colors.orange,
      );
      return;
    }

    final success = await provider.addComment(content);

    if (success) {
      _commentController.clear();
      _showMessage(
        context,
        'Comentário adicionado com sucesso!',
        color: Colors.green,
      );
    } else {
      _showMessage(
        context,
        'Erro ao adicionar comentário',
        isError: true,
      );
    }
  }

  Future<void> _deleteComment(String commentId, DetalheDefensivoProvider provider) async {
    final success = await provider.deleteComment(commentId);

    if (success) {
      _showMessage(context, 'Comentário excluído');
    } else {
      _showMessage(
        context,
        'Erro ao excluir comentário',
        isError: true,
      );
    }
  }

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

  void _showMessage(BuildContext context, String message, {bool isError = false, Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? (isError ? Colors.red : null),
      ),
    );
  }

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