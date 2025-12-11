import 'package:flutter/material.dart';

/// Enhanced loading states with better UX and animations
class EnhancedLoadingStates {
  /// Adaptive loading indicator that changes based on context
  static Widget adaptiveLoading({
    String? message,
    double size = 24.0,
    Color? color,
    bool showMessage = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: size > 30 ? 3.0 : 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ),
            if (showMessage && message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }

  /// Shimmer loading effect for list items
  static Widget shimmerLoading({
    double height = 80,
    double width = double.infinity,
    BorderRadius? borderRadius,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: _ShimmerAnimation(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.grey[800]!,
                          Colors.grey[700]!,
                          Colors.grey[800]!,
                        ]
                      : [
                          Colors.grey[300]!,
                          Colors.grey[100]!,
                          Colors.grey[300]!,
                        ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                ),
                borderRadius: borderRadius ?? BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Loading overlay for the entire screen
  static Widget screenLoading({
    String? message,
    bool showBackground = true,
    Color? backgroundColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: showBackground
              ? (backgroundColor ??
                    theme.colorScheme.surface.withValues(alpha: 0.8))
              : Colors.transparent,
          child: Center(
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: adaptiveLoading(
                  message: message ?? 'Carregando...',
                  size: 32,
                  showMessage: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Skeleton loader for specific content types
  static Widget skeletonLoader({
    required SkeletonType type,
    int itemCount = 3,
  }) {
    return Column(
      children: List.generate(itemCount, (index) {
        switch (type) {
          case SkeletonType.plantCard:
            return _buildPlantCardSkeleton();
          case SkeletonType.taskItem:
            return _buildTaskItemSkeleton();
          case SkeletonType.listTile:
            return _buildListTileSkeleton();
        }
      }),
    );
  }

  static Widget _buildPlantCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: shimmerLoading(
        height: 120,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static Widget _buildTaskItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          shimmerLoading(
            height: 40,
            width: 40,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerLoading(height: 16, width: double.infinity),
                const SizedBox(height: 4),
                shimmerLoading(height: 12, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildListTileSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: shimmerLoading(height: 60),
    );
  }

  /// Progress indicator with percentage
  static Widget progressLoading({
    required double progress,
    String? message,
    bool showPercentage = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final percentage = (progress * 100).round();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (showPercentage)
                    Text(
                      '$percentage%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Skeleton loader types
enum SkeletonType { plantCard, taskItem, listTile }

/// Shimmer animation widget
class _ShimmerAnimation extends StatefulWidget {
  final Widget child;

  const _ShimmerAnimation({required this.child});

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * 200, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Mixin for widgets with loading states
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _loadingMessage;

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  /// Show loading state
  void showLoading({String? message}) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  /// Hide loading state
  void hideLoading() {
    setState(() {
      _isLoading = false;
      _loadingMessage = null;
    });
  }

  /// Build loading overlay if needed
  Widget buildWithLoading({required Widget child}) {
    return Stack(
      children: [
        child,
        if (_isLoading)
          EnhancedLoadingStates.screenLoading(message: _loadingMessage),
      ],
    );
  }
}
