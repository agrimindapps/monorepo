import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../notifiers/catalog_publisher_notifier.dart';

/// Widget de botão para publicar catálogo no Firebase Storage
/// 
/// Exibe:
/// - Botão de publicação
/// - Loading state
/// - Última data de publicação
/// - Mensagens de erro/sucesso
class PublishCatalogButton extends ConsumerWidget {
  const PublishCatalogButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogPublisherProvider);
    final notifier = ref.read(catalogPublisherProvider.notifier);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Publicar Catálogo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Descrição
            Text(
              'Atualiza o catálogo de bovinos e equinos para todos os usuários.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão de publicação
            ElevatedButton.icon(
              onPressed: state.isPublishing 
                  ? null 
                  : () => _showConfirmDialog(context, notifier),
              icon: state.isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                state.isPublishing 
                    ? 'Publicando...' 
                    : 'Publicar Agora',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Última publicação
            if (state.lastPublished != null)
              _buildInfoRow(
                context,
                icon: Icons.check_circle,
                iconColor: Colors.green,
                text: 'Última publicação: ${_formatDateTime(state.lastPublished!)}',
              ),
            
            // Mensagem de sucesso
            if (state.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildMessageCard(
                  context,
                  message: state.successMessage!,
                  isError: false,
                  onDismiss: () => notifier.clearMessages(),
                ),
              ),
            
            // Mensagem de erro
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildMessageCard(
                  context,
                  message: state.errorMessage!,
                  isError: true,
                  onDismiss: () => notifier.clearMessages(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageCard(
    BuildContext context, {
    required String message,
    required bool isError,
    required VoidCallback onDismiss,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError 
            ? Colors.red.withOpacity(0.1) 
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red[900] : Colors.green[900],
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showConfirmDialog(
    BuildContext context,
    CatalogPublisherNotifier notifier,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.blue),
            SizedBox(width: 8),
            Text('Publicar Catálogo'),
          ],
        ),
        content: const Text(
          'Isso irá atualizar o catálogo de bovinos e equinos '
          'para todos os usuários do app.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Publicar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await notifier.publishCatalog();
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy \'às\' HH:mm');
    return formatter.format(dateTime);
  }
}
