// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../controller/loteamento_bovino_controller.dart';

class LoteamentoInputFormWidget extends StatelessWidget {
  const LoteamentoInputFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoteamentoBovinoController>(
      builder: (controller) {
        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VTextField(
                  labelText: 'Quantidade de Animais',
                  hintText: '0',
                  focusNode: controller.focus1,
                  txEditController: controller.quantidadeAnimais,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 0)],
                  showClearButton: true,
                ),
                VTextField(
                  labelText: 'Peso Médio (kg)',
                  hintText: '0,0',
                  focusNode: controller.focus2,
                  txEditController: controller.pesoMedio,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                VTextField(
                  labelText: 'Área Total (ha)',
                  hintText: '0,0',
                  focusNode: controller.focus3,
                  txEditController: controller.quantidadeHectares,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
                  showClearButton: true,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: controller.limpar,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpar'),
                        style: ShadcnStyle.textButtonStyle,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => controller.calcular(context),
                        icon: const Icon(Icons.calculate_outlined, size: 18),
                        label: const Text('Calcular'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}