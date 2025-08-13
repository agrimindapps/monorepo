// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/praga_cultura_constants.dart';

class LoadingSkeleton extends StatelessWidget {
  final bool isGridMode;
  final int itemCount;
  final bool isDark;

  const LoadingSkeleton({
    super.key,
    this.isGridMode = true,
    this.itemCount = PragaCulturaConstants.skeletonItemCount,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return isGridMode ? _buildGridSkeleton() : _buildListSkeleton();
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: PragaCulturaConstants.minCrossAxisCount,
        childAspectRatio: PragaCulturaConstants.gridChildAspectRatio,
        crossAxisSpacing: PragaCulturaConstants.gridSpacing,
        mainAxisSpacing: PragaCulturaConstants.gridSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonGridItem(isDark: isDark),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(
        itemCount,
        (index) => SkeletonListItem(isDark: isDark),
      ),
    );
  }
}

class SkeletonGridItem extends StatelessWidget {
  final bool isDark;

  const SkeletonGridItem({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(PragaCulturaConstants.smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: double.infinity,
              height: PragaCulturaConstants.skeletonImageHeight,
              borderRadius: BorderRadius.circular(PragaCulturaConstants.smallPadding),
              isDark: isDark,
            ),
            const SizedBox(height: PragaCulturaConstants.smallSpacing * 2),
            ShimmerBox(
              height: PragaCulturaConstants.skeletonTextHeight,
              width: 120,
              isDark: isDark,
            ),
            const SizedBox(height: PragaCulturaConstants.smallSpacing),
            ShimmerBox(
              height: PragaCulturaConstants.skeletonSubtextHeight,
              width: 80,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  final bool isDark;

  const SkeletonListItem({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: PragaCulturaConstants.smallSpacing),
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(PragaCulturaConstants.mediumPadding),
        child: Row(
          children: [
            ShimmerBox(
              width: PragaCulturaConstants.imageSize,
              height: PragaCulturaConstants.imageSize,
              borderRadius: BorderRadius.circular(PragaCulturaConstants.smallPadding),
              isDark: isDark,
            ),
            const SizedBox(width: PragaCulturaConstants.largeSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    height: PragaCulturaConstants.skeletonTextHeight,
                    width: 200,
                    isDark: isDark,
                  ),
                  const SizedBox(height: PragaCulturaConstants.smallSpacing),
                  ShimmerBox(
                    height: PragaCulturaConstants.skeletonSubtextHeight,
                    width: 150,
                    isDark: isDark,
                  ),
                  const SizedBox(height: PragaCulturaConstants.smallSpacing),
                  ShimmerBox(
                    height: PragaCulturaConstants.skeletonSubtextHeight,
                    width: 100,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isDark;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualIsDark = isDark || theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
        color: actualIsDark ? Colors.grey.shade800 : Colors.grey.shade300,
      ),
    );
  }
}
