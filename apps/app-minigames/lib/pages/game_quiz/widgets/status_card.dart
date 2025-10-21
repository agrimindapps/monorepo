// Flutter imports:
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const StatusCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$label: $value', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
