// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/menu_item_model.dart';
import '../models/section_model.dart';
import '../utils/more_constants.dart';
import '../utils/more_helpers.dart';
import 'menu_item_widget.dart';

class MenuSectionWidget extends StatelessWidget {
  final MenuSection section;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Function(MenuItem)? onItemTap;
  final bool enableCollapse;
  final EdgeInsetsGeometry? padding;

  const MenuSectionWidget({
    super.key,
    required this.section,
    this.isExpanded = true,
    this.onExpansionChanged,
    this.onItemTap,
    this.enableCollapse = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding ?? const EdgeInsets.symmetric(vertical: MoreConstants.itemSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildSectionItems(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = TextStyle(
      fontSize: MoreConstants.titleFontSize,
      fontWeight: MoreConstants.titleFontWeight,
      color: section.color ?? theme.primaryColor,
    );

    if (!enableCollapse) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MoreConstants.defaultPadding,
          vertical: MoreConstants.itemSpacing,
        ),
        child: Row(
          children: [
            if (section.icon != null) ...[
              Icon(
                section.icon,
                color: section.color ?? theme.primaryColor,
                size: MoreConstants.iconSize,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: titleStyle),
                  if (section.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      section.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_buildSectionBadge(context) != null) _buildSectionBadge(context)!,
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onExpansionChanged?.call(!isExpanded),
        borderRadius: BorderRadius.circular(MoreConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MoreConstants.defaultPadding,
            vertical: MoreConstants.itemSpacing,
          ),
          child: Row(
            children: [
              if (section.icon != null) ...[
                Icon(
                  section.icon,
                  color: section.color ?? theme.primaryColor,
                  size: MoreConstants.iconSize,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: titleStyle),
                    if (section.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        section.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_buildSectionBadge(context) != null) _buildSectionBadge(context)!,
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: MoreConstants.fastAnimationDuration,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSectionBadge(BuildContext context) {
    final itemCount = section.visibleItemCount;
    if (itemCount == 0) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (section.color ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        itemCount.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: section.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSectionItems(BuildContext context) {
    if (section.visibleItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(MoreConstants.defaultPadding),
        child: MoreHelpers.buildEmptyWidget('Nenhum item disponível nesta seção'),
      );
    }

    return AnimatedSize(
      duration: MoreConstants.defaultAnimationDuration,
      curve: MoreConstants.defaultAnimationCurve,
      child: Column(
        children: [
          for (int index = 0; index < section.visibleItems.length; index++)
            MenuItemWidget(
              item: section.visibleItems[index],
              onTap: () => onItemTap?.call(section.visibleItems[index]),
              showDivider: index < section.visibleItems.length - 1,
            ),
          if (section.hasMoreItems) _buildShowMoreButton(context),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(BuildContext context) {
    final hiddenCount = section.hiddenItemCount;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // In a real implementation, this would expand to show all items
          MoreHelpers.debugLog('Show more items requested: $hiddenCount hidden');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MoreConstants.defaultPadding,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.expand_more,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                'Mostrar mais $hiddenCount ${hiddenCount == 1 ? 'item' : 'itens'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollapsibleMenuSectionWidget extends StatefulWidget {
  final MenuSection section;
  final Function(MenuItem)? onItemTap;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;

  const CollapsibleMenuSectionWidget({
    super.key,
    required this.section,
    this.onItemTap,
    this.initiallyExpanded = true,
    this.padding,
  });

  @override
  State<CollapsibleMenuSectionWidget> createState() => _CollapsibleMenuSectionWidgetState();
}

class _CollapsibleMenuSectionWidgetState extends State<CollapsibleMenuSectionWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return MenuSectionWidget(
      section: widget.section,
      isExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      onItemTap: widget.onItemTap,
      padding: widget.padding,
    );
  }
}

class CompactMenuSectionWidget extends StatelessWidget {
  final MenuSection section;
  final Function(MenuItem)? onItemTap;
  final int maxItems;

  const CompactMenuSectionWidget({
    super.key,
    required this.section,
    this.onItemTap,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = section.visibleItems.take(maxItems).toList();
    final remainingCount = section.visibleItems.length - visibleItems.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: MoreConstants.itemSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(MoreConstants.defaultPadding),
            child: Row(
              children: [
                if (section.icon != null) ...[
                  Icon(
                    section.icon,
                    color: section.color,
                    size: MoreConstants.iconSize,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: MoreConstants.titleFontSize,
                      fontWeight: MoreConstants.titleFontWeight,
                    ),
                  ),
                ),
                if (remainingCount > 0)
                  Text(
                    '+$remainingCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: section.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final item in visibleItems)
            MenuItemWidget(
              item: item,
              onTap: () => onItemTap?.call(item),
              compact: true,
            ),
        ],
      ),
    );
  }
}
