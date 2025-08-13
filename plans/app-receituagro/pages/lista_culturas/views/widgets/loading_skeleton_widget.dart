// Flutter imports:
import 'package:flutter/material.dart';

/// Skeleton Loading Widget with Shimmer Effect
///
/// Provides modern skeleton screens for different view modes (list/grid)
/// with smooth shimmer animations and accessibility support.
class LoadingSkeletonWidget extends StatefulWidget {
  final bool isDark;
  final ViewMode viewMode;
  final int itemCount;
  final bool showShimmer;

  const LoadingSkeletonWidget({
    super.key,
    required this.isDark,
    this.viewMode = ViewMode.list,
    this.itemCount = 8,
    this.showShimmer = true,
  });

  @override
  State<LoadingSkeletonWidget> createState() => _LoadingSkeletonWidgetState();
}

class _LoadingSkeletonWidgetState extends State<LoadingSkeletonWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _entranceController.forward();
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando lista de culturas',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: widget.viewMode == ViewMode.grid
              ? _buildGridSkeleton()
              : _buildListSkeleton(),
        ),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 65,
        endIndent: 10,
        color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
      itemBuilder: (_, index) => _buildListItemSkeleton(index),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (_, index) => _buildGridItemSkeleton(index),
    );
  }

  Widget _buildListItemSkeleton(int index) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // Avatar skeleton
                  _buildShimmerContainer(
                    width: 45,
                    height: 45,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),
                  // Content skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        _buildShimmerContainer(
                          width: double.infinity,
                          height: 16,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 8),
                        // Subtitle skeleton
                        _buildShimmerContainer(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 12,
                          borderRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Arrow skeleton
                  _buildShimmerContainer(
                    width: 12,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridItemSkeleton(int index) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E1E22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon skeleton
                  Row(
                    children: [
                      _buildShimmerContainer(
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                      ),
                      const Spacer(),
                      _buildShimmerContainer(
                        width: 8,
                        height: 8,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Title skeleton
                  _buildShimmerContainer(
                    width: double.infinity,
                    height: 14,
                    borderRadius: 7,
                  ),
                  const SizedBox(height: 6),
                  // Subtitle skeleton
                  _buildShimmerContainer(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    if (!widget.showShimmer) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      Colors.grey.shade800,
                      Colors.grey.shade700,
                      Colors.grey.shade800,
                    ]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// View Mode for skeleton loading
enum ViewMode {
  list,
  grid,
}

/// Enhanced Loading Skeleton with Progress Information
class EnhancedLoadingSkeletonWidget extends StatefulWidget {
  final bool isDark;
  final ViewMode viewMode;
  final String? progressText;
  final double? progress;
  final int estimatedTimeSeconds;

  const EnhancedLoadingSkeletonWidget({
    super.key,
    required this.isDark,
    this.viewMode = ViewMode.list,
    this.progressText,
    this.progress,
    this.estimatedTimeSeconds = 3,
  });

  @override
  State<EnhancedLoadingSkeletonWidget> createState() =>
      _EnhancedLoadingSkeletonWidgetState();
}

class _EnhancedLoadingSkeletonWidgetState
    extends State<EnhancedLoadingSkeletonWidget> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: Duration(seconds: widget.estimatedTimeSeconds),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
        if (_elapsedSeconds < widget.estimatedTimeSeconds) {
          _startTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator section
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                widget.isDark ? const Color(0xFF2A2A2E) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hourglass_top,
                    size: 20,
                    color: widget.isDark
                        ? Colors.green.shade300
                        : Colors.green.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.progressText ?? 'Carregando lista de culturas...',
                      style: TextStyle(
                        color: widget.isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${_elapsedSeconds}s',
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: widget.progress ?? _progressAnimation.value,
                    backgroundColor: widget.isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isDark
                          ? Colors.green.shade300
                          : Colors.green.shade600,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ],
          ),
        ),
        // Skeleton content
        Expanded(
          child: LoadingSkeletonWidget(
            isDark: widget.isDark,
            viewMode: widget.viewMode,
            itemCount: 6,
            showShimmer: true,
          ),
        ),
      ],
    );
  }
}
