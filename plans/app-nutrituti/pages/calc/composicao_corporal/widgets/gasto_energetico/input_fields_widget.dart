// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/gasto_energetico_controller.dart';

class InputFieldsWidget extends StatelessWidget {
  final GastoEnergeticoController controller;
  final VoidCallback onCalcular;
  final VoidCallback onLimpar;
  final VoidCallback onInfoPressed;

  final _pesomask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _alturamask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _idademask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  InputFieldsWidget({
    super.key,
    required this.controller,
    required this.onCalcular,
    required this.onLimpar,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: isDark ? Colors.orange.shade300 : Colors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dados para cálculo do GET',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark ? Colors.blue.shade300 : Colors.blue,
                    ),
                    onPressed: onInfoPressed,
                    tooltip: 'Informações sobre o cálculo',
                  ),
                ],
              ),
            ),
            _buildGeneroDropdown(isDark),
            Row(
              children: [
                Expanded(
                  child: VTextField(
                    labelText: 'Peso (kg)',
                    hintText: 'Ex: 70',
                    focusNode: controller.focusPeso,
                    txEditController: controller.pesoController,
                    prefixIcon: Icon(
                      Icons.monitor_weight_outlined,
                      color: isDark ? Colors.blue.shade300 : Colors.blue,
                    ),
                    inputFormatters: [_pesomask],
                    showClearButton: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: VTextField(
                    labelText: 'Altura (cm)',
                    hintText: 'Ex: 170',
                    focusNode: controller.focusAltura,
                    txEditController: controller.alturaController,
                    prefixIcon: Icon(
                      Icons.height,
                      color: isDark ? Colors.green.shade300 : Colors.green,
                    ),
                    inputFormatters: [_alturamask],
                    showClearButton: true,
                  ),
                ),
              ],
            ),
            VTextField(
              labelText: 'Idade (anos)',
              hintText: 'Ex: 30',
              focusNode: controller.focusIdade,
              txEditController: controller.idadeController,
              prefixIcon: Icon(
                Icons.calendar_today,
                color: isDark ? Colors.purple.shade300 : Colors.purple,
              ),
              inputFormatters: [_idademask],
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
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
                  TextButton.icon(
                    onPressed: onCalcular,
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Calcular'),
                    style: ShadcnStyle.primaryButtonStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ShadcnStyle.borderColor),
          color: isDark ? ShadcnStyle.backgroundColor : Colors.blueGrey.shade50,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: controller.model.generoSelecionado,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
            style: TextStyle(color: ShadcnStyle.textColor),
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            items: controller.generos.map((genero) {
              return DropdownMenuItem<int>(
                value: genero['id'] as int,
                child: Row(
                  children: [
                    Icon(
                      genero['id'] == 1 ? Icons.male : Icons.female,
                      color: genero['id'] == 1
                          ? (isDark ? Colors.blue.shade300 : Colors.blue)
                          : (isDark ? Colors.pink.shade300 : Colors.pink),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(genero['text'] as String),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => controller.setGenero(value ?? 1),
          ),
        ),
      ),
    );
  }
}
