import 'package:flutter/material.dart';
import 'design_tokens.dart';

// TODO: This file should be moved to the specific feature's directory that uses it,
// as it is no longer a global design token file but a component-specific configuration.

/// Defines configurations for loading-related components and animations.
///
/// This class provides component-specific configurations, such as the steps for
/// a login animation, and derives its core styling from the global [GasometerDesignTokens].
class LoadingComponentConfig {
  LoadingComponentConfig._();

  /// A predefined list of steps for the login loading animation.
  static const List<LoadingStepConfig> loginSteps = [
    LoadingStepConfig(
      icon: Icons.account_circle_outlined,
      title: 'Authenticating',
      subtitle: 'Verifying your credentials...',
      duration: Duration(milliseconds: 1000),
    ),
    LoadingStepConfig(
      icon: Icons.cloud_download_outlined,
      title: 'Syncing',
      subtitle: 'Downloading your data...',
      duration: Duration(milliseconds: 1500),
    ),
    LoadingStepConfig(
      icon: Icons.directions_car_outlined,
      title: 'Loading Vehicles',
      subtitle: 'Preparing your fleet...',
      duration: Duration(milliseconds: 1200),
    ),
    LoadingStepConfig(
      icon: Icons.local_gas_station_outlined,
      title: 'Processing Data',
      subtitle: 'Analyzing consumption...',
      duration: Duration(milliseconds: 800),
    ),
    LoadingStepConfig(
      icon: Icons.check_circle_outline,
      title: 'Done!',
      subtitle: 'Redirecting...',
      duration: Duration(milliseconds: 600),
    ),
  ];

  /// The default text style for titles in loading components.
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f18,
    fontWeight: GasometerDesignTokens.Typography.semiBold,
    letterSpacing: 0.5,
  );

  /// The default text style for body text in loading components.
  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f14,
    fontWeight: GasometerDesignTokens.Typography.regular,
    height: 1.4,
  );

  /// Returns a color scheme for loading components, adapted for the current theme.
  static LoadingColorScheme getColorScheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColors = GasometerDesignTokens.Colors;

    return LoadingColorScheme(
      primary: themeColors.secondary,
      secondary: themeColors.secondaryLight,
      success: themeColors.success,
      background: isDark ? themeColors.neutral900 : themeColors.background,
      surface: isDark ? themeColors.neutral700 : themeColors.surface,
      onSurface: isDark ? themeColors.textOnPrimary : themeColors.textPrimary,
      onSurfaceLight: isDark
          ? themeColors.textOnPrimary.withOpacity(0.7)
          : themeColors.textSecondary,
    );
  }

  /// Returns an animation configuration based on the desired [AnimationSpeed].
  static AnimationConfig getAnimationConfig(AnimationSpeed speed) {
    switch (speed) {
      case AnimationSpeed.fast:
        return const AnimationConfig(
          duration: GasometerDesignTokens.Animations.fast,
          curve: GasometerDesignTokens.Animations.enter,
        );
      case AnimationSpeed.normal:
        return const AnimationConfig(
          duration: GasometerDesignTokens.Animations.normal,
          curve: GasometerDesignTokens.Animations.standard,
        );
      case AnimationSpeed.slow:
        return const AnimationConfig(
          duration: GasometerDesignTokens.Animations.slow,
          curve: GasometerDesignTokens.Animations.exit,
        );
      case AnimationSpeed.bounce:
        return const AnimationConfig(
          duration: GasometerDesignTokens.Animations.normal,
          curve: GasometerDesignTokens.Animations.bounce,
        );
    }
  }
}

/// A data class representing a single step in a multi-step loading indicator.
class LoadingStepConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final Duration duration;

  const LoadingStepConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
  });
}

/// A set of colors tailored for loading components.
class LoadingColorScheme {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceLight;

  const LoadingColorScheme({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceLight,
  });
}

/// A data class holding the duration and curve for an animation.
class AnimationConfig {
  final Duration duration;
  final Curve curve;

  const AnimationConfig({
    required this.duration,
    required this.curve,
  });
}

/// An enum representing available animation speeds.
enum AnimationSpeed {
  fast,
  normal,
  slow,
  bounce,
}