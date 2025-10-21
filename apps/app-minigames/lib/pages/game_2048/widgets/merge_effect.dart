// Flutter imports:
import 'package:flutter/material.dart';

class MergeEffect extends StatefulWidget {
  final Widget child;
  final bool isMerging;

  const MergeEffect({
    super.key,
    required this.child,
    required this.isMerging,
  });

  @override
  State<MergeEffect> createState() => _MergeEffectState();
}

class _MergeEffectState extends State<MergeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MergeEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMerging) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}
