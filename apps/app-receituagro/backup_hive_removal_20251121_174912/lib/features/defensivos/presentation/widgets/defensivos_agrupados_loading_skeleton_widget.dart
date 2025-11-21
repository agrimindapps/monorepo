import 'package:flutter/material.dart';
import '../../data/defensivos_agrupados_view_mode.dart';

class DefensivosAgrupadosLoadingSkeletonWidget extends StatefulWidget {
  final DefensivosAgrupadosViewMode viewMode;
  final bool isDark;
  final int itemCount;

  const DefensivosAgrupadosLoadingSkeletonWidget({
    super.key,
    required this.viewMode,
    required this.isDark,
    this.itemCount = 12,
  });

  @override
  State<DefensivosAgrupadosLoadingSkeletonWidget> createState() => 
      _DefensivosAgrupadosLoadingSkeletonWidgetState();
}

class _DefensivosAgrupadosLoadingSkeletonWidgetState 
    extends State<DefensivosAgrupadosLoadingSkeletonWidget>
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.itemCount.clamp(6, 10),
      itemBuilder: (context, index) => _buildListSkeletonItem(),
    );
  }

  Widget _buildGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.itemCount,
            itemBuilder: (context, index) => _buildGridSkeletonItem(),
          );
        },
      ),
    );
  }

  Widget _buildListSkeletonItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  _buildShimmerBox(180, 16, 4),
                  const SizedBox(height: 12),
                  _buildShimmerBox(80, 20, 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _buildShimmerBox(40, 24, 12),
                const SizedBox(height: 8),
                _buildShimmerBox(24, 24, 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSkeletonItem() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerBox(56, 56, 12),
            const SizedBox(height: 12),
            _buildShimmerBox(null, 16, 4),
            const SizedBox(height: 6),
            _buildShimmerBox(120, 14, 4),
            const SizedBox(height: 12),
            _buildShimmerBox(50, 20, 12),
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
            gradient: _buildShimmerGradient(),
          ),
        );
      },
    );
  }

  LinearGradient _buildShimmerGradient() {
    final colors = widget.isDark 
        ? [
            Colors.grey.shade800,
            Colors.grey.shade700,
            Colors.grey.shade800,
          ]
        : [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ];

    return LinearGradient(
      colors: colors,
      stops: [
        (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
        _shimmerAnimation.value.clamp(0.0, 1.0),
        (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth <= 480) return 2;
    if (screenWidth <= 768) return 3;
    if (screenWidth <= 1024) return 4;
    return 5;
  }
}
