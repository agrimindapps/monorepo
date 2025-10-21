// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/calorias_diarias_controller.dart';

class CaloriasDiariasResult extends StatelessWidget {
  final CaloriasDiariasController controller;

  const CaloriasDiariasResult({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.model.resultado == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Resultado'),
            trailing: IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: controller.compartilhar,
            ),
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
          _buildResultValues(),
        ],
      ),
    );
  }

  Widget _buildResultValues() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Text(
            'Consumo calórico diário estimado: ${controller.model.resultado} Kcal',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Text(
            'Dicas:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: Text(
            '• Para manutenção de peso, consuma aproximadamente esta quantidade de calorias.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: Text(
            '• Para perder peso, reduza esta quantidade em 15-20%.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: Text(
            '• Para ganhar peso, aumente esta quantidade em 15-20%.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Text(
            '• Esta é uma estimativa. Consulte um profissional de saúde para recomendações personalizadas.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
