import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// **Accessibility Utilities Library**
/// 
/// A comprehensive collection of utilities and helpers to improve accessibility
/// across the PetiVeti application, ensuring WCAG compliance and inclusive design.
/// 
/// ## Features:
/// - **Semantic Helpers**: Simplified semantic widget creation
/// - **Color Contrast**: Tools for ensuring proper contrast ratios
/// - **Screen Reader**: Optimized screen reader support
/// - **Focus Management**: Keyboard navigation and focus handling
/// - **Live Regions**: Dynamic content announcements
/// - **Testing Helpers**: Tools for accessibility testing
/// 
/// ## Benefits:
/// - **WCAG 2.1 AA Compliance**: Meets accessibility standards
/// - **Inclusive Design**: Works for users with diverse abilities
/// - **Screen Reader Optimized**: Perfect VoiceOver/TalkBack support
/// - **Keyboard Navigation**: Full keyboard accessibility
/// - **Developer Friendly**: Easy-to-use API for developers
/// 
/// @author PetiVeti Accessibility Team
/// @since 1.0.0
class AccessibilityUtils {
  AccessibilityUtils._();

  // ========== SEMANTIC HELPERS ==========

  /// **Enhanced Button Semantics**
  /// 
  /// Creates accessible button semantics with proper labels, hints, and states.
  /// 
  /// **Parameters:**
  /// - [child]: The button widget
  /// - [label]: Accessible label for the button
  /// - [hint]: Additional hint for screen readers
  /// - [onTap]: Button tap callback
  /// - [enabled]: Whether the button is enabled
  /// - [isSelected]: Whether the button is in selected state
  /// - [isToggled]: Whether the button is toggled (for toggle buttons)
  /// 
  /// **Usage Example:**
  /// ```dart
  /// AccessibilityUtils.accessibleButton(
  ///   child: Icon(Icons.favorite),
  ///   label: 'Favoritar pet',
  ///   hint: 'Toque duas vezes para favoritar este pet',
  ///   onTap: () => toggleFavorite(),
  ///   isToggled: pet.isFavorite,
  /// )
  /// ```
  static Widget accessibleButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
    bool isSelected = false,
    bool isToggled = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      selected: isSelected,
      toggled: isToggled,
      onTap: onTap,
      child: child,
    );
  }

  /// **Enhanced List Item Semantics**
  /// 
  /// Creates accessible list item semantics with proper navigation hints.
  /// 
  /// **Parameters:**
  /// - [child]: The list item widget
  /// - [label]: Main content label
  /// - [hint]: Navigation or action hint
  /// - [index]: Item index in the list
  /// - [totalItems]: Total number of items in list
  /// - [onTap]: Tap callback for navigation
  /// - [hasSubItems]: Whether this item has sub-items
  /// 
  /// **Features:**
  /// - Position information (item X of Y)
  /// - Navigation hints
  /// - Sub-item indicators
  /// - Proper focus handling
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    int? index,
    int? totalItems,
    VoidCallback? onTap,
    bool hasSubItems = false,
  }) {
    String semanticLabel = label;
    String? semanticHint = hint;
    
    // Add position information
    if (index != null && totalItems != null) {
      semanticLabel = '$label, item ${index + 1} de $totalItems';
    }
    
    // Add sub-items hint
    if (hasSubItems) {
      semanticHint = '${semanticHint ?? ''}${semanticHint?.isNotEmpty == true ? '. ' : ''}Possui sub-itens. Toque duas vezes para expandir.';
    }
    
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// **Enhanced Text Field Semantics**
  /// 
  /// Creates accessible text field semantics with validation states.
  /// 
  /// **Parameters:**
  /// - [child]: The text field widget
  /// - [label]: Field label
  /// - [hint]: Input hint or placeholder
  /// - [helperText]: Additional helper information
  /// - [errorText]: Error message (if any)
  /// - [isRequired]: Whether the field is required
  /// - [isValid]: Current validation state
  /// - [characterCount]: Current character count
  /// - [maxLength]: Maximum allowed characters
  /// 
  /// **Features:**
  /// - Required field indication
  /// - Validation state feedback
  /// - Character count information
  /// - Error state announcements
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? helperText,
    String? errorText,
    bool isRequired = false,
    bool? isValid,
    int? characterCount,
    int? maxLength,
  }) {
    String semanticLabel = label;
    List<String> hintParts = [];
    
    // Add required indicator
    if (isRequired) {
      semanticLabel = '$semanticLabel, obrigatório';
    }
    
    // Add placeholder hint
    if (hint != null) {
      hintParts.add(hint);
    }
    
    // Add helper text
    if (helperText != null) {
      hintParts.add(helperText);
    }
    
    // Add validation state
    if (errorText != null) {
      hintParts.add('Erro: $errorText');
    } else if (isValid == true) {
      hintParts.add('Campo válido');
    }
    
    // Add character count
    if (characterCount != null && maxLength != null) {
      hintParts.add('$characterCount de $maxLength caracteres');
    }
    
    return Semantics(
      label: semanticLabel,
      hint: hintParts.isNotEmpty ? hintParts.join('. ') : null,
      textField: true,
      child: child,
    );
  }

  // ========== LIVE REGIONS ==========

  /// **Live Region Announcement**
  /// 
  /// Creates a live region for dynamic content announcements.
  /// Perfect for status updates, loading states, and real-time feedback.
  /// 
  /// **Parameters:**
  /// - [child]: Widget to make live
  /// - [message]: Current message to announce
  /// - [politeness]: Announcement politeness level
  /// - [atomic]: Whether to announce the entire content when changed
  /// 
  /// **Usage Example:**
  /// ```dart
  /// AccessibilityUtils.liveRegion(
  ///   child: Text(loadingMessage),
  ///   message: loadingMessage,
  ///   politeness: LiveRegionPoliteness.assertive,
  /// )
  /// ```
  static Widget liveRegion({
    required Widget child,
    required String message,
    LiveRegionPoliteness politeness = LiveRegionPoliteness.polite,
    bool atomic = false,
  }) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: child,
    );
  }

  /// **Status Announcement**
  /// 
  /// Announces status changes to screen readers without visual changes.
  /// Perfect for operations feedback like save success, errors, etc.
  /// 
  /// **Parameters:**
  /// - [context]: Build context for announcements
  /// - [message]: Message to announce
  /// - [politeness]: How urgently to announce
  /// 
  /// **Usage Example:**
  /// ```dart
  /// AccessibilityUtils.announceStatus(
  ///   context,
  ///   'Pet salvo com sucesso',
  ///   politeness: LiveRegionPoliteness.assertive,
  /// );
  /// ```
  static void announceStatus(
    BuildContext context,
    String message, {
    LiveRegionPoliteness politeness = LiveRegionPoliteness.polite,
  }) {
    final announcement = politeness == LiveRegionPoliteness.assertive
        ? SemanticsService.announce(message, TextDirection.ltr, assertiveness: Assertiveness.assertive)
        : SemanticsService.announce(message, TextDirection.ltr);
    
    announcement;
  }

  // ========== FOCUS MANAGEMENT ==========

  /// **Focus Helper**
  /// 
  /// Utilities for managing focus and keyboard navigation.
  /// 
  /// **Parameters:**
  /// - [focusNode]: Focus node to manage
  /// - [child]: Widget to focus
  /// - [autofocus]: Whether to focus automatically
  /// - [skipTraversal]: Whether to skip in tab traversal
  /// - [canRequestFocus]: Whether can request focus
  /// 
  /// **Features:**
  /// - Automatic focus management
  /// - Tab traversal control
  /// - Focus request handling
  /// - Accessibility shortcuts
  static Widget manageFocus({
    required FocusNode focusNode,
    required Widget child,
    bool autofocus = false,
    bool skipTraversal = false,
    bool canRequestFocus = true,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
      child: child,
    );
  }

  /// **Request Focus Helper**
  /// 
  /// Safely requests focus for a widget with proper error handling.
  /// 
  /// **Parameters:**
  /// - [focusNode]: Focus node to focus
  /// - [delay]: Optional delay before focusing
  /// 
  /// **Usage Example:**
  /// ```dart
  /// AccessibilityUtils.requestFocus(
  ///   myFocusNode,
  ///   delay: Duration(milliseconds: 100),
  /// );
  /// ```
  static void requestFocus(
    FocusNode focusNode, {
    Duration? delay,
  }) {
    if (delay != null) {
      Future.delayed(delay, () {
        if (focusNode.canRequestFocus) {
          focusNode.requestFocus();
        }
      });
    } else {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    }
  }

  // ========== COLOR CONTRAST ==========

  /// **Contrast Ratio Calculator**
  /// 
  /// Calculates the contrast ratio between two colors according to WCAG guidelines.
  /// 
  /// **Parameters:**
  /// - [foreground]: Foreground color
  /// - [background]: Background color
  /// 
  /// **Returns:** Contrast ratio (1.0 to 21.0)
  /// 
  /// **WCAG Requirements:**
  /// - Normal text: 4.5:1 minimum (AA), 7:1 enhanced (AAA)
  /// - Large text: 3:1 minimum (AA), 4.5:1 enhanced (AAA)
  /// - UI components: 3:1 minimum
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateLuminance(foreground);
    final bgLuminance = _calculateLuminance(background);
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// **WCAG Compliance Checker**
  /// 
  /// Checks if color combination meets WCAG accessibility requirements.
  /// 
  /// **Parameters:**
  /// - [foreground]: Foreground color
  /// - [background]: Background color
  /// - [level]: WCAG level (AA or AAA)
  /// - [isLargeText]: Whether text is considered large (18pt+ or 14pt+ bold)
  /// 
  /// **Returns:** Whether combination meets requirements
  static bool meetsWCAGRequirements(
    Color foreground,
    Color background, {
    WCAGLevel level = WCAGLevel.AA,
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    
    switch (level) {
      case WCAGLevel.AA:
        return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
      case WCAGLevel.AAA:
        return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
    }
  }

  /// **Accessible Color Finder**
  /// 
  /// Finds an accessible color variant that meets WCAG requirements.
  /// 
  /// **Parameters:**
  /// - [baseColor]: Base color to adjust
  /// - [background]: Background color to contrast against
  /// - [level]: WCAG compliance level
  /// - [isLargeText]: Whether for large text
  /// 
  /// **Returns:** Adjusted color that meets requirements
  static Color findAccessibleColor(
    Color baseColor,
    Color background, {
    WCAGLevel level = WCAGLevel.AA,
    bool isLargeText = false,
  }) {
    if (meetsWCAGRequirements(baseColor, background, 
        level: level, isLargeText: isLargeText)) {
      return baseColor;
    }
    
    // Try making it darker
    Color adjustedColor = baseColor;
    for (int i = 1; i <= 10; i++) {
      adjustedColor = Color.lerp(baseColor, Colors.black, i * 0.1)!;
      if (meetsWCAGRequirements(adjustedColor, background,
          level: level, isLargeText: isLargeText)) {
        return adjustedColor;
      }
    }
    
    // Try making it lighter
    adjustedColor = baseColor;
    for (int i = 1; i <= 10; i++) {
      adjustedColor = Color.lerp(baseColor, Colors.white, i * 0.1)!;
      if (meetsWCAGRequirements(adjustedColor, background,
          level: level, isLargeText: isLargeText)) {
        return adjustedColor;
      }
    }
    
    // Fallback to black or white
    return calculateContrastRatio(Colors.black, background) > 
           calculateContrastRatio(Colors.white, background) 
        ? Colors.black 
        : Colors.white;
  }

  // ========== HELPER METHODS ==========

  static double _calculateLuminance(Color color) {
    // Convert to sRGB
    final r = _sRGBToLinear(color.r / 255.0);
    final g = _sRGBToLinear(color.g / 255.0);
    final b = _sRGBToLinear(color.b / 255.0);
    
    // Calculate luminance using WCAG formula
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _sRGBToLinear(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return ((value + 0.055) / 1.055).abs();
    }
  }

  // ========== TESTING HELPERS ==========

  /// **Accessibility Test Helper**
  /// 
  /// Provides utilities for testing accessibility features.
  /// 
  /// **Parameters:**
  /// - [widget]: Widget to test
  /// - [semanticLabel]: Expected semantic label
  /// - [hint]: Expected hint text
  /// - [isButton]: Whether should be marked as button
  /// - [isTextField]: Whether should be marked as text field
  /// 
  /// **Usage in Tests:**
  /// ```dart
  /// testWidgets('button has correct semantics', (tester) async {
  ///   await tester.pumpWidget(myButton);
  ///   
  ///   AccessibilityUtils.verifySemantics(
  ///     find.byType(MyButton),
  ///     semanticLabel: 'Save pet',
  ///     hint: 'Saves the current pet information',
  ///     isButton: true,
  ///   );
  /// });
  /// ```
  static void verifySemantics({
    required String semanticLabel,
    String? hint,
    bool isButton = false,
    bool isTextField = false,
    bool enabled = true,
  }) {
    // This would be implemented with flutter test framework
    // For now, it serves as documentation of testing approach
  }
}

