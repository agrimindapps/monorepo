import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/timeline_item.dart';
import 'timeline_item_card.dart';

/// Widget para exibir um grupo de eventos por data
class TimelineDateGroup extends StatelessWidget {
  const TimelineDateGroup({
    required this.date,
    required this.items,
    required this.isFirstGroup,
    this.onItemTap,
    super.key,
  });

  final DateTime date;
  final List<TimelineItem> items;
  final bool isFirstGroup;
  final void Function(TimelineItem)? onItemTap;

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoje';
    } else if (dateOnly == yesterday) {
      return 'Ontem';
    } else if (dateOnly == tomorrow) {
      return 'Amanhã';
    } else {
      final dayFormat = DateFormat('EEEE', 'pt_BR');
      final fullFormat = DateFormat('d \'de\' MMMM', 'pt_BR');
      return '${dayFormat.format(date).capitalize()}, ${fullFormat.format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: EdgeInsets.fromLTRB(16, isFirstGroup ? 8 : 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getDateLabel(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${items.length} ${items.length == 1 ? 'evento' : 'eventos'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Events list
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TimelineItemCard(
            item: item,
            isFirst: index == 0,
            isLast: index == items.length - 1,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          );
        }),
      ],
    );
  }
}

/// Extensão para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
