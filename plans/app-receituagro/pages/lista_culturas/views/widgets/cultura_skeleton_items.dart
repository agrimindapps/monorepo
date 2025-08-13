// Flutter imports:
import 'package:flutter/material.dart';

/// Skeleton Item for Cultura Grid View
///
/// Provides skeleton loading for individual grid items with shimmer effect
class CulturaGridSkeleton extends StatefulWidget {
  final bool isDark;
  final int animationIndex;
  final bool showShimmer;

  const CulturaGridSkeleton({
    super.key,
    required this.isDark,
    this.animationIndex = 0,
    this.showShimmer = true,
  });

  @override
  State<CulturaGridSkeleton> createState() => _CulturaGridSkeletonState();
}

class _CulturaGridSkeletonState extends State<CulturaGridSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _entranceController = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.animationIndex * 100)),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E1E22) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isDark ? Colors.black : Colors.grey)
                        .withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with icon and badge
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
                    const SizedBox(height: 16),
                    // Title skeleton
                    _buildShimmerContainer(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 8,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle skeleton
                    _buildShimmerContainer(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 12,
                      borderRadius: 6,
                    ),
                    const SizedBox(height: 12),
                    // Tags skeleton
                    Row(
                      children: [
                        _buildShimmerContainer(
                          width: 40,
                          height: 8,
                          borderRadius: 4,
                        ),
                        const SizedBox(width: 8),
                        _buildShimmerContainer(
                          width: 30,
                          height: 8,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ],
                ),
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

/// Skeleton Item for Cultura List View
///
/// Provides skeleton loading for individual list items with shimmer effect
class CulturaListSkeleton extends StatefulWidget {
  final bool isDark;
  final int animationIndex;
  final bool showShimmer;

  const CulturaListSkeleton({
    super.key,
    required this.isDark,
    this.animationIndex = 0,
    this.showShimmer = true,
  });

  @override
  State<CulturaListSkeleton> createState() => _CulturaListSkeletonState();
}

class _CulturaListSkeletonState extends State<CulturaListSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _entranceController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.animationIndex * 80)),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
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
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
