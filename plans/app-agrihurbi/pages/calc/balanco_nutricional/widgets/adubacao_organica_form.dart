// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../constants.dart';
import '../controllers/adubacao_organica_controller.dart';
import '../models/adubacao_organica_model.dart';
import 'base_form_widget.dart';

class AdubacaoOrganicaForm extends StatelessWidget {
  final AdubacaoOrganicaController controller;
  const AdubacaoOrganicaForm({super.key, required this.controller});

  Widget _buildUnidadeSeletor(AdubacaoOrganicaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.model.unidadeAdubo,
          isExpanded: true,
          icon: const Icon(BalancoNutricionalIcons.arrowDropDown),
          dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          style: TextStyle(color: ShadcnStyle.textColor),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: [
            BalancoNutricionalStrings.unitTHa,
            BalancoNutricionalStrings.unitKgha
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.setUnidadeAdubo(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFonteOrganicaSeletor(AdubacaoOrganicaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadcnStyle.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: controller.model.fonteOrganicaSelecionada,
          isExpanded: true,
          icon: const Icon(BalancoNutricionalIcons.arrowDropDown),
          dropdownColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          style: TextStyle(color: ShadcnStyle.textColor),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: AdubacaoOrganicaModel.fontesOrganicas
              .asMap()
              .entries
              .map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value['nome']),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              controller.setFonteOrganica(newValue);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final controller = Get.find<AdubacaoOrganicaController>();

    return GetBuilder<AdubacaoOrganicaController>(
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
              BalancoNutricionalStrings.formFonteOrganica,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFonteOrganicaSeletor(controller),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              BalancoNutricionalIcons.scaleOutlined,
              color: isDark
                  ? BalancoNutricionalColors.blue
                  : BalancoNutricionalColors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              BalancoNutricionalStrings.formUnidade,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildUnidadeSeletor(controller),
        const SizedBox(height: 16),
        VTextField(
          labelText:
              '${BalancoNutricionalStrings.labelQuantidadeAdubo} (${controller.model.unidadeAdubo})',
          hintText: 'Ex: 10',
          focusNode: controller.focus1,
          txEditController: controller.quantidadeAduboController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        if (controller.model.fonteOrganicaSelecionada == 0) ...[
          const SizedBox(height: 16),
          VTextField(
            labelText: BalancoNutricionalStrings.labelTeorNitrogenio,
            hintText: 'Ex: 1.7',
            focusNode: controller.focus2,
            txEditController: controller.teorNitrogenioController,
            inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
            showClearButton: true,
          ),
          const SizedBox(height: 16),
          VTextField(
            labelText: BalancoNutricionalStrings.labelTeorFosforo,
            hintText: 'Ex: 0.9',
            focusNode: controller.focus3,
            txEditController: controller.teorFosforoController,
            inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
            showClearButton: true,
          ),
          const SizedBox(height: 16),
          VTextField(
            labelText: BalancoNutricionalStrings.labelTeorPotassio,
            hintText: 'Ex: 1.4',
            focusNode: controller.focus4,
            txEditController: controller.teorPotassioController,
            inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
            showClearButton: true,
          ),
          const SizedBox(height: 16),
          VTextField(
            labelText: BalancoNutricionalStrings.labelMateriaSecaAdubo,
            hintText: 'Ex: 40',
            focusNode: controller.focus6,
            txEditController: controller.materiaSecaAduboController,
            inputFormatters: [DecimalInputFormatter(decimalPlaces: 1)],
            showClearButton: true,
          ),
        ],
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelAreaTratada,
          hintText: 'Ex: 10',
          focusNode: controller.focus5,
          txEditController: controller.areaTratadaController,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
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
