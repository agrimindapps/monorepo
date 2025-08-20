// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/nivel_dano_economico_controller.dart';

class InputFieldsWidget extends StatelessWidget {
  final NivelDanoEconomicoController controller;

  const InputFieldsWidget({super.key, required this.controller});

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
            _buildInputs(isDark),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputs(bool isDark) {
    return Column(
      children: [
        VTextField(
          labelText: 'Custo do produto de controle (R\$/ha)',
          hintText: 'Ex: 150',
          focusNode: controller.focus1,
          txEditController: controller.custoProduto,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        VTextField(
          labelText: 'Eficácia do controle (%)',
          hintText: 'Ex: 80',
          focusNode: controller.focus2,
          txEditController: controller.eficaciaControle,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        VTextField(
          labelText: 'Dano causado por praga/doença (%)',
          hintText: 'Ex: 30',
          focusNode: controller.focus3,
          txEditController: controller.danoPlanta,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        VTextField(
          labelText: 'Valor do produto agrícola (R\$/unidade)',
          hintText: 'Ex: 50',
          focusNode: controller.focus4,
          txEditController: controller.valorProduto,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
