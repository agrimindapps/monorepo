// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../controller/znew_indice_adiposidade_controller.dart';

class ZNewIndiceAdiposidadeInputForm extends StatelessWidget {
  final ZNewIndiceAdiposidadeController controller;
  const ZNewIndiceAdiposidadeInputForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final quadrilMask = MaskTextInputFormatter(
      mask: '###,#',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    final alturaMask = MaskTextInputFormatter(
      mask: '###,#',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados Pessoais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gênero',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Masculino'),
                  value: 1,
                  groupValue: controller.generoSelecionado,
                  onChanged: (value) =>
                      controller.setGeneroSelecionado(value ?? 1),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  title: const Text('Feminino'),
                  value: 2,
                  groupValue: controller.generoSelecionado,
                  onChanged: (value) =>
                      controller.setGeneroSelecionado(value ?? 2),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VTextField(
            txEditController: controller.quadrilController,
            labelText: 'Circunferência do Quadril (cm)',
            keyboardType: TextInputType.number,
            inputFormatters: [
              quadrilMask,
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text.replaceAll('.', ',');
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            focusNode: controller.focusQuadril,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(controller.focusAltura),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          VTextField(
            txEditController: controller.alturaController,
            labelText: 'Altura (cm)',
            keyboardType: TextInputType.number,
            inputFormatters: [
              alturaMask,
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text.replaceAll('.', ',');
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            focusNode: controller.focusAltura,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(controller.focusIdade),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          VTextField(
            txEditController: controller.idadeController,
            labelText: 'Idade (anos)',
            keyboardType: TextInputType.number,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text.replaceAll('.', ',');
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            focusNode: controller.focusIdade,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: controller.limpar,
                child: const Text('Limpar'),
              ),
              ElevatedButton(
                onPressed: () => controller.calcular(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Calcular'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
