import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Enhanced settings item with multiple types and improved UX
class EnhancedSettingsItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final bool loading;
  final SettingsItemType type;
  final String? badge;
  final VoidCallback? onLongPress;

  const EnhancedSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
    this.enabled = true,
    this.loading = false,
    this.type = SettingsItemType.normal,
    this.badge,
    this.onLongPress,
  });

  @override
  State<EnhancedSettingsItem> createState() => _EnhancedSettingsItemState();
}

class _EnhancedSettingsItemState extends State<EnhancedSettingsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.loading) {
      _animationController.forward();
      // Haptic feedback for interactive items
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled && !widget.loading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled && !widget.loading) {
      _animationController.reverse();
    }
  }

  Color _getIconColor(ThemeData theme) {
    if (!widget.enabled) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.38);
    }

    if (widget.iconColor != null) {
      return widget.iconColor!;
    }

    switch (widget.type) {
      case SettingsItemType.normal:
        return PlantisColors.primary;
      case SettingsItemType.premium:
        return PlantisColors.sun;
      case SettingsItemType.danger:
        return PlantisColors.error;
      case SettingsItemType.info:
        return PlantisColors.water;
      case SettingsItemType.success:
        return PlantisColors.success;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (!widget.enabled) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }

    if (_isHovered) {
      switch (widget.type) {
        case SettingsItemType.normal:
          return PlantisColors.primaryLight.withValues(alpha: 0.08);
        case SettingsItemType.premium:
          return PlantisColors.sunLight.withValues(alpha: 0.08);
        case SettingsItemType.danger:
          return PlantisColors.errorLight.withValues(alpha: 0.08);
        case SettingsItemType.info:
          return PlantisColors.waterLight.withValues(alpha: 0.08);
        case SettingsItemType.success:
          return PlantisColors.successLight.withValues(alpha: 0.08);
      }
    }

    return Colors.transparent;
  }

  Widget _buildIcon(ThemeData theme) {
    if (widget.loading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _getIconColor(theme).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(_getIconColor(theme)),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getIconColor(theme),
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            widget.enabled
                ? [
                  BoxShadow(
                    color: _getIconColor(theme).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Icon(widget.icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    if (widget.trailing != null) {
      return widget.trailing!;
    }

    if (widget.type == SettingsItemType.premium && widget.badge != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PlantisColors.sun,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.badge!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      );
    }

    return Icon(
      Icons.chevron_right,
      color:
          widget.enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.enabled && !widget.loading ? widget.onTap : null,
                onLongPress:
                    widget.enabled && !widget.loading
                        ? widget.onLongPress
                        : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(theme),
                    border:
                        !widget.isLast
                            ? Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            )
                            : null,
                    borderRadius: BorderRadius.vertical(
                      top:
                          widget.isFirst
                              ? const Radius.circular(12)
                              : Radius.zero,
                      bottom:
                          widget.isLast
                              ? const Radius.circular(12)
                              : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildIcon(theme),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      color:
                                          widget.enabled
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.38),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.type == SettingsItemType.premium)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: PlantisColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  color:
                                      widget.enabled
                                          ? theme.colorScheme.onSurfaceVariant
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.38),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildTrailing(theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Settings item types with specific styling
enum SettingsItemType {
  normal, // Default green theme
  premium, // Gold/yellow theme for premium features
  danger, // Red theme for destructive actions
  info, // Blue theme for informational items
  success, // Green theme for success states
}
