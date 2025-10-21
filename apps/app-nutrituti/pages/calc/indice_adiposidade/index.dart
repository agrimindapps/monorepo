// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'controller/znew_indice_adiposidade_controller.dart';
import 'widgets/znew_indice_adiposidade_info_dialog.dart';
import 'widgets/znew_indice_adiposidade_input_form.dart';
import 'widgets/znew_indice_adiposidade_result_card.dart';

class ZNewIndiceAdiposidadePage extends StatelessWidget {
  const ZNewIndiceAdiposidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ZNewIndiceAdiposidadeController();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Text('Índice de Adiposidade Corporal'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => Column(
                children: [
                  // Header com botão de informações
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Índice de Adiposidade Corporal (IAC)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              ZNewIndiceAdiposidadeInfoDialog.show(context),
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Informações sobre o índice',
                        ),
                      ],
                    ),
                  ),
                  ZNewIndiceAdiposidadeInputForm(controller: controller),
                  if (controller.calculado) ...[
                    const SizedBox(height: 24),
                    ZNewIndiceAdiposidadeResultCard(
                      modelo: controller.modelo,
                      onCompartilhar: controller.compartilhar,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
