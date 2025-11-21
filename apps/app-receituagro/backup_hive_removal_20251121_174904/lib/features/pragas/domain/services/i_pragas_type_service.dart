import 'package:flutter/material.dart';

/// Interface for praga type-related mappings and configurations
/// Centralizes type-based logic (colors, icons, labels, emojis)
abstract class IPragasTypeService {
  /// Get color for a specific praga type
  Color getTypeColor(String tipoPraga);

  /// Get icon for a specific praga type
  IconData getTypeIcon(String tipoPraga);

  /// Get label for a specific praga type
  String getTypeLabel(String tipoPraga);

  /// Get emoji for a specific praga type
  String getTypeEmoji(String tipoPraga);

  /// Check if a type has custom color
  bool hasCustomColor(String tipoPraga);

  /// Check if a type has custom icon
  bool hasCustomIcon(String tipoPraga);

  /// Get all registered type IDs
  List<String> getRegisteredTypeIds();

  /// Build a complete type info map for UI display
  Map<String, dynamic> getTypeInfo(String tipoPraga);

  /// Build a type badge widget with icon and label
  Widget buildTypeBadge(
    String tipoPraga, {
    bool showIcon = true,
    bool showLabel = true,
    double iconSize = 16,
    TextStyle? labelStyle,
  });

  /// Create icon widget for a praga type with styling
  Widget buildTypeIcon(String tipoPraga, {double size = 24, Color? color});
}
