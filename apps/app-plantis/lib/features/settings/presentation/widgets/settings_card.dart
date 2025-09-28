import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Interactive settings card with expandable content and plant-themed styling
class SettingsCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color? backgroundColor;
  final Color? headerColor;
  final SettingsCardCategory category;
  final bool expandable;
  final VoidCallback? onTap;
  final VoidCallback? onHeaderTap;

  const SettingsCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    required this.children,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.headerColor,
    this.category = SettingsCardCategory.general,
    this.expandable = true,
    this.onTap,
    this.onHeaderTap,
  });

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _hoverController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _hoverAnimation;

  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.expandable) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });

    HapticFeedback.lightImpact();
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.category) {
      case SettingsCardCategory.general:
        return PlantisColors.getPageBackgroundColor(context);
      case SettingsCardCategory.account:
        return PlantisColors.leafLight.withValues(alpha: 0.1);
      case SettingsCardCategory.premium:
        return PlantisColors.sunLight.withValues(alpha: 0.1);
      case SettingsCardCategory.privacy:
        return PlantisColors.waterLight.withValues(alpha: 0.1);
      case SettingsCardCategory.development:
        return PlantisColors.soilLight.withValues(alpha: 0.1);
    }
  }

  Color _getHeaderColor() {
    if (widget.headerColor != null) {
      return widget.headerColor!;
    }

    switch (widget.category) {
      case SettingsCardCategory.general:
        return PlantisColors.primary;
      case SettingsCardCategory.account:
        return PlantisColors.leaf;
      case SettingsCardCategory.premium:
        return PlantisColors.sun;
      case SettingsCardCategory.privacy:
        return PlantisColors.water;
      case SettingsCardCategory.development:
        return PlantisColors.soil;
    }
  }

  Color _getBorderColor() {
    final color = _getHeaderColor();
    return _isHovered
        ? color.withValues(alpha: 0.3)
        : color.withValues(alpha: 0.1);
  }

  Widget _buildLeading() {
    if (widget.leading != null) {
      return widget.leading!;
    }

    if (widget.icon != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getHeaderColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _getHeaderColor().withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 20),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryBadge() {
    String badgeText;
    Color badgeColor;

    switch (widget.category) {
      case SettingsCardCategory.general:
        return const SizedBox.shrink();
      case SettingsCardCategory.account:
        badgeText = 'CONTA';
        badgeColor = PlantisColors.leaf;
        break;
      case SettingsCardCategory.premium:
        badgeText = 'PREMIUM';
        badgeColor = PlantisColors.sun;
        break;
      case SettingsCardCategory.privacy:
        badgeText = 'PRIVACIDADE';
        badgeColor = PlantisColors.water;
        break;
      case SettingsCardCategory.development:
        badgeText = 'DEV';
        badgeColor = PlantisColors.soil;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getBorderColor(), width: 2),
                boxShadow:
                    _isHovered
                        ? [
                          BoxShadow(
                            color: _getHeaderColor().withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
              ),
              child: Column(
                children: [
                  // Header
                  GestureDetector(
                    onTap: () {
                      if (widget.onHeaderTap != null) {
                        widget.onHeaderTap!();
                      } else if (widget.expandable) {
                        _toggleExpanded();
                      } else if (widget.onTap != null) {
                        widget.onTap!();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getHeaderColor().withValues(alpha: 0.05),
                            _getHeaderColor().withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildLeading(),
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
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    _buildCategoryBadge(),
                                  ],
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.expandable) ...[
                            const SizedBox(width: 8),
                            AnimatedBuilder(
                              animation: _iconRotation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _iconRotation.value * 3.14159,
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Expandable content
                  if (widget.expandable)
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: widget.children),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (widget.children.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: widget.children),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Settings card categories with specific theming
enum SettingsCardCategory {
  general, // Default green theme
  account, // Leaf green theme
  premium, // Gold theme for premium features
  privacy, // Blue theme for privacy settings
  development, // Brown theme for dev settings
}

/// Quick settings card for immediate actions
class QuickSettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? badge;

  const QuickSettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? PlantisColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardColor, cardColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
