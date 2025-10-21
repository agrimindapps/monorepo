// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/calorias_exercicio_controller.dart';
import '../model/atividade_fisica_model.dart';

class CardCalculosWidget extends StatelessWidget {
  CardCalculosWidget({super.key});

  final _tempomask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CaloriasExercicioController>();
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
            _buildAtividadeDropdown(context, isDark, controller),
            VTextField(
              labelText: 'Tempo (min)',
              hintText: '0',
              txEditController: controller.tempoController,
              focusNode: controller.tempoFocus,
              prefixIcon: Icon(
                Icons.timer_outlined,
                color: isDark ? Colors.amber.shade300 : Colors.amber,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_tempomask],
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
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
                  TextButton.icon(
                    onPressed: () => controller.calcular(context),
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

  Widget _buildAtividadeDropdown(
    BuildContext context,
    bool isDark,
    CaloriasExercicioController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Atividade Física:',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.directions_run_outlined,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: controller.atividadeSelecionada.id,
          isExpanded: true,
          items: controller.atividades.map((AtividadeFisicaModel item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.text,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final atividade =
                  controller.atividades.firstWhere((item) => item.id == value);
              controller.setAtividade(atividade);
            }
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
