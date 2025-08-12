// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/themes/manager.dart';

class SkeletonLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoadingWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.grey.shade800,
                      Colors.grey.shade700,
                      Colors.grey.shade800,
                    ]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                      Colors.grey.shade300,
                    ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

class AbastecimentoSkeletonWidget extends StatelessWidget {
  const AbastecimentoSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header skeleton
          _buildAbastecimentoHeaderSkeleton(context),
          const SizedBox(height: 16),

          // Metrics skeleton
          _buildMetricsSkeleton(context),
          const SizedBox(height: 16),

          // List items skeleton
          ..._buildAbastecimentoListItemsSkeleton(context),
        ],
      ),
    );
  }

  Widget _buildAbastecimentoHeaderSkeleton(BuildContext context) {
    return const Row(
      children: [
        SkeletonLoadingWidget(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoadingWidget(
                width: double.infinity,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              SizedBox(height: 8),
              SkeletonLoadingWidget(
                width: 200,
                height: 14,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSkeleton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCardSkeleton(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCardSkeleton(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCardSkeleton(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCardSkeleton(context),
        ),
      ],
    );
  }

  Widget _buildMetricCardSkeleton(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoadingWidget(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          SizedBox(height: 8),
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 14,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          SizedBox(height: 4),
          SkeletonLoadingWidget(
            width: double.infinity,
            height: 12,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAbastecimentoListItemsSkeleton(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return List.generate(
      3,
      (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonLoadingWidget(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoadingWidget(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      SizedBox(height: 8),
                      SkeletonLoadingWidget(
                        width: 150,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoSkeleton(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoSkeleton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSkeleton() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoadingWidget(
          width: double.infinity,
          height: 12,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        SizedBox(height: 4),
        SkeletonLoadingWidget(
          width: 60,
          height: 10,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }
}

class OdometroSkeletonWidget extends StatelessWidget {
  const OdometroSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header skeleton
          _buildHeaderSkeleton(context),
          const SizedBox(height: 16),

          // List items skeleton
          ..._buildListItemsSkeleton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoadingWidget(
            width: 120,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListItemsSkeleton(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return List.generate(
      3,
      (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonLoadingWidget(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoadingWidget(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      SizedBox(height: 8),
                      SkeletonLoadingWidget(
                        width: 150,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
                SkeletonLoadingWidget(
                  width: 60,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (index) => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoadingWidget(
                      width: 80,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 4),
                    SkeletonLoadingWidget(
                      width: 40,
                      height: 10,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
