// Flutter imports:
import 'package:flutter/material.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final double textScaleFactor;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
        textScaler: TextScaler.linear(textScaleFactor),
      ),
    );
  }
}
