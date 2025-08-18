import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/models/pragas_hive.dart';
import '../../../core/extensions/pragas_hive_extension.dart';
import '../models/praga_view_mode.dart';

class PragaItemWidget extends StatelessWidget {
  final PragasHive praga;
  final PragaViewMode viewMode;
  final bool isDark;
  final VoidCallback onTap;

  const PragaItemWidget({
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
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContent(),
              ),
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
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 12),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getTypeColor();
    final icon = _getTypeIcon();

    return Container(
      width: viewMode.isList ? 48 : 56,
      height: viewMode.isList ? 48 : 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: color,
          size: viewMode.isList ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: viewMode.isList 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          praga.displayName,
          style: TextStyle(
            fontSize: viewMode.isList ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: viewMode.isList ? TextAlign.start : TextAlign.center,
          maxLines: viewMode.isList ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.displaySecondaryName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            praga.displaySecondaryName,
            style: TextStyle(
              fontSize: viewMode.isList ? 14 : 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: viewMode.isList ? TextAlign.start : TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTypeColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            praga.displayType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTypeColor(),
            ),
          ),
        ),
      ],
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