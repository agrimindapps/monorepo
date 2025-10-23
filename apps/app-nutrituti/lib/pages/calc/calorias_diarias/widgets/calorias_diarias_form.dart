// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/calorias_diarias_controller.dart';

class CaloriasDiariasForm extends StatelessWidget {
  final CaloriasDiariasController controller;

  final idadeMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final alturaMask = MaskTextInputFormatter(
    mask: '#,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final pesoMask = MaskTextInputFormatter(
    mask: '##,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  CaloriasDiariasForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _buildGeneroDropdown(isDark),
            _buildTextField(
              controller: controller.idadeController,
              labelText: 'Idade',
              prefixIcon: Icons.calendar_today,
              maskFormatter: idadeMask,
              isDark: isDark,
            ),
            _buildTextField(
              controller: controller.alturaController,
              labelText: 'Altura (metros)',
              prefixIcon: Icons.height,
              maskFormatter: alturaMask,
              isDark: isDark,
            ),
            _buildTextField(
              controller: controller.pesoController,
              labelText: 'Peso (kg)',
              prefixIcon: Icons.scale,
              maskFormatter: pesoMask,
              isDark: isDark,
            ),
            _buildAtividadeDropdown(isDark),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.calcular(context),
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calcular'),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.limpar,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroDropdown(bool isDark) {
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
            labelText: 'Gênero',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: controller.model.generoSelecionado,
          items: CaloriasDiariasController.generos.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'] as int?,
              child: Text(item['text'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) controller.setGenero(value);
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAtividadeDropdown(bool isDark) {
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
            labelText: 'Nível de Atividade',
            labelStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            prefixIcon: Icon(
              Icons.directions_run,
              color: isDark ? Colors.purple.shade300 : Colors.purple,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
          dropdownColor: isDark ? const Color(0xFF303030) : Colors.white,
          value: controller.model.atividadeSelecionada,
          items: CaloriasDiariasController.atividades.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'] as int?,
              child: Text(item['text'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) controller.setAtividade(value);
          },
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required MaskTextInputFormatter maskFormatter,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(
            prefixIcon,
            color: isDark ? Colors.purple.shade300 : Colors.purple,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          filled: true,
          fillColor: isDark
              ? ShadcnStyle.backgroundColor.withValues(alpha: 0.5)
              : Colors.grey.shade50,
        ),
        inputFormatters: [maskFormatter],
        keyboardType: TextInputType.number,
      ),
    );
  }
}
