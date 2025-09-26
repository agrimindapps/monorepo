import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Enhanced vaccine calendar widget showing vaccination timeline
class VaccineCalendarWidget extends ConsumerStatefulWidget {
  final String? animalId;
  final void Function(Vaccine)? onVaccineSelected;
  
  const VaccineCalendarWidget({
    super.key,
    this.animalId,
    this.onVaccineSelected,
  });

  @override
  ConsumerState<VaccineCalendarWidget> createState() => _VaccineCalendarWidgetState();
}

class _VaccineCalendarWidgetState extends ConsumerState<VaccineCalendarWidget> {
  late DateTime _currentMonth;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController(initialPage: 12); // Current month
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calendarAsync = ref.watch(vaccineCalendarProvider(_currentMonth));

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(theme),
          calendarAsync.when(
            loading: () => _buildLoadingState(),
            error: (error, stackTrace) => _buildErrorState(theme, error.toString()),
            data: (calendar) => _buildCalendarContent(theme, calendar),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendário de Vacinas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _formatMonth(_currentMonth),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: theme.colorScheme.primary,
                onPressed: () => _navigateMonth(-1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: theme.colorScheme.primary,
                onPressed: () => _navigateMonth(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Erro ao carregar calendário',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContent(ThemeData theme, Map<DateTime, List<Vaccine>> calendar) {
    // Get vaccines for the current month and group by day
    final monthVaccines = <DateTime, List<Vaccine>>{};
    final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final endOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    for (var entry in calendar.entries) {
      if (entry.key.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        monthVaccines[entry.key] = entry.value;
      }
    }

    if (monthVaccines.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: _buildVaccinesList(theme, monthVaccines),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma vacina agendada',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'para ${_formatMonth(_currentMonth)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinesList(
    ThemeData theme,
    Map<DateTime, List<Vaccine>> monthVaccines,
  ) {
    final sortedDays = monthVaccines.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final vaccines = monthVaccines[day]!;
        return _buildDayGroup(theme, day, vaccines);
      },
    );
  }

  Widget _buildDayGroup(ThemeData theme, DateTime day, List<Vaccine> vaccines) {
    final isToday = DateTime.now().difference(day).inDays == 0;
    final isPast = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        color: isToday 
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : isPast
                      ? Colors.grey[100]
                      : Colors.blue[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.colorScheme.primary
                        : isPast
                            ? Colors.grey[400]
                            : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(day),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isToday ? theme.colorScheme.primary : null,
                        ),
                      ),
                      Text(
                        '${vaccines.length} ${vaccines.length == 1 ? 'vacina' : 'vacinas'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HOJE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...vaccines.map((vaccine) => _buildVaccineItem(theme, vaccine)),
        ],
      ),
    );
  }

  Widget _buildVaccineItem(ThemeData theme, Vaccine vaccine) {
    final color = vaccine.isOverdue
        ? Colors.red
        : vaccine.isDueToday
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              vaccine.isOverdue
                  ? Icons.warning
                  : vaccine.isDueToday
                      ? Icons.today
                      : Icons.vaccines,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  vaccine.veterinarian,
                  style: theme.textTheme.bodySmall,
                ),
                if (vaccine.notes != null && vaccine.notes!.isNotEmpty)
                  Text(
                    vaccine.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vaccine.nextDoseInfo,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (vaccine.isOverdue || vaccine.isDueToday) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vaccine.isOverdue ? 'URGENTE' : 'HOJE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _navigateMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        1,
      );
    });
  }

  String _formatMonth(DateTime date) {
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}';
  }
}