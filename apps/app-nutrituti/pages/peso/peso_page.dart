// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../widgets/bar_chart_example.dart';
import 'controllers/peso_controller.dart';
import 'models/peso_model.dart';
import 'pages/peso_form_page.dart';
import 'widgets/achievements_card_widget.dart';
import 'widgets/meta_card_widget.dart';
import 'widgets/registros_card_widget.dart';
import 'widgets/tip_card_widget.dart';

class PesoPage extends StatefulWidget {
  const PesoPage({super.key});

  @override
  State<PesoPage> createState() => _PesoPageState();
}

class _PesoPageState extends State<PesoPage> {
  final PesoController pesoController = Get.put(PesoController());

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {};

  String formatDateTime(int dateTime) {
    final date = DateTime.fromMillisecondsSinceEpoch(dateTime);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Peso'),
      ),
      body: Obx(() {
        return pesoController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: 1020,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TipCardWidget(tip: pesoController.getTipOfTheDay()),
                          const SizedBox(height: 8),
                          MetaCardWidget(
                            pesoInicial: pesoController.pesoInicial.toString(),
                            pesoAtual: pesoController.pesoAtual.toString(),
                            pesoMeta: pesoController.pesoMeta.toString(),
                            onSetMeta: () => _showMetaDialog(),
                          ),
                          const SizedBox(height: 8),
                          _buildCalendarAndChartCard(),
                          const SizedBox(height: 8),
                          RegistrosCardWidget(
                            registros: pesoController.registros,
                            formatDateTime: formatDateTime,
                            onEdit: (peso) => _dialogNovoPeso(peso),
                            onDelete: (peso) => _showDeleteConfirmation(peso),
                          ),
                          const SizedBox(height: 16),
                          AchievementsCardWidget(
                            achievements: pesoController.achievements,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogNovoPeso(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarAndChartCard() {
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
                return events[day] ?? [];
              },
            ),
            const SizedBox(height: 16),
            const BarChartSample3(),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(PesoModel peso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este registro de peso?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              pesoController.deleteRegistro(peso);
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showMetaDialog() {
    final controller = TextEditingController(
        text: pesoController.pesoMeta.value > 0
            ? pesoController.pesoMeta.value.toString()
            : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Meta de Peso'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta (kg)',
            hintText: 'Insira sua meta de peso',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newMeta = double.tryParse(controller.text);
                if (newMeta != null && newMeta > 0) {
                  pesoController.saveMetaPeso(newMeta);
                }
              }
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future _dialogNovoPeso(PesoModel? peso) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 400,
          height: 240,
          child: PesoFormPage(
            registro: peso,
            onSave: (registro) {
              if (peso == null) {
                pesoController.addRegistro(registro);
              } else {
                pesoController.updateRegistro(registro);
              }
            },
          ),
        ),
      ),
    );
  }
}
