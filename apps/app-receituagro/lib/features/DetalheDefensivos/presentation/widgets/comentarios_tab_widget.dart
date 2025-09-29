import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../providers/detalhe_defensivo_provider.dart';

/// Widget para tab de comentários com restrição premium
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
    return provider.Consumer<DetalheDefensivoProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Para usuários premium, mostra campo de comentário + lista
              if (provider.isPremium) ...[
                // Add new comment section (campo de cadastro)
                _buildAddCommentSection(provider),
                const SizedBox(height: 24),
              ],
              
              // Content
              provider.isPremium 
                ? _buildPremiumContent(provider)
                : _buildFreeContent(),
                
              const SizedBox(height: 80), // Espaço para bottom navigation
            ],
          ),
        );
      },
    );
  }

  /// Constrói seção para adicionar comentário
  Widget _buildAddCommentSection(DetalheDefensivoProvider provider) {
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
                  onPressed: () => _commentController.clear(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addComment(provider),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            // Exibe erro se houver
            if (provider.errorMessage.isNotEmpty) ...[
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
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 14),
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

  Widget _buildPremiumContent(DetalheDefensivoProvider provider) {
    // Comments list (sem estado vazio)
    if (provider.isLoadingComments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.comentarios.isEmpty) {
      // Não mostra mais estado vazio aqui, pois usuários podem adicionar comentários acima
      return const SizedBox.shrink();
    }

    return _buildCommentsList(provider);
  }

  /// Constrói lista de comentários
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

  /// Constrói card de comentário individual
  Widget _buildCommentCard(dynamic comentario, DetalheDefensivoProvider provider) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key((comentario.id ?? comentario.hashCode).toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) => provider.deleteComment((comentario.id ?? '').toString()),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (comentario.ferramenta?.toString()?.split(' - ')?.isNotEmpty == true 
                              ? comentario.ferramenta.toString().split(' - ').first 
                              : widget.defensivoName),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          (comentario.ferramenta?.toString()?.split(' - ')?.length ?? 0) > 1
                              ? comentario.ferramenta.toString().split(' - ')[1]
                              : '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(comentario.createdAt is DateTime ? comentario.createdAt as DateTime : DateTime.now()),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (comentario.conteudo ?? comentario.titulo ?? '').toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeContent() {
    return Center(
      child: Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Comentários Premium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesse comentários da comunidade e compartilhe suas experiências',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to subscription
                },
                child: const Text('Upgrade para Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Adiciona comentário
  Future<void> _addComment(DetalheDefensivoProvider provider) async {
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

    final success = await provider.addComment(content);
    if (success) {
      _commentController.clear();
      // Mostra sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Erro já é gerenciado pelo provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : 'Erro ao adicionar comentário'),
            backgroundColor: Colors.red,
          ),
        );
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
          content: const Text('Tem certeza que deseja excluir este comentário?'),
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