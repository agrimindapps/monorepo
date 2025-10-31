import 'package:flutter/material.dart';

/// **Loading Type Enumeration**
/// 
/// Defines different types of loading states for consistent usage
/// across the application with appropriate visual treatments.
enum LoadingType {
  /// Centered loading state for full-screen contexts
  center,
  
  /// Inline loading state for list items and small components
  inline,
  
  /// Overlay loading state that blocks user interaction
  overlay,
}

/// Factory pattern implementation for widget creation following SOLID principles
/// 
/// Provides a centralized way to create commonly used widgets with consistent styling
/// and behavior across the application. Follows Factory Pattern and DIP.
class WidgetFactory {
  const WidgetFactory._();
  /// Creates a standardized card widget
  static Widget createCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      color: backgroundColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Creates a standardized section header
  static Widget createSectionHeader({
    required String title,
    required ThemeData theme,
    IconData? icon,
    Color? iconColor,
    List<Widget>? actions,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actions != null) ...[
          const Spacer(),
          ...actions,
        ],
      ],
    );
  }

  /// Creates a standardized form field
  static Widget createFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    String? suffixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  /// Creates a standardized switch list tile
  static Widget createSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
    );
  }

  /// Creates a standardized progress indicator with label
  static Widget createProgressIndicator({
    required double progress,
    required String label,
    Color? progressColor,
    String? percentageLabel,
  }) {
    final color = progressColor ?? 
        (progress >= 0.8 ? Colors.green : 
         progress >= 0.5 ? Colors.orange : Colors.red);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              percentageLabel ?? '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }

  /// Creates a standardized action button row
  static Widget createActionButtonRow({
    required List<Widget> buttons,
    MainAxisAlignment alignment = MainAxisAlignment.spaceEvenly,
    double spacing = 16,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: buttons
          .expand((button) => [button, SizedBox(width: spacing)])
          .take(buttons.length * 2 - 1)
          .toList(),
    );
  }

  /// Creates a standardized empty state widget
  static Widget createEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
    Color? iconColor,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: iconColor ?? Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  /// Creates a standardized info container
  static Widget createInfoContainer({
    required String title,
    required String content,
    required ThemeData theme,
    IconData? icon,
    Color? color,
  }) {
    final containerColor = color ?? theme.colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: containerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: containerColor, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: containerColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: containerColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a standardized loading widget
  ///
  /// **Deprecated**: Use WidgetFactory.createEnhancedLoading instead
  /// This method will be removed in future versions.
  @Deprecated(
    'Use WidgetFactory.createEnhancedLoading(LoadingType.center) instead. '
    'This method will be removed in v2.0.0. Migration guide: '
    'Replace createLoadingWidget() with createEnhancedLoading(LoadingType.center, message: "...")'
  )
  // TODO(v2.0.0): Remove deprecated createLoadingWidget method
  static Widget createLoadingWidget({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: color != null 
                ? AlwaysStoppedAnimation(color)
                : null,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// **Enhanced Loading State Factory**
  /// 
  /// Creates optimized loading states with accessibility and performance improvements.
  /// Uses the new UIComponents library for consistency.
  /// 
  /// **Parameters:**
  /// - [type]: Type of loading state (center, inline, overlay)
  /// - [message]: Optional loading message
  /// - [size]: Size of the loading indicator
  /// - [semanticLabel]: Accessibility label
  /// 
  /// **Usage Examples:**
  /// ```dart
  /// // Centered loading for full screen
  /// WidgetFactory.createEnhancedLoading(LoadingType.center, message: 'Carregando pets...')
  /// 
  /// // Inline loading for lists
  /// WidgetFactory.createEnhancedLoading(LoadingType.inline)
  /// 
  /// // Loading overlay
  /// WidgetFactory.createEnhancedLoading(LoadingType.overlay, child: myWidget)
  /// ```
  static Widget createEnhancedLoading(
    LoadingType type, {
    String? message,
    double size = 24,
    String? semanticLabel,
    Widget? child,
    bool isLoading = true,
  }) {
    switch (type) {
      case LoadingType.center:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: const CircularProgressIndicator(strokeWidth: 2.0),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      
      case LoadingType.inline:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        );
      
      case LoadingType.overlay:
        if (child == null) {
          throw ArgumentError('child cannot be null for overlay loading type');
        }
        return Stack(
          children: [
            child,
            if (isLoading)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: size,
                            height: size,
                            child: const CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                          if (message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
    }
  }

  /// Creates a standardized error widget
  static Widget createErrorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ops! Algo deu errado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ],
      ),
    );
  }
}
