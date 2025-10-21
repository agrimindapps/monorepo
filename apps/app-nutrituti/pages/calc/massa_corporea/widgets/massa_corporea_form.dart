// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/massa_corporea_controller.dart';

class MassaCorporeaForm extends StatelessWidget {
  final bool isMobile;

  const MassaCorporeaForm({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MassaCorporeaController>();
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneroDropdown(controller),
            const SizedBox(height: 15),
            isMobile
                ? _buildMobileInputFields(isDark, controller)
                : _buildDesktopInputFields(isDark, controller),
            const SizedBox(height: 15),
            _buildButtons(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInputFields(
      bool isDark, MassaCorporeaController controller) {
    return Column(
      children: [
        VTextField(
          labelText: 'Peso (kg)',
          hintText: '0.0',
          focusNode: controller.focusPeso,
          txEditController: controller.pesoController,
          prefixIcon: Icon(
            Icons.monitor_weight_outlined,
            color: isDark ? Colors.amber.shade300 : Colors.amber,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.pesomask],
          showClearButton: true,
        ),
        const SizedBox(height: 8),
        VTextField(
          labelText: 'Altura (cm)',
          hintText: '0.0',
          focusNode: controller.focusAltura,
          txEditController: controller.alturaController,
          prefixIcon: Icon(
            Icons.height_outlined,
            color: isDark ? Colors.blue.shade300 : Colors.blue,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [controller.alturamask],
          showClearButton: true,
        ),
      ],
    );
  }

  Widget _buildDesktopInputFields(
      bool isDark, MassaCorporeaController controller) {
    return Row(
      children: [
        Expanded(
          child: VTextField(
            labelText: 'Peso (kg)',
            hintText: '0.0',
            focusNode: controller.focusPeso,
            txEditController: controller.pesoController,
            prefixIcon: Icon(
              Icons.monitor_weight_outlined,
              color: isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [controller.pesomask],
            showClearButton: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: VTextField(
            labelText: 'Altura (cm)',
            hintText: '0.0',
            focusNode: controller.focusAltura,
            txEditController: controller.alturaController,
            prefixIcon: Icon(
              Icons.height_outlined,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [controller.alturamask],
            showClearButton: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneroDropdown(MassaCorporeaController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Gênero',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          prefixIcon: Icon(Icons.person_outline),
        ),
        value: controller.generoSelecionado,
        items: controller.generos.map((genero) {
          return DropdownMenuItem<int>(
            value: genero['id'] as int,
            child: Text(genero['text'] as String),
          );
        }).toList(),
        onChanged: (value) => controller.setGenero(value ?? 1),
      ),
    );
  }

  Widget _buildButtons(
      BuildContext context, MassaCorporeaController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: controller.limpar,
          icon: const Icon(Icons.refresh),
          label: const Text('Limpar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => controller.calcular(context),
          style: ShadcnStyle.primaryButtonStyle,
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Calcular'),
        ),
      ],
    );
  }
}
