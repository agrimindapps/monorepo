import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/equine_entity.dart';

/// Widget de card para exibição de equinos em listas
///
/// Implementa o novo design system de cartões de animais
class EquineCardWidget extends StatelessWidget {
  final EquineEntity equine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const EquineCardWidget({
    super.key,
    required this.equine,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Status Strip
            Container(
              height: 4,
              width: double.infinity,
              color: equine.isActive 
                  ? const Color(0xFF8D6E63) // Brown for horses
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEquineImage(context),
                      const SizedBox(width: 16.0),
                      Expanded(child: _buildEquineInfo(context)),
                      if (showActions) _buildActionsMenu(context),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  const Divider(height: 24),
                  _buildEquineMetadata(context),
                  const SizedBox(height: 8.0),
                  _buildStatusInfo(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquineImage(BuildContext context) {
    const double imageSize = 80.0;

    if (equine.imageUrls.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: equine.thumbnailUrl ?? equine.imageUrls.first,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: imageSize,
            height: imageSize,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
          errorWidget: (context, url, error) =>
              _buildDefaultImage(context, imageSize),
        ),
      );
    }

    return _buildDefaultImage(context, imageSize);
  }

  Widget _buildDefaultImage(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        Icons.pets, // Could use a horse icon if available, generic pets for now
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEquineInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          equine.commonName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4.0),
        Text(
          'Registro: ${equine.registrationId.isNotEmpty ? equine.registrationId : "N/A"}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2.0),
        Row(
          children: [
            Icon(
              Icons.public,
              size: 14.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                equine.originCountry,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquineMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildChip(
              context,
              equine.primaryUse.displayName,
              Icons.work_outline,
              Theme.of(context).colorScheme.tertiaryContainer,
              Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 8.0),
            _buildChip(
              context,
              equine.coat.displayName,
              Icons.palette_outlined,
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildChip(
              context,
              equine.temperament.displayName,
              Icons.psychology_outlined,
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.0,
            color: foregroundColor,
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: equine.isActive
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                equine.isActive ? Icons.check_circle : Icons.cancel,
                size: 14.0,
                color: equine.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4.0),
              Text(
                equine.isActive ? 'Ativo' : 'Inativo',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: equine.isActive
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (equine.updatedAt != null)
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                'Atualizado ${_formatDate(equine.updatedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
