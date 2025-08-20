// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/semeadura_controller.dart';

class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalInputFormatter({required this.decimalPlaces});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (newText.isEmpty) return newValue.copyWith(text: '');

    if (newText.contains('.')) {
      var parts = newText.split('.');
      if (parts.length > 2) newText = '${parts[0]}.${parts[1]}';
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        newText = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class InputFieldsWidget extends StatelessWidget {
  final SemeaduraController controller;
  final VoidCallback onCalcular;
  final VoidCallback onLimpar;

  const InputFieldsWidget({
    super.key,
    required this.controller,
    required this.onCalcular,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

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
              labelText: 'Área plantada (ha)',
              hintText: '0.0',
              focusNode: controller.focus1,
              txEditController: controller.areaPlantada,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Espaçamento entre linhas (m)',
              hintText: '0.0',
              focusNode: controller.focus2,
              txEditController: controller.espacamentoLinha,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Espaçamento entre plantas (m)',
              hintText: '0.0',
              focusNode: controller.focus3,
              txEditController: controller.espacamentoPlanta,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Poder de germinação (%)',
              hintText: '0.0',
              focusNode: controller.focus4,
              txEditController: controller.poderGerminacao,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Peso de mil sementes (g)',
              hintText: '0.0',
              focusNode: controller.focus5,
              txEditController: controller.pesoMilSementes,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onLimpar,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                    style: ShadcnStyle.textButtonStyle,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onCalcular,
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
  }
}
