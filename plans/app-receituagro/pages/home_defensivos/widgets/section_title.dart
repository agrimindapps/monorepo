// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/layout_constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: LayoutConstants.sectionTitleVerticalPadding, 
          horizontal: LayoutConstants.sectionTitleHorizontalPadding),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green[ColorConstants.greenShade700],
              borderRadius: BorderRadius.circular(LayoutConstants.smallBorderRadius),
            ),
            width: LayoutConstants.sectionTitleIndicatorWidth,
            height: LayoutConstants.sectionTitleIndicatorHeight,
          ),
          const SizedBox(width: LayoutConstants.defaultSpacing),
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConstants.largeFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green[ColorConstants.greenShade800],
              letterSpacing: SizeConstants.defaultLetterSpacing,
            ),
          ),
          const SizedBox(width: LayoutConstants.defaultSpacing),
          Expanded(
            child: Container(
              height: LayoutConstants.sectionTitleDividerHeight,
              color: Colors.green[ColorConstants.greenShade200],
            ),
          ),
          const SizedBox(width: LayoutConstants.defaultSpacing),
          Icon(
            icon,
            size: LayoutConstants.sectionTitleIconSize,
            color: Colors.green[ColorConstants.greenShade700],
          ),
        ],
      ),
    );
  }
}
