// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../constants.dart';
import '../controllers/correcao_acidez_controller.dart';
import '../models/correcao_acidez_model.dart';
import 'base_form_widget.dart';

class CorrecaoAcidezForm extends StatelessWidget {
  final CorrecaoAcidezController controller;
  const CorrecaoAcidezForm({super.key, required this.controller});

  Widget _buildMetodoSelector(CorrecaoAcidezController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.model.metodoSelecionado,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          style: TextStyle(color: ShadcnStyle.textColor),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: CorrecaoAcidezModel.metodos.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.setMetodo(newValue);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final controller = Get.find<CorrecaoAcidezController>();

    return GetBuilder<CorrecaoAcidezController>(
      builder: (_) {

        return BaseFormWidget(
      children: [
        Row(
          children: [
            Icon(
              BalancoNutricionalIcons.scienceOutlined,
              color: isDark
                  ? BalancoNutricionalColors.amber
                  : BalancoNutricionalColors.amber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              BalancoNutricionalStrings.formMetodoCalculo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildMetodoSelector(controller),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              BalancoNutricionalIcons.landscapeOutlined,
              color: isDark
                  ? BalancoNutricionalColors.brown
                  : BalancoNutricionalColors.brown,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              BalancoNutricionalStrings.formDadosSolo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelPHAtual,
          hintText: 'Ex: 5.2',
          focusNode: controller.focus1,
          txEditController: controller.pHAtualController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelPHDesejado,
          hintText: 'Ex: 6.5',
          focusNode: controller.focus2,
          txEditController: controller.pHDesejadoController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorCTC,
          hintText: 'Ex: 8.5',
          focusNode: controller.focus3,
          txEditController: controller.teorCTCController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelProfundidadeSolo,
          hintText: 'Ex: 20',
          focusNode: controller.focus4,
          txEditController: controller.profundidadeSoloController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 1)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelAreaCalagem,
          hintText: 'Ex: 10',
          focusNode: controller.focus5,
          txEditController: controller.areaCalagemController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelPRNTCalcario,
          hintText: 'Ex: 85',
          focusNode: controller.focus6,
          txEditController: controller.prntCalcarioController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 1)],
          showClearButton: true,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: controller.limpar,
              icon: const Icon(BalancoNutricionalIcons.clear, size: 18),
              label: const Text(BalancoNutricionalStrings.buttonTextClear),
              style: ShadcnStyle.textButtonStyle,
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => controller.calcular(context),
              icon: const Icon(BalancoNutricionalIcons.calculateOutlined,
                  size: 18),
              label: const Text(BalancoNutricionalStrings.buttonTextCalculate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        ],
        );
      },
    );
  }
}
