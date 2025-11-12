import 'package:flutter/material.dart';

import '../../../../core/widgets/unified_image_widget.dart';

/// @deprecated Use UnifiedImageWidget directly. Kept for backward compatibility.
class OptimizedPlantImageWidget extends StatelessWidget {
  final String? imageBase64;
  final List<String> imageUrls;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedPlantImageWidget({
    super.key,
    this.imageBase64,
    this.imageUrls = const [],
    this.size = 80.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedImageWidget.plant(
      imageBase64: imageBase64,
      imageUrls: imageUrls,
      size: size,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
