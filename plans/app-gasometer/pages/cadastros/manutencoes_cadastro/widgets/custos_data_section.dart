// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../models/manutencoes_constants.dart';

class CustosDataSectionWidget extends StatelessWidget {
  final ManutencoesCadastroFormController controller;

  const CustosDataSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            ManutencaoConstants.sectionTitles['custosData']!,
            ManutencaoConstants.sectionIcons['custosData']!,
          ),
          const SizedBox(height: 16),
          _buildTipoField(),
          const SizedBox(height: 12),
          _buildValorField(),
          const SizedBox(height: 12),
          _buildDescricaoField(),
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
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.green,
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
              labelText: ManutencaoConstants.fieldLabels['tipo'],
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
            value: controller.tipo.value,
            dropdownColor: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.white,
            items: ManutencaoConstants.tiposManutencao.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _getTipoColor(value),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(value),
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
    switch (tipo.toLowerCase()) {
      case 'preventiva':
        return Icons.build_circle;
      case 'corretiva':
        return Icons.build;
      case 'preditiva':
        return Icons.analytics;
      default:
        return Icons.build_outlined;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'preventiva':
        return Colors.blue;
      case 'corretiva':
        return Colors.orange;
      case 'preditiva':
        return Colors.purple;
      default:
        return ShadcnStyle.primaryColor;
    }
  }

  Widget _buildValorField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: ManutencaoConstants.fieldLabels['valor'],
            hintText: ManutencaoConstants.fieldHints['valor'],
            prefix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'R\$',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            prefixIcon: const Icon(
              Icons.attach_money,
              color: Colors.green,
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
                color: Colors.green,
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
              final cleanValue = value!.replaceAll(',', '.');
              controller.setValor(double.parse(cleanValue));
            }
          },
          onChanged: (value) => controller.parseAndSetValor(value),
        ));
  }

  Widget _buildDescricaoField() {
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(
            color: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ShadcnStyle.primaryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 16,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ManutencaoConstants.fieldLabels['descricao']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ShadcnStyle.mutedTextColor,
                      ),
                    ),
                    const Spacer(),
                    if (controller.descricao.value.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.descricao.value.length}/255',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextFormField(
                  initialValue: controller.descricao.value,
                  decoration: InputDecoration(
                    hintText: ManutencaoConstants.fieldHints['descricao'],
                    hintStyle: TextStyle(
                      color: ShadcnStyle.mutedTextColor.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLength: 255,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: controller.validateDescricao,
                  onSaved: (value) => controller.setDescricao(value?.trim() ?? ''),
                  onChanged: (value) => controller.setDescricao(value),
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) {
                    return null;
                  },
                ),
              ),
            ],
          ),
        ));
  }
}