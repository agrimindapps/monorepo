// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../../widgets/line_chart_example.dart';
import '../controllers/agua_controller.dart';

class AguaCalendarCard extends StatefulWidget {
  const AguaCalendarCard({super.key});

  @override
  State<AguaCalendarCard> createState() => _AguaCalendarCardState();
}

class _AguaCalendarCardState extends State<AguaCalendarCard> {
  final AguaController controller = Get.find<AguaController>();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    // Método para carregar eventos no calendário com base nos registros
    // Este é um exemplo simples, poderia ser adaptado para mostrar datas reais
    final Map<DateTime, List<String>> eventSource = {};

    for (final registro in controller.registros) {
      final dataRegistro =
          DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
      final dateOnly =
          DateTime(dataRegistro.year, dataRegistro.month, dataRegistro.day);

      if (eventSource[dateOnly] == null) {
        eventSource[dateOnly] = [];
      }

      eventSource[dateOnly]!.add('${registro.quantidade.toInt()} ml');
    }

    setState(() {
      _events = eventSource;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
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
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            const LineChartSample1(), // Reutilizando o gráfico existente
          ],
        ),
      ),
    );
  }
}
