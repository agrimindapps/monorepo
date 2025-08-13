// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../config/ui_constants.dart';
import '../../models/defensivo_item_model.dart';
import '../../utils/defensivos_category.dart';
import '../../utils/defensivos_helpers.dart';

class DefensivoGridItem extends StatelessWidget {
  final DefensivoItemModel item;
  final bool isDark;
  final DefensivosCategory categoria;
  final VoidCallback onTap;
  final int index;

  const DefensivoGridItem({
    super.key,
    required this.item,
    required this.isDark,
    required this.categoria,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final standardGreen = DefensivosHelpers.getStandardGreen();
    final itemCount = item.itemCount;

    return Card(
      elevation: 0,
      color: isDark
          ? standardGreen.withValues(alpha: AlphaConstants.darkModeBackground)
          : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.smallBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.smallBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.mediumPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIcon(itemCount, standardGreen),
              const SizedBox(height: UiConstants.verticalSpacing),
              _buildTitle(),
              if (item.line2.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    item.line2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ),
              if (itemCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '$itemCount registro${itemCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int itemCount, Color standardGreen) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          DefensivosHelpers.getIconForCategory(categoria),
          size: UiConstants.extraLargeIconSize,
          color: isDark ? Colors.green.shade300 : standardGreen,
        ),
        if (itemCount > 0)
          Positioned(
            top: UiConstants.gridBadgeOffset,
            right: UiConstants.gridBadgeOffset,
            child: Container(
              padding: const EdgeInsets.all(UiConstants.badgePadding),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: UiConstants.extraSmallFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      item.line1,
      maxLines: UiConstants.maxTitleLines,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: UiConstants.bodyFontSize,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
      ),
    );
  }
}
