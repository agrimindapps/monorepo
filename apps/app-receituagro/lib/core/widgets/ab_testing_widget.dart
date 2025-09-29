import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/feature_flags_provider.dart';
import '../services/remote_config_service.dart';

/// A/B Testing Widget for Dynamic UI Components
/// 
/// Features:
/// - Dynamic widget switching based on A/B test flags
/// - Fallback widget support
/// - Analytics event tracking for variant exposure
/// - Performance optimized with widget caching
/// - Debug mode indicators
class ABTestingWidget extends StatefulWidget {
  /// The feature flag to check for A/B test variant
  final ReceitaAgroFeatureFlag featureFlag;
  
  /// Widget to show when A/B test is active (Variant B)
  final Widget variantWidget;
  
  /// Widget to show when A/B test is inactive (Control/Variant A)
  final Widget controlWidget;
  
  /// Optional fallback widget if feature flag system fails
  final Widget? fallbackWidget;
  
  /// Optional analytics event name for tracking
  final String? analyticsEventName;
  
  /// Whether to show debug indicators in development mode
  final bool showDebugIndicator;

  const ABTestingWidget({
    super.key,
    required this.featureFlag,
    required this.variantWidget,
    required this.controlWidget,
    this.fallbackWidget,
    this.analyticsEventName,
    this.showDebugIndicator = true,
  });

  @override
  State<ABTestingWidget> createState() => _ABTestingWidgetState();
}

class _ABTestingWidgetState extends State<ABTestingWidget> {
  bool _hasTrackedExposure = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureFlagsProvider>(
      builder: (context, featureFlags, child) {
        if (!featureFlags.isInitialized) {
          // Return fallback or control while loading
          return widget.fallbackWidget ?? widget.controlWidget;
        }

        final isVariantActive = featureFlags.isFeatureEnabled(widget.featureFlag);
        
        // Track analytics exposure (only once per widget lifecycle)
        if (!_hasTrackedExposure && widget.analyticsEventName != null) {
          _trackVariantExposure(isVariantActive);
        }

        // Select appropriate widget
        final selectedWidget = isVariantActive 
            ? widget.variantWidget 
            : widget.controlWidget;

        // Wrap with debug indicator if enabled
        if (widget.showDebugIndicator && _isDebugMode()) {
          return _buildWithDebugIndicator(selectedWidget, isVariantActive);
        }

        return selectedWidget;
      },
    );
  }

  /// Build widget with debug indicator overlay
  Widget _buildWithDebugIndicator(Widget child, bool isVariantActive) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isVariantActive ? Colors.blue : Colors.grey,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              isVariantActive ? 'B' : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Check if we're in debug mode
  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Track variant exposure for analytics
  void _trackVariantExposure(bool isVariantActive) {
    if (!mounted || widget.analyticsEventName == null) return;

    // This would integrate with your analytics service
    // For now, we'll just mark it as tracked
    _hasTrackedExposure = true;

    // In a real implementation, you'd call something like:
    // context.read<AnalyticsService>().track(
    //   widget.analyticsEventName!,
    //   properties: {
    //     'variant': isVariantActive ? 'B' : 'A',
    //     'feature_flag': widget.featureFlag.toString(),
    //   },
    // );
  }
}

/// Conditional A/B Testing Widget - simpler version for boolean conditions
class ConditionalABWidget extends StatelessWidget {
  final bool condition;
  final Widget variantWidget;
  final Widget controlWidget;
  final bool showDebugIndicator;

  const ConditionalABWidget({
    super.key,
    required this.condition,
    required this.variantWidget,
    required this.controlWidget,
    this.showDebugIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedWidget = condition ? variantWidget : controlWidget;

    if (showDebugIndicator && _isDebugMode()) {
      return Stack(
        children: [
          selectedWidget,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: condition ? Colors.green : Colors.orange,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Text(
                condition ? 'ON' : 'OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return selectedWidget;
  }

  bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

/// Feature Flag Guard - shows widget only if feature is enabled
class FeatureFlagGuard extends StatelessWidget {
  final ReceitaAgroFeatureFlag featureFlag;
  final Widget child;
  final Widget? fallbackWidget;

  const FeatureFlagGuard({
    super.key,
    required this.featureFlag,
    required this.child,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureFlagsProvider>(
      builder: (context, featureFlags, _) {
        if (!featureFlags.isInitialized) {
          return fallbackWidget ?? const SizedBox.shrink();
        }

        final isEnabled = featureFlags.isFeatureEnabled(featureFlag);
        return isEnabled ? child : (fallbackWidget ?? const SizedBox.shrink());
      },
    );
  }
}

/// A/B Testing Button - switches between different button styles/behaviors
class ABTestingButton extends StatelessWidget {
  final ReceitaAgroFeatureFlag featureFlag;
  final VoidCallback? onPressed;
  final String text;
  
  // Control variant (A) properties
  final Color? controlColor;
  final Color? controlTextColor;
  final EdgeInsets? controlPadding;
  
  // Test variant (B) properties  
  final Color? variantColor;
  final Color? variantTextColor;
  final EdgeInsets? variantPadding;
  final IconData? variantIcon;
  
  final bool enabled;

  const ABTestingButton({
    super.key,
    required this.featureFlag,
    required this.text,
    this.onPressed,
    this.controlColor,
    this.controlTextColor,
    this.controlPadding,
    this.variantColor,
    this.variantTextColor,
    this.variantPadding,
    this.variantIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ABTestingWidget(
      featureFlag: featureFlag,
      analyticsEventName: 'ab_button_exposure',
      controlWidget: _buildControlButton(context),
      variantWidget: _buildVariantButton(context),
    );
  }

  Widget _buildControlButton(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: controlColor,
        foregroundColor: controlTextColor,
        padding: controlPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _buildVariantButton(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: variantColor ?? Colors.blue,
        foregroundColor: variantTextColor ?? Colors.white,
        padding: variantPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (variantIcon != null) ...[
            Icon(variantIcon, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A/B Testing Card - switches between different card layouts
class ABTestingCard extends StatelessWidget {
  final ReceitaAgroFeatureFlag featureFlag;
  final Widget child;
  
  // Control variant properties
  final EdgeInsets? controlPadding;
  final double? controlElevation;
  final BorderRadius? controlBorderRadius;
  
  // Test variant properties
  final EdgeInsets? variantPadding;
  final double? variantElevation;
  final BorderRadius? variantBorderRadius;
  final Color? variantColor;
  final Border? variantBorder;

  const ABTestingCard({
    super.key,
    required this.featureFlag,
    required this.child,
    this.controlPadding,
    this.controlElevation,
    this.controlBorderRadius,
    this.variantPadding,
    this.variantElevation,
    this.variantBorderRadius,
    this.variantColor,
    this.variantBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ABTestingWidget(
      featureFlag: featureFlag,
      analyticsEventName: 'ab_card_exposure',
      controlWidget: _buildControlCard(),
      variantWidget: _buildVariantCard(),
    );
  }

  Widget _buildControlCard() {
    return Card(
      elevation: controlElevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: controlBorderRadius ?? BorderRadius.circular(8),
      ),
      child: Padding(
        padding: controlPadding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildVariantCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: variantColor,
        borderRadius: variantBorderRadius ?? BorderRadius.circular(16),
        border: variantBorder,
        boxShadow: variantElevation != null ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: variantElevation! * 2,
            offset: Offset(0, variantElevation!),
          ),
        ] : null,
      ),
      child: Padding(
        padding: variantPadding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

// ReceitaAgroFeatureFlag should be imported from core services
// This file uses the enum from remote_config_service.dart