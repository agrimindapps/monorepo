import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';

/// Reusable card component for displaying recent records
///
/// Displays a category section with:
/// - Header: Icon + Title + "Ver Todos" button (if !isEmpty)
/// - Body: Column of record items OR empty state
/// - Empty state: Icon + Message + "Adicionar Primeiro" button
class RecentRecordsCard extends StatelessWidget {
  const RecentRecordsCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.recordItems,
    required this.onViewAll,
    required this.isEmpty,
    required this.emptyMessage,
    this.onAddFirst,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> recordItems;
  final VoidCallback onViewAll;
  final bool isEmpty;
  final String emptyMessage;
  final VoidCallback? onAddFirst;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GasometerDesignTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),

          // Body (records or empty state)
          if (isEmpty)
            _buildEmptyState(context)
          else
            _buildRecordsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GasometerDesignTokens.spacingLg),
      child: Row(
        children: [
          // Icon + Title (clickable area)
          Expanded(
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: GasometerDesignTokens.spacingMd),

                  // Title
                  Expanded(
                    child: SemanticText.heading(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // View All button (always visible)
          SemanticButton.icon(
            semanticLabel: 'Ver todos os registros de $title',
            onPressed: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ver Todos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GasometerDesignTokens.spacingLg,
        vertical: GasometerDesignTokens.spacingXxl,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: GasometerDesignTokens.spacingLg),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (onAddFirst != null) ...[
              const SizedBox(height: GasometerDesignTokens.spacingLg),
              OutlinedButton.icon(
                onPressed: onAddFirst,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Primeiro'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: iconColor,
                  side: BorderSide(color: iconColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GasometerDesignTokens.spacingMd),
      child: Column(
        children: recordItems,
      ),
    );
  }
}
