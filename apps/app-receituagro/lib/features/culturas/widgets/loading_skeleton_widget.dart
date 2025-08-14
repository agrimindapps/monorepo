import 'package:flutter/material.dart';

class LoadingSkeletonWidget extends StatefulWidget {
  final bool isDark;
  final int itemCount;

  const LoadingSkeletonWidget({
    super.key,
    required this.isDark,
    this.itemCount = 8,
  });

  @override
  State<LoadingSkeletonWidget> createState() => _LoadingSkeletonWidgetState();
}

class _LoadingSkeletonWidgetState extends State<LoadingSkeletonWidget>
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonItem(index);
      },
    );
  }

  Widget _buildSkeletonItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildSkeletonContainer(120, 16, false),
                        ),
                        const SizedBox(width: 16),
                        _buildSkeletonContainer(60, 16, false),
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