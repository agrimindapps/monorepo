// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../controllers/maquinario_controller.dart';

class PatinamentoWidget extends StatelessWidget {
  final MaquinarioController controller;
  final int index;

  const PatinamentoWidget({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final calculo = controller.calculos[index];
    final isDark = ThemeManager().isDark.value;

    final valor1Controller = TextEditingController(
        text: calculo.valor1 != 0 ? calculo.valor1.toString() : '');
    final valor2Controller = TextEditingController(
        text: calculo.valor2 != 0 ? calculo.valor2.toString() : '');

    return Column(
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VTextField(
                  txEditController: valor1Controller,
                  labelText: 'Tempo com implemento levantado',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    if (value.isNotEmpty && valor2Controller.text.isNotEmpty) {
                      controller.updateCalculo(
                        index,
                        double.parse(value.replaceAll(',', '.')),
                        double.parse(
                            valor2Controller.text.replaceAll(',', '.')),
                      );
                    }
                  },
                  showClearButton: true,
                ),
                VTextField(
                  txEditController: valor2Controller,
                  labelText: 'Tempo com implemento baixado',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    if (value.isNotEmpty && valor1Controller.text.isNotEmpty) {
                      controller.updateCalculo(
                        index,
                        double.parse(
                            valor1Controller.text.replaceAll(',', '.')),
                        double.parse(value.replaceAll(',', '.')),
                      );
                    }
                  },
                  showClearButton: true,
                ),
              ],
            ),
          ),
        ),
        if (calculo.resultado != 0) ...[
          const SizedBox(height: 10),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            controller.compartilharResultado(index),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Compartilhar'),
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
                  const SizedBox(height: 16),
                  Card(
                    color: (isDark ? Colors.blue.shade800 : Colors.blue.shade50)
                        .withAlpha(isDark ? 77 : 255),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: (isDark ? Colors.blue.shade300 : Colors.blue)
                            .withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${controller.formatNumber(calculo.resultado)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
