// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/skeleton_constants.dart';
import '../widgets/cultura_skeleton_items.dart';
import '../widgets/loading_skeleton_widget.dart';

/// Smart Skeleton System for Lista Culturas
///
/// Provides context-aware skeleton loading that adapts to different states:
/// - Initial loading: Full skeleton with progress
/// - Search loading: Quick skeleton items
/// - Refresh loading: Shimmer overlay
class SmartSkeletonSystem extends StatefulWidget {
  final bool isDark;
  final SkeletonType type;
  final ViewMode viewMode;
  final int? customItemCount;
  final String? customMessage;
  final bool showProgress;

  const SmartSkeletonSystem({
    super.key,
    required this.isDark,
    required this.type,
    this.viewMode = ViewMode.list,
    this.customItemCount,
    this.customMessage,
    this.showProgress = true,
  });

  @override
  State<SmartSkeletonSystem> createState() => _SmartSkeletonSystemState();
}

class _SmartSkeletonSystemState extends State<SmartSkeletonSystem> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case SkeletonType.initial:
        return _buildInitialLoadingSkeleton();
      case SkeletonType.search:
        return _buildSearchLoadingSkeleton();
      case SkeletonType.refresh:
        return _buildRefreshLoadingSkeleton();
      case SkeletonType.filter:
        return _buildFilterLoadingSkeleton();
    }
  }

  Widget _buildInitialLoadingSkeleton() {
    return EnhancedLoadingSkeletonWidget(
      isDark: widget.isDark,
      viewMode: widget.viewMode,
      progressText:
          widget.customMessage ?? 'Carregando culturas disponíveis...',
      estimatedTimeSeconds: 3,
    );
  }

  Widget _buildSearchLoadingSkeleton() {
    final itemCount = widget.customItemCount ?? SkeletonConfig.defaultItemCount;

    return Column(
      children: [
        // Search feedback
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.blue.shade900.withValues(alpha: 0.3)
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  widget.isDark ? Colors.blue.shade700 : Colors.blue.shade200,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDark ? Colors.blue.shade300 : Colors.blue.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.customMessage ?? 'Buscando culturas...',
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.blue.shade200
                        : Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Quick skeleton items
        Expanded(
          child: widget.viewMode == ViewMode.grid
              ? _buildSearchGridSkeleton(itemCount)
              : _buildSearchListSkeleton(itemCount),
        ),
      ],
    );
  }

  Widget _buildRefreshLoadingSkeleton() {
    return Stack(
      children: [
        // Dimmed background
        Container(
          color: (widget.isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
        ),
        // Centered loading indicator
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF2A2A2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDark
                        ? Colors.green.shade300
                        : Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.customMessage ?? 'Atualizando lista...',
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterLoadingSkeleton() {
    final itemCount = widget.customItemCount ?? 4;

    return Column(
      children: [
        // Filter feedback
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.orange.shade900.withValues(alpha: 0.3)
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDark
                        ? Colors.orange.shade300
                        : Colors.orange.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.customMessage ?? 'Aplicando filtros...',
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.orange.shade200
                      : Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Compact skeleton items
        Expanded(
          child: widget.viewMode == ViewMode.grid
              ? _buildFilterGridSkeleton(itemCount)
              : _buildFilterListSkeleton(itemCount),
        ),
      ],
    );
  }

  Widget _buildSearchListSkeleton(int itemCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 65,
        endIndent: 10,
        color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
      itemBuilder: (_, index) => CulturaListSkeleton(
        isDark: widget.isDark,
        animationIndex: index,
        showShimmer: true,
      ),
    );
  }

  Widget _buildSearchGridSkeleton(int itemCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) => CulturaGridSkeleton(
        isDark: widget.isDark,
        animationIndex: index,
        showShimmer: true,
      ),
    );
  }

  Widget _buildFilterListSkeleton(int itemCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, index) => CulturaListSkeleton(
        isDark: widget.isDark,
        animationIndex: index,
        showShimmer: false, // No shimmer for filter loading
      ),
    );
  }

  Widget _buildFilterGridSkeleton(int itemCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.0, // More compact for filter view
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) => CulturaGridSkeleton(
        isDark: widget.isDark,
        animationIndex: index,
        showShimmer: false, // No shimmer for filter loading
      ),
    );
  }
}

/// Types of skeleton loading states
enum SkeletonType {
  /// Initial page load - full skeleton with progress
  initial,

  /// Search operation - quick skeleton with search feedback
  search,

  /// Pull-to-refresh - overlay skeleton
  refresh,

  /// Filter operation - compact skeleton
  filter,
}

/// Skeleton Factory for easy creation
class SkeletonFactory {
  SkeletonFactory._();

  /// Create initial loading skeleton
  static Widget initial({
    required bool isDark,
    ViewMode viewMode = ViewMode.list,
    String? message,
  }) {
    return SmartSkeletonSystem(
      isDark: isDark,
      type: SkeletonType.initial,
      viewMode: viewMode,
      customMessage: message,
    );
  }

  /// Create search loading skeleton
  static Widget search({
    required bool isDark,
    ViewMode viewMode = ViewMode.list,
    String? message,
    int itemCount = 6,
  }) {
    return SmartSkeletonSystem(
      isDark: isDark,
      type: SkeletonType.search,
      viewMode: viewMode,
      customMessage: message,
      customItemCount: itemCount,
    );
  }

  /// Create refresh loading skeleton
  static Widget refresh({
    required bool isDark,
    String? message,
  }) {
    return SmartSkeletonSystem(
      isDark: isDark,
      type: SkeletonType.refresh,
      customMessage: message,
      showProgress: false,
    );
  }

  /// Create filter loading skeleton
  static Widget filter({
    required bool isDark,
    ViewMode viewMode = ViewMode.list,
    String? message,
    int itemCount = 4,
  }) {
    return SmartSkeletonSystem(
      isDark: isDark,
      type: SkeletonType.filter,
      viewMode: viewMode,
      customMessage: message,
      customItemCount: itemCount,
    );
  }
}
