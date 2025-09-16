import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/bovine_entity.dart';

/// Widget de card para exibição de bovinos em listas
/// 
/// Substitui os antigos widgets GetX com design clean e responsivo
/// Inclui imagem, informações principais e ações rápidas
class BovineCardWidget extends StatelessWidget {
  final BovineEntity bovine;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const BovineCardWidget({
    super.key,
    required this.bovine,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com imagem e informações básicas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do bovino
                  _buildBovineImage(context),
                  const SizedBox(width: 12.0),
                  
                  // Informações principais
                  Expanded(
                    child: _buildBovineInfo(context),
                  ),
                  
                  // Menu de ações (se habilitado)
                  if (showActions)
                    _buildActionsMenu(context),
                ],
              ),
              
              // Tags e informações adicionais
              const SizedBox(height: 8.0),
              _buildBovineMetadata(context),
              
              // Status e última atualização
              const SizedBox(height: 8.0),
              _buildStatusInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBovineImage(BuildContext context) {
    const double imageSize = 80.0;
    
    if (bovine.imageUrls.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: bovine.thumbnailUrl ?? bovine.imageUrls.first,
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
          errorWidget: (context, url, error) => _buildDefaultImage(context, imageSize),
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
        Icons.pets,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBovineInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome comum
        Text(
          bovine.commonName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4.0),
        
        // Raça
        Text(
          bovine.breed,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 2.0),
        
        // ID de registro
        Text(
          'ID: ${bovine.registrationId}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 2.0),
        
        // País de origem
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
                bovine.originCountry,
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
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Editar'),
            ],
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

  Widget _buildBovineMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aptidão e sistema de criação
        Row(
          children: [
            _buildChip(
              context,
              bovine.aptitude.displayName,
              Icons.agriculture,
              Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8.0),
            _buildChip(
              context,
              bovine.breedingSystem.displayName,
              Icons.settings,
              Theme.of(context).colorScheme.secondaryContainer,
            ),
          ],
        ),
        
        // Tags (se houver)
        if (bovine.tags.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: bovine.tags.take(3).map((tag) => _buildTag(context, tag)).toList(),
          ),
          if (bovine.tags.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '+${bovine.tags.length - 3} mais',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.0,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status ativo/inativo
        Row(
          children: [
            Icon(
              bovine.isActive ? Icons.check_circle : Icons.cancel,
              size: 16.0,
              color: bovine.isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 4.0),
            Text(
              bovine.isActive ? 'Ativo' : 'Inativo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: bovine.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        // Data de última atualização
        if (bovine.updatedAt != null)
          Text(
            _formatDate(bovine.updatedAt!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget de card compacto para bovinos
/// 
/// Versão simplificada para uso em carrosséis ou listas menores
class CompactBovineCardWidget extends StatelessWidget {
  final BovineEntity bovine;
  final VoidCallback? onTap;

  const CompactBovineCardWidget({
    super.key,
    required this.bovine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Imagem pequena
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: bovine.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: bovine.thumbnailUrl ?? bovine.imageUrls.first,
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _buildDefaultIcon(context),
                      )
                    : _buildDefaultIcon(context),
              ),
              
              const SizedBox(width: 8.0),
              
              // Informações essenciais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bovine.commonName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      bovine.breed,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Indicador de aptidão
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  bovine.aptitude.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Icon(
        Icons.pets,
        size: 24.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}