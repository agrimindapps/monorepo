// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import '../../widgets/line_chart_example.dart';
import 'beber_agua_cadastro_page.dart';
import 'models/beber_agua_model.dart';

class WaterAchievement {
  final String title;
  final String description;
  final bool isUnlocked;

  WaterAchievement({
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });
}

class BeberAguaPage extends StatefulWidget {
  const BeberAguaPage({super.key});

  @override
  State<BeberAguaPage> createState() => _BeberAguaPageState();
}

class _BeberAguaPageState extends State<BeberAguaPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {};

  final registros = <BeberAgua>[].obs;
  final dailyWaterGoal = 2000.0.obs;
  final todayProgress = 0.0.obs;

  final List<String> healthTips = [
    'Beber água ajuda a melhorar a concentração',
    'A hidratação é essencial para a saúde da pele',
    'Beba água antes, durante e depois de exercícios',
    'Água ajuda no funcionamento do intestino',
    'Mantenha uma garrafa de água sempre por perto',
  ];

  final List<WaterAchievement> achievements = [
    WaterAchievement(
      title: '🌱 Iniciante',
      description: 'Registrou água por 3 dias seguidos',
    ),
    WaterAchievement(
      title: '💧 Hidratado',
      description: 'Atingiu a meta diária 7 dias seguidos',
    ),
    WaterAchievement(
      title: '🌊 Mestre da Hidratação',
      description: 'Completou 30 dias seguidos',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadProgress();
    _scheduleReminders();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    todayProgress.value = prefs.getDouble('todayProgress') ?? 0;
    dailyWaterGoal.value = prefs.getDouble('dailyWaterGoal') ?? 2000;
  }

  void _scheduleReminders() {
    // Implementar notificações aqui
  }

  Widget _buildProgressCard() {
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
                      Obx(() => CircularProgressIndicator(
                            value: todayProgress.value / dailyWaterGoal.value,
                            backgroundColor: Colors.blue[100],
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.blue),
                            strokeWidth: 10,
                          )),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() => Text(
                                  '${(todayProgress.value / dailyWaterGoal.value * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            Obx(() => Text(
                                  '${todayProgress.value.toInt()}ml',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Obx(() => Text(
                          'Meta: ${dailyWaterGoal.value.toInt()}ml',
                          style: const TextStyle(fontSize: 16),
                        )),
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
  }

  Widget _buildHealthTips() {
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
              healthTips[DateTime.now().day % healthTips.length],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
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
              children: achievements
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
  }

  Future<void> _showGoalDialog() async {
    double tempGoal = dailyWaterGoal.value;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Meta Diária'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta em ml',
            suffixText: 'ml',
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              tempGoal = double.parse(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('dailyWaterGoal', tempGoal);
              dailyWaterGoal.value = tempGoal;
              Navigator.pop(context);
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => registros.isNotEmpty
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
                      return Column(
                        children: [
                          ListTile(
                            dense: true,
                            title:
                                Text('Quantidade: ${registro.quantidade} ml'),
                            subtitle: Text('Data: ${registro.dataRegistro}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // delete(registro.id);
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
