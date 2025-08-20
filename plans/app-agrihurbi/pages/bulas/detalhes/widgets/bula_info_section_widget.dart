// Flutter imports:
import 'package:flutter/material.dart';

class BulaInfoSectionWidget extends StatelessWidget {
  final String label;
  final String content;

  const BulaInfoSectionWidget({
    super.key,
    required this.label,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
