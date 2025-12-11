import 'package:flutter/material.dart';

/// Banner widget that displays "Coming Soon" status
/// Shows at the top of the promotional page when the app is not yet launched
class PromoComingSoonBanner extends StatelessWidget {
  /// The label to display (e.g., "Em Breve")
  final String label;

  /// Optional additional message below the label
  final String? message;

  /// Style configuration for the banner
  final ComingSoonBannerStyle style;

  const PromoComingSoonBanner({
    required this.label,
    this.message,
    this.style = const ComingSoonBannerStyle(),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: style.padding,
      decoration: style.decoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                color: style.iconColor,
                size: style.iconSize,
              ),
              SizedBox(width: style.spacing),
              Text(label, style: style.labelStyle),
            ],
          ),
          if (message != null) ...[
            SizedBox(height: style.spacing),
            Text(
              message!,
              style: style.messageStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Style configuration for the coming soon banner
class ComingSoonBannerStyle {
  /// Padding inside the banner
  final EdgeInsets padding;

  /// Decoration for the banner background
  final BoxDecoration decoration;

  /// Icon color
  final Color iconColor;

  /// Icon size
  final double iconSize;

  /// Spacing between icon and text
  final double spacing;

  /// Style for the main label
  final TextStyle labelStyle;

  /// Style for the optional message
  final TextStyle messageStyle;

  const ComingSoonBannerStyle({
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.decoration = const BoxDecoration(
      color: Color(0xFFFFF3E0),
      border: Border(bottom: BorderSide(color: Color(0xFFFF9800), width: 3)),
    ),
    this.iconColor = const Color(0xFFFF6F00),
    this.iconSize = 24,
    this.spacing = 12,
    this.labelStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color(0xFFE65100),
    ),
    this.messageStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFFBF360C),
      fontWeight: FontWeight.w500,
    ),
  });
}
