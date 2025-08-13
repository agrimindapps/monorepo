// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GenericListDisplayWidget<T> extends StatelessWidget {
  final List<T> items;
  final bool isDark;
  final bool isGridMode;
  final Function(T) onItemTap;
  final Widget Function(T item, int index, bool isDark, VoidCallback onTap)
      itemBuilder;
  final String emptyMessage;
  final bool wrapWithCard;
  final int Function(double screenWidth) calculateCrossAxisCount;
  final double gridSpacing;
  final double cardElevation;
  final double borderRadius;
  final Color? darkContainerColor;
  final EdgeInsets? cardMargin;
  final EdgeInsets? cardPadding;
  final Widget? Function(String message, bool isDark)? emptyStateBuilder;

  const GenericListDisplayWidget({
    super.key,
    required this.items,
    required this.isDark,
    required this.isGridMode,
    required this.onItemTap,
    required this.itemBuilder,
    this.emptyMessage = 'Nenhum resultado encontrado',
    this.wrapWithCard = false,
    required this.calculateCrossAxisCount,
    this.gridSpacing = 2.0,
    this.cardElevation = 0.0,
    this.borderRadius = 8.0,
    this.darkContainerColor,
    this.cardMargin,
    this.cardPadding,
    this.emptyStateBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (items.isEmpty) {
      if (emptyStateBuilder != null) {
        final emptyWidget = emptyStateBuilder!(emptyMessage, isDark);
        if (emptyWidget != null) {
          content = emptyWidget;
        } else {
          content = _buildDefaultEmptyState();
        }
      } else {
        content = _buildDefaultEmptyState();
      }
    } else {
      content = isGridMode ? _buildGridView(context) : _buildListView();
    }

    if (wrapWithCard) {
      return Card(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: isDark ? (darkContainerColor ?? Colors.grey[800]) : Colors.white,
        margin: cardMargin ?? EdgeInsets.only(top: isGridMode ? 4.0 : 4.0),
        child: Padding(
          padding: cardPadding ?? const EdgeInsets.all(16.0),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildGridView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = calculateCrossAxisCount(screenWidth);

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: gridSpacing,
      crossAxisSpacing: gridSpacing,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return StaggeredGridTile.fit(
          crossAxisCellCount: 1,
          child: itemBuilder(
            item,
            index,
            isDark,
            () => onItemTap(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListView() {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return itemBuilder(
          item,
          index,
          isDark,
          () => onItemTap(item),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
