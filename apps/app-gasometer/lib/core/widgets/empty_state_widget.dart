import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

/// Reusable empty state widget with illustrations and actions
/// Provides consistent empty state handling across the app
class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustrationAsset,
    this.onAction,
    this.onSecondaryAction,
    this.actionButtonText,
    this.secondaryButtonText,
    this.style = const EmptyStateStyle(),
    this.isCompact = false,
  });

  /// Factory for empty expenses
  factory EmptyStateWidget.expenses({
    VoidCallback? onAddExpense,
    VoidCallback? onImport,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Expenses Yet',
      message: 'Start tracking your vehicle expenses to get insights about your spending.',
      icon: Icons.receipt_long_outlined,
      onAction: onAddExpense,
      onSecondaryAction: onImport,
      actionButtonText: 'Add First Expense',
      secondaryButtonText: 'Import Data',
      style: style.copyWith(
        iconColor: Colors.blue.shade400,
        actionButtonColor: Colors.blue.shade600,
      ),
    );
  }

  /// Factory for empty fuel records
  factory EmptyStateWidget.fuelRecords({
    VoidCallback? onAddFuel,
    VoidCallback? onLearnMore,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Fuel Records',
      message: 'Track your fuel consumption to monitor efficiency and costs.',
      icon: Icons.local_gas_station_outlined,
      onAction: onAddFuel,
      onSecondaryAction: onLearnMore,
      actionButtonText: 'Add Fuel Record',
      secondaryButtonText: 'Learn More',
      style: style.copyWith(
        iconColor: Colors.green.shade400,
        actionButtonColor: Colors.green.shade600,
      ),
    );
  }

  /// Factory for empty vehicles
  factory EmptyStateWidget.vehicles({
    VoidCallback? onAddVehicle,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Vehicles Added',
      message: 'Add your first vehicle to start tracking expenses and maintenance.',
      icon: Icons.directions_car_outlined,
      onAction: onAddVehicle,
      actionButtonText: 'Add Vehicle',
      style: style.copyWith(
        iconColor: Colors.purple.shade400,
        actionButtonColor: Colors.purple.shade600,
      ),
    );
  }

  /// Factory for empty maintenance records
  factory EmptyStateWidget.maintenance({
    VoidCallback? onAddMaintenance,
    VoidCallback? onSchedule,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Maintenance Records',
      message: 'Keep track of your vehicle maintenance to ensure optimal performance.',
      icon: Icons.build_outlined,
      onAction: onAddMaintenance,
      onSecondaryAction: onSchedule,
      actionButtonText: 'Add Maintenance',
      secondaryButtonText: 'Schedule Service',
      style: style.copyWith(
        iconColor: Colors.orange.shade400,
        actionButtonColor: Colors.orange.shade600,
      ),
    );
  }

  /// Factory for search results
  factory EmptyStateWidget.searchResults({
    String? searchQuery,
    VoidCallback? onClearSearch,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Results Found',
      message: searchQuery != null 
          ? 'No results found for "$searchQuery". Try adjusting your search terms.'
          : 'No results found. Try adjusting your search terms.',
      icon: Icons.search_off_outlined,
      onAction: onClearSearch,
      actionButtonText: 'Clear Search',
      style: style.copyWith(
        iconColor: Colors.grey.shade400,
        actionButtonColor: Colors.grey.shade600,
      ),
    );
  }

  /// Factory for filters
  factory EmptyStateWidget.filteredResults({
    VoidCallback? onClearFilters,
    VoidCallback? onAdjustFilters,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'No Matching Results',
      message: 'No items match your current filters. Try adjusting or clearing the filters.',
      icon: Icons.filter_list_off_outlined,
      onAction: onClearFilters,
      onSecondaryAction: onAdjustFilters,
      actionButtonText: 'Clear Filters',
      secondaryButtonText: 'Adjust Filters',
      style: style.copyWith(
        iconColor: Colors.amber.shade400,
        actionButtonColor: Colors.amber.shade600,
      ),
    );
  }

  /// Factory for offline content
  factory EmptyStateWidget.offline({
    VoidCallback? onRetry,
    VoidCallback? onViewCached,
    EmptyStateStyle style = const EmptyStateStyle(),
  }) {
    return EmptyStateWidget(
      title: 'Content Unavailable',
      message: 'This content requires an internet connection. Please check your connection and try again.',
      icon: Icons.cloud_off_outlined,
      onAction: onRetry,
      onSecondaryAction: onViewCached,
      actionButtonText: 'Retry',
      secondaryButtonText: 'View Cached',
      style: style.copyWith(
        iconColor: Colors.red.shade400,
        actionButtonColor: Colors.red.shade600,
      ),
    );
  }
  final String title;
  final String? message;
  final IconData? icon;
  final String? illustrationAsset;
  final VoidCallback? onAction;
  final VoidCallback? onSecondaryAction;
  final String? actionButtonText;
  final String? secondaryButtonText;
  final EmptyStateStyle style;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isCompact) {
      return _buildCompactEmpty(theme);
    }
    
    return _buildFullEmpty(theme);
  }

  Widget _buildCompactEmpty(ThemeData theme) {
    return Container(
      padding: style.padding ?? const EdgeInsets.all(AppSpacing.large),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: style.iconSize ?? AppSizes.iconL,
              color: style.iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: AppSpacing.large),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: style.titleStyle ??
                      theme.textTheme.titleMedium?.copyWith(
                        color: style.titleColor ?? theme.colorScheme.onSurface,
                        fontWeight: AppFontWeights.semiBold,
                      ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: style.messageStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: style.messageColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionButtonText ?? 'Add'),
            ),
        ],
      ),
    );
  }

  Widget _buildFullEmpty(ThemeData theme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        padding: style.padding ?? const EdgeInsets.all(AppSpacing.xxxlarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(theme),
            const SizedBox(height: AppSpacing.xxlarge),
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
              const SizedBox(height: AppSpacing.medium),
              Text(
                message!,
                style: style.messageStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: style.messageColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xxxlarge),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    if (illustrationAsset != null) {
      return SizedBox(
        width: style.illustrationSize ?? AppSizes.imageThumbSize,
        height: style.illustrationSize ?? AppSizes.imageThumbSize,
        child: Image.asset(
          illustrationAsset!,
          fit: BoxFit.contain,
          cacheHeight: (style.illustrationSize ?? AppSizes.imageThumbSize).toInt(),
          cacheWidth: (style.illustrationSize ?? AppSizes.imageThumbSize).toInt(),
          excludeFromSemantics: true,
        ),
      );
    }

    if (icon != null) {
      return Container(
        width: style.illustrationSize ?? AppSizes.imageThumbSize,
        height: style.illustrationSize ?? AppSizes.imageThumbSize,
        decoration: BoxDecoration(
          color: (style.iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: style.iconSize ?? AppSizes.iconXXL,
          color: style.iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(ThemeData theme) {
    final buttons = <Widget>[];

    if (onAction != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onAction,
          icon: Icon(_getActionIcon()),
          label: Text(actionButtonText ?? 'Get Started'),
          style: ElevatedButton.styleFrom(
            backgroundColor: style.actionButtonColor ?? theme.colorScheme.primary,
            foregroundColor: style.actionButtonTextColor ?? theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxlarge, vertical: AppSpacing.medium),
          ),
        ),
      );
    }

    if (onSecondaryAction != null) {
      buttons.add(
        TextButton(
          onPressed: onSecondaryAction,
          style: TextButton.styleFrom(
            foregroundColor: style.secondaryButtonColor ?? theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxlarge, vertical: AppSpacing.medium),
          ),
          child: Text(secondaryButtonText ?? 'Learn More'),
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
        const SizedBox(height: AppSpacing.medium),
        buttons.last,
      ],
    );
  }

  IconData _getActionIcon() {
    if (actionButtonText?.toLowerCase().contains('add') == true) {
      return Icons.add;
    }
    if (actionButtonText?.toLowerCase().contains('retry') == true) {
      return Icons.refresh;
    }
    if (actionButtonText?.toLowerCase().contains('clear') == true) {
      return Icons.clear;
    }
    return Icons.add;
  }
}

/// Animated empty state with fade-in animation
class AnimatedEmptyState extends StatefulWidget {

  const AnimatedEmptyState({
    super.key,
    required this.emptyWidget,
    this.animationDuration = const Duration(milliseconds: 500),
    this.delay = const Duration(milliseconds: 200),
  });
  final EmptyStateWidget emptyWidget;
  final Duration animationDuration;
  final Duration delay;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        child: widget.emptyWidget,
      ),
    );
  }
}

