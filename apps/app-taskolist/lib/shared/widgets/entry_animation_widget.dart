import 'package:flutter/material.dart';

class EntryAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double verticalOffset;

  const EntryAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.verticalOffset = 50.0,
  });

  @override
  State<EntryAnimationWidget> createState() => _EntryAnimationWidgetState();
}

class _EntryAnimationWidgetState extends State<EntryAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: Offset(
        0,
        widget.verticalOffset / 100,
      ), // Approximate pixel to fractional conversion logic if needed, but SlideTransition uses fractional relative to child size.
      // Actually SlideTransition offset is percentage of child size.
      // To slide up from a bit down, we can use Offset(0, 0.5) for half height.
      // Let's use a small offset like 0.1 (10% of height)
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay != Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (!_isDisposed && mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
