// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../widgets/line_chart_example.dart';
import 'beber_agua_cadastro_page.dart';
import 'controllers/agua_controller.dart';
import 'models/beber_agua_model.dart';

class BeberAguaPage extends ConsumerStatefulWidget {
  const BeberAguaPage({super.key});

  @override
  ConsumerState<BeberAguaPage> createState() => _BeberAguaPageState();
}

class _BeberAguaPageState extends ConsumerState<BeberAguaPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _scheduleReminders();
  }

  void _scheduleReminders() {
    // Implementar notificações aqui
  }

  Widget _buildProgressCard() {
    final aguaAsync = ref.watch(aguaProvider);

    return aguaAsync.when(
      data: (aguaState) {
        final progress = aguaState.todayProgress / aguaState.dailyWaterGoal;
        final percentage = (progress * 100).toInt();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Meta Diária de Água',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.blue[100],
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.blue),
                            strokeWidth: 10,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$percentage%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${aguaState.todayProgress.toInt()}ml',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Meta: ${aguaState.dailyWaterGoal.toInt()}ml',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showGoalDialog(),
                          child: const Text('Ajustar Meta'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text('Erro ao carregar dados: $error')),
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    final tipOfTheDay = ref.read(aguaProvider.notifier).getTipOfTheDay();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Dica do Dia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tipOfTheDay,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final aguaAsync = ref.watch(aguaProvider);

    return aguaAsync.when(
      data: (aguaState) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conquistas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: aguaState.achievements
                      .map((achievement) => Tooltip(
                            message: achievement.description,
                            child: Chip(
                              avatar: Text(achievement.title.split(' ')[0]),
                              label: Text(achievement.title.split(' ')[1]),
                              backgroundColor: achievement.isUnlocked
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Erro ao carregar conquistas'),
        ),
      ),
    );
  }

  Future<void> _showGoalDialog() async {
    final aguaState = await ref.read(aguaProvider.future);
    final controller = TextEditingController(
      text: aguaState.dailyWaterGoal.toInt().toString(),
    );

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Meta Diária'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta em ml',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                final newGoal = double.tryParse(value);
                if (newGoal != null && newGoal > 0) {
                  await ref
                      .read(aguaProvider.notifier)
                      .updateDailyGoal(newGoal);
                }
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Hidratação'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 1020
                  ? 1020
                  : MediaQuery.of(context).size.width * 0.95,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 12),
                  _buildHealthTips(),
                  const SizedBox(height: 12),
                  _buildCalendarCard(),
                  const SizedBox(height: 12),
                  _buildAchievements(),
                  const SizedBox(height: 12),
                  _buildRegistrosCard(),
                  const SizedBox(height: 80), // Espaço para o FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogNovoComentario(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(
              height: 200,
              child: LineChartSample1(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrosCard() {
    final aguaAsync = ref.watch(aguaProvider);

    return aguaAsync.when(
      data: (aguaState) {
        final registros = aguaState.registros;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: registros.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Registros de Hidratação',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...registros.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final registro = entry.value;
                        final date = DateTime.fromMillisecondsSinceEpoch(
                            registro.dataRegistro);
                        final dateStr =
                            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

                        return Column(
                          children: [
                            ListTile(
                              dense: true,
                              title:
                                  Text('Quantidade: ${registro.quantidade} ml'),
                              subtitle: Text('Data: $dateStr'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  ref
                                      .read(aguaProvider.notifier)
                                      .deleteRegistro(registro);
                                },
                              ),
                              onTap: () {
                                _dialogNovoComentario(registro);
                              },
                            ),
                            if (index < registros.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }),
                    ],
                  )
                : const Center(
                    heightFactor: 3,
                    child: Text('Nenhum registro encontrado'),
                  ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Text('Erro ao carregar registros')),
        ),
      ),
    );
  }

  Future<void> _dialogNovoComentario(BeberAgua? registro) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 400,
          height: 240,
          child: BeberAguaFormWidget(registro: registro),
        ),
      ),
    );
  }
}
