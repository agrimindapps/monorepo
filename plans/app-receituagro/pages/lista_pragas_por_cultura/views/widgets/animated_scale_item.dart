// Flutter imports:
import 'package:flutter/material.dart';

class AnimatedScaleItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedScaleItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
