// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../../core/widgets/textbuttontopicon_widget.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/dimensionamento_controller.dart';

class DimensionamentoFormWidget extends StatelessWidget {
  final DimensionamentoController controller;
  final VoidCallback onShowHelp;

  const DimensionamentoFormWidget({
    super.key,
    required this.controller,
    required this.onShowHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dados de Entrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: onShowHelp,
                  tooltip: 'Ajuda',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            VTextField(
              labelText: 'Vazão requerida (m³/h/ha)',
              focusNode: controller.vazaoRequeridaFocus,
              txEditController: controller.vazaoRequeridaController,
              prefixIcon: const Icon(FontAwesome.water_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Área irrigada (hectares)',
              focusNode: controller.areaIrrigadaFocus,
              txEditController: controller.areaIrrigadaController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_combined_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Espaçamento entre aspersores (m)',
              focusNode: controller.espacamentoAspersoresFocus,
              txEditController: controller.espacamentoAspersoresController,
              prefixIcon:
                  const Icon(FontAwesome.ruler_horizontal_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Pressão de operação (mca)',
              focusNode: controller.pressaoOperacaoFocus,
              txEditController: controller.pressaoOperacaoController,
              prefixIcon: const Icon(FontAwesome.gauge_high_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            VTextField(
              labelText: 'Tempo disponível (horas/dia)',
              focusNode: controller.tempoDisponivelFocus,
              txEditController: controller.tempoDisponivelController,
              prefixIcon: const Icon(FontAwesome.clock_solid, size: 18),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VTextButtom(
                    title: 'Limpar',
                    onPress: controller.limpar,
                  ),
                  const SizedBox(width: 8),
                  VTextButtom(
                    title: 'Calcular',
                    onPress: controller.calcular,
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
