// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../constants.dart';
import '../controllers/micronutrientes_controller.dart';
import '../models/micronutrientes_model.dart';
import 'base_form_widget.dart';

class MicronutrientesFormNew extends StatelessWidget {
  const MicronutrientesFormNew({super.key});

  void _mostrarSeletorCultura(
      BuildContext context, MicronutrientesController controller) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          title: Text(
            BalancoNutricionalStrings.dialogTitleCultura,
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MicronutrientesModel.culturas.map((String cultura) {
                return ListTile(
                  title: Text(
                    cultura,
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.setCultura(cultura);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ShadcnStyle.textButtonStyle,
              child: const Text(BalancoNutricionalStrings.buttonTextCancelar),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MicronutrientesController>();

    return GetBuilder<MicronutrientesController>(
      builder: (_) {
    final model = controller.model;

        return BaseFormWidget(
      children: [
        // Campo de seleção de cultura
        TextField(
          controller: model.culturaController,
          focusNode: model.focusCultura,
          readOnly: true,
          onTap: () => _mostrarSeletorCultura(context, controller),
          decoration: const InputDecoration(
            labelText: 'Cultura',
            suffixIcon: Icon(BalancoNutricionalIcons.arrowDropDown),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Campos de entrada de dados
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorZinco,
          focusNode: model.focusZinco,
          txEditController: model.teorZincoController,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorBoro,
          focusNode: model.focusBoro,
          txEditController: model.teorBoroController,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorCobre,
          focusNode: model.focusCobre,
          txEditController: model.teorCobreController,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorManganes,
          focusNode: model.focusManganes,
          txEditController: model.teorManganesController,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelTeorFerro,
          focusNode: model.focusFerro,
          txEditController: model.teorFerroController,
        ),
        const SizedBox(height: 16),
        VTextField(
          labelText: BalancoNutricionalStrings.labelAreaPlantada,
          focusNode: model.focusArea,
          txEditController: model.areaPlantadaController,
        ),
        const SizedBox(height: 16),

        // Botões de ação
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(BalancoNutricionalIcons.refresh),
                label: const Text(BalancoNutricionalStrings.buttonTextClear),
                onPressed: controller.limpar,
                style: ShadcnStyle.textButtonStyle,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(BalancoNutricionalIcons.calculate),
                label:
                    const Text(BalancoNutricionalStrings.buttonTextCalculate),
                onPressed: () => controller.calcular(context),
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
        ),
        ],
        );
      },
    );
  }
}
