import 'package:flutter/material.dart';

import '../../../../core/widgets/unified_image_widget.dart';

/// Legacy wrapper for OptimizedImageWidget - now uses UnifiedImageWidget
/// Kept for backward compatibility during transition
class OptimizedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? base64Image;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enablePreloading;
  final int? cacheKey; // For ListView optimization

  const OptimizedImageWidget({
    super.key,
    this.imageUrl,
    this.base64Image,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enablePreloading = true,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedImageWidget(
      imageBase64: base64Image,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      enablePreloading: enablePreloading,
      cacheKey: cacheKey,
      keepAlive: true,
    );
  }
}
