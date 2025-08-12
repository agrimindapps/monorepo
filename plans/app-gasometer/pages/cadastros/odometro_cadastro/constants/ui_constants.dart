// Flutter imports:
import 'package:flutter/material.dart';

/// UI-related constants for the odometer registration feature
/// Contains styling, dimensions, and visual configuration constants
class OdometroUIConstants {
  // Private constructor to prevent instantiation
  OdometroUIConstants._();

  /// Dialog configuration constants
  static const DialogConfig dialog = DialogConfig._();

  /// Styling and dimensions constants
  static const StyleConfig style = StyleConfig._();

  /// Icon configuration constants
  static const IconConfig icons = IconConfig._();

  /// Color configuration constants
  static const ColorConfig colors = ColorConfig._();
}

/// Dialog-specific configuration constants
class DialogConfig {
  const DialogConfig._();

  /// Maximum height for the odometer registration dialog
  /// Calculated to accommodate all fields without requiring scroll
  static const double maxHeight = 484.0;

  /// Preferred height for optimal display on medium-sized devices
  /// Provides better user experience by fitting content naturally
  static const double preferredHeight = 470.0;
}

/// Styling and dimension constants following Material Design guidelines
class StyleConfig {
  const StyleConfig._();

  /// Card styling constants
  static const CardStyle card = CardStyle._();

  /// Spacing and padding constants
  static const SpacingStyle spacing = SpacingStyle._();

  /// Icon sizing constants
  static const IconSizing iconSizes = IconSizing._();
}

/// Card-specific styling constants
class CardStyle {
  const CardStyle._();

  /// Flat design elevation (modern UI trend)
  static const double elevation = 0.0;

  /// Material Design 3 standard border radius for content elements
  static const double borderRadius = 8.0;

  /// Vertical spacing between cards for visual breathing room
  static const double marginBottom = 12.0;

  /// Internal padding for comfortable reading (Material Design multiple of 4)
  static const double padding = 12.0;
}

/// Spacing and padding configuration
class SpacingStyle {
  const SpacingStyle._();

  /// Internal section padding for visual hierarchy
  static const double sectionPadding = 8.0;

  /// Minimal spacing between related fields for visual grouping
  static const double fieldSpacing = 4.0;

  /// Divider spacing for content alignment
  static const double dividerSpacing = 40.0;

  /// Time picker specific spacing for comfortable touch area
  static const double timePickerSpacing = 20.0;
}

/// Icon sizing configuration for consistent visual hierarchy
class IconSizing {
  const IconSizing._();

  /// Small icons for secondary elements
  static const double small = 16.0;

  /// Clear action icons (slightly larger for better accessibility)
  static const double clear = 18.0;

  /// Calendar icons (larger for easy identification)
  static const double calendar = 20.0;
}

/// Icon configuration constants
class IconConfig {
  const IconConfig._();

  /// Section-specific icons
  static const Map<String, IconData> sections = {
    'informacoesBasicas': Icons.event_note,
    'adicionais': Icons.notes,
  };

  /// Field-specific icons
  static const Map<String, IconData> fields = {
    'odometro': Icons.speed,
    'dataHora': Icons.calendar_today,
    'descricao': Icons.description,
    'clear': Icons.clear,
  };
}

/// Color configuration constants (placeholder for future theme support)
class ColorConfig {
  const ColorConfig._();

  /// Divider styling
  static const double dividerWidth = 1.0;
}
