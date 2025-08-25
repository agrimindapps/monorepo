// Flutter imports:
import 'package:flutter/material.dart';

class ImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isDark;

  const ImageWithLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualIsDark = isDark || theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: actualIsDark ? Colors.grey.shade800 : Colors.grey.shade200,
        child: Stack(
          children: [
            Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return errorWidget ?? _buildDefaultErrorWidget(actualIsDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget(bool isDark) {
    return ColoredBox(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }
}
