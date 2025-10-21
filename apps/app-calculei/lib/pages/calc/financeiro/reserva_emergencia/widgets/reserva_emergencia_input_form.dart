// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';
import 'package:app_calculei/pages/calc/financeiro/reserva_emergencia/widgets/controller/reserva_emergencia_controller.dart';

class ReservaEmergenciaInputForm extends StatelessWidget {
  const ReservaEmergenciaInputForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReservaEmergenciaController>();
    final isDark = ThemeManager().isDark.value;

    final maskFormatter = MaskTextInputFormatter(
      mask: 'R\$ #.###.###,##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 30, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              context: context,
              labelText: 'Despesas Mensais *',
              controller: controller.despesasMensaisController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [maskFormatter],
              focusNode: controller.focusDespesasMensais,
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: isDark ? Colors.amber.shade300 : Colors.amber,
              ),
              helperText: 'Insira o total de suas despesas mensais fixas',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              labelText: 'Despesas Extras (opcional)',
              controller: controller.despesasExtrasController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [maskFormatter],
              focusNode: controller.focusDespesasExtras,
              prefixIcon: Icon(
                Icons.add_shopping_cart_rounded,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              helperText:
                  'Despesas adicionais não incluídas nas despesas fixas',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildMesesSelector(isDark),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              labelText: 'Valor Economizado Mensalmente (opcional)',
              controller: controller.valorPoupadoController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [maskFormatter],
              focusNode: controller.focusValorPoupado,
              prefixIcon: Icon(
                Icons.savings_outlined,
                color: isDark ? Colors.green.shade300 : Colors.green,
              ),
              helperText:
                  'Para estimar o tempo necessário para construir sua reserva',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: controller.limparCampos,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Limpar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => controller.calcularReserva(context),
                  style: ShadcnStyle.primaryButtonStyle,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calcular'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMesesSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meses de Cobertura *',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Consumer<ReservaEmergenciaController>(
          builder: (context, controller, _) {
            return Row(
              children: [
                _buildIconButton(
                  icon: Icons.remove,
                  onPressed: controller.decrementarMeses,
                  isDark: isDark,
                  isLeft: true,
                ),
                Expanded(
                  child: TextField(
                    controller: controller.mesesController,
                    focusNode: controller.focusMeses,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                _buildIconButton(
                  icon: Icons.add,
                  onPressed: controller.incrementarMeses,
                  isDark: isDark,
                  isRight: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Recomendado: De 3 a 12 meses, dependendo da sua situação',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    bool isLeft = false,
    bool isRight = false,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(8) : Radius.zero,
          right: isRight ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String labelText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required FocusNode focusNode,
    required Widget prefixIcon,
    required String helperText,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        helperText: helperText,
        helperStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            size: 20,
          ),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }
}
