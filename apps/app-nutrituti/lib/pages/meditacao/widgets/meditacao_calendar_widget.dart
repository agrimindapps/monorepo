// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../models/meditacao_model.dart';
import '../providers/meditacao_provider.dart';

class MeditacaoCalendarWidget extends ConsumerStatefulWidget {
  const MeditacaoCalendarWidget({super.key});

  @override
  ConsumerState<MeditacaoCalendarWidget> createState() =>
      _MeditacaoCalendarWidgetState();
}

class _MeditacaoCalendarWidgetState
    extends ConsumerState<MeditacaoCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Build events mapping from sessions
  Map<DateTime, List<MeditacaoModel>> _buildEvents(
      List<MeditacaoModel> sessoes) {
    final Map<DateTime, List<MeditacaoModel>> events = {};

    for (final sessao in sessoes) {
      // Normalize the date to compare only year, month and day
      final normalizedDate = DateTime(
        sessao.dataRegistro.year,
        sessao.dataRegistro.month,
        sessao.dataRegistro.day,
      );

      if (events.containsKey(normalizedDate)) {
        events[normalizedDate]!.add(sessao);
      } else {
        events[normalizedDate] = [sessao];
      }
    }

    return events;
  }

  // Helper function to get events for a day
  List<MeditacaoModel> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<MeditacaoModel>> events,
  ) {
    // Normalize the date
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final sessoes = ref.watch(
      meditacaoProvider.select((state) => state.sessoes),
    );

    final events = _buildEvents(sessoes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendário de Meditação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) => _getEventsForDay(day, events),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                // Mark days with meditation sessions
                markerDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                // Today
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                // Selected day
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (_selectedDay != null &&
                _getEventsForDay(_selectedDay!, events).isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildEventosParaDiaSelecionado(_selectedDay!, events),
            ],
          ],
        ),
      ),
    );
  }

  // Build list of events for the selected day
  Widget _buildEventosParaDiaSelecionado(
    DateTime day,
    Map<DateTime, List<MeditacaoModel>> events,
  ) {
    final eventos = _getEventsForDay(day, events);
    final dateFormatter = DateFormat.yMMMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sessões em ${dateFormatter.format(day)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...eventos.map((sessao) => ListTile(
              leading: const Icon(Icons.self_improvement),
              title: Text('${sessao.tipo} - ${sessao.duracao} min'),
              subtitle: Text('Humor: ${sessao.humor}'),
              trailing: Text(
                DateFormat('HH:mm').format(sessao.dataRegistro),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )),
      ],
    );
  }
}
