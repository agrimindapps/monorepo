// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';
import '../../lista_pragas/utils/praga_constants.dart';
import '../../lista_pragas/utils/praga_utils.dart';

class PragaFavoritoListItem extends StatelessWidget {
  final FavoritoPragaModel praga;
  final bool isDark;
  final VoidCallback onTap;

  const PragaFavoritoListItem({
    super.key,
    required this.praga,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 1), // Reduzido ainda mais de 3 para 1
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(PragaConstants.borderRadius),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PragaConstants.mediumPadding),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: PragaConstants.mediumSpacing + PragaConstants.spacingAdjustment),
              Expanded(child: _buildInfo()),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Construir o path da imagem usando nomeCientifico + .jpg
    final String imageUrl = PragaUtils.getImagePath(praga.nomeCientifico);
    
    final Widget errorWidget = Container(
      width: 52, // Reduzido de 60 para 52
      height: 52, // Reduzido de 60 para 52
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Icon(
        FontAwesome.bug_solid, // Ícone padrão para pragas
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: 32,
      ),
    );

    if (imageUrl.isEmpty || praga.nomeCientifico.isEmpty) {
      return errorWidget;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      child: Image.asset(
        imageUrl,
        width: 52, // Reduzido de 60 para 52
        height: 52, // Reduzido de 60 para 52
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          praga.nomeComum,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14, // Reduzido de PragaConstants.largeTextSize (16) para 14
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.nomeCientifico.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            praga.nomeCientifico,
            style: TextStyle(
              fontSize: 11, // Reduzido de PragaConstants.mediumTextSize (13) para 11
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      size: 16, // Menor que PragaConstants.iconSize
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    );
  }
}
