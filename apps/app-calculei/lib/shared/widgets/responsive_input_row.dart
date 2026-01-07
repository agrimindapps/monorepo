import 'package:flutter/material.dart';

class ResponsiveInputRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint;

  const ResponsiveInputRow({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 800,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We use MediaQuery here to stick to the "Desktop vs Mobile" concept
        // regardless of the parent container's specific width,
        // assuming the main page layout is what drives the decision.
        // However, checking the screen width is generally what was requested.
        final isDesktop = MediaQuery.of(context).size.width >= breakpoint;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          );
        } else {
          return Column(children: [left, const SizedBox(height: 16), right]);
        }
      },
    );
  }
}
