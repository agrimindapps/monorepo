// Flutter imports:
import 'package:flutter/material.dart';

/// A reusable widget for displaying month information with consistent styling.
/// 
/// This widget provides a unified approach to displaying month information
/// across all pages in the pet management module. It supports different
/// visual styles, theme awareness, and responsive design.
/// 
/// Features:
/// - Multiple display styles (card, gradient, chip)
/// - Theme-aware styling with dark mode support
/// - Responsive design with LayoutBuilder
/// - Customizable colors and spacing
/// - Icon support for enhanced visual appeal
/// - Accessibility support
class MonthDisplayWidget extends StatelessWidget {
  /// The formatted month string to display
  final String formattedMonth;
  
  /// The display style for the month widget
  final MonthDisplayStyle style;
  
  /// Optional icon to display alongside the month
  final IconData? icon;
  
  /// Custom background color (overrides theme)
  final Color? backgroundColor;
  
  /// Custom text color (overrides theme)
  final Color? textColor;
  
  /// Custom border color (overrides theme)
  final Color? borderColor;
  
  /// Whether to show shadow
  final bool showShadow;
  
  /// Custom padding
  final EdgeInsets? padding;
  
  /// Custom border radius
  final double? borderRadius;

  const MonthDisplayWidget({
    super.key,
    required this.formattedMonth,
    this.style = MonthDisplayStyle.card,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.showShadow = true,
    this.padding,
    this.borderRadius,
  });

  /// Creates a card-style month display (like despesas_page)
  factory MonthDisplayWidget.card({
    required String formattedMonth,
    Color? backgroundColor,
    Color? textColor,
    bool showShadow = true,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return MonthDisplayWidget(
      formattedMonth: formattedMonth,
      style: MonthDisplayStyle.card,
      backgroundColor: backgroundColor,
      textColor: textColor,
      showShadow: showShadow,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  /// Creates a gradient-style month display (like lembretes_page)
  factory MonthDisplayWidget.gradient({
    required String formattedMonth,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return MonthDisplayWidget(
      formattedMonth: formattedMonth,
      style: MonthDisplayStyle.gradient,
      icon: icon ?? Icons.calendar_month,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  /// Creates a chip-style month display (like vacina_page)
  factory MonthDisplayWidget.chip({
    required String formattedMonth,
    Color? backgroundColor,
    Color? textColor,
    bool showShadow = true,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return MonthDisplayWidget(
      formattedMonth: formattedMonth,
      style: MonthDisplayStyle.chip,
      backgroundColor: backgroundColor,
      textColor: textColor,
      showShadow: showShadow,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case MonthDisplayStyle.card:
        return _buildCardStyle(context);
      case MonthDisplayStyle.gradient:
        return _buildGradientStyle(context);
      case MonthDisplayStyle.chip:
        return _buildChipStyle(context);
    }
  }

  /// Builds the card-style month display
  Widget _buildCardStyle(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: padding ?? const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? theme.cardColor : Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius ?? 8),
            ),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the gradient-style month display
  Widget _buildGradientStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            (backgroundColor ?? theme.primaryColor).withValues(alpha: 0.1),
            (backgroundColor ?? theme.primaryColor).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: borderColor ?? theme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? theme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Text(
            formattedMonth,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor ?? theme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the chip-style month display
  Widget _buildChipStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius ?? 8),
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 20),
            ),
            child: Text(
              formattedMonth,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum defining different display styles for the month widget
enum MonthDisplayStyle {
  /// Card style with theme-aware background and shadow
  card,
  
  /// Gradient style with icon and border
  gradient,
  
  /// Chip style with simple background and shadow
  chip,
}
