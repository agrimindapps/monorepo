// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PesoPage extends ConsumerStatefulWidget {
  const PesoPage({super.key});

  @override
  ConsumerState<PesoPage> createState() => _PesoPageState();
}

class _PesoPageState extends ConsumerState<PesoPage> {

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
    final pesoAsync = ref.watch(pesoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Peso'),
      ),
      body: pesoAsync.when(
        data: (pesoState) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1020,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TipCardWidget(
                        tip: ref
                            .read(pesoProvider.notifier)
                            .getTipOfTheDay(),
                      ),
                      const SizedBox(height: 8),
                      MetaCardWidget(
                        pesoInicial: pesoState.pesoInicial.toString(),
                        pesoAtual: pesoState.pesoAtual.toString(),
                        pesoMeta: pesoState.pesoMeta.toString(),
                        onSetMeta: () => _showMetaDialog(),
                      ),
                      const SizedBox(height: 8),
                      _buildCalendarAndChartCard(),
                      const SizedBox(height: 8),
                      RegistrosCardWidget(
                        registros: pesoState.registros,
                        formatDateTime: formatDateTime,
                        onEdit: (peso) => _dialogNovoPeso(peso),
                        onDelete: (peso) => _showDeleteConfirmation(peso),
                      ),
                      const SizedBox(height: 16),
                      AchievementsCardWidget(
                        achievements: pesoState.achievements,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar dados: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(pesoProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
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
    showDialog<void>(
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
            onPressed: () async {
              await ref.read(pesoProvider.notifier).deleteRegistro(peso);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMetaDialog() async {
    final pesoState = await ref.read(pesoProvider.future);
    final controller = TextEditingController(
        text: pesoState.pesoMeta > 0 ? pesoState.pesoMeta.toString() : '');

    if (!mounted) return;

    await showDialog<void>(
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
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final newMeta = double.tryParse(controller.text);
                if (newMeta != null && newMeta > 0) {
                  await ref
                      .read(pesoProvider.notifier)
                      .saveMetaPeso(newMeta);
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogNovoPeso(PesoModel? peso) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 400,
          height: 240,
          child: PesoFormPage(
            registro: peso,
            onSave: (registro) async {
              if (peso == null) {
                await ref.read(pesoProvider.notifier).addRegistro(registro);
              } else {
                await ref
                    .read(pesoProvider.notifier)
                    .updateRegistro(registro);
              }
            },
          ),
        ),
      ),
    );
  }
}
