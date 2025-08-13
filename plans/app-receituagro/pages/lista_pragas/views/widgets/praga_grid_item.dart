// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/praga_item_model.dart';
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';

class PragaGridItem extends StatelessWidget {
  final PragaItemModel praga;
  final String pragaType;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const PragaGridItem({
    super.key,
    required this.praga,
    required this.pragaType,
    required this.isDark,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(
            alpha: 0.15), // Fundo verde leve para visualização dos limites
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
              _buildImage(),
              const SizedBox(height: 6), // Espaçamento reduzido
              _buildInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String imageUrl = PragaUtils.getImagePath(praga.nomeImagem);

    final Widget errorWidget = Container(
      width: double.infinity,
      height: 100, // Altura fixa mais compacta
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Icon(
        PragaUtils.getIconForPragaType(pragaType),
        size: 32,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      ),
    );

    if (imageUrl.isEmpty) {
      return errorWidget;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      child: SizedBox(
        width: double.infinity,
        height: 100, // Altura fixa mais compacta
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
      children: [
        Text(
          praga.nomeComum.trim(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: PragaConstants.mediumTextSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.nomeSecundario != null && praga.nomeSecundario!.trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            praga.nomeSecundario!.trim(),
            style: TextStyle(
              fontSize: PragaConstants.smallTextSize,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (praga.nomeCientifico != null && praga.nomeCientifico!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            praga.nomeCientifico!.trim(),
            style: TextStyle(
              fontSize: PragaConstants.smallTextSize,
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
}
