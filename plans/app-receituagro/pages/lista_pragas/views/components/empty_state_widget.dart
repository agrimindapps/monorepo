// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';

class EmptyStateWidget extends StatelessWidget {
  final String pragaType;
  final bool isDark;

  const EmptyStateWidget({
    super.key,
    required this.pragaType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PragaConstants.emptyStateElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PragaConstants.borderRadius),
      ),
      color: isDark ? PragaConstants.darkContainerColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(PragaConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PragaUtils.getEmptyStateIcon(pragaType),
              size: PragaConstants.largeIconSize,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: PragaConstants.largeSpacing),
            Text(
              PragaUtils.getEmptyStateMessage(pragaType),
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: PragaConstants.largeTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PragaConstants.smallSpacing * 2),
            Text(
              PragaConstants.emptyStateMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                fontSize: PragaConstants.mediumTextSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
