// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/layout_constants.dart';

class CategoryButton extends StatelessWidget {
  final String count;
  final String title;
  final double width;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;

  const CategoryButton({
    super.key,
    required this.count,
    required this.title,
    required this.width,
    required this.onTap,
    this.icon,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: LayoutConstants.categoryButtonHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(LayoutConstants.categoryButtonBorderRadius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.7),
                  color.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                  LayoutConstants.categoryButtonBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: ColorConstants.shadowOpacity),
                  blurRadius: ElevationConstants.shadowBlurRadius,
                  offset: ElevationConstants.shadowOffset,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -LayoutConstants.defaultBorderRadius - 3,
                  bottom: -LayoutConstants.defaultBorderRadius - 3,
                  child: Icon(
                    icon ?? Icons.circle,
                    size: LayoutConstants.backgroundIconSize,
                    color: Colors.white.withValues(alpha: ColorConstants.lowOpacity),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                      LayoutConstants.categoryButtonPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon ?? Icons.circle,
                            color: Colors.white,
                            size: LayoutConstants.categoryIconSize,
                          ),
                          const SizedBox(width: LayoutConstants.defaultSpacing),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: LayoutConstants.defaultSpacing + 2,
                                vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  LayoutConstants.badgeBorderRadius),
                            ),
                            child: Text(
                              count,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConstants.defaultFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: LayoutConstants.defaultSpacing),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConstants.mediumFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: ElevationConstants.textShadowOffset,
                              blurRadius:
                                  ElevationConstants.shadowBlurRadiusSmall,
                              color: Colors.black
                                  .withValues(alpha: ColorConstants.shadowOpacity),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: LayoutConstants.defaultSpacing,
                  right: LayoutConstants.defaultSpacing,
                  child: Icon(
                    Icons.touch_app,
                    color:
                        Colors.white.withValues(alpha: ColorConstants.mediumOpacity),
                    size: LayoutConstants.smallIconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
