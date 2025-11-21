import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/services/i_pragas_type_service.dart';

/// Service responsible for praga type-related mappings and configurations
/// Centralizes type-based logic (colors, icons, labels, emojis)
/// Follows SRP and OCP - uses Map registry instead of switch statements
class PragasTypeService implements IPragasTypeService {
  PragasTypeService();

  /// Type color registry
  /// Maps praga type ID to corresponding color
  static const Map<String, Color> _typeColors = {
    '1': Color(0xFFE53935), // Insetos - Red
    '2': Color(0xFFFF9800), // Doenças - Orange
    '3': Color(0xFF4CAF50), // Plantas Daninhas - Green
  };

  /// Type icon registry
  /// Maps praga type ID to corresponding FontAwesome icon
  static const Map<String, IconData> _typeIcons = {
    '1': FontAwesomeIcons.bug, // Insetos
    '2': FontAwesomeIcons.virus, // Doenças
    '3': FontAwesomeIcons.seedling, // Plantas Daninhas
  };

  /// Type label registry
  /// Maps praga type ID to human-readable label
  static const Map<String, String> _typeLabels = {
    '1': 'Inseto',
    '2': 'Doença',
    '3': 'Planta Daninha',
  };

  /// Type emoji registry
  /// Maps praga type ID to corresponding emoji
  static const Map<String, String> _typeEmojis = {
    '1': '🐛', // Insetos
    '2': '🦠', // Doenças
    '3': '🌿', // Plantas Daninhas
  };

  /// Default values for unknown types
  static const Color _defaultColor = Color(0xFF757575); // Grey
  static const IconData _defaultIcon = FontAwesomeIcons.triangleExclamation;
  static const String _defaultLabel = 'Praga';
  static const String _defaultEmoji = '❓';

  /// Get color for a specific praga type
  /// Returns default grey color if type not found
  ///
  /// Example:
  /// ```dart
  /// final color = service.getTypeColor('1'); // Red for insects
  /// ```
  @override
  Color getTypeColor(String tipoPraga) {
    return _typeColors[tipoPraga] ?? _defaultColor;
  }

  /// Get icon for a specific praga type
  /// Returns default warning icon if type not found
  ///
  /// Example:
  /// ```dart
  /// final icon = service.getTypeIcon('2'); // Virus icon for diseases
  /// ```
  @override
  IconData getTypeIcon(String tipoPraga) {
    return _typeIcons[tipoPraga] ?? _defaultIcon;
  }

  /// Get label for a specific praga type
  /// Returns default 'Praga' label if type not found
  ///
  /// Example:
  /// ```dart
  /// final label = service.getTypeLabel('1'); // 'Inseto'
  /// ```
  @override
  String getTypeLabel(String tipoPraga) {
    return _typeLabels[tipoPraga] ?? _defaultLabel;
  }

  /// Get emoji for a specific praga type
  /// Returns default question mark emoji if type not found
  ///
  /// Example:
  /// ```dart
  /// final emoji = service.getTypeEmoji('3'); // '🌿'
  /// ```
  @override
  String getTypeEmoji(String tipoPraga) {
    return _typeEmojis[tipoPraga] ?? _defaultEmoji;
  }

  /// Check if a type has custom color
  /// Useful for conditional UI rendering
  @override
  bool hasCustomColor(String tipoPraga) {
    return _typeColors.containsKey(tipoPraga);
  }

  /// Check if a type has custom icon
  /// Useful for conditional UI rendering
  @override
  bool hasCustomIcon(String tipoPraga) {
    return _typeIcons.containsKey(tipoPraga);
  }

  /// Get all registered type IDs
  /// Useful for validation or testing
  @override
  List<String> getRegisteredTypeIds() {
    return _typeLabels.keys.toList();
  }

  /// Build a complete type info map for UI display
  /// Convenient method that returns all type information at once
  ///
  /// Returns:
  /// ```dart
  /// {
  ///   'color': Color,
  ///   'icon': IconData,
  ///   'label': String,
  ///   'emoji': String,
  /// }
  /// ```
  @override
  Map<String, dynamic> getTypeInfo(String tipoPraga) {
    return {
      'color': getTypeColor(tipoPraga),
      'icon': getTypeIcon(tipoPraga),
      'label': getTypeLabel(tipoPraga),
      'emoji': getTypeEmoji(tipoPraga),
    };
  }

  /// Build a type badge widget with icon and label
  /// Centralizes type badge UI component
  @override
  Widget buildTypeBadge(
    String tipoPraga, {
    bool showIcon = true,
    bool showLabel = true,
    double iconSize = 16,
    TextStyle? labelStyle,
  }) {
    final color = getTypeColor(tipoPraga);
    final icon = getTypeIcon(tipoPraga);
    final label = getTypeLabel(tipoPraga);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: iconSize, color: color),
            if (showLabel) const SizedBox(width: 4),
          ],
          if (showLabel)
            Text(
              label,
              style:
                  labelStyle?.copyWith(color: color) ??
                  TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  /// Create icon widget for a praga type with styling
  /// Centralizes icon rendering
  @override
  Widget buildTypeIcon(String tipoPraga, {double size = 24, Color? color}) {
    return Icon(
      getTypeIcon(tipoPraga),
      size: size,
      color: color ?? getTypeColor(tipoPraga),
    );
  }
}
