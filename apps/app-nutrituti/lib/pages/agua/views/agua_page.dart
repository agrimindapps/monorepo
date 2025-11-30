// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../widgets/appbar.dart';
import '../controllers/agua_controller.dart';
import '../models/beber_agua_model.dart';
import '../widgets/agua_achievement_card.dart';
import '../widgets/agua_cadastro_widget.dart';
import '../widgets/agua_calendar_card.dart';
import '../widgets/agua_progress_card.dart';
import '../widgets/agua_registros_card.dart';
import '../widgets/agua_tips_card.dart';

class AguaPage extends ConsumerWidget {
  const AguaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aguaAsync = ref.watch(aguaProvider);

    return Scaffold(
      appBar: const NutriAppBar(),
      body: aguaAsync.when(
        data: (state) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 1020,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Cartão de progresso
                      AguaProgressCard(
                        dailyWaterGoal: state.dailyWaterGoal,
                        todayProgress: state.todayProgress,
                        onAjustarMeta: () => _showGoalDialog(context, ref, state.dailyWaterGoal),
                      ),
                      const SizedBox(height: 8),

                      // Dicas de saúde
                      AguaTipsCard(tip: _getTipOfTheDay()),
                      const SizedBox(height: 8),

                      // Calendário e gráfico
                      const AguaCalendarCard(),
                      const SizedBox(height: 8),

                      // Conquistas
                      const AguaAchievementCard(),
                      const SizedBox(height: 8),

                      // Lista de registros
                      const AguaRegistrosCard(),
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
              Text('Erro: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(aguaProvider),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegistroDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTipOfTheDay() {
    final tips = [
      'Beber água ao acordar ajuda a hidratar o corpo após o sono.',
      'Manter-se hidratado melhora a concentração e o desempenho mental.',
      'A água ajuda a regular a temperatura corporal.',
      'Beber água antes das refeições pode ajudar na digestão.',
      'A hidratação adequada melhora a saúde da pele.',
    ];
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  // Método para exibir diálogo de ajuste de meta diária
  Future<void> _showGoalDialog(BuildContext context, WidgetRef ref, double currentGoal) async {
    final TextEditingController textController = TextEditingController(
        text: currentGoal.toInt().toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Meta Diária'),
        content: TextField(
          controller: textController,
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
              if (textController.text.isNotEmpty) {
                final double newGoal = double.parse(textController.text);
                ref.read(aguaProvider.notifier).updateDailyGoal(newGoal);
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Método para exibir diálogo de cadastro/edição de registro
  Future<void> _showRegistroDialog(BuildContext context, WidgetRef ref, BeberAgua? registro) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: 400,
          height: 240,
          child: AguaCadastroWidget(
            registro: registro,
            onSave: (newRegistro) async {
              if (registro == null) {
                await ref.read(aguaProvider.notifier).addRegistro(newRegistro);
              } else {
                await ref.read(aguaProvider.notifier).updateRegistro(newRegistro);
              }
            },
          ),
        ),
      ),
    );
  }

  // Método para deletar um registro
  // ignore: unused_element
  Future<void> _deleteRegistro(BuildContext context, WidgetRef ref, BeberAgua registro) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(aguaProvider.notifier).deleteRegistro(registro);
    }
  }
}
