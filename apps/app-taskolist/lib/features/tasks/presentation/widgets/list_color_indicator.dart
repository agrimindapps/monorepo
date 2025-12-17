import 'package:flutter/material.dart';
import '../../../../core/theme/list_colors.dart';

class ListColorIndicator extends StatelessWidget {
  final String colorKey;
  final double size;
  final bool showBorder;

  const ListColorIndicator({
    super.key,
    required this.colorKey,
    this.size = 12.0,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ListColors.getColor(colorKey);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }
}
