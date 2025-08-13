// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/home_pragas_constants.dart';
import '../models/praga_item.dart';
import 'recent_list_item.dart';
import 'section_title.dart';

class RecentSection extends StatelessWidget {
  final List<PragaItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Function(String) onItemTap;
  final VoidCallback? onLoadMore;
  final Function(double, double)? onScrollPositionChanged;

  const RecentSection({
    super.key,
    required this.items,
    required this.isLoading,
    this.isLoadingMore = false,
    this.hasMore = false,
    required this.onItemTap,
    this.onLoadMore,
    this.onScrollPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Últimos Acessados',
          icon: Icons.history,
        ),
        _buildRecentCard(),
      ],
    );
  }

  Widget _buildRecentCard() {
    return Card(
      elevation: UiConstants.cardElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.cardBorderRadius)),
      child: _buildCardContent(),
    );
  }

  static const Widget _loadingWidget = Padding(
    padding: EdgeInsets.all(UiConstants.standardPadding),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _buildCardContent() {
    if (isLoading) {
      return _loadingWidget;
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRecentList();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(UiConstants.standardPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesome.clock_rotate_left_solid,
              size: UiConstants.standardIconSize,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: UiConstants.smallPadding),
            Text(
              'Nenhum registro acessado recentemente',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification &&
              onScrollPositionChanged != null) {
            onScrollPositionChanged!(
              notification.metrics.pixels,
              notification.metrics.maxScrollExtent,
            );
          }

          // Infinite scroll trigger
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent *
                      PerformanceConstants.scrollLoadThresholdMultiplier &&
              hasMore &&
              !isLoadingMore &&
              onLoadMore != null) {
            Future.microtask(() => onLoadMore!());
          }

          return false;
        },
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getItemCount(),
          separatorBuilder: (_, __) => const Divider(
              height: UiConstants.dividerHeight,
              indent: UiConstants.dividerIndent),
          itemBuilder: (_, index) {
            if (index == items.length) {
              return _buildLoadMoreButton();
            }
            return _buildListItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    // Lazy loading for list items - only build when near viewport
    return RecentListItem(
      item: items[index],
      onTap: onItemTap,
      isLazyLoaded: true,
    );
  }

  int _getItemCount() {
    int count = items.length;
    if (hasMore && !isLoadingMore) {
      count++; // Add load more button
    }
    return count;
  }

  Widget _buildLoadMoreButton() {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(UiConstants.standardPadding),
        child: Center(
          child: SizedBox(
            width: UiConstants.smallIconSize,
            height: UiConstants.smallIconSize,
            child: CircularProgressIndicator(
                strokeWidth: UiConstants.progressIndicatorStrokeWidth),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(UiConstants.smallPadding),
      child: Center(
        child: TextButton.icon(
          onPressed: onLoadMore,
          icon: const Icon(Icons.expand_more),
          label: const Text('Carregar mais'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.green.shade700,
          ),
        ),
      ),
    );
  }
}
