// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../controller/adiposidade_controller.dart';
import '../widgets/adiposidade_input_form.dart';
import '../widgets/adiposidade_result_card.dart';

class AdipososidadeView extends StatelessWidget {
  const AdipososidadeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdipososidadeController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdipososidadeInputForm(
              generoSelecionado: controller.generoSelecionado,
              quadrilController: controller.quadrilController,
              alturaController: controller.alturaController,
              idadeController: controller.idadeController,
              focusQuadril: controller.focusQuadril,
              focusAltura: controller.focusAltura,
              focusIdade: controller.focusIdade,
              onCalcular: () => controller.calcular(context),
              onLimpar: controller.limpar,
              onInfoPressed: () => _mostrarInfoDialog(context),
              onGeneroChanged: controller.atualizarGenero,
              quadrilError: controller.quadrilError,
              alturaError: controller.alturaError,
              idadeError: controller.idadeError,
            ),
            const SizedBox(height: 16),
            AdipososidadeResultCard(
              model: controller.modelo,
              isVisible: controller.calculado,
              onShare: controller.compartilhar,
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _mostrarInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Índice de Adiposidade Corporal (IAC)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'O que é o IAC?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O Índice de Adiposidade Corporal (IAC) é uma medida alternativa ao IMC para estimar a porcentagem de gordura corporal, sendo especialmente útil quando não é possível medir o peso.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Como é calculado?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fórmula: IAC = (Circunferência do Quadril / Altura^1,5) - 18',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utiliza apenas a circunferência do quadril e a altura, tornando-se uma alternativa prática quando a balança não está disponível.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vantagens do IAC:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Não requer medição de peso\n'
                  '• Considera diferenças entre gêneros\n'
                  '• Correlaciona bem com métodos mais precisos\n'
                  '• Fácil de medir em campo',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Limitações:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Menos preciso que DEXA ou bioimpedância\n'
                  '• Pode não ser adequado para atletas\n'
                  '• Necessita calibração para diferentes etnias',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text(
                    'Importante: Este cálculo tem fins educativos. Para avaliação médica precisa, consulte sempre um profissional de saúde.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
