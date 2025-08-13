// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';

/// Widget específico para itens de defensivos favoritos em GridView
/// Usa o mesmo estilo da lista_defensivos para consistência visual
class DefensivoFavoritoGridItem extends StatelessWidget {
  final FavoritoDefensivoModel defensivo;
  final VoidCallback onTap;
  final bool isDark;
  final int index;

  const DefensivoFavoritoGridItem({
    super.key,
    required this.defensivo,
    required this.onTap,
    this.isDark = false,
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
          borderRadius: BorderRadius.circular(
              12), // Same as DefensivosConstants.cardBorderRadius
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
              12), // Same as DefensivosConstants.cardBorderRadius
          child: Padding(
            padding: const EdgeInsets.all(
                8.0), // Same as DefensivosConstants.gridItemPadding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    FontAwesome.leaf_solid,
                    color:
                        isDark ? Colors.green.shade300 : Colors.green.shade700,
                    size: 36.0, // Same as DefensivosConstants.gridIconSize
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  defensivo.nomeComum,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.0, // Same as DefensivosConstants.titleFontSize
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade900,
                  ),
                ),
                const SizedBox(
                    height: 4.0), // Same as DefensivosConstants.smallSpacing
                Text(
                  defensivo.ingredienteAtivo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        12.0, // Same as DefensivosConstants.subtitleFontSize
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(
                    height: 4.0), // Same as DefensivosConstants.smallSpacing
              ],
            ),
          ),
        ));
  }
}
