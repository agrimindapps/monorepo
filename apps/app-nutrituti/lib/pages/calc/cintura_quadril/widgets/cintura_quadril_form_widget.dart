// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/utils/decimal_input_formatter.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/cintura_quadril_controller.dart';

class CinturaQuadrilFormWidget extends StatelessWidget {
  final CinturaQuadrilController controller;
  final VoidCallback? onInfoPressed;

  const CinturaQuadrilFormWidget({
    super.key,
    required this.controller,
    this.onInfoPressed,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Informe os valores para o cálculo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
            _buildGeneroSelector(context),
            VTextField(
              labelText: 'Cintura (cm)',
              hintText: '0.0',
              focusNode: controller.focusCintura,
              txEditController: controller.cinturaController,
              prefixIcon: Icon(
                Icons.straighten_outlined,
                color: isDark ? Colors.teal.shade300 : Colors.teal,
              ),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 1),
              ],
              keyboardType: TextInputType.number,
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Quadril (cm)',
              hintText: '0.0',
              focusNode: controller.focusQuadril,
              txEditController: controller.quadrilController,
              prefixIcon: Icon(
                Icons.straighten_outlined,
                color: isDark ? Colors.teal.shade300 : Colors.teal,
              ),
              inputFormatters: [
                DecimalInputFormatter(decimalPlaces: 1),
              ],
              keyboardType: TextInputType.number,
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: controller.limpar,
                    child: const Text('Limpar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: controller.calcular,
                    child: const Text('Calcular'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroSelector(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ValueListenableBuilder<int>(
        valueListenable: controller.generoNotifier,
        builder: (context, generoSelecionado, child) {
          return Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Masculino'),
                  value: 1,
                  groupValue: generoSelecionado,
                  onChanged: (value) {
                    if (value != null) controller.onGeneroChanged(value);
                  },
                  activeColor: isDark ? Colors.teal.shade300 : Colors.teal,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Feminino'),
                  value: 2,
                  groupValue: generoSelecionado,
                  onChanged: (value) {
                    if (value != null) controller.onGeneroChanged(value);
                  },
                  activeColor: isDark ? Colors.teal.shade300 : Colors.teal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
