// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/defensivo_item_model.dart';
import '../../utils/defensivos_category.dart';
import '../../utils/defensivos_helpers.dart';

class DefensivoListItem extends StatelessWidget {
  final DefensivoItemModel item;
  final bool isDark;
  final DefensivosCategory categoria;
  final VoidCallback onTap;
  final int index;

  const DefensivoListItem({
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
    final secondaryInfo = item.line2;
    final avatarColor = DefensivosHelpers.getAvatarColor(isDark);
    final borderColor = DefensivosHelpers.getBorderColor(isDark);

    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 4),
        leading:
            _buildLeading(itemCount, avatarColor, borderColor, standardGreen),
        title: _buildTitle(),
        subtitle: _buildSubtitle(secondaryInfo),
        trailing: _buildTrailing(standardGreen),
        onTap: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildLeading(int itemCount, Color avatarColor, Color borderColor,
      Color standardGreen) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              DefensivosHelpers.getIconForCategory(categoria),
              color: isDark ? Colors.green.shade300 : standardGreen,
              size: 18,
            ),
          ),
        ),
        if (itemCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: Text(
                itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
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
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSubtitle(String secondaryInfo) {
    return Text(
      secondaryInfo,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildTrailing(Color standardGreen) {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios, size: 14),
      onPressed: onTap,
      color: isDark ? Colors.green.shade300 : standardGreen,
      splashRadius: 20,
      tooltip: 'Ver defensivos',
    );
  }
}