/// Empty state style configuration
class EmptyStateStyle {

  const EmptyStateStyle({
    this.iconColor,
    this.titleColor,
    this.messageColor,
    this.actionButtonColor,
    this.actionButtonTextColor,
    this.secondaryButtonColor,
    this.titleStyle,
    this.messageStyle,
    this.iconSize,
    this.illustrationSize,
    this.padding,
  });
  final Color? iconColor;
  final Color? titleColor;
  final Color? messageColor;
  final Color? actionButtonColor;
  final Color? actionButtonTextColor;
  final Color? secondaryButtonColor;
  
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  
  final double? iconSize;
  final double? illustrationSize;
  final EdgeInsetsGeometry? padding;

  EmptyStateStyle copyWith({
    Color? iconColor,
    Color? titleColor,
    Color? messageColor,
    Color? actionButtonColor,
    Color? actionButtonTextColor,
    Color? secondaryButtonColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    double? iconSize,
    double? illustrationSize,
    EdgeInsetsGeometry? padding,
  }) {
    return EmptyStateStyle(
      iconColor: iconColor ?? this.iconColor,
      titleColor: titleColor ?? this.titleColor,
      messageColor: messageColor ?? this.messageColor,
      actionButtonColor: actionButtonColor ?? this.actionButtonColor,
      actionButtonTextColor: actionButtonTextColor ?? this.actionButtonTextColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      titleStyle: titleStyle ?? this.titleStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      iconSize: iconSize ?? this.iconSize,
      illustrationSize: illustrationSize ?? this.illustrationSize,
      padding: padding ?? this.padding,
    );
  }
}