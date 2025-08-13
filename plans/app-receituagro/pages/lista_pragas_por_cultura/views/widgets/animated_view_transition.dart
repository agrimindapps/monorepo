// Flutter imports:
import 'package:flutter/material.dart';

class AnimatedViewTransition extends StatelessWidget {
  final Widget child;
  final String viewMode;
  final Duration duration;

  const AnimatedViewTransition({
    super.key,
    required this.child,
    required this.viewMode,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
