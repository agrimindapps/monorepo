// Flutter imports:
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isActive;

  const StatusIndicator({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Em andamento' : 'Finalizado',
        style: TextStyle(
          color: isActive ? Colors.green[900] : Colors.grey[700],
        ),
      ),
    );
  }
}