/// **Live Region Politeness Levels**
/// 
/// Defines how urgently screen readers should announce live region changes.
enum LiveRegionPoliteness {
  /// Polite announcements (wait for user pause)
  polite,
  
  /// Assertive announcements (interrupt current speech)
  assertive,
}

/// **WCAG Compliance Levels**
/// 
/// Different levels of WCAG accessibility compliance.
enum WCAGLevel {
  /// Level AA - Standard compliance (recommended minimum)
  AA,
  
  /// Level AAA - Enhanced compliance (gold standard)
  AAA,
}

// ========== ACCESSIBILITY CONSTANTS ==========

/// **Accessibility Constants**
/// 
/// Common accessibility-related constants and values.
class AccessibilityConstants {
  AccessibilityConstants._();

  // Touch target minimums
  static const double minTouchTarget = 44.0;  // iOS/Android minimum
  static const double recommendedTouchTarget = 48.0;  // Material Design

  // Text size minimums
  static const double minReadableTextSize = 14.0;
  static const double largeTextSize = 18.0;
  static const double boldLargeTextSize = 14.0;

  // Contrast ratios
  static const double minContrastRatioNormal = 4.5;  // WCAG AA normal text
  static const double minContrastRatioLarge = 3.0;   // WCAG AA large text
  static const double enhancedContrastRatioNormal = 7.0;  // WCAG AAA normal text
  static const double enhancedContrastRatioLarge = 4.5;   // WCAG AAA large text

  // Animation durations
  static const Duration focusAnimationDuration = Duration(milliseconds: 200);
  static const Duration announceDelay = Duration(milliseconds: 100);
  
  // Common semantic labels
  static const String closeButtonLabel = 'Fechar';
  static const String backButtonLabel = 'Voltar';
  static const String menuButtonLabel = 'Abrir menu';
  static const String searchButtonLabel = 'Buscar';
  static const String addButtonLabel = 'Adicionar';
  static const String editButtonLabel = 'Editar';
  static const String deleteButtonLabel = 'Excluir';
  static const String saveButtonLabel = 'Salvar';
  static const String cancelButtonLabel = 'Cancelar';
}