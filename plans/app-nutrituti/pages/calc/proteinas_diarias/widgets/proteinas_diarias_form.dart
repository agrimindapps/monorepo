// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/proteinas_diarias_controller.dart';
import '../model/proteinas_diarias_model.dart';

class ProteinasDiariasForm extends StatelessWidget {
  final ProteinasDiariasModel model;
  final ProteinasDiariasController controller;
  final Function setState;

  const ProteinasDiariasForm({
    super.key,
    required this.model,
    required this.controller,
    required this.setState,
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
            _buildNivelAtividadeSelector(context),
            VTextField(
              labelText: 'Peso (kg)',
              hintText: '0.0',
              focusNode: model.focusPeso,
              txEditController: model.pesoController,
              prefixIcon: Icon(
                Icons.scale_outlined,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              inputFormatters: [model.pesoMask],
              showClearButton: true,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      controller.limpar();
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.grey : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.calcular(context);
                      setState(() {});
                    },
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calcular'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.blue.shade700 : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelAtividadeSelector(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

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
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Nível de Atividade Física',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.fitness_center_outlined,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: model.nivelAtividade,
          items: model.niveisAtividade.map((String nivel) {
            return DropdownMenuItem<String>(
              value: nivel,
              child: Text(
                nivel,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade200 : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                model.nivelAtividade = newValue;
              });
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
