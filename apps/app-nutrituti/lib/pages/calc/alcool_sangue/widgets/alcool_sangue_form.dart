// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../controller/alcool_sangue_controller.dart';

class AlcoolSangueForm extends StatelessWidget {
  final AlcoolSangueController controller;

  const AlcoolSangueForm({
    super.key,
    required this.controller,
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
            _buildBebidaSelector(),
            VTextField(
              txEditController: controller.alcoolController,
              focusNode: controller.focusAlcool,
              labelText: '% de Álcool da Bebida',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 2),
              ],
              prefixIcon: Icon(
                Icons.percent_outlined,
                color: isDark ? Colors.red.shade300 : Colors.red,
              ),
              showClearButton: true,
            ),
            VTextField(
              txEditController: controller.volumeController,
              focusNode: controller.focusVolume,
              labelText: 'Volume Consumido (ml)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 2),
              ],
              prefixIcon: Icon(
                Icons.local_drink_outlined,
                color: isDark ? Colors.amber.shade300 : Colors.amber,
              ),
              showClearButton: true,
            ),
            VTextField(
              txEditController: controller.tempoController,
              focusNode: controller.focusTempo,
              labelText: 'Tempo Passado (horas)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 2),
              ],
              prefixIcon: Icon(
                Icons.timer_outlined,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              showClearButton: true,
            ),
            VTextField(
              txEditController: controller.pesoController,
              focusNode: controller.focusPeso,
              labelText: 'Peso (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 2),
              ],
              prefixIcon: Icon(
                Icons.monitor_weight_outlined,
                color: isDark ? Colors.green.shade300 : Colors.green,
              ),
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: controller.limpar,
                    style: ShadcnStyle.primaryButtonStyle,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Limpar'),
                  ),
                  TextButton.icon(
                    onPressed: controller.calcular,
                    style: ShadcnStyle.primaryButtonStyle,
                    icon: const Icon(Icons.calculate_outlined),
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

  Widget _buildBebidaSelector() {
    final isDark = ThemeManager().isDark.value;
    final bebidas = [
      {'nome': 'Cerveja Pilsen', 'alcool': '4,5'},
      {'nome': 'Cerveja IPA', 'alcool': '6,2'},
      {'nome': 'Vinho Tinto', 'alcool': '13,0'},
      {'nome': 'Vinho Branco', 'alcool': '11,5'},
      {'nome': 'Espumante', 'alcool': '12,0'},
      {'nome': 'Vodka', 'alcool': '40,0'},
      {'nome': 'Whisky', 'alcool': '43,0'},
      {'nome': 'Cachaça', 'alcool': '39,0'},
      {'nome': 'Outro...', 'alcool': ''},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Tipo de Bebida',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.local_bar_outlined,
              color: isDark ? Colors.red.shade300 : Colors.red,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          items: List.generate(bebidas.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                '${bebidas[index]['nome']} ${bebidas[index]['alcool']!.isNotEmpty ? '(${bebidas[index]['alcool']}%)' : ''}',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
            );
          }),
          onChanged: (index) {
            if (index != null && index < bebidas.length - 1) {
              controller.alcoolController.text = bebidas[index]['alcool']!;
            } else {
              controller.alcoolController.clear();
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalInputFormatter({required this.decimalPlaces});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp regEx = RegExp(r'^\d*[\,\.]?\d*$');
    if (!regEx.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Verificar se há mais de um separador decimal
    if (newValue.text.indexOf(',') != newValue.text.lastIndexOf(',') ||
        newValue.text.indexOf('.') != newValue.text.lastIndexOf('.')) {
      return oldValue;
    }

    // Verificar se há mais de um tipo de separador decimal
    if (newValue.text.contains(',') && newValue.text.contains('.')) {
      return oldValue;
    }

    // Verificar o número de casas decimais
    if (newValue.text.contains(',')) {
      final parts = newValue.text.split(',');
      if (parts.length > 1 && parts[1].length > decimalPlaces) {
        return oldValue;
      }
    } else if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length > 1 && parts[1].length > decimalPlaces) {
        return oldValue;
      }
    }

    return newValue;
  }
}
