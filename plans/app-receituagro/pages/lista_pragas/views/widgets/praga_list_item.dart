// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/praga_item_model.dart';
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';

class PragaListItem extends StatelessWidget {
  final PragaItemModel praga;
  final String pragaType;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const PragaListItem({
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
      margin: const EdgeInsets.symmetric(
          vertical: PragaConstants.listItemSpacing),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : Colors.white,
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
    final String imageUrl = PragaUtils.getImagePath(praga.nomeImagem);
    
    final Widget errorWidget = Container(
      width: PragaConstants.imageSize - 12,
      height: PragaConstants.imageSize - 12,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      ),
      child: Icon(
        PragaUtils.getIconForPragaType(pragaType),
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: 32,
      ),
    );

    if (imageUrl.isEmpty) {
      return errorWidget;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(PragaConstants.smallPadding),
      child: Image.asset(
        imageUrl,
        width: PragaConstants.imageSize - 12,
        height: PragaConstants.imageSize - 12,
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
          praga.nomeComum.trim(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: PragaConstants.largeTextSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.nomeSecundario != null && praga.nomeSecundario!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            praga.nomeSecundario!.trim(),
            style: TextStyle(
              fontSize: PragaConstants.mediumTextSize,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (praga.nomeCientifico != null && praga.nomeCientifico!.trim().isNotEmpty) ...[
          const SizedBox(height: 1),
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

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      size: PragaConstants.iconSize,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    );
  }
}
