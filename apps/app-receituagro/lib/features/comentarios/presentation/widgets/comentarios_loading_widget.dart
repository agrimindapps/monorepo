import 'package:flutter/material.dart';

/// **COMENTARIOS LOADING WIDGET**
/// 
/// Displays loading state while comentarios are being fetched.
/// Provides visual feedback during async operations.
/// 
/// ## Features:
/// 
/// - **Skeleton Loading**: Mimics the structure of actual content
/// - **Smooth Animation**: Shimmer effect for better UX
/// - **Responsive Design**: Adapts to different screen sizes
/// - **Consistent Design**: Matches app-receituagro loading patterns

class ComentariosLoadingWidget extends StatefulWidget {
  final int itemCount;
  final bool showHeader;

  const ComentariosLoadingWidget({
    super.key,
    this.itemCount = 3,
    this.showHeader = false,
  });

  @override
  State<ComentariosLoadingWidget> createState() => _ComentariosLoadingWidgetState();
}

class _ComentariosLoadingWidgetState extends State<ComentariosLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            if (widget.showHeader) _buildHeaderSkeleton(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.itemCount,
                itemBuilder: (context, index) => _buildItemSkeleton(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildShimmerBox(40, 40, isCircular: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(120, 18),
                const SizedBox(height: 8),
                _buildShimmerBox(80, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemHeader(),
          _buildItemContent(),
        ],
      ),
    );
  }

  Widget _buildItemHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildShimmerBox(28, 28, isCircular: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(80, 14),
                const SizedBox(height: 4),
                _buildShimmerBox(60, 12),
              ],
            ),
          ),
          _buildShimmerBox(40, 12),
          const SizedBox(width: 8),
          _buildShimmerBox(18, 18, isCircular: true),
        ],
      ),
    );
  }

  Widget _buildItemContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(double.infinity, 16),
          const SizedBox(height: 8),
          _buildShimmerBox(double.infinity, 14),
          const SizedBox(height: 4),
          _buildShimmerBox(200, 14),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {bool isCircular = false}) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
          borderRadius: isCircular 
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Factory constructor for simple loading state
  // ignore: unused_element
  static ComentariosLoadingWidget simple() {
    return const ComentariosLoadingWidget(
      itemCount: 3,
      showHeader: false,
    );
  }

  /// Factory constructor for full page loading
  // ignore: unused_element
  static ComentariosLoadingWidget fullPage() {
    return const ComentariosLoadingWidget(
      itemCount: 5,
      showHeader: true,
    );
  }

  /// Factory constructor for minimal loading
  // ignore: unused_element
  static ComentariosLoadingWidget minimal() {
    return const ComentariosLoadingWidget(
      itemCount: 2,
      showHeader: false,
    );
  }
}