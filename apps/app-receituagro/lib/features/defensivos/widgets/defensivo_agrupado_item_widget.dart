import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/defensivo_agrupado_item_model.dart';
import '../models/defensivos_agrupados_category.dart';
import '../models/defensivos_agrupados_view_mode.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
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
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
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
              ? '${item.displayCount} Registros'
              : item.displaySubtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.hasIngredienteAtivo) ...[
          const SizedBox(height: 6),
          _buildIngredienteChip(),
        ],
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

  Widget _buildIngredienteChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.blue.shade900.withValues(alpha: 0.3)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? Colors.blue.shade700.withValues(alpha: 0.5)
              : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Text(
        item.ingredienteAtivo!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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