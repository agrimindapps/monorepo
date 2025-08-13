// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/praga_cultura_item_model.dart';
import '../../utils/praga_cultura_constants.dart';
import '../../utils/praga_cultura_utils.dart';
import 'animated_scale_item.dart';
import 'image_with_loader.dart';

class PragaListItem extends StatelessWidget {
  final PragaCulturaItemModel item;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const PragaListItem({
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
        margin: const EdgeInsets.symmetric(
            vertical: PragaCulturaConstants.smallSpacing),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
          borderRadius:
              BorderRadius.circular(PragaCulturaConstants.borderRadius),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(PragaCulturaConstants.mediumPadding),
            child: Row(
              children: [
                _buildImage(),
                const SizedBox(width: PragaCulturaConstants.largeSpacing),
                Expanded(child: _buildInfo()),
                _buildTrailingIcon(),
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
      width: PragaCulturaConstants.imageSize - 12,
      height: PragaCulturaConstants.imageSize - 12,
      borderRadius: BorderRadius.circular(PragaCulturaConstants.smallPadding),
      isDark: isDark,
      errorWidget: Container(
        width: PragaCulturaConstants.imageSize - 12,
        height: PragaCulturaConstants.imageSize - 12,
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
          const SizedBox(height: 2),
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
          const SizedBox(height: 1),
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

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      size: PragaCulturaConstants.tabIconSize,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    );
  }
}
