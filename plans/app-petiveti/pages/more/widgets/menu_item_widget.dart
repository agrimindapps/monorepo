// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/menu_item_model.dart';
import '../utils/more_constants.dart';
import '../utils/more_helpers.dart';

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool compact;
  final EdgeInsetsGeometry? padding;

  const MenuItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.showDivider = false,
    this.compact = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(context),
        if (showDivider) const Divider(height: 1, indent: 72),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(MoreConstants.borderRadius),
        child: Opacity(
          opacity: item.isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: MoreConstants.defaultPadding,
              vertical: compact ? 8 : 12,
            ),
            child: Row(
              children: [
                _buildLeadingIcon(context),
                const SizedBox(width: 16),
                Expanded(child: _buildContent(context)),
                if (item.showBadge) ...[
                  const SizedBox(width: 8),
                  _buildBadge(context),
                ],
                const SizedBox(width: 8),
                _buildTrailingIcon(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return Container(
      width: MoreConstants.iconContainerSize,
      height: MoreConstants.iconContainerSize,
      decoration: BoxDecoration(
        color: MoreHelpers.getColorWithOpacity(item.color, 0.1),
        borderRadius: BorderRadius.circular(MoreConstants.borderRadius),
      ),
      child: Icon(
        item.icon,
        color: item.color,
        size: compact ? 20 : MoreConstants.iconSize,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontWeight: MoreConstants.subtitleFontWeight,
            fontSize: compact ? 14 : MoreConstants.bodyFontSize,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (item.subtitle != null && !compact) ...[
          const SizedBox(height: 2),
          Text(
            item.subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    if (!item.showBadge || item.badgeText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item.badgeText!,
        style: TextStyle(
          color: MoreHelpers.getContrastColor(item.color),
          fontSize: MoreConstants.captionFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    final theme = Theme.of(context);
    final trailingIcon = MoreHelpers.getTrailingIconForType(item.type);
    
    return Icon(
      trailingIcon,
      color: theme.iconTheme.color?.withValues(alpha: 0.5),
      size: compact ? 16 : 20,
    );
  }
}

class HighlightedMenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;
  final String? searchQuery;
  final bool showDivider;

  const HighlightedMenuItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.searchQuery,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuItemWidget(
          item: item,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 72),
      ],
    );
  }
}

class DetailedMenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? subtitle;

  const DetailedMenuItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: MoreConstants.defaultPadding,
        vertical: MoreConstants.itemSpacing / 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(MoreConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(MoreConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: MoreHelpers.getColorWithOpacity(item.color, 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.showBadge && item.badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: TextStyle(
                            color: MoreHelpers.getContrastColor(item.color),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ] else ...[
                      const SizedBox(width: 8),
                      Icon(
                        MoreHelpers.getTrailingIconForType(item.type),
                        color: theme.iconTheme.color?.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  subtitle!,
                ],
                if (_shouldShowDescription()) ...[
                  const SizedBox(height: 12),
                  Text(
                    MoreHelpers.getDescriptionForType(item.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDescription() {
    // Show description for non-navigation items
    return item.type != MenuItemType.navigation;
  }
}

class GridMenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;
  final double? aspectRatio;

  const GridMenuItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: aspectRatio ?? 1.2,
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(MoreConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: MoreHelpers.getColorWithOpacity(item.color, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.showBadge && item.badgeText != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badgeText!,
                        style: TextStyle(
                          color: MoreHelpers.getContrastColor(item.color),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
