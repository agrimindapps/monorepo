import 'package:flutter/material.dart';

/// Card reutilizável para exibir registros recentes
///
/// Exibe uma seção de categoria com:
/// - Header: Ícone + Título + botão "Ver Todos" (se !isEmpty)
/// - Body: Coluna de itens OU estado vazio
/// - Estado vazio: Ícone + Mensagem + botão "Adicionar Primeiro"
///
/// Usa a cor primária do tema (mesma do header) para ícones e botões,
/// garantindo consistência visual e boa visibilidade em ambos os temas.
class RecentRecordsCard extends StatelessWidget {
  const RecentRecordsCard({
    required this.title,
    required this.icon,
    required this.recordItems,
    required this.onViewAll,
    required this.isEmpty,
    required this.emptyMessage,
    this.onAddFirst,
    this.onAdd,
    @Deprecated('Use theme primary color instead') this.iconColor,
    super.key,
  });

  final String title;
  final IconData icon;
  @Deprecated('Color is now derived from theme primary')
  final Color? iconColor;
  final List<Widget> recordItems;
  final VoidCallback onViewAll;
  final bool isEmpty;
  final String emptyMessage;
  final VoidCallback? onAddFirst;
  final VoidCallback? onAdd;

  /// Returns the accent color for icons and buttons
  /// Uses the theme primary color for consistency with the page header
  Color _getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
    final accentColor = _getAccentColor(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
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
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Title
                  Expanded(
                    child: Text(
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

          // Add button (if onAdd is provided)
          if (onAdd != null) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // View All button (always visible)
          TextButton(
            onPressed: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ver Todos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final accentColor = _getAccentColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: accentColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (onAddFirst != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAddFirst,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Primeiro'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: BorderSide(color: accentColor),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: recordItems,
      ),
    );
  }
}
