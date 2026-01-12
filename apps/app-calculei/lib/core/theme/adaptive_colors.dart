import 'package:flutter/material.dart';

/// Helper class for theme-adaptive colors
/// Provides consistent colors that adapt to light/dark theme
class AdaptiveColors {
  final BuildContext context;
  
  AdaptiveColors(this.context);
  
  /// Quick access to check if dark mode
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  
  /// Access to the current color scheme
  ColorScheme get scheme => Theme.of(context).colorScheme;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Main background color (scaffold)
  Color get background => scheme.surface;
  
  /// Surface color for cards and containers
  Color get surface => scheme.surfaceContainer;
  
  /// Elevated surface (cards, dialogs)
  Color get surfaceElevated => scheme.surfaceContainerHigh;
  
  /// Sidebar background - elegant gray in light theme, dark blue in dark theme
  Color get sidebar => isDark 
      ? const Color(0xFF16162A) 
      : const Color(0xFFE8E8EC);  // Cinza claro elegante
  
  /// Header/AppBar background
  Color get header => isDark 
      ? const Color(0xFF1A1A2E) 
      : scheme.primary;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary text color (high emphasis)
  Color get textPrimary => scheme.onSurface;
  
  /// Secondary text color (medium emphasis)
  Color get textSecondary => scheme.onSurfaceVariant;
  
  /// Muted text color (low emphasis) - 50% opacity
  Color get textMuted => scheme.onSurface.withValues(alpha: 0.5);
  
  /// Hint text color - 40% opacity
  Color get textHint => scheme.onSurface.withValues(alpha: 0.4);
  
  /// Disabled text color - 30% opacity
  Color get textDisabled => scheme.onSurface.withValues(alpha: 0.3);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SIDEBAR TEXT COLORS (Adapts to sidebar background)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Sidebar text primary
  Color get sidebarTextPrimary => isDark 
      ? Colors.white 
      : const Color(0xFF1A1C1E);
  
  /// Sidebar text secondary
  Color get sidebarTextSecondary => isDark 
      ? Colors.white.withValues(alpha: 0.8) 
      : const Color(0xFF49454F);
  
  /// Sidebar text muted
  Color get sidebarTextMuted => isDark 
      ? Colors.white.withValues(alpha: 0.5) 
      : const Color(0xFF79747E);
  
  /// Sidebar border
  Color get sidebarBorder => isDark 
      ? Colors.white.withValues(alpha: 0.1) 
      : const Color(0xFFD0D0D4);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ACCENT & PRIMARY COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary accent color
  Color get primary => scheme.primary;
  
  /// On primary (text/icons on primary color)
  Color get onPrimary => scheme.onPrimary;
  
  /// Secondary accent color
  Color get secondary => scheme.secondary;
  
  /// Error color
  Color get error => scheme.error;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER & DIVIDER COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Standard border color
  Color get border => scheme.outline;
  
  /// Subtle border color
  Color get borderSubtle => scheme.outlineVariant;
  
  /// Divider color
  Color get divider => scheme.outlineVariant;
  
  /// Divider color with custom opacity
  Color dividerWithOpacity(double opacity) => 
      scheme.onSurface.withValues(alpha: opacity);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // INTERACTIVE ELEMENT COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Hover state background
  Color get hover => scheme.onSurface.withValues(alpha: 0.08);
  
  /// Selected state background
  Color get selected => scheme.primary.withValues(alpha: 0.12);
  
  /// Pressed state background
  Color get pressed => scheme.onSurface.withValues(alpha: 0.12);
  
  /// Focused state border
  Color get focused => scheme.primary;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ICON COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary icon color
  Color get icon => scheme.onSurfaceVariant;
  
  /// Muted icon color
  Color get iconMuted => scheme.onSurface.withValues(alpha: 0.5);
  
  /// Icon on primary background
  Color get iconOnPrimary => scheme.onPrimary;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // SHADOW & OVERLAY
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Shadow color
  Color get shadow => isDark 
      ? Colors.black.withValues(alpha: 0.4)
      : Colors.black.withValues(alpha: 0.1);
  
  /// Scrim/overlay color
  Color get scrim => scheme.scrim;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY COLORS (Fixed - don't change with theme)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color categoryFinancial = Color(0xFF4CAF50);   // Green
  static const Color categoryHealth = Color(0xFFE91E63);      // Pink
  static const Color categoryConstruction = Color(0xFFFF9800); // Orange
  static const Color categoryAgriculture = Color(0xFF8BC34A);  // Light green
  static const Color categoryLivestock = Color(0xFFFF5722);    // Deep orange
  static const Color categoryPet = Color(0xFF795548);          // Brown
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER COLORS (Fixed - don't change with theme)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color filterFavorites = Colors.red;
  static const Color filterRecents = Colors.purple;
  static const Color filterPopular = Colors.amber;
}

/// Extension for quick access via context
extension AdaptiveColorsExtension on BuildContext {
  /// Get adaptive colors helper
  AdaptiveColors get colors => AdaptiveColors(this);
  
  /// Quick check for dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  /// Quick access to color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

/// Semantic colors that adapt to theme
class SemanticColors {
  /// Success color (green)
  static Color success(BuildContext context) => 
      context.isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50);
  
  /// Warning color (amber)
  static Color warning(BuildContext context) => 
      context.isDark ? const Color(0xFFFFCA28) : const Color(0xFFFFA000);
  
  /// Info color (blue)
  static Color info(BuildContext context) => 
      context.isDark ? const Color(0xFF42A5F5) : const Color(0xFF2196F3);
  
  /// Danger/Error color (red)
  static Color danger(BuildContext context) => 
      context.isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336);
}
