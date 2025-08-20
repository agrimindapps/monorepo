// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/diluicao_defensivos_controller.dart';
import 'unidade_selector_widget.dart';

class InputFieldsWidget extends StatelessWidget {
  final DiluicaoDefensivosController controller;

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
            _buildInputRow(isDark),
            _buildVolumeFields(isDark),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: VTextField(
            labelText: 'Dose recomendada por hectare',
            hintText: 'Ex: 2.5',
            focusNode: controller.focus1,
            txEditController: controller.doseRecomendada,
            inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
            showClearButton: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: UnidadeSelectorWidget(controller: controller),
        ),
      ],
    );
  }

  Widget _buildVolumeFields(bool isDark) {
    return Column(
      children: [
        VTextField(
          labelText: 'Volume de calda recomendado (L/ha)',
          hintText: 'Ex: 200',
          focusNode: controller.focus2,
          txEditController: controller.volumeCalda,
          inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
          showClearButton: true,
        ),
        VTextField(
          labelText: 'Volume do pulverizador (L)',
          hintText: 'Ex: 20',
          focusNode: controller.focus3,
          txEditController: controller.volumePulverizador,
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
