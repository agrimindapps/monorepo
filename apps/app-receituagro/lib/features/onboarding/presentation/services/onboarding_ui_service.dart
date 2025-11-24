import 'package:flutter/material.dart';


/// Service responsible for onboarding UI-related mappings and configurations
/// Follows SRP by centralizing UI presentation logic

class OnboardingUIService {
  OnboardingUIService();

  /// Icon mapping registry for onboarding steps
  /// Using Map instead of switch for OCP compliance
  static const Map<String, IconData> _stepIcons = {
    'welcome': Icons.waving_hand_outlined,
    'explore_database': Icons.search_outlined,
    'diagnostic_tool': Icons.analytics_outlined,
    'favorites': Icons.favorite_outline,
    'premium_features': Icons.star_outline,
    'notifications': Icons.notifications_outlined,
    'profile_setup': Icons.person_outline,
  };

  /// Default fallback icon
  static const IconData _defaultIcon = Icons.info_outline;

  /// Get icon for a specific onboarding step
  /// Returns default icon if step not found
  ///
  /// Example:
  /// ```dart
  /// final icon = service.getStepIcon('welcome');
  /// // Returns: Icons.waving_hand_outlined
  /// ```
  IconData getStepIcon(String stepId) {
    return _stepIcons[stepId] ?? _defaultIcon;
  }

  /// Check if a step has a custom icon
  /// Useful for conditional UI rendering
  bool hasCustomIcon(String stepId) {
    return _stepIcons.containsKey(stepId);
  }

  /// Get all registered step IDs
  /// Useful for validation or testing
  List<String> getRegisteredStepIds() {
    return _stepIcons.keys.toList();
  }

  /// Create icon widget for a step with default styling
  /// Centralizes icon styling for consistency
  Widget buildStepIcon(
    String stepId, {
    double size = 100,
    Color color = Colors.white,
  }) {
    return Icon(getStepIcon(stepId), size: size, color: color);
  }

  /// Create icon container for onboarding pages
  /// Centralizes the circular container design
  Widget buildStepIconContainer(
    String stepId, {
    double width = 200,
    double height = 200,
    double iconSize = 100,
    Color iconColor = Colors.white,
    Color? backgroundColor,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(width / 2),
      ),
      child: buildStepIcon(stepId, size: iconSize, color: iconColor),
    );
  }
}
