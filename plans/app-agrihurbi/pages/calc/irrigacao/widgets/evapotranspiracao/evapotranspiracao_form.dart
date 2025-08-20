// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../../core/widgets/textbuttontopicon_widget.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/evapotranspiracao_controller.dart';

class EvapotranspiracaoForm extends StatelessWidget {
  final EvapotranspiracaoController controller;
  final VoidCallback onShowHelp;

  const EvapotranspiracaoForm({
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
                  'Dados para Cálculo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onShowHelp,
                  icon: const Icon(Icons.help_outline, size: 20),
                  tooltip: 'Ajuda',
                ),
              ],
            ),
            const Divider(),
            VTextField(
              labelText: 'Evapotranspiração de referência (mm/dia)',
              hintText: 'Ex: 5.2',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.evapotranspiracaoReferenciaFocus,
              txEditController:
                  controller.evapotranspiracaoReferenciaController,
              prefixIcon:
                  const Icon(FontAwesome.cloud_sun_rain_solid, size: 18),
            ),
            VTextField(
              labelText: 'Coeficiente de cultura (Kc)',
              hintText: 'Ex: 0.8',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.coeficienteCulturaFocus,
              txEditController: controller.coeficienteCulturaController,
              prefixIcon: const Icon(FontAwesome.leaf_solid, size: 18),
            ),
            VTextField(
              labelText: 'Coeficiente de estresse (Ks)',
              hintText: 'Ex: 1.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              focusNode: controller.coeficienteEstresseFocus,
              txEditController: controller.coeficienteEstresseController,
              prefixIcon: const Icon(FontAwesome.link_slash_solid, size: 18),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButtonTopIcon(
                    icon: Icons.calculate_outlined,
                    title: 'Calcular',
                    onPress: () => controller.calcular(context),
                  ),
                  const SizedBox(width: 12),
                  TextButtonTopIcon(
                    icon: Icons.refresh_outlined,
                    title: 'Limpar',
                    onPress: () => controller.limpar(context),
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
