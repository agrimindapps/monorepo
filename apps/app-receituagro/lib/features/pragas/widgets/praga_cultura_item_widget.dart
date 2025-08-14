import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/praga_cultura_item_model.dart';
import '../models/praga_view_mode.dart';

class PragaCulturaItemWidget extends StatelessWidget {
  final PragaCulturaItemModel praga;
  final PragaViewMode viewMode;
  final bool isDark;
  final VoidCallback onTap;

  const PragaCulturaItemWidget({
    super.key,
    required this.praga,
    required this.viewMode,
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(48),
              const SizedBox(width: 16),
              Expanded(
                child: _buildListContent(),
              ),
              const SizedBox(width: 12),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(56),
              const SizedBox(height: 12),
              _buildGridContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(double size) {
    final color = _getTypeColor();
    final icon = _getTypeIcon();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: color,
          size: size * 0.4,
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
          praga.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.displaySecondaryName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            praga.displaySecondaryName,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeChip(),
            if (praga.categoria?.isNotEmpty == true) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _buildCategoryChip(),
              ),
            ],
          ],
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
          praga.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.displaySecondaryName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            praga.displaySecondaryName,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        _buildTypeChip(),
      ],
    );
  }

  Widget _buildTypeChip() {
    final color = _getTypeColor();
    
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
        praga.displayType,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey.shade700.withValues(alpha: 0.5)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        praga.categoria!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      size: 24,
    );
  }

  Color _getTypeColor() {
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935); // Vermelho
      case '2': // Doenças
        return const Color(0xFFFF9800); // Laranja
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF757575); // Cinza
    }
  }

  IconData _getTypeIcon() {
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.exclamationTriangle;
    }
  }
}