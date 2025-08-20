// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

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

class AguaPage extends StatefulWidget {
  const AguaPage({super.key});

  @override
  State<AguaPage> createState() => _AguaPageState();
}

class _AguaPageState extends State<AguaPage> {
  // Usando GetX para gerenciamento de estado
  final AguaController controller = Get.put(AguaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NutriAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

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
                      dailyWaterGoal: controller.dailyWaterGoal.value,
                      todayProgress: controller.todayProgress.value,
                      onAjustarMeta: _showGoalDialog,
                    ),
                    const SizedBox(height: 8),

                    // Dicas de saúde
                    AguaTipsCard(tip: controller.getTipOfTheDay()),
                    const SizedBox(height: 8),

                    // Calendário e gráfico
                    const AguaCalendarCard(),
                    const SizedBox(height: 8),

                    // Conquistas
                    AguaAchievementCard(
                      achievements: controller.achievements,
                    ),
                    const SizedBox(height: 8),

                    // Lista de registros
                    AguaRegistrosCard(
                      registros: controller.registros,
                      onTap: _showRegistroDialog,
                      onDelete: _deleteRegistro,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegistroDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Método para exibir diálogo de ajuste de meta diária
  Future<void> _showGoalDialog() async {
    final TextEditingController textController = TextEditingController(
        text: controller.dailyWaterGoal.value.toInt().toString());

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
                controller.updateDailyGoal(newGoal);
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
  Future<void> _showRegistroDialog(BeberAgua? registro) {
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
                await controller.addRegistro(newRegistro);
              } else {
                await controller.updateRegistro(newRegistro);
              }
            },
          ),
        ),
      ),
    );
  }

  // Método para deletar um registro
  Future<void> _deleteRegistro(BeberAgua registro) async {
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
      await controller.deleteRegistro(registro);
    }
  }
}
