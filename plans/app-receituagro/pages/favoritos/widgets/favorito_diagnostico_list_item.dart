// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../models/favorito_model.dart';
import '../../lista_pragas/utils/praga_constants.dart';
import '../../lista_pragas/utils/praga_utils.dart';

class FavoritoDiagnosticoListItem extends StatelessWidget {
  final FavoritoDiagnosticoModel diagnostico;
  final bool isDark;
  final VoidCallback onTap;

  const FavoritoDiagnosticoListItem({
    super.key,
    required this.diagnostico,
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
    // Usar a imagem da praga do diagnóstico
    final String imageUrl = PragaUtils.getImagePath(diagnostico.nomeCientifico);
    
    final Widget errorWidget = Container(
      width: 52, // Reduzido de 60 para 52
      height: 52, // Reduzido de 60 para 52
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Icon(
        FontAwesome.stethoscope_solid, // Ícone para diagnóstico
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: 32,
      ),
    );

    if (imageUrl.isEmpty || diagnostico.nomeCientifico.isEmpty) {
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
        // Nome do defensivo
        if (diagnostico.nomeComum.isNotEmpty) ...[
          Text(
            diagnostico.nomeComum,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14, // Reduzido de PragaConstants.largeTextSize (16) para 14
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
        // Nome comum da praga
        if (diagnostico.priNome.isNotEmpty) ...[
          Text(
            diagnostico.priNome,
            style: TextStyle(
              fontSize: 11, // Reduzido de PragaConstants.mediumTextSize (13) para 11
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
        // Cultura
        if (diagnostico.cultura != null && diagnostico.cultura!.isNotEmpty) ...[
          Text(
            diagnostico.cultura!,
            style: TextStyle(
              fontSize: 10, // Reduzido de PragaConstants.smallTextSize (12) para 10
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.green.shade400 : Colors.green.shade700,
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
