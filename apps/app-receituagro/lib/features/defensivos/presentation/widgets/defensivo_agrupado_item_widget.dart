import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../models/defensivo_agrupado_item_model.dart';
import '../../models/defensivos_agrupados_category.dart';
import '../../models/defensivos_agrupados_view_mode.dart';

class DefensivoAgrupadoItemWidget extends StatelessWidget {
  final DefensivoAgrupadoItemModel item;
  final DefensivosAgrupadosViewMode viewMode;
  final DefensivosAgrupadosCategory category;
  final bool isDark;
  final VoidCallback onTap;

  const DefensivoAgrupadoItemWidget({
    super.key,
    required this.item,
    required this.viewMode,
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return viewMode.isList 
        ? _buildListItem(context)
        : _buildGridItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: theme.brightness == Brightness.dark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: theme.brightness == Brightness.dark
            ? BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              )
            : BorderSide.none,
      ),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildListContent(),
              ),
              const SizedBox(width: 8),
              _buildTrailingContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: theme.brightness == Brightness.dark ? 4 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: theme.brightness == Brightness.dark
            ? BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              )
            : BorderSide.none,
      ),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 12),
              _buildGridContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getItemColor();
    final icon = item.isDefensivo ? _getDefensivoIcon() : _getCategoryIcon();
    
    return Container(
      width: viewMode.isList ? 40 : 56,
      height: viewMode.isList ? 40 : 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: viewMode.isList ? 18 : 24,
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.displayTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          item.hasCount 
              ? '${item.displayCount} registros'
              : '0 registros',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.displayTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.displaySubtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            item.displaySubtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (item.hasCount) ...[
          const SizedBox(height: 8),
          _buildCountChip(),
        ],
      ],
    );
  }

  Widget _buildTrailingContent() {
    return Icon(
      item.isDefensivo 
          ? Icons.open_in_new_rounded 
          : Icons.chevron_right_rounded,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      size: 24,
    );
  }

  Widget _buildCountChip() {
    final color = _getItemColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        item.displayCount,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }


  Color _getItemColor() {
    // Todos os ícones devem ser verdes como nos mockups
    return const Color(0xFF4CAF50);
  }

  IconData _getDefensivoIcon() {
    return FontAwesomeIcons.shield;
  }

  IconData _getCategoryIcon() {
    return category.icon;
  }
}