// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../../widgets/bar_chart_example.dart';
import '../constants/exercicio_constants.dart';
import '../controllers/index.dart';
import '../models/exercicio_model.dart';
import '../services/exercicio_cache_service.dart';
import '../services/exercicio_logger_service.dart';
import './exercicio_form_page.dart';

/// Exercise page with calendar, statistics, and exercise management

class ExercicioPage extends StatefulWidget {
  const ExercicioPage({super.key});

  @override
  State<ExercicioPage> createState() => _ExercicioPageState();
}

class _ExercicioPageState extends State<ExercicioPage> {
  final ExercicioListController exercicioController =
      Get.put(ExercicioListController());

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ExercicioModel>> events = {};

  Worker? _registrosWorker;

  @override
  void initState() {
    super.initState();
    _registrosWorker = ever(exercicioController.registros, (_) => _updateEventsMap());
  }

  @override
  void dispose() {
    _registrosWorker?.dispose();
    super.dispose();
  }

  void _updateEventsMap() {
    final cached = ExercicioCacheService.getCachedEvents(exercicioController.registros);
    if (cached != null) {
      events = cached;
      return;
    }

    events.clear();
    for (var exercicio in exercicioController.registros) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);
        final day = DateTime(date.year, date.month, date.day);

        if (events[day] == null) {
          events[day] = [];
        }
        events[day]!.add(exercicio);
      } catch (e) {
        ExercicioLoggerService.e('Erro ao processar timestamp', 
          component: 'ExercicioPage', 
          context: {'timestamp': exercicio.dataRegistro, 'exerciseName': exercicio.nome});
      }
    }

    ExercicioCacheService.setCachedEvents(exercicioController.registros, events);
  }

  String formatDateTime(int dateTime) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(dateTime);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      ExercicioLoggerService.e('Erro ao formatar timestamp', 
        component: 'ExercicioPage', 
        context: {'timestamp': dateTime});
      return 'Data inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
      ),
      body: Obx(() {
        return exercicioController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await exercicioController.loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: SizedBox(
                      width: ExercicioConstants.mainScreenMaxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(ExercicioConstants.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTipCard(),
                            const SizedBox(height: ExercicioConstants.defaultPadding),
                            _buildMetaCard(),
                            const SizedBox(height: ExercicioConstants.defaultPadding),
                            _buildCalendarAndChartCard(),
                            const SizedBox(height: ExercicioConstants.defaultPadding),
                            _buildRegistrosCard(),
                            const SizedBox(height: ExercicioConstants.cardInternalPadding),
                            _buildAchievementsCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogNovoExercicio(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700], size: ExercicioConstants.iconeTipSize),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                exercicioController.getTipOfTheDay(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Progresso Semanal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressColumn(
                  'Tempo de Exercício',
                  '${exercicioController.totalMinutosSemana} min',
                  '${exercicioController.metaMinutosSemanal.value.toInt()} min',
                  exercicioController.metaMinutosSemanal.value > 0
                      ? exercicioController.totalMinutosSemana.value /
                          exercicioController.metaMinutosSemanal.value
                      : 0,
                ),
                _buildProgressColumn(
                  'Calorias Queimadas',
                  '${exercicioController.totalCaloriasSemana} kcal',
                  '${exercicioController.metaCaloriasSemanal.value.toInt()} kcal',
                  exercicioController.metaCaloriasSemanal.value > 0
                      ? exercicioController.totalCaloriasSemana.value /
                          exercicioController.metaCaloriasSemanal.value
                      : 0,
                ),
                _buildSetMetaButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressColumn(
      String label, String atual, String meta, double progresso) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          atual,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          'Meta: $meta',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: ExercicioConstants.progressBarWidth,
          child: LinearProgressIndicator(
            value: progresso > 1 ? 1 : progresso,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSetMetaButton() {
    return ElevatedButton(
      onPressed: () {
        _showMetaDialog();
      },
      child: const Text('Definir Metas'),
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
              firstDay: DateTime(ExercicioConstants.calendarioAnoInicio),
              lastDay: DateTime(ExercicioConstants.calendarioAnoFim),
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
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return (events[normalizedDay] ?? [])
                    .map((e) => e.nome)
                    .toList();
              },
              calendarStyle: const CalendarStyle(
                markersMaxCount: ExercicioConstants.calendarioMaxMarkers,
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: ExercicioConstants.chartHeight,
              child: exercicioController.registros.isNotEmpty
                  ? const BarChartSample3()
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Registre exercícios para ver o gráfico',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Exercícios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            exercicioController.registros.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercicioController.registros.length,
                    itemBuilder: (context, index) {
                      final exercicio = exercicioController.registros[index];
                      return ListTile(
                        dense: true,
                        title: Text(exercicio.nome),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${formatDateTime(exercicio.dataRegistro)} - ${exercicio.categoria}'),
                            Text(
                                'Duração: ${exercicio.duracao} min | Calorias: ${exercicio.caloriasQueimadas} kcal'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _dialogNovoExercicio(exercicio);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmation(exercicio);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nenhum registro de exercício encontrado'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conquistas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: ExercicioConstants.achievementsHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: exercicioController.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = exercicioController.achievements[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: ExercicioConstants.achievementContainerWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: achievement.isUnlocked
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? Colors.green
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              achievement.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: achievement.isUnlocked
                                    ? Colors.green[800]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: ExercicioConstants.defaultPadding),
                            Text(
                              achievement.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: achievement.isUnlocked
                                    ? Colors.green[800]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: ExercicioConstants.defaultPadding),
                            Icon(
                              achievement.isUnlocked
                                  ? Icons.check_circle
                                  : Icons.lock,
                              color: achievement.isUnlocked
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMetaDialog() {
    final minutosSemanalController = TextEditingController(
        text: exercicioController.metaMinutosSemanal.value > 0
            ? exercicioController.metaMinutosSemanal.value.toString()
            : '');

    final caloriasSemanalController = TextEditingController(
        text: exercicioController.metaCaloriasSemanal.value > 0
            ? exercicioController.metaCaloriasSemanal.value.toString()
            : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Metas de Exercício'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutosSemanalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos semanais',
                hintText: 'Insira sua meta de minutos por semana',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriasSemanalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calorias semanais',
                hintText: 'Insira sua meta de calorias por semana',
              ),
            ),
          ],
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
              double minutos = 0;
              double calorias = 0;

              if (minutosSemanalController.text.isNotEmpty) {
                minutos = double.tryParse(minutosSemanalController.text) ?? 0;
              }

              if (caloriasSemanalController.text.isNotEmpty) {
                calorias = double.tryParse(caloriasSemanalController.text) ?? 0;
              }

              if (minutos > 0 || calorias > 0) {
                exercicioController.saveMetaExercicios(minutos, calorias);
              }

              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future _dialogNovoExercicio(ExercicioModel? exercicio) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: ExercicioConstants.exerciseDialogWidth,
          height: ExercicioConstants.exerciseDialogHeight,
          child: ExercicioFormPage(
            registro: exercicio,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(ExercicioModel exercicio) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o exercício "${exercicio.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true && exercicio.id != null) {
      try {
        await exercicioController.excluirExercicio(exercicio.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercício excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir exercício: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
