// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controllers/micronutrientes_controller.dart';
import '../models/micronutrientes_model.dart';

// Global key para acesso ao contexto
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MicronutrientesForm extends StatelessWidget {
  const MicronutrientesForm({super.key});

  void _mostrarSeletorCultura(
      BuildContext context, MicronutrientesController controller) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? ShadcnStyle.backgroundColor : Colors.white,
          title: Text(
            'Selecione a cultura',
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MicronutrientesModel.culturas.map((cultura) {
                return ListTile(
                  title: Text(
                    cultura,
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  onTap: () {
                    controller.setCultura(cultura);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: ShadcnStyle.textButtonStyle,
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCulturaSeletor(MicronutrientesController controller) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _mostrarSeletorCultura(context, controller),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.model.culturaSelecionada.isEmpty
                    ? 'Selecione uma cultura'
                    : controller.model.culturaSelecionada,
                style: TextStyle(
                  color: controller.model.culturaSelecionada.isEmpty
                      ? Colors.grey.shade600
                      : ShadcnStyle.textColor,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final controller = Get.find<MicronutrientesController>();

    return GetBuilder<MicronutrientesController>(
      builder: (_) {

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
                    Icons.grain_outlined,
                    color: isDark ? Colors.green.shade300 : Colors.green,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dados para Cálculo de Micronutrientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.agriculture_outlined,
                  color: isDark ? Colors.amber.shade300 : Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cultura:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildCulturaSeletor(controller),
            VTextField(
              labelText: 'Teor de Zinco (mg/dm³)',
              hintText: 'Ex: 1.0',
              focusNode: controller.focus1,
              txEditController: controller.teorZincoController,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Teor de Boro (mg/dm³)',
              hintText: 'Ex: 0.3',
              focusNode: controller.focus2,
              txEditController: controller.teorBoroController,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Teor de Cobre (mg/dm³)',
              hintText: 'Ex: 0.8',
              focusNode: controller.focus3,
              txEditController: controller.teorCobreController,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Teor de Manganês (mg/dm³)',
              hintText: 'Ex: 5.0',
              focusNode: controller.focus4,
              txEditController: controller.teorManganesController,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Teor de Ferro (mg/dm³)',
              hintText: 'Ex: 12.0',
              focusNode: controller.focus5,
              txEditController: controller.teorFerroController,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Área plantada (ha)',
              hintText: 'Ex: 10',
              focusNode: controller.focus6,
              txEditController: controller.areaPlantadaController,
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
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpar'),
                  style: ShadcnStyle.textButtonStyle,
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => controller.calcular(context),
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Calcular'),
                  style: ShadcnStyle.primaryButtonStyle,
                ),
              ],
            ),
          ],
        ),
        ),
      );
      },
    );
  }
}
