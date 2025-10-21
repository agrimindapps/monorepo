// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controller/new_macronutrientes_controller.dart';

class NewMacronutrientesFormWidget extends StatelessWidget {
  const NewMacronutrientesFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MacronutrientesController>(context);
    final model = controller.model;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildCaloriasDiariasField(model),
            const SizedBox(height: 16),
            _buildPorcentagensSection(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriasDiariasField(model) {
    final isDark = ThemeManager().isDark.value;

    return VTextField(
      labelText: 'Calorias Diárias (kcal)',
      hintText: 'Ex: 2000',
      focusNode: model.focusCalorias,
      txEditController: model.caloriasDiariasController,
      prefixIcon: Icon(
        Icons.local_fire_department_outlined,
        color: isDark ? Colors.orange.shade300 : Colors.orange,
      ),
      inputFormatters: [model.caloriasmask],
      showClearButton: true,
    );
  }

  Widget _buildPorcentagensSection(BuildContext context) {
    final controller = Provider.of<MacronutrientesController>(context);
    final model = controller.model;
    final isDark = ThemeManager().isDark.value;
    final somaPorcentagens = controller.getSomaPorcentagens();
    final isSomaValida = somaPorcentagens == 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distribuição (%)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSomaValida
                      ? Colors.green.withValues(alpha: isDark ? 0.2 : 0.1)
                      : Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSomaValida
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Total: $somaPorcentagens%',
                  style: TextStyle(
                    color: isSomaValida ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildPorcentagemField(
                context,
                'Carboidratos (%)',
                'Ex: 50',
                model.carboidratosController,
                Icons.grain,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPorcentagemField(
                context,
                'Proteínas (%)',
                'Ex: 25',
                model.proteinasController,
                Icons.egg_alt,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPorcentagemField(
                context,
                'Gorduras (%)',
                'Ex: 25',
                model.gordurasController,
                Icons.water_drop,
                Colors.blue,
              ),
            ),
          ],
        ),
        if (!isSomaValida)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Text(
              'As porcentagens devem somar 100%',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPorcentagemField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
    Color color,
  ) {
    final mainController =
        Provider.of<MacronutrientesController>(context, listen: false);
    final isDark = ThemeManager().isDark.value;

    return VTextField(
      labelText: label,
      hintText: hint,
      txEditController: controller,
      prefixIcon: Icon(
        icon,
        color: isDark ? color.withValues(alpha: 0.8) : color,
      ),
      inputFormatters: [mainController.model.porcentagemmask],
      onChanged: (_) => mainController.notifyListeners(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller =
        Provider.of<MacronutrientesController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Limpar'),
            onPressed: () => controller.limpar(),
            style: ShadcnStyle.textButtonStyle,
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular'),
            onPressed: () => controller.calcular(context),
            style: ShadcnStyle.primaryButtonStyle,
          ),
        ],
      ),
    );
  }
}
