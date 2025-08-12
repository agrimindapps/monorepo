// Flutter imports:
import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String content;
  final double textScaleFactor;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.content,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            const Divider(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
              textScaler: TextScaler.linear(textScaleFactor),
            ),
          ],
        ),
      ),
    );
  }
}
