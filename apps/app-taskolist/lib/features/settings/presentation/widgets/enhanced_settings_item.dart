import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Enhanced settings item with animations, haptic feedback and multiple types
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
        return AppColors.primaryColor;
      case SettingsItemType.premium:
        return AppColors.premium;
      case SettingsItemType.danger:
        return AppColors.error;
      case SettingsItemType.info:
        return AppColors.info;
      case SettingsItemType.success:
        return AppColors.success;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (!widget.enabled) {
      return Colors.grey.withValues(alpha: 0.1);
    }

    if (_isHovered) {
      switch (widget.type) {
        case SettingsItemType.normal:
          return AppColors.primaryColor.withValues(alpha: 0.08);
        case SettingsItemType.premium:
          return AppColors.premium.withValues(alpha: 0.08);
        case SettingsItemType.danger:
          return AppColors.error.withValues(alpha: 0.08);
        case SettingsItemType.info:
          return AppColors.info.withValues(alpha: 0.08);
        case SettingsItemType.success:
          return AppColors.success.withValues(alpha: 0.08);
      }
    }

    return Colors.transparent;
  }

  Widget _buildIcon(ThemeData theme) {
    if (widget.loading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _getIconColor(theme).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _getIconColor(theme),
        borderRadius: BorderRadius.circular(10),
        boxShadow: widget.enabled
            ? [
                BoxShadow(
                  color: _getIconColor(theme).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(widget.icon, color: Colors.white, size: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.premium, AppColors.premium.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.badge!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
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
      color: widget.enabled
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
                onLongPress: widget.enabled && !widget.loading
                    ? widget.onLongPress
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(theme),
                    border: !widget.isLast
                        ? Border(
                            bottom: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          )
                        : null,
                    borderRadius: BorderRadius.vertical(
                      top: widget.isFirst
                          ? const Radius.circular(12)
                          : Radius.zero,
                      bottom: widget.isLast
                          ? const Radius.circular(12)
                          : Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildIcon(theme),
                      const SizedBox(width: 14),
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
                                      color: widget.enabled
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
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.premium,
                                          AppColors.premium.withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 3),
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
                              const SizedBox(height: 3),
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  color: widget.enabled
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.38,
                                        ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
  normal, // Default theme
  premium, // Premium features (gold)
  danger, // Destructive actions (red)
  info, // Informational items (blue)
  success, // Success states (green)
}
