// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../models/defensivo_model.dart';
import '../../utils/defensivos_constants.dart';

class DefensivoListItem extends StatelessWidget {
  final DefensivoModel defensivo;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const DefensivoListItem({
    super.key,
    required this.defensivo,
    required this.isDark,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: DefensivosConstants.listItemHeight,
        child: ListTile(
          dense: false,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(
              DefensivosConstants.listItemContentPaddingStart,
              0,
              DefensivosConstants.listItemContentPaddingEnd,
              0),
          leading: _buildLeading(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: _buildTrailing(),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
          isThreeLine: true,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return CircleAvatar(
      backgroundColor:
          isDark ? Colors.green.withValues(alpha: 0.16) : Colors.green.shade100,
      foregroundColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
      child: Icon(
        FontAwesome.leaf_solid,
        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        size: DefensivosConstants.leadingIconSize,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Text(
        defensivo.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: DefensivosConstants.titleFontSize,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          defensivo.displayIngredient,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: DefensivosConstants.subtitleFontSize,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (defensivo.displayClass.trim().isNotEmpty &&
                defensivo.displayClass.trim().toLowerCase() !=
                    'não especificado') ...[
              Icon(
                FontAwesome.tag_solid,
                size: DefensivosConstants.tagIconSize,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
              const SizedBox(width: DefensivosConstants.smallSpacing),
              Text(
                defensivo.displayClass,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: DefensivosConstants.tagFontSize,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios,
          size: DefensivosConstants.trailingIconSize),
      onPressed: onTap,
      color: isDark ? Colors.green.shade300 : Colors.green.shade700,
      tooltip: 'Ver detalhes',
      splashRadius: DefensivosConstants.splashRadius,
    );
  }
}
