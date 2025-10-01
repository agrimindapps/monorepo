import 'package:flutter/material.dart';

/// Reusable error state widget with recovery actions
/// Provides consistent error handling across the app
class ErrorStateWidget extends StatelessWidget {

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.onSecondaryAction,
    this.retryButtonText,
    this.secondaryButtonText,
    this.style = const ErrorStateStyle(),
    this.isCompact = false,
  });

  /// Factory for network errors
  factory ErrorStateWidget.network({
    VoidCallback? onRetry,
    String? customMessage,
    ErrorStateStyle style = const ErrorStateStyle(),
  }) {
    return ErrorStateWidget(
      title: 'Connection Problem',
      message: customMessage ?? 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryButtonText: 'Try Again',
      style: style.copyWith(
        iconColor: Colors.orange.shade600,
        primaryButtonColor: Colors.orange.shade600,
      ),
    );
  }

  /// Factory for server errors
  factory ErrorStateWidget.server({
    VoidCallback? onRetry,
    String? customMessage,
    ErrorStateStyle style = const ErrorStateStyle(),
  }) {
    return ErrorStateWidget(
      title: 'Server Error',
      message: customMessage ?? 'Something went wrong on our end. Please try again later.',
      icon: Icons.error_outline,
      onRetry: onRetry,
      retryButtonText: 'Retry',
      style: style.copyWith(
        iconColor: Colors.red.shade600,
        primaryButtonColor: Colors.red.shade600,
      ),
    );
  }

  /// Factory for data loading errors
  factory ErrorStateWidget.dataLoading({
    VoidCallback? onRetry,
    String? customMessage,
    ErrorStateStyle style = const ErrorStateStyle(),
  }) {
    return ErrorStateWidget(
      title: 'Failed to Load Data',
      message: customMessage ?? 'We couldn\'t load your data. Please try again.',
      icon: Icons.refresh,
      onRetry: onRetry,
      retryButtonText: 'Reload',
      style: style.copyWith(
        iconColor: Colors.blue.shade600,
        primaryButtonColor: Colors.blue.shade600,
      ),
    );
  }

  /// Factory for permission errors
  factory ErrorStateWidget.permission({
    VoidCallback? onGrantPermission,
    VoidCallback? onSkip,
    String? customMessage,
    ErrorStateStyle style = const ErrorStateStyle(),
  }) {
    return ErrorStateWidget(
      title: 'Permission Required',
      message: customMessage ?? 'This feature requires permission to work properly.',
      icon: Icons.security,
      onRetry: onGrantPermission,
      onSecondaryAction: onSkip,
      retryButtonText: 'Grant Permission',
      secondaryButtonText: 'Skip',
      style: style.copyWith(
        iconColor: Colors.amber.shade600,
        primaryButtonColor: Colors.amber.shade600,
      ),
    );
  }

  /// Factory for sync errors
  factory ErrorStateWidget.sync({
    VoidCallback? onRetry,
    VoidCallback? onViewOffline,
    String? customMessage,
    ErrorStateStyle style = const ErrorStateStyle(),
  }) {
    return ErrorStateWidget(
      title: 'Sync Failed',
      message: customMessage ?? 'Your data couldn\'t be synchronized. You can still view offline data.',
      icon: Icons.sync_problem,
      onRetry: onRetry,
      onSecondaryAction: onViewOffline,
      retryButtonText: 'Try Sync Again',
      secondaryButtonText: 'View Offline',
      style: style.copyWith(
        iconColor: Colors.purple.shade600,
        primaryButtonColor: Colors.purple.shade600,
      ),
    );
  }
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String? retryButtonText;
  final String? secondaryButtonText;
  final ErrorStateStyle style;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isCompact) {
      return _buildCompactError(theme);
    }
    
    return _buildFullError(theme);
  }

  Widget _buildCompactError(ThemeData theme) {
    return Container(
      padding: style.padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: style.backgroundColor ?? theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: style.borderRadius ?? BorderRadius.circular(8.0),
        border: Border.all(
          color: style.borderColor ?? theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: style.iconSize ?? 24.0,
              color: style.iconColor ?? theme.colorScheme.error,
            ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: style.titleStyle ??
                      theme.textTheme.titleSmall?.copyWith(
                        color: style.titleColor ?? theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: style.messageStyle ??
                        theme.textTheme.bodySmall?.copyWith(
                          color: style.messageColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(retryButtonText ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildFullError(ThemeData theme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: style.padding ?? const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: (style.iconColor ?? theme.colorScheme.error).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: style.iconSize ?? 48.0,
                  color: style.iconColor ?? theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24.0),
            ],
            Text(
              title,
              style: style.titleStyle ??
                  theme.textTheme.headlineSmall?.copyWith(
                    color: style.titleColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12.0),
              Text(
                message!,
                style: style.messageStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: style.messageColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32.0),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final buttons = <Widget>[];

    if (onRetry != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryButtonText ?? 'Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: style.primaryButtonColor ?? theme.colorScheme.primary,
            foregroundColor: style.primaryButtonTextColor ?? theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
        ),
      );
    }

    if (onSecondaryAction != null) {
      buttons.add(
        OutlinedButton(
          onPressed: onSecondaryAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: style.secondaryButtonColor ?? theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
          child: Text(secondaryButtonText ?? 'Cancel'),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    if (buttons.length == 1) {
      return buttons.first;
    }

    return Column(
      children: [
        buttons.first,
        const SizedBox(height: 12.0),
        buttons.last,
      ],
    );
  }
}

/// Animated error state with slide-in animation
class AnimatedErrorState extends StatefulWidget {

  const AnimatedErrorState({
    super.key,
    required this.errorWidget,
    this.animationDuration = const Duration(milliseconds: 300),
  });
  final ErrorStateWidget errorWidget;
  final Duration animationDuration;

  @override
  State<AnimatedErrorState> createState() => _AnimatedErrorStateState();
}

class _AnimatedErrorStateState extends State<AnimatedErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.errorWidget,
      ),
    );
  }
}

/// Error state style configuration
class ErrorStateStyle {

  const ErrorStateStyle({
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.titleColor,
    this.messageColor,
    this.primaryButtonColor,
    this.primaryButtonTextColor,
    this.secondaryButtonColor,
    this.titleStyle,
    this.messageStyle,
    this.iconSize,
    this.padding,
    this.borderRadius,
  });
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final Color? primaryButtonColor;
  final Color? primaryButtonTextColor;
  final Color? secondaryButtonColor;
  
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  ErrorStateStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? iconColor,
    Color? titleColor,
    Color? messageColor,
    Color? primaryButtonColor,
    Color? primaryButtonTextColor,
    Color? secondaryButtonColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    double? iconSize,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    return ErrorStateStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      titleColor: titleColor ?? this.titleColor,
      messageColor: messageColor ?? this.messageColor,
      primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
      primaryButtonTextColor: primaryButtonTextColor ?? this.primaryButtonTextColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      titleStyle: titleStyle ?? this.titleStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      iconSize: iconSize ?? this.iconSize,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}