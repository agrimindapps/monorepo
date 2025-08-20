// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../config/despesas_page_config.dart';

/// Skeleton loading widget for better loading UX
class SkeletonLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4.0,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DespesasPageConfig.getAnimationDuration(slow: true),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, _animation.value)!,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loading specifically for despesa cards
class DespesaCardSkeleton extends StatelessWidget {
  const DespesaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: DespesasPageConfig.cardElevation,
      margin: const EdgeInsets.all(DespesasPageConfig.cardMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DespesasPageConfig.cardBorderRadius),
      ),
      child: const Padding(
        padding: EdgeInsets.all(DespesasPageConfig.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonLoading(width: 24, height: 24, borderRadius: 12),
                SizedBox(width: DespesasPageConfig.spacingSmall),
                Expanded(
                  child: SkeletonLoading(width: double.infinity, height: 16),
                ),
                SizedBox(width: DespesasPageConfig.spacingSmall),
                SkeletonLoading(width: 80, height: 16),
              ],
            ),
            SizedBox(height: DespesasPageConfig.spacingSmall),
            SkeletonLoading(width: double.infinity, height: 14),
            SizedBox(height: DespesasPageConfig.spacingTiny),
            SkeletonLoading(width: 120, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Loading widget for the entire list
class DespesasListSkeleton extends StatelessWidget {
  final int itemCount;

  const DespesasListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const DespesaCardSkeleton(),
      ),
    );
  }
}
