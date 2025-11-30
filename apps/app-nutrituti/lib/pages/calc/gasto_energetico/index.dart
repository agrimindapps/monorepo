// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/gasto_energetico_controller.dart';
import 'gasto_energetico_utils.dart';
import 'widgets/gasto_energetico_info_dialog.dart';
import 'widgets/gasto_energetico_input_form.dart';
import 'widgets/gasto_energetico_result_card.dart';

class GastoEnergeticoPage extends StatelessWidget {
  const GastoEnergeticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GastoEnergeticoController(),
      child: const _GastoEnergeticoView(),
    );
  }
}

class _GastoEnergeticoView extends StatelessWidget {
  const _GastoEnergeticoView();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GastoEnergeticoController>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GastoEnergeticoInputForm(
          generoSelecionado: controller.generoSelecionado,
          pesoController: controller.pesoController,
          alturaController: controller.alturaController,
          idadeController: controller.idadeController,
          horasControllers: controller.horasControllers,
          focusPeso: controller.focusPeso,
          focusAltura: controller.focusAltura,
          focusIdade: controller.focusIdade,
          onCalcular: () {
            final msg = controller.calcular();
            if (msg != null) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(msg)));
            } else {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(
                    content: Text('Cálculo realizado com sucesso!')));
            }
          },
          onLimpar: controller.limpar,
          onInfoPressed: () => GastoEnergeticoInfoDialog.show(context),
          onGeneroChanged: controller.atualizarGenero,
        ),
        const SizedBox(height: 16),
        GastoEnergeticoResultCard(
          model: controller.modelo,
          isVisible: controller.calculado,
          onShare: () {
            // ignore: unused_local_variable
            final texto = GastoEnergeticoUtils.gerarTextoCompartilhamento(
                controller.modelo);
            // TODO: Implement share functionality
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
