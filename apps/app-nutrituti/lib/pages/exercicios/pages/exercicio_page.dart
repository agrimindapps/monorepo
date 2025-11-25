// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../../widgets/bar_chart_example.dart';
import '../constants/exercicio_constants.dart';
import '../controllers/exercicio_list_controller.dart';
import '../models/exercicio_model.dart';
import '../services/exercicio_cache_service.dart';
import '../services/exercicio_logger_service.dart';
import './exercicio_form_page.dart';

/// Exercise page with calendar, statistics, and exercise management

class ExercicioPage extends ConsumerStatefulWidget {
  const ExercicioPage({super.key});

  @override
  ConsumerState<ExercicioPage> createState() => _ExercicioPageState();
}

class _ExercicioPageState extends ConsumerState<ExercicioPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ExercicioModel>> events = {};

  @override
  void initState() {
    super.initState();
    // Initial load will be handled by Riverpod
  }

  void _updateEventsMap(List<ExercicioModel> registros) {
    final cached = ExercicioCacheService.getCachedEvents(registros);
    if (cached != null) {
      setState(() {
        events = cached;
      });
      return;
    }

    final newEvents = <DateTime, List<ExercicioModel>>{};
    for (var exercicio in registros) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);
        final day = DateTime(date.year, date.month, date.day);

        if (newEvents[day] == null) {
          newEvents[day] = [];
        }
        newEvents[day]!.add(exercicio);
      } catch (e) {
        ExercicioLoggerService.e('Erro ao processar timestamp',
          component: 'ExercicioPage',
          context: {'timestamp': exercicio.dataRegistro, 'exerciseName': exercicio.nome});
      }
    }

    ExercicioCacheService.setCachedEvents(registros, newEvents);
    setState(() {
      events = newEvents;
    });
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
    final exercicioAsync = ref.watch(exercicioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
      ),
      body: exercicioAsync.when(
        data: (state) {
          // Update events map when registros change
          if (state.registros != events.values.expand((e) => e).toList()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateEventsMap(state.registros);
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(exercicioListProvider);
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
                        _buildTipCard(state),
                        const SizedBox(height: ExercicioConstants.defaultPadding),
                        _buildMetaCard(state),
                        const SizedBox(height: ExercicioConstants.defaultPadding),
                        _buildCalendarAndChartCard(state),
                        const SizedBox(height: ExercicioConstants.defaultPadding),
                        _buildRegistrosCard(state),
                        const SizedBox(height: ExercicioConstants.cardInternalPadding),
                        _buildAchievementsCard(state),
                      ],
                    ),
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
              Text('Erro ao carregar exercícios: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(exercicioListProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogNovoExercicio(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTipCard(ExercicioListState state) {
    // Get tip of the day from controller
    final tipOfDay = ref.read(exercicioListProvider.notifier).getTipOfTheDay();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700], size: ExercicioConstants.iconeTipSize),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tipOfDay,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCard(ExercicioListState state) {
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
                  '${state.totalMinutosSemana} min',
                  '${state.metaMinutosSemanal.toInt()} min',
                  state.metaMinutosSemanal > 0
                      ? state.totalMinutosSemana / state.metaMinutosSemanal
                      : 0,
                ),
                _buildProgressColumn(
                  'Calorias Queimadas',
                  '${state.totalCaloriasSemana} kcal',
                  '${state.metaCaloriasSemanal.toInt()} kcal',
                  state.metaCaloriasSemanal > 0
                      ? state.totalCaloriasSemana / state.metaCaloriasSemanal
                      : 0,
                ),
                _buildSetMetaButton(state),
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

  Widget _buildSetMetaButton(ExercicioListState state) {
    return ElevatedButton(
      onPressed: () {
        _showMetaDialog(state);
      },
      child: const Text('Definir Metas'),
    );
  }

  Widget _buildCalendarAndChartCard(ExercicioListState state) {
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
              child: state.registros.isNotEmpty
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

  Widget _buildRegistrosCard(ExercicioListState state) {
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
            state.registros.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.registros.length,
                    itemBuilder: (context, index) {
                      final exercicio = state.registros[index];
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

  Widget _buildAchievementsCard(ExercicioListState state) {
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
                itemCount: state.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = state.achievements[index];
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

  void _showMetaDialog(ExercicioListState state) {
    final minutosSemanalController = TextEditingController(
        text: state.metaMinutosSemanal > 0
            ? state.metaMinutosSemanal.toString()
            : '');

    final caloriasSemanalController = TextEditingController(
        text: state.metaCaloriasSemanal > 0
            ? state.metaCaloriasSemanal.toString()
            : '');

    showDialog<void>(
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
                ref.read(exercicioListProvider.notifier)
                    .saveMetaExercicios(minutos, calorias);
              }

              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogNovoExercicio(ExercicioModel? exercicio) {
    return showDialog<void>(
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
        await ref.read(exercicioListProvider.notifier)
            .excluirExercicio(exercicio.id!);
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
