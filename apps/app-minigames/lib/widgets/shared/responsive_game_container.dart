import 'package:flutter/material.dart';

/// A wrapper widget that limits the maximum width of its content
/// to prevent layout stretching on wide screens.
/// 
/// Default max width is 1120 logical pixels.
class ResponsiveGameContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const ResponsiveGameContainer({
    super.key,
    required this.child,
    this.maxWidth = 1120.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
