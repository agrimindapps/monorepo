import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sistema de skeleton loading com shimmer effect para melhorar UX
/// durante carregamentos de lista, resolvendo problemas identificados na análise
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration animationDuration;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.leftToRight,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        widget.baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return _createShimmerGradient(
              bounds,
              baseColor,
              highlightColor,
              _animation.value,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  LinearGradient _createShimmerGradient(
    Rect bounds,
    Color baseColor,
    Color highlightColor,
    double animationValue,
  ) {
    final double width = bounds.width;
    final double position = animationValue * width;

    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            math.max(0.0, (position - width) / width),
            position / width,
            math.min(1.0, (position + width) / width),
          ],
        );
      case ShimmerDirection.rightToLeft:
        return LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            math.max(0.0, (position - width) / width),
            position / width,
            math.min(1.0, (position + width) / width),
          ],
        );
      case ShimmerDirection.topToBottom:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            math.max(0.0, (position - width) / width),
            position / width,
            math.min(1.0, (position + width) / width),
          ],
        );
    }
  }
}

/// Direções de animação do shimmer
enum ShimmerDirection { leftToRight, rightToLeft, topToBottom }

/// Skeleton pré-definidos para diferentes tipos de conteúdo
class SkeletonShapes {
  /// Skeleton para card de planta
  static Widget plantCard({
    double height = 120,
    double width = double.infinity,
    bool isLoading = true,
  }) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 32,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton para item de tarefa
  static Widget taskItem({bool isLoading = true}) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton para ListTile genérico
  static Widget listTile({
    bool showLeading = true,
    bool showTrailing = true,
    bool isLoading = true,
  }) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (showLeading) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 16),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Skeleton para texto simples
  static Widget text({
    double height = 16,
    double? width,
    bool isLoading = true,
    BorderRadius? borderRadius,
  }) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  /// Skeleton para imagem circular
  static Widget circularImage({double size = 48, bool isLoading = true}) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }

  /// Skeleton para imagem retangular
  static Widget rectangularImage({
    double width = double.infinity,
    double height = 120,
    BorderRadius? borderRadius,
    bool isLoading = true,
  }) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget para criar listas de skeletons
class SkeletonList extends StatelessWidget {
  final Widget Function(int index) itemBuilder;
  final int itemCount;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const SkeletonList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.isLoading,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: padding,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }
}

/// Widget conveniente para skeleton de lista de plantas
class PlantListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isLoading;

  const PlantListSkeleton({
    super.key,
    this.itemCount = 3,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      isLoading: isLoading,
      itemCount: itemCount,
      itemBuilder: (index) => SkeletonShapes.plantCard(),
    );
  }
}

/// Widget conveniente para skeleton de lista de tarefas
class TaskListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isLoading;

  const TaskListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      isLoading: isLoading,
      itemCount: itemCount,
      itemBuilder: (index) => SkeletonShapes.taskItem(),
    );
  }
}
