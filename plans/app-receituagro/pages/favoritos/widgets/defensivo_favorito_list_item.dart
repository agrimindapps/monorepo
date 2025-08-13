// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';

/// Widget específico para itens de defensivos favoritos em ListView
/// Usa o mesmo estilo da lista_defensivos para consistência visual
class DefensivoFavoritoListItem extends StatelessWidget {
  final FavoritoDefensivoModel defensivo;
  final VoidCallback onTap;
  final bool isDark;
  final int index;

  const DefensivoFavoritoListItem({
    super.key,
    required this.defensivo,
    required this.onTap,
    this.isDark = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Hero(
        tag: 'favorito-defensivo-${defensivo.id}',
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 60.0, // Same as DefensivosConstants.listItemHeight
            child: ListTile(
              dense: false,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              leading: _buildLeading(),
              title: _buildTitle(),
              subtitle: _buildSubtitle(),
              trailing: _buildTrailing(),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
              isThreeLine: true,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
      child: Icon(
        FontAwesome.leaf_solid,
        color: isDark ? Colors.green.shade300 : Colors.green.shade700,
        size: 18.0, // Same as DefensivosConstants.leadingIconSize
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Text(
        defensivo.nomeComum,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.0, // Same as DefensivosConstants.titleFontSize
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
          defensivo.ingredienteAtivo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.0, // Same as DefensivosConstants.subtitleFontSize
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios,
          size: 14.0), // Same as DefensivosConstants.trailingIconSize
      onPressed: onTap,
      color: isDark ? Colors.green.shade300 : Colors.green.shade700,
      tooltip: 'Ver detalhes',
      splashRadius: 20.0, // Same as DefensivosConstants.splashRadius
    );
  }
}
