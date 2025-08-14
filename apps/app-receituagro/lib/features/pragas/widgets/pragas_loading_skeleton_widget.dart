import 'package:flutter/material.dart';
import '../models/praga_view_mode.dart';

class PragasLoadingSkeletonWidget extends StatefulWidget {
  final PragaViewMode viewMode;
  final bool isDark;

  const PragasLoadingSkeletonWidget({
    super.key,
    required this.viewMode,
    required this.isDark,
  });

  @override
  State<PragasLoadingSkeletonWidget> createState() => _PragasLoadingSkeletonWidgetState();
}

class _PragasLoadingSkeletonWidgetState extends State<PragasLoadingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.viewMode.isList 
        ? _buildListSkeleton()
        : _buildGridSkeleton();
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(8, (index) => _buildListSkeletonItem()),
    );
  }

  Widget _buildGridSkeleton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        final itemCount = (crossAxisCount * 4).clamp(8, 20);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => _buildGridSkeletonItem(),
        );
      },
    );
  }

  Widget _buildListSkeletonItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDark ? const Color(0xFF222228) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildShimmerBox(48, 48, 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(null, 20, 4),
                  const SizedBox(height: 8),
                  _buildShimmerBox(150, 16, 4),
                  const SizedBox(height: 8),
                  _buildShimmerBox(80, 24, 12),
                ],
              ),
            ),
            _buildShimmerBox(24, 24, 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSkeletonItem() {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDark ? const Color(0xFF222228) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerBox(56, 56, 12),
            const SizedBox(height: 12),
            _buildShimmerBox(null, 16, 4),
            const SizedBox(height: 6),
            _buildShimmerBox(80, 14, 4),
            const SizedBox(height: 8),
            _buildShimmerBox(60, 20, 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double? width, double height, double borderRadius) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.isDark 
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
                (_shimmerAnimation.value - 1.0).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 1.0).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1100) return 4;
    return 5;
  }
}