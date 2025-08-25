// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/despesas_cadastro_form_controller.dart';
import '../models/despesas_constants.dart';

class DespesaValorSectionWidget extends StatelessWidget {
  final DespesaCadastroFormController controller;

  const DespesaValorSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            DespesaConstants.sectionTitles['despesa']!,
            DespesaConstants.sectionIcons['despesa']!,
          ),
          const SizedBox(height: 16),
          _buildTipoField(),
          const SizedBox(height: 12),
          _buildValorField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeManager().isDark.value
                ? Colors.white
                : ShadcnStyle.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTipoField() {
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo da Despesa',
              prefixIcon: Icon(
                _getTipoIcon(controller.tipo.value),
                color: _getTipoColor(controller.tipo.value),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            value: controller.tipo.value.isEmpty ? null : controller.tipo.value,
            isExpanded: true,
            hint: const Text('Selecione o tipo'),
            dropdownColor: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            items: DespesaConstants.tiposDespesa.map((tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _getTipoColor(tipo),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(tipo),
                  ],
                ),
              );
            }).toList(),
            validator: controller.validateTipo,
            onChanged: (value) => controller.setTipo(value ?? ''),
            onSaved: (value) => controller.setTipo(value ?? ''),
          ),
        ));
  }

  IconData _getTipoIcon(String tipo) {
    return DespesaConstants.tiposIcons[tipo] ?? Icons.attach_money;
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'seguro':
        return Colors.green;
      case 'ipva':
        return Colors.purple;
      case 'estacionamento':
        return Colors.teal;
      case 'lavagem':
        return Colors.blue;
      case 'multa':
        return Colors.red;
      case 'pedágio':
        return Colors.brown;
      case 'licenciamento':
        return Colors.indigo;
      case 'acessórios':
        return Colors.orange;
      case 'documentação':
        return Colors.blueGrey;
      case 'outro':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  Widget _buildValorField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: 'Valor da Despesa',
            hintText: '0,00',
            prefix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'R\$',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            prefixIcon: const Icon(
              Icons.attach_money,
              color: Colors.red,
            ),
            suffixIcon: controller.valor.value > 0
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => controller.clearValor(),
                    tooltip: 'Limpar',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.grey.shade50,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.formatCurrency(controller.valor.value),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
          ],
          validator: controller.validateValor,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              final cleanValue =
                  value!.replaceAll('.', '').replaceAll(',', '.');
              controller.setValor(double.parse(cleanValue));
            }
          },
          onChanged: (value) => controller.parseAndSetValor(value),
        ));
  }
}