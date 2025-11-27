import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/water_daily_progress_entity.dart';
import '../providers/water_tracker_providers.dart';

/// Calendar widget showing daily water intake history
class WaterCalendar extends ConsumerStatefulWidget {
  const WaterCalendar({super.key});

  @override
  ConsumerState<WaterCalendar> createState() => _WaterCalendarState();
}

class _WaterCalendarState extends ConsumerState<WaterCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final calendarDataAsync = ref.watch(calendarDataProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, size: 20),
                SizedBox(width: 8),
                Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            calendarDataAsync.when(
              data: (progressList) => _buildCalendar(context, progressList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar calendário'),
            ),
            const SizedBox(height: 12),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<WaterDailyProgressEntity> progressList,
  ) {
    final progressMap = {
      for (final p in progressList)
        DateTime(p.date.year, p.date.month, p.date.day): p
    };

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      locale: 'pt_BR',
      startingDayOfWeek: StartingDayOfWeek.sunday,
      selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _showDayDetails(context, selectedDay, progressMap);
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        ref.read(calendarDataProvider.notifier).loadMonth(
              focusedDay.year,
              focusedDay.month,
            );
      },
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: true,
        formatButtonShowsNext: false,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle(color: Colors.red),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          final progress = progressMap[normalizedDay];
          return _buildDayCell(context, day, progress, false);
        },
        todayBuilder: (context, day, focusedDay) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          final progress = progressMap[normalizedDay];
          return _buildDayCell(context, day, progress, true);
        },
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    WaterDailyProgressEntity? progress,
    bool isToday,
  ) {
    Color? backgroundColor;
    Color textColor = Colors.black87;

    if (progress != null) {
      if (progress.goalAchieved) {
        backgroundColor = Colors.green.withValues(alpha: 0.7);
        textColor = Colors.white;
      } else if (progress.totalMl > 0) {
        final percentage = progress.progressPercentage / 100;
        if (percentage >= 0.8) {
          backgroundColor = Colors.yellow.withValues(alpha: 0.7);
        } else if (percentage >= 0.5) {
          backgroundColor = Colors.orange.withValues(alpha: 0.5);
        } else {
          backgroundColor = Colors.red.withValues(alpha: 0.3);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem(color: Colors.green, label: '100%+'),
        _LegendItem(color: Colors.yellow[700]!, label: '80-99%'),
        _LegendItem(color: Colors.orange, label: '50-79%'),
        _LegendItem(color: Colors.red[300]!, label: '<50%'),
      ],
    );
  }

  void _showDayDetails(
    BuildContext context,
    DateTime day,
    Map<DateTime, WaterDailyProgressEntity> progressMap,
  ) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final progress = progressMap[normalizedDay];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.day.toString().padLeft(2, '0')}/'
              '${day.month.toString().padLeft(2, '0')}/'
              '${day.year}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (progress != null) ...[
              _DetailRow(
                icon: Icons.water_drop,
                label: 'Total',
                value: '${progress.totalMl} ml',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.flag,
                label: 'Meta',
                value: '${progress.goalMl} ml',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.percent,
                label: 'Progresso',
                value: '${progress.progressPercentage.round()}%',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.check_circle,
                label: 'Meta atingida',
                value: progress.goalAchieved ? 'Sim ✓' : 'Não',
                valueColor: progress.goalAchieved ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.list,
                label: 'Registros',
                value: '${progress.recordCount}',
              ),
            ] else ...[
              const Center(
                child: Text(
                  'Nenhum registro neste dia',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
