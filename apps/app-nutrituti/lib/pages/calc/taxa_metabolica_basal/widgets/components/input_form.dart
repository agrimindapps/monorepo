// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controller/taxa_metabolica_basal_controller.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class InputForm extends StatelessWidget {
  const InputForm({super.key});

  Widget _buildGeneroDropdown() {
    return Consumer<TaxaMetabolicaBasalController>(
      builder: (context, controller, _) {
        final isDark = ThemeManager().isDark.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: controller.model.generoSelecionado,
            items: TMBConstants.generos.map((genero) {
              return DropdownMenuItem<int>(
                value: genero['id'] as int?,
                child: Text(genero['text'] as String),
              );
            }).toList(),
            onChanged: (value) => controller.setGenero(value!),
            decoration: InputDecoration(
              labelText: 'Gênero',
              prefixIcon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.purple.shade300 : Colors.purple,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNivelAtividadeDropdown() {
    return Consumer<TaxaMetabolicaBasalController>(
      builder: (context, controller, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<int>(
            initialValue: controller.model.nivelAtividadeSelecionado,
            items: TMBConstants.niveisAtividade.map((nivel) {
              return DropdownMenuItem<int>(
                value: nivel['id'] as int?,
                child: Text(nivel['text'] as String),
              );
            }).toList(),
            onChanged: (value) => controller.setNivelAtividade(value!),
            decoration: InputDecoration(
              labelText: 'Nível de Atividade Física',
              prefixIcon: Icon(
                TMBConstants.getNivelAtividadeIcon(
                  controller.model.nivelAtividadeSelecionado,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<TaxaMetabolicaBasalController>(
      builder: (context, controller, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: controller.limpar,
                icon: const Icon(Icons.refresh),
                label: const Text('Limpar'),
                style: ShadcnStyle.primaryButtonStyle,
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => controller.calcular(context),
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calcular'),
                style: ShadcnStyle.primaryButtonStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return Consumer<TaxaMetabolicaBasalController>(
      builder: (context, controller, _) {
        return Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ShadcnStyle.borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGeneroDropdown(),
                _buildNivelAtividadeDropdown(),
                VTextField(
                  labelText: 'Peso (kg)',
                  hintText: 'Ex: 70,5',
                  focusNode: controller.focusPeso,
                  txEditController: controller.pesoController,
                  prefixIcon: Icon(
                    Icons.monitor_weight_outlined,
                    color: isDark ? Colors.green.shade300 : Colors.green,
                  ),
                  inputFormatters: [TMBFormatters.pesoMask],
                  showClearButton: true,
                ),
                const SizedBox(height: 15),
                VTextField(
                  labelText: 'Altura (cm)',
                  hintText: 'Ex: 175',
                  focusNode: controller.focusAltura,
                  txEditController: controller.alturaController,
                  prefixIcon: Icon(
                    Icons.height_outlined,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                  inputFormatters: [TMBFormatters.alturaMask],
                  showClearButton: true,
                ),
                const SizedBox(height: 15),
                VTextField(
                  labelText: 'Idade',
                  hintText: 'Ex: 25',
                  focusNode: controller.focusIdade,
                  txEditController: controller.idadeController,
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: isDark ? Colors.orange.shade300 : Colors.orange,
                  ),
                  inputFormatters: [TMBFormatters.idadeMask],
                  showClearButton: true,
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}
