// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/tempo_irrigacao_controller.dart';
import '../../models/sistema_irrigacao_model.dart';

class TempoIrrigacaoForm extends StatelessWidget {
  final TempoIrrigacaoController controller;

  const TempoIrrigacaoForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 30, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ExpansionTile(
              title: Text(
                'Selecione um sistema de irrigação',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              leading: const Icon(FontAwesome.faucet_drip_solid, size: 18),
              children: [
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    itemCount: SistemaIrrigacaoInfo.sistemasDisponiveis.length,
                    itemBuilder: (context, index) {
                      final sistema =
                          SistemaIrrigacaoInfo.sistemasDisponiveis[index];
                      final isSelected =
                          controller.selectedSistema == sistema.nome;

                      return ListTile(
                        title: Text(sistema.nome),
                        subtitle: Text(
                          'Vazão: ${sistema.vazaoPadrao} L/h | Espaçamento: ${sistema.espacamentoPadrao} m | Eficiência: ${(sistema.eficienciaPadrao * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        leading: const Icon(FontAwesome.faucet_solid, size: 18),
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade50,
                        onTap: () =>
                            controller.setSistemaIrrigacao(sistema.nome),
                      );
                    },
                  ),
                ),
              ],
            ),
            VTextField(
              labelText: 'Lâmina a aplicar (mm)',
              hintText: 'Ex: 15',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.laminaAplicarFocus,
              txEditController: controller.laminaAplicarController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_vertical_solid, size: 18),
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Vazão por emissor (L/h)',
              hintText: 'Ex: 2.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.vazaoEmissorFocus,
              txEditController: controller.vazaoEmissorController,
              prefixIcon: const Icon(FontAwesome.faucet_drip_solid, size: 18),
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Espaçamento entre emissores (m)',
              hintText: 'Ex: 0.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.espacamentoEmissoresFocus,
              txEditController: controller.espacamentoEmissoresController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_horizontal_solid, size: 18),
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Espaçamento entre linhas (m)',
              hintText: 'Ex: 1.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.espacamentoLinhasFocus,
              txEditController: controller.espacamentoLinhasController,
              prefixIcon:
                  const Icon(FontAwesome.arrows_up_down_solid, size: 18),
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Eficiência da irrigação (%)',
              hintText: 'Ex: 85',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.eficienciaIrrigacaoFocus,
              txEditController: controller.eficienciaIrrigacaoController,
              prefixIcon: const Icon(FontAwesome.percent_solid, size: 18),
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: controller.limpar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: controller.calcular,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
