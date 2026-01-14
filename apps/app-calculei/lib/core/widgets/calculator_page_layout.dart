import 'package:flutter/material.dart';

import '../theme/adaptive_colors.dart';
import 'app_shell.dart';

/// Layout wrapper for calculator pages
/// 
/// Uses [AppShell] internally for consistent layout across the app.
/// Maintains the same API for backwards compatibility.
class CalculatorPageLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? accentColor;
  final List<Widget>? actions;
  final Widget? bottomWidget;
  final IconData? icon;
  final double maxContentWidth;
  final String? currentCategory;
  
  const CalculatorPageLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.accentColor,
    this.actions,
    this.bottomWidget,
    this.icon,
    this.maxContentWidth = 800,
    this.currentCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveAccentColor = accentColor ?? colors.primary;

    // Apply accent color to theme so child widgets (like cards) pick it up
    final currentTheme = Theme.of(context);
    // Determine appropriate container colors based on brightness
    final isDark = currentTheme.brightness == Brightness.dark;
    final primaryContainer = isDark 
        ? effectiveAccentColor.withValues(alpha: 0.2)
        : effectiveAccentColor.withValues(alpha: 0.1);
    final onPrimaryContainer = isDark
        ? effectiveAccentColor.withValues(alpha: 0.9)
        : effectiveAccentColor.withValues(alpha: 0.9);

    final themeWithAccent = currentTheme.copyWith(
      primaryColor: effectiveAccentColor,
      colorScheme: currentTheme.colorScheme.copyWith(
        primary: effectiveAccentColor,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        // Also update outline/border colors if they use primary
        outline: effectiveAccentColor.withValues(alpha: 0.5),
      ),
      // Update toggle buttons, switches, etc
      toggleButtonsTheme: currentTheme.toggleButtonsTheme.copyWith(
        selectedColor: effectiveAccentColor,
        selectedBorderColor: effectiveAccentColor,
      ),
    );
    
    return Theme(
      data: themeWithAccent,
      child: AppShell(
        pageTitle: title,
        pageSubtitle: subtitle,
        accentColor: effectiveAccentColor,
        pageIcon: icon,
        actions: actions,
        showBackButton: true,
        currentCategory: currentCategory,
        showBackgroundPattern: true,
        child: _buildContent(context, effectiveAccentColor),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, Color accentColor) {
    final colors = context.colors;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calculator container with max width
            Container(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: child,
              ),
            ),
            
            // Bottom widget (additional info, tips, etc)
            if (bottomWidget != null) ...[
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth,
                ),
                child: bottomWidget!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category accent colors for different calculator types
class CalculatorAccentColors {
  static const financial = Color(0xFF2196F3);     // Blue (was Green)
  static const health = Color(0xFFE91E63);        // Pink
  static const construction = Color(0xFFFF9800);  // Orange
  static const agriculture = Color(0xFF8BC34A);   // Light green
  static const pet = Color(0xFF795548);           // Brown
  static const labor = Color(0xFF4CAF50);         // Green (swapped with Financial to avoid duplicate)
  
  /// Get accent color by category name
  static Color fromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'financeiro':
      case 'financial':
        return financial;
      case 'saúde':
      case 'health':
        return health;
      case 'construção':
      case 'construction':
        return construction;
      case 'agricultura':
      case 'agriculture':
        return agriculture;
      case 'pet':
      case 'veterinário':
        return pet;
      case 'trabalhista':
      case 'labor':
        return labor;
      default:
        return financial;
    }
  }
}
