// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';
import '../../lista_pragas/utils/praga_constants.dart';
import '../../lista_pragas/utils/praga_utils.dart';

class PragaFavoritoGridItem extends StatelessWidget {
  final FavoritoPragaModel praga;
  final bool isDark;
  final VoidCallback onTap;

  const PragaFavoritoGridItem({
    super.key,
    required this.praga,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius:
            BorderRadius.circular(PragaConstants.borderRadius),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(PragaConstants.smallPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _buildImage(),
              ),
              const SizedBox(height: PragaConstants.itemSpacingHeight),
              Expanded(
                flex: 2,
                child: _buildInfo(),
              ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Center(
        child: Icon(
          FontAwesome.bug_solid, // Ícone padrão para pragas
          size: 32,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );

    if (imageUrl.isEmpty || praga.nomeCientifico.isEmpty) {
      return errorWidget;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      child: SizedBox(
        width: double.infinity,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            praga.nomeComum,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: PragaConstants.mediumTextSize,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (praga.nomeCientifico.isNotEmpty) ...[
          const SizedBox(height: PragaConstants.itemSpacingHeight),
          Flexible(
            child: Text(
              praga.nomeCientifico,
              style: TextStyle(
                fontSize: PragaConstants.smallTextSize,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
