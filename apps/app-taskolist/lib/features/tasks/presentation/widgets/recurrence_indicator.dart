import 'package:flutter/material.dart';

import '../../domain/recurrence_entity.dart';

/// Widget to display recurrence information
class RecurrenceIndicator extends StatelessWidget {
  final RecurrencePattern recurrence;
  final VoidCallback? onTap;

  const RecurrenceIndicator({
    super.key,
    required this.recurrence,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!recurrence.isRecurring) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: const Icon(Icons.repeat, size: 16),
        label: Text(
          recurrence.toString(),
          style: const TextStyle(fontSize: 12),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
