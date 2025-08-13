// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../models/defensivo_model.dart';
import '../../utils/defensivos_constants.dart';

class DefensivoGridItem extends StatelessWidget {
  final DefensivoModel defensivo;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const DefensivoGridItem({
    super.key,
    required this.defensivo,
    required this.isDark,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isDark
          ? Colors.green.shade900.withValues(alpha: 0.10)
          : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DefensivosConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(DefensivosConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(DefensivosConstants.gridItemPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  FontAwesome.leaf_solid,
                  color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                  size: DefensivosConstants.gridIconSize,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                defensivo.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: DefensivosConstants.titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: DefensivosConstants.smallSpacing),
              Text(
                defensivo.displayIngredient,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: DefensivosConstants.subtitleFontSize,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: DefensivosConstants.smallSpacing),
              if (defensivo.displayClass.trim().isNotEmpty &&
                  defensivo.displayClass.trim().toLowerCase() !=
                      'não especificado')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesome.tag_solid,
                      size: DefensivosConstants.tagIconSize,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                    const SizedBox(width: DefensivosConstants.smallSpacing),
                    Expanded(
                      child: Text(
                        defensivo.displayClass,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: DefensivosConstants.tagFontSize,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
