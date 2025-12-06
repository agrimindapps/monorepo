import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/design_system_components.dart';
import '../providers/livestock_provider.dart';

/// Seção de botões de ação do formulário de bovino
///
/// Responsabilidades:
/// - Botões de cancelar e salvar
/// - Estados de loading diferenciados
/// - Integração com LivestockNotifier
/// - Confirmação de ações destrutivas
/// - Feedback visual consistente
class BovineFormActionButtons extends ConsumerWidget {
  const BovineFormActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
    required this.isEditing,
    this.onDelete,
    this.hasUnsavedChanges = false,
    this.enabled = true,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isEditing;
  final VoidCallback? onDelete;
  final bool hasUnsavedChanges;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(livestockProvider.notifier);
    final isLoading = provider.isCreating ||
                     provider.isUpdating ||
                     provider.isDeleting;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasUnsavedChanges && !isLoading)
              _buildUnsavedChangesIndicator(context),
            Row(
              children: [
                Expanded(
                  child: _buildCancelButton(context, isLoading),
                ),

                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildSaveButton(context, provider, isLoading),
                ),
              ],
            ),
            if (isEditing && onDelete != null) ...[
              const SizedBox(height: 12),
              _buildDeleteButton(context, provider, isLoading),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnsavedChangesIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você tem alterações não salvas',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, bool isLoading) {
    return DSSecondaryButton(
      text: 'Cancelar',
      onPressed: !isLoading && enabled
          ? hasUnsavedChanges
              ? () => _showCancelConfirmation(context)
              : onCancel
          : null,
      icon: Icons.close,
    );
  }

  Widget _buildSaveButton(BuildContext context, LivestockNotifier provider, bool isLoading) {
    String buttonText = isEditing ? 'Salvar' : 'Criar';
    IconData buttonIcon = isEditing ? Icons.save : Icons.add;
    
    if (provider.isCreating) {
      buttonText = 'Criando...';
      buttonIcon = Icons.hourglass_empty;
    } else if (provider.isUpdating) {
      buttonText = 'Salvando...';
      buttonIcon = Icons.hourglass_empty;
    }

    return DSPrimaryButton(
      text: buttonText,
      onPressed: !isLoading && enabled ? onSave : null,
      isLoading: isLoading,
      icon: !isLoading ? buttonIcon : null,
    );
  }

  Widget _buildDeleteButton(BuildContext context, LivestockNotifier provider, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: !isLoading && enabled ? () => _showDeleteConfirmation(context) : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: provider.isDeleting
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Excluir Bovino',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Descartar Alterações?'),
          ],
        ),
        content: const Text(
          'Você tem alterações não salvas. Tem certeza que deseja sair sem salvar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continuar Editando',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tem certeza que deseja excluir este bovino?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Esta ação não pode ser desfeita:',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...[
                    'Todos os dados do bovino serão removidos',
                    'Histórico de atividades será perdido',
                    'Vínculos com outros registros serão quebrados',
                  ].map((warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: Theme.of(context).colorScheme.error,
                          size: 6,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );
  }
}

/// Botões de ação simplificados para uso em outros contextos
class BovineFormSimpleActions extends StatelessWidget {
  const BovineFormSimpleActions({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.isEditing,
    this.isLoading = false,
    this.enabled = true,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isEditing;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DSSecondaryButton(
            text: 'Cancelar',
            onPressed: !isLoading && enabled ? onCancel : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: DSPrimaryButton(
            text: isEditing ? 'Salvar' : 'Criar',
            onPressed: !isLoading && enabled ? onSave : null,
            isLoading: isLoading,
            icon: isEditing ? Icons.save : Icons.add,
          ),
        ),
      ],
    );
  }
}
