import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/water_tracker_providers.dart';
import '../widgets/achievements_grid.dart';
import '../widgets/animated_water_bottle.dart';
import '../widgets/quick_add_buttons.dart';
import '../widgets/streak_display.dart';
import '../widgets/water_calendar.dart';
import '../widgets/weekly_chart.dart';

/// Main Water Tracker home page
class WaterTrackerHomePage extends ConsumerStatefulWidget {
  const WaterTrackerHomePage({super.key});

  @override
  ConsumerState<WaterTrackerHomePage> createState() => _WaterTrackerHomePageState();
}

class _WaterTrackerHomePageState extends ConsumerState<WaterTrackerHomePage>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;
  bool _hasShownCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _checkAndShowCelebration(bool goalAchieved) {
    if (goalAchieved && !_hasShownCelebration) {
      setState(() {
        _showCelebration = true;
        _hasShownCelebration = true;
      });
      _celebrationController.forward();
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCelebration = false);
          _celebrationController.reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(todayProgressProvider);
    final goalAsync = ref.watch(waterGoalProvider);
    final goalAchieved = ref.watch(isTodayGoalAchievedProvider);

    // Check for celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowCelebration(goalAchieved);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Hidratação'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayProgressProvider);
              ref.invalidate(todayRecordsProvider);
              ref.invalidate(currentStreakProvider);
              ref.invalidate(statisticsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Animated water bottle
                        progressAsync.when(
                          data: (progress) => goalAsync.when(
                            data: (goal) => AnimatedWaterBottle(
                              progress: progress.progressPercentage / 100,
                              currentMl: progress.totalMl,
                              goalMl: goal.effectiveGoalMl,
                              size: 180,
                              onTap: () => _showQuickAddBottomSheet(context),
                            ),
                            loading: () => const SizedBox(
                              height: 230,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox(height: 230),
                          ),
                          loading: () => const SizedBox(
                            height: 230,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => const SizedBox(height: 230),
                        ),

                        const SizedBox(height: 16),

                        // Quick add buttons
                        QuickAddButtons(
                          onRecordAdded: () {
                            // Reset celebration flag at start of day
                            final now = DateTime.now();
                            if (now.hour == 0 && now.minute < 5) {
                              _hasShownCelebration = false;
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // Streak display
                        const StreakDisplay(),

                        const SizedBox(height: 16),

                        // Weekly chart
                        const WeeklyChart(),

                        const SizedBox(height: 16),

                        // Achievements
                        const AchievementsGrid(maxItems: 6),

                        const SizedBox(height: 16),

                        // Calendar
                        const WaterCalendar(),

                        const SizedBox(height: 16),

                        // Today's records
                        _buildTodayRecords(),

                        const SizedBox(height: 80), // FAB space
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Celebration overlay
          if (_showCelebration)
            _CelebrationOverlay(
              controller: _celebrationController,
              onDismiss: () => setState(() => _showCelebration = false),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildTodayRecords() {
    final recordsAsync = ref.watch(todayRecordsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 8),
                Text(
                  'Registros de hoje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum registro hoje.\nToque no botão + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.water_drop, color: Colors.white),
                      ),
                      title: Text(
                        '${record.amountMl} ml',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${record.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${record.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDeleteRecord(context, record.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar registros'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adicionar água',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            QuickAddButtons(
              onRecordAdded: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCustomAmountDialog(context);
              },
              child: const Text('Quantidade personalizada...'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quantidade personalizada'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantidade em ml',
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
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0 && amount <= 5000) {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                await ref.read(todayRecordsProvider.notifier).addRecord(amount);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRecord(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro'),
        content: const Text('Deseja excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(todayRecordsProvider.notifier).deleteRecord(id);
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WaterSettingsPage(),
      ),
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onDismiss;

  const _CelebrationOverlay({
    required this.controller,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Transform.scale(
              scale: 0.5 + (controller.value * 0.5),
              child: Opacity(
                opacity: controller.value > 0.8 ? (1 - controller.value) * 5 : 1,
                child: child,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Meta Atingida!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Parabéns! Continue assim!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Water Tracker Settings Page
class WaterSettingsPage extends ConsumerWidget {
  const WaterSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(waterGoalProvider);
    final reminderAsync = ref.watch(reminderSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meta Diária',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    goalAsync.when(
                      data: (goal) => Column(
                        children: [
                          ListTile(
                            title: const Text('Meta atual'),
                            trailing: Text(
                              '${goal.effectiveGoalMl} ml',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () => _showGoalDialog(context, ref, goal.dailyGoalMl),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('Usar meta calculada'),
                            subtitle: Text(
                              goal.calculatedGoalMl != null
                                  ? 'Baseado em ${goal.weightKg}kg: ${goal.calculatedGoalMl}ml'
                                  : 'Informe seu peso para calcular',
                            ),
                            value: goal.useCalculatedGoal,
                            onChanged: (value) {
                              if (value && goal.weightKg == null) {
                                _showWeightDialog(context, ref);
                              } else {
                                // Toggle use calculated goal
                              }
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Calcular por peso'),
                            subtitle: const Text('30-35ml por kg'),
                            trailing: const Icon(Icons.calculate),
                            onTap: () => _showWeightDialog(context, ref),
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Erro ao carregar'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lembretes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    reminderAsync.when(
                      data: (settings) => Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Lembretes ativos'),
                            value: settings.isEnabled,
                            onChanged: (value) {
                              final updated = settings.copyWith(
                                isEnabled: value,
                                updatedAt: DateTime.now(),
                              );
                              ref
                                  .read(reminderSettingsProvider.notifier)
                                  .updateSettings(updated);
                            },
                          ),
                          if (settings.isEnabled) ...[
                            const Divider(),
                            ListTile(
                              title: const Text('Intervalo'),
                              trailing: DropdownButton<int>(
                                value: settings.intervalMinutes,
                                onChanged: (value) {
                                  if (value != null) {
                                    final updated = settings.copyWith(
                                      intervalMinutes: value,
                                      updatedAt: DateTime.now(),
                                    );
                                    ref
                                        .read(reminderSettingsProvider.notifier)
                                        .updateSettings(updated);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(value: 30, child: Text('30 min')),
                                  DropdownMenuItem(value: 60, child: Text('1 hora')),
                                  DropdownMenuItem(value: 90, child: Text('1h30')),
                                  DropdownMenuItem(value: 120, child: Text('2 horas')),
                                ],
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('Horário de início'),
                              trailing: Text(settings.startTime),
                              onTap: () => _showTimePicker(
                                context,
                                ref,
                                settings,
                                true,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('Horário de fim'),
                              trailing: Text(settings.endTime),
                              onTap: () => _showTimePicker(
                                context,
                                ref,
                                settings,
                                false,
                              ),
                            ),
                            const Divider(),
                            SwitchListTile(
                              title: const Text('Lembretes adaptativos'),
                              subtitle: const Text(
                                'Lembrar se não registrar por muito tempo',
                              ),
                              value: settings.adaptiveReminders,
                              onChanged: (value) {
                                final updated = settings.copyWith(
                                  adaptiveReminders: value,
                                  updatedAt: DateTime.now(),
                                );
                                ref
                                    .read(reminderSettingsProvider.notifier)
                                    .updateSettings(updated);
                              },
                            ),
                          ],
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Erro ao carregar'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Custom Cups Management
            Card(
              child: ListTile(
                title: const Text('Gerenciar recipientes'),
                subtitle: const Text('Adicionar ou editar copos personalizados'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _navigateToCustomCups(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meta diária'),
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
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                ref.read(waterGoalProvider.notifier).updateDailyGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seu peso'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Peso em kg',
            suffixText: 'kg',
            hintText: 'Ex: 70.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text.replaceAll(',', '.'));
              if (weight != null && weight > 0) {
                ref.read(waterGoalProvider.notifier).updateGoalByWeight(weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
    bool isStart,
  ) async {
    final parts = (isStart ? settings.startTime : settings.endTime).split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final updated = isStart
          ? settings.copyWith(startTime: timeStr, updatedAt: DateTime.now())
          : settings.copyWith(endTime: timeStr, updatedAt: DateTime.now());
      ref.read(reminderSettingsProvider.notifier).updateSettings(updated);
    }
  }

  void _navigateToCustomCups(BuildContext context) {
    // Navigate to custom cups management page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gerenciador de copos em desenvolvimento')),
    );
  }
}
