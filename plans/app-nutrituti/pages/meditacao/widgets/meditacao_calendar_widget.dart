// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../controllers/meditacao_controller.dart';
import '../models/meditacao_model.dart';

class MeditacaoCalendarWidget extends StatefulWidget {
  final MeditacaoController controller;

  const MeditacaoCalendarWidget({
    super.key,
    required this.controller,
  });

  @override
  State<MeditacaoCalendarWidget> createState() =>
      _MeditacaoCalendarWidgetState();
}

class _MeditacaoCalendarWidgetState extends State<MeditacaoCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapeamento de dias para eventos (sessões de meditação)
  Map<DateTime, List<MeditacaoModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _atualizarEventos();
  }

  @override
  void didUpdateWidget(MeditacaoCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.sessoes.length !=
        widget.controller.sessoes.length) {
      _atualizarEventos();
    }
  }

  // Atualizar o mapeamento de eventos baseado nas sessões
  void _atualizarEventos() {
    _events = {};

    for (final sessao in widget.controller.sessoes) {
      // Normalizar a data para comparar apenas ano, mês e dia
      final normalizedDate = DateTime(
        sessao.dataRegistro.year,
        sessao.dataRegistro.month,
        sessao.dataRegistro.day,
      );

      if (_events.containsKey(normalizedDate)) {
        _events[normalizedDate]!.add(sessao);
      } else {
        _events[normalizedDate] = [sessao];
      }
    }

    setState(() {});
  }

  // Função auxiliar para obter os eventos para um dia
  List<MeditacaoModel> _getEventsForDay(DateTime day) {
    // Normalizar a data
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
              eventLoader: _getEventsForDay,
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
                // Marcar dias com sessões de meditação
                markerDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                // Hoje
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                // Dia selecionado
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (_selectedDay != null &&
                _getEventsForDay(_selectedDay!).isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildEventosParaDiaSelecionado(_selectedDay!),
            ],
          ],
        ),
      ),
    );
  }

  // Construir lista de eventos para o dia selecionado
  Widget _buildEventosParaDiaSelecionado(DateTime day) {
    final eventos = _getEventsForDay(day);
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
