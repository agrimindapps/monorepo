// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/praga_cultura_item_model.dart';
import '../../utils/praga_cultura_constants.dart';
import '../../utils/praga_cultura_utils.dart';
import 'animated_scale_item.dart';
import 'image_with_loader.dart';

class PragaGridItem extends StatelessWidget {
  final PragaCulturaItemModel item;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const PragaGridItem({
    super.key,
    required this.item,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleItem(
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: Colors.green.withValues(
              alpha: 0.15), // Fundo verde leve para visualização dos limites
          borderRadius:
              BorderRadius.circular(PragaCulturaConstants.borderRadius),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(PragaCulturaConstants.smallPadding),
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
      ),
    );
  }

  Widget _buildImage() {
    return ImageWithLoader(
      imageUrl: item.imagePath,
      width: double.infinity,
      height: 100, // Altura fixa mais compacta
      borderRadius: BorderRadius.circular(PragaCulturaConstants.smallPadding),
      isDark: isDark,
      errorWidget: Container(
        width: double.infinity,
        height: 100, // Altura fixa mais compacta
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(PragaCulturaConstants.smallPadding),
        ),
        child: Icon(
          PragaCulturaUtils.getIconForPragaType(item.tipoPraga ?? '1'),
          size: 32,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.nomeComum,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: PragaCulturaConstants.largeTextSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.nomeCientifico != null && item.nomeCientifico!.isNotEmpty) ...[
          const SizedBox(height: 4), // Espaçamento reduzido
          Text(
            item.nomeCientifico!,
            style: TextStyle(
              fontSize: PragaCulturaConstants.mediumTextSize,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (item.nomeSecundario != null && item.nomeSecundario!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            item.nomeSecundario!,
            style: TextStyle(
              fontSize: PragaCulturaConstants.smallTextSize,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
