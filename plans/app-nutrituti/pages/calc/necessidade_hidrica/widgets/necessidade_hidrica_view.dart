// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../controllers/necessidade_hidrica_controller.dart';
import 'info_card.dart';
import 'input_form.dart';
import 'result_card.dart';

class NecessidadeHidricaView extends StatelessWidget {
  const NecessidadeHidricaView({super.key});

  void _mostrarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.local_drink,
                color: Colors.cyan,
              ),
              SizedBox(width: 10),
              Text('Necessidade Hídrica'),
            ],
          ),
          content: const SingleChildScrollView(
            child: NecessidadeHidricaInfoCard(),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<NecessidadeHidricaController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
            title: Row(
              children: [
                Icon(
                  Icons.water_drop,
                  size: 20,
                  color: Colors.cyan.shade600,
                ),
                const SizedBox(width: 10),
                const Text('Necessidade Hídrica'),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.cyan.shade600,
                ),
                onPressed: () => _mostrarInfo(context),
                tooltip: 'Informações sobre a necessidade hídrica',
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      NecessidadeHidricaInputForm(
                        model: controller.model,
                        onCalcular: () => controller.calcular(context),
                        onLimpar: controller.limpar,
                      ),
                      if (controller.calculado)
                        NecessidadeHidricaResultCard(
                          model: controller.model,
                          isVisible: controller.calculado,
                          onShare: controller.compartilhar,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
