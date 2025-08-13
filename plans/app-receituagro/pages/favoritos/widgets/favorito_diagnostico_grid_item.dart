// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';
import '../../lista_pragas/utils/praga_constants.dart';
import '../../lista_pragas/utils/praga_utils.dart';

class FavoritoDiagnosticoGridItem extends StatelessWidget {
  final FavoritoDiagnosticoModel diagnostico;
  final bool isDark;
  final VoidCallback onTap;

  const FavoritoDiagnosticoGridItem({
    super.key,
    required this.diagnostico,
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
    // Usar a imagem da praga do diagnóstico
    final String imageUrl = PragaUtils.getImagePath(diagnostico.nomeCientifico);

    final Widget errorWidget = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Center(
        child: Icon(
          FontAwesome.stethoscope_solid, // Ícone para diagnóstico
          size: 32,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );

    if (imageUrl.isEmpty || diagnostico.nomeCientifico.isEmpty) {
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
        // Nome do defensivo
        if (diagnostico.nomeComum.isNotEmpty) ...[
          Flexible(
            child: Text(
              diagnostico.nomeComum,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: PragaConstants.mediumTextSize,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
        ],
        // Nome comum da praga
        if (diagnostico.priNome.isNotEmpty) ...[
          Flexible(
            child: Text(
              diagnostico.priNome,
              style: TextStyle(
                fontSize: PragaConstants.smallTextSize,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
        ],
        // Cultura
        if (diagnostico.cultura != null && diagnostico.cultura!.isNotEmpty) ...[
          Flexible(
            child: Text(
              diagnostico.cultura!,
              style: TextStyle(
                fontSize: PragaConstants.smallTextSize,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.green.shade400 : Colors.green.shade700,
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
