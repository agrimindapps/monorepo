import 'package:flutter/material.dart';
import '../../models/view_mode.dart';

class DefensivosLoadingSkeletonWidget extends StatefulWidget {
  final bool isDark;
  final int itemCount;
  final ViewMode viewMode;

  const DefensivosLoadingSkeletonWidget({
    super.key,
    required this.isDark,
    required this.viewMode,
    this.itemCount = 8,
  });

  @override
  State<DefensivosLoadingSkeletonWidget> createState() => _DefensivosLoadingSkeletonWidgetState();
}

class _DefensivosLoadingSkeletonWidgetState extends State<DefensivosLoadingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewMode == ViewMode.grid) {
      return _buildGridSkeleton();
    } else {
      return _buildListSkeleton();
    }
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonListItem();
      },
    );
  }

  Widget _buildGridSkeleton() {
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonGridItem();
      },
    );
  }

  Widget _buildSkeletonListItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildSkeletonContainer(56, 56, true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonContainer(double.infinity, 20, false),
                    const SizedBox(height: 8),
                    _buildSkeletonContainer(200, 16, false),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSkeletonContainer(100, 16, false),
                        ),
                        const SizedBox(width: 16),
                        _buildSkeletonContainer(50, 16, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSkeletonContainer(24, 24, true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonGridItem() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSkeletonContainer(32, 32, true),
                const Spacer(),
                _buildSkeletonContainer(30, 16, false),
              ],
            ),
            const SizedBox(height: 12),
            _buildSkeletonContainer(double.infinity, 16, false),
            const SizedBox(height: 8),
            _buildSkeletonContainer(120, 14, false),
            const SizedBox(height: 8),
            _buildSkeletonContainer(100, 14, false),
            const Spacer(),
            _buildSkeletonContainer(double.infinity, 20, false),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonContainer(double width, double height, bool isCircular) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: isCircular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: widget.isDark
                  ? [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF3A3A3A),
                      const Color(0xFF2A2A2A),
                    ]
                  : [
                      const Color(0xFFE0E0E0),
                      const Color(0xFFF5F5F5),
                      const Color(0xFFE0E0E0),
                    ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
            ),
          ),
        );
      },
    );
  }
}