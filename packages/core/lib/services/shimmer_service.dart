import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A centralized service for creating standardized shimmer effects.
///
/// This class provides a set of static builders for generating consistent
/// loading animations for different UI components like images, text, and cards.
class ShimmerService {
  /// Returns the base color for the shimmer effect, adapting to the current theme.
  static Color _getBaseColor(BuildContext context, Color? customBaseColor) {
    return customBaseColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!
            : Colors.grey[300]!);
  }

  /// Returns the highlight color for the shimmer effect, adapting to the current theme.
  static Color _getHighlightColor(
    BuildContext context,
    Color? customHighlightColor,
  ) {
    return customHighlightColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[100]!);
  }

  /// Creates a generic shimmer effect with theme-adaptive colors.
  ///
  /// This is the base for all other shimmer builders in this service.
  static Widget fromColors({
    required BuildContext context,
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return Shimmer.fromColors(
      baseColor: _getBaseColor(context, baseColor),
      highlightColor: _getHighlightColor(context, highlightColor),
      period: period,
      child: child,
    );
  }

  /// Creates a shimmer placeholder for an image.
  static Widget imageShimmer({
    required BuildContext context,
    double? width,
    double? height,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Creates a shimmer placeholder for a line of text.
  static Widget textShimmer({
    required BuildContext context,
    double width = double.infinity,
    double height = 16,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Creates a shimmer placeholder for a card component.
  static Widget cardShimmer({
    required BuildContext context,
    double height = 120,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    bool showShadow = true,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final theme = Theme.of(context);
    final placeholderColor = _getHighlightColor(context, highlightColor);

    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a shimmer placeholder for a list of items.
  static Widget listShimmer({
    required BuildContext context,
    int itemCount = 5,
    double itemHeight = 120,
    EdgeInsetsGeometry? itemMargin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => cardShimmer(
        context: context,
        height: itemHeight,
        margin: itemMargin,
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }

  /// Creates a shimmer placeholder for a header or app bar.
  static Widget headerShimmer({
    required BuildContext context,
    double height = 48,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final placeholderColor = _getHighlightColor(context, highlightColor);
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates a circular shimmer placeholder, typically for avatars.
  static Widget circularShimmer({
    required BuildContext context,
    double size = 48,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// A flexible shimmer builder for creating custom shimmer layouts.
  ///
  /// The [builder] should return a widget tree that represents the shape of
  /// the content being loaded.
  static Widget customShimmer({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1500),
  }) {
    return fromColors(
      context: context,
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      child: builder(context),
    );
  }
}