import 'package:flutter/material.dart';
import '../../domain/entities/item_master_entity.dart';

/// Card widget displaying an ItemMaster
/// Shows item icon/photo, name, category badge, usage count, and actions
class ItemMasterCard extends StatelessWidget {
  final ItemMasterEntity itemMaster;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemMasterCard({
    super.key,
    required this.itemMaster,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon/Photo header
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Center(
                child: itemMaster.hasPhoto
                    ? Image.network(
                        itemMaster.photoUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _buildDefaultIcon(theme),
                      )
                    : _buildDefaultIcon(theme),
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      itemMaster.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(itemMaster.category),
                            size: 12,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              itemMaster.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Usage count
                    Row(
                      children: [
                        Icon(
                          Icons.replay,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${itemMaster.usageCount}x usado',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Price estimate (if available)
                    if (itemMaster.hasPrice) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: colorScheme.secondary,
                          ),
                          Text(
                            'R\$ ${itemMaster.estimatedPrice!.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            if (onEdit != null || onDelete != null)
              OverflowBar(
                alignment: MainAxisAlignment.start,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      tooltip: 'Editar',
                      iconSize: 20,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Remover',
                      iconSize: 20,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build default icon when no photo is available
  Widget _buildDefaultIcon(ThemeData theme) {
    return Icon(
      _getCategoryIcon(itemMaster.category),
      size: 48,
      color: theme.colorScheme.onPrimaryContainer,
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'compras':
        return Icons.shopping_cart;
      case 'mercado':
        return Icons.local_grocery_store;
      case 'farmacia':
        return Icons.local_pharmacy;
      case 'higiene':
        return Icons.soap;
      case 'limpeza':
        return Icons.cleaning_services;
      case 'trabalho':
        return Icons.work;
      case 'lazer':
        return Icons.sports_esports;
      default:
        return Icons.inventory_2;
    }
  }
}
