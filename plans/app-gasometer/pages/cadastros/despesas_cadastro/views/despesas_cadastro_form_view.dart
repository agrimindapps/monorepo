// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/despesas_cadastro_form_controller.dart';
import '../models/despesas_constants.dart';

class DespesaCadastroFormView extends GetView<DespesaCadastroFormController> {
  const DespesaCadastroFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              DespesaConstants.sectionTitles['informacoesBasicas']!,
              DespesaConstants.sectionIcons['informacoesBasicas']!,
            ),
            const SizedBox(height: 8),
            _buildOdometroField(),
            const SizedBox(height: 8),
            _buildDataField(context),
            const SizedBox(height: 8),
            _buildSectionHeader(
              DespesaConstants.sectionTitles['despesa']!,
              DespesaConstants.sectionIcons['despesa']!,
            ),
            const SizedBox(height: 4),
            _buildTipoField(),
            const SizedBox(height: 12),
            _buildValorField(),
            const SizedBox(height: 8),
            _buildSectionHeader(
              DespesaConstants.sectionTitles['descricao']!,
              DespesaConstants.sectionIcons['descricao']!,
            ),
            _buildDescricaoField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ShadcnStyle.mutedTextColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: ShadcnStyle.sectionHeaderStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTipoField() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.tipo.value.isEmpty ? null : controller.tipo.value,
          decoration: ShadcnStyle.inputDecoration(
            label: 'Tipo',
          ),
          isExpanded: true,
          hint: const Text('Selecione o tipo'),
          items: DespesaConstants.tiposDespesa
              .map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  ))
              .toList(),
          validator: controller.validateTipo,
          onChanged: (value) => controller.setTipo(value ?? ''),
          onSaved: (value) => controller.setTipo(value ?? ''),
        ));
  }

  Widget _buildDescricaoField() {
    return Obx(() => TextFormField(
          initialValue: controller.descricao.value,
          maxLines: 3,
          maxLength: 255,
          decoration: ShadcnStyle.inputDecoration(
            label: 'Descrição',
            hint: 'Descreva a despesa',
            suffixIcon: controller.descricao.value.isNotEmpty
                ? IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearDescricao(),
                  )
                : null,
            showCounter: true,
          ),
          validator: controller.validateDescricao,
          onSaved: (value) => controller.setDescricao(value?.trim() ?? ''),
          onChanged: (value) => controller.setDescricao(value),
        ));
  }

  Widget _buildValorField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.formatCurrency(controller.valor.value),
          decoration: ShadcnStyle.inputDecoration(
            label: 'Valor',
            prefix: 'R\$ ',
            hint: '0,00',
            suffixIcon: controller.valor.value > 0
                ? IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearValor(),
                  )
                : null,
          ),
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

  Widget _buildDataField(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          InputDecorator(
            decoration: ShadcnStyle.inputDecoration(
              label: 'Data e Hora',
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: ShadcnStyle.labelColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date picker
                Expanded(
                  child: InkWell(
                    onTap: () => controller.pickDate(context),
                    child: Text(
                      controller.formatDate(controller.data.value),
                      style: ShadcnStyle.inputStyle,
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: ShadcnStyle.borderColor,
                ),
                // Time picker
                Expanded(
                  child: InkWell(
                    onTap: () => controller.pickTime(context),
                    child: Text(
                      controller.formatTime(controller.data.value),
                      style: ShadcnStyle.inputStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOdometroField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.odometro.value > 0
              ? controller.odometro.value
                  .toStringAsFixed(1)
                  .replaceAll('.', ',')
              : '',
          decoration: ShadcnStyle.inputDecoration(
            label: 'Odometro',
            suffix: 'km',
            suffixIcon: controller.odometro.value > 0
                ? IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearOdometro(),
                  )
                : null,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,1}')),
          ],
          validator: controller.validateOdometro,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              final cleanValue = value!.replaceAll(',', '.');
              controller.setOdometro(double.parse(cleanValue));
            }
          },
          onChanged: (value) => controller.parseAndSetOdometro(value),
        ));
  }
}
