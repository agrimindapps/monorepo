import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Unified month selector widget
/// 
/// Displays a horizontal list of months for filtering records.
/// Automatically includes the current month even if no records exist.
/// 
/// Usage:
/// ```dart
/// MonthSelector(
///   months: monthsList,
///   selectedMonth: selectedDate,
///   onMonthSelected: (month) => notifier.selectMonth(month),
/// )
/// ```
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.onMonthSelected,
    this.height = 50,
  });

  /// List of available months (ordered newest to oldest)
  final List<DateTime> months;

  /// Currently selected month
  final DateTime? selectedMonth;

  /// Callback when a month is selected
  final ValueChanged<DateTime> onMonthSelected;

  /// Height of the selector
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (months.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth != null &&
              month.year == selectedMonth!.year &&
              month.month == selectedMonth!.month;

          return _MonthChip(
            month: month,
            isSelected: isSelected,
            onTap: () => onMonthSelected(month),
            theme: theme,
          );
        },
      ),
    );
  }
}

/// Individual month chip widget
class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.month,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final DateTime month;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMM yy', 'pt_BR').format(month);
    final formattedMonth = monthName[0].toUpperCase() + monthName.substring(1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            formattedMonth,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
