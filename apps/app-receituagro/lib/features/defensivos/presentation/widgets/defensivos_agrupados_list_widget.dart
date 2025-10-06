import 'package:flutter/material.dart';

import '../../data/defensivo_agrupado_item_model.dart';
import '../../data/defensivos_agrupados_category.dart';
import '../../data/defensivos_agrupados_state.dart';
import '../../data/defensivos_agrupados_view_mode.dart';
import 'defensivo_agrupado_item_widget.dart';
import 'defensivos_agrupados_empty_state_widget.dart';
import 'defensivos_agrupados_loading_skeleton_widget.dart';

/// Widget principal de lista para Defensivos Agrupados
/// Gerencia exibição de lista, grid, loading e empty states
class DefensivosAgrupadosListWidget extends StatelessWidget {
  final DefensivosAgrupadosState state;
  final DefensivosAgrupadosCategory category;
  final ScrollController scrollController;
  final void Function(DefensivoAgrupadoItemModel) onItemTap;

  const DefensivosAgrupadosListWidget({
    super.key,
    required this.state,
    required this.category,
    required this.scrollController,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.isLoading && state.defensivosListFiltered.isEmpty) {
      return DefensivosAgrupadosLoadingSkeletonWidget(
        viewMode: state.selectedViewMode,
        isDark: state.isDark,
        itemCount: 12,
      );
    }
    if (state.defensivosListFiltered.isEmpty) {
      return DefensivosAgrupadosEmptyStateWidget(
        category: category,
        isDark: state.isDark,
        isSearching: state.searchText.isNotEmpty,
        searchText: state.searchText,
        navigationLevel: state.navigationLevel,
      );
    }
    return _buildListContainer(context);
  }

  Widget _buildListContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    if (state.selectedViewMode.isList) {
      return _buildListViewMode();
    } else {
      return _buildGridViewMode();
    }
  }

  Widget _buildListViewMode() {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: state.defensivosListFiltered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final item = state.defensivosListFiltered[index];
        return RepaintBoundary(
          child: DefensivoAgrupadoItemWidget(
            item: item,
            viewMode: state.selectedViewMode,
            category: category,
            isDark: state.isDark,
            onTap: () => onItemTap(item),
          ),
        );
      },
    );
  }

  Widget _buildGridViewMode() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.defensivosListFiltered.length,
          itemBuilder: (context, index) {
            final item = state.defensivosListFiltered[index];
            return RepaintBoundary(
              child: DefensivoAgrupadoItemWidget(
                item: item,
                viewMode: state.selectedViewMode,
                category: category,
                isDark: state.isDark,
                onTap: () => onItemTap(item),
              ),
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth <= 480) return 2;
    if (screenWidth <= 768) return 3;
    if (screenWidth <= 1024) return 4;
    return 5;
  }
}