// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../models/manutencoes_constants.dart';

class ManutencoesCadastroFormView
    extends GetView<ManutencoesCadastroFormController> {
  const ManutencoesCadastroFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(
              ManutencaoConstants.sectionTitles['informacoesBasicas']!,
              ManutencaoConstants.sectionIcons['informacoesBasicas']!,
            ),
            const SizedBox(height: 4),
            _buildOdometroField(),
            const SizedBox(height: 4),
            _buildDataField(context),
            const SizedBox(height: 12),
            _buildSectionHeader(
              ManutencaoConstants.sectionTitles['custosData']!,
              ManutencaoConstants.sectionIcons['custosData']!,
            ),
            const SizedBox(height: 8),
            _buildTipoField(),
            const SizedBox(height: 8),
            _buildValorField(),
            const SizedBox(height: 8),
            _buildDescricaoField(),
            const SizedBox(height: 12),
            _buildSectionHeader(
              ManutencaoConstants.sectionTitles['configuracoes']!,
              ManutencaoConstants.sectionIcons['configuracoes']!,
            ),
            const SizedBox(height: 8),
            _buildProximaRevisaoField(context),
            const SizedBox(height: 8),
            _buildConcluidaField(),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoField() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: ShadcnStyle.inputDecoration(
            label: ManutencaoConstants.fieldLabels['tipo']!,
          ),
          value: controller.tipo.value,
          items: ManutencaoConstants.tiposManutencao.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: controller.validateTipo,
          onChanged: (value) => controller.setTipo(value ?? ''),
          onSaved: (value) => controller.setTipo(value ?? ''),
        ));
  }

  Widget _buildDescricaoField() {
    return Obx(() => TextFormField(
          initialValue: controller.descricao.value,
          decoration: ShadcnStyle.inputDecoration(
            label: ManutencaoConstants.fieldLabels['descricao']!,
            hint: ManutencaoConstants.fieldHints['descricao']!,
            showCounter: true,
            suffixIcon: controller.descricao.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearDescricao(),
                  )
                : null,
          ),
          maxLength: 255,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: controller.validateDescricao,
          onSaved: (value) => controller.setDescricao(value?.trim() ?? ''),
          onChanged: (value) => controller.setDescricao(value),
        ));
  }

  Widget _buildValorField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          decoration: ShadcnStyle.inputDecoration(
            label: ManutencaoConstants.fieldLabels['valor']!,
            prefix: 'R\$ ',
            hint: ManutencaoConstants.fieldHints['valor']!,
            suffixIcon: controller.valor.value > 0
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearValor(),
                  )
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.formatCurrency(controller.valor.value),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
          ],
          validator: controller.validateValor,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              final cleanValue = value!.replaceAll(',', '.');
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
              label: ManutencaoConstants.fieldLabels['dataHora']!,
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: ShadcnStyle.labelColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
          decoration: ShadcnStyle.inputDecoration(
            label: ManutencaoConstants.fieldLabels['odometro']!,
            suffix: 'km',
            suffixIcon: controller.odometro.value > 0
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clearOdometro(),
                  )
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.formatOdometro(controller.odometro.value),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,1}')),
          ],
          validator: controller.validateOdometro,
          onSaved: (value) {
            if (value?.isNotEmpty ?? false) {
              final cleanValue = value!.replaceAll(',', '.');
              controller.setOdometro(double.parse(cleanValue).round());
            }
          },
          onChanged: (value) => controller.parseAndSetOdometro(value),
        ));
  }

  Widget _buildProximaRevisaoField(BuildContext context) {
    return Obx(() => InkWell(
          onTap: () => controller.pickProximaRevisao(context),
          child: InputDecorator(
            decoration: ShadcnStyle.inputDecoration(
              label: ManutencaoConstants.fieldLabels['proximaRevisao']!,
              suffixIcon: controller.proximaRevisao.value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clearProximaRevisao(),
                    )
                  : null,
            ),
            child: Text(
              controller.formatProximaRevisao(controller.proximaRevisao.value),
              style: ShadcnStyle.inputStyle,
            ),
          ),
        ));
  }

  Widget _buildConcluidaField() {
    return Obx(() => Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          decoration: BoxDecoration(
            color: ShadcnStyle.backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ShadcnStyle.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ManutencaoConstants.fieldLabels['concluida']!,
                style: TextStyle(
                  fontSize: 14,
                  color: ShadcnStyle.textColor,
                ),
              ),
              Switch(
                value: controller.concluida.value,
                onChanged: (value) => controller.setConcluida(value),
                activeColor: ShadcnStyle.focusedBorderColor,
              ),
            ],
          ),
        ));
  }
}
