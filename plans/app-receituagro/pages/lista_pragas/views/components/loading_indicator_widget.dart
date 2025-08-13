// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final String pragaType;
  final bool isDark;

  const LoadingIndicatorWidget({
    super.key,
    required this.pragaType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary to isolate loading animation repaints
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: PragaConstants.extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.green.shade300 : Colors.green.shade600,
              ),
              strokeWidth: PragaConstants.loadingStrokeWidth,
            ),
            const SizedBox(height: PragaConstants.largeSpacing),
            Text(
              PragaUtils.getLoadingMessage(pragaType),
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: PragaConstants.mediumTextSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
