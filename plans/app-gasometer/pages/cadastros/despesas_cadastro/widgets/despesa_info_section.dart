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

class DespesaInfoSectionWidget extends StatelessWidget {
  final DespesaCadastroFormController controller;

  const DespesaInfoSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            DespesaConstants.sectionTitles['informacoesBasicas']!,
            DespesaConstants.sectionIcons['informacoesBasicas']!,
          ),
          const SizedBox(height: 16),
          _buildOdometroField(),
          const SizedBox(height: 12),
          _buildDataField(context),
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
            color: Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.blue,
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

  Widget _buildOdometroField() {
    return Obx(() => TextFormField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: 'Odômetro',
            hintText: 'Digite o odômetro atual',
            suffix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            prefixIcon: const Icon(
              Icons.speed,
              color: Colors.blue,
            ),
            suffixIcon: controller.odometro.value > 0
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.red.shade400,
                    ),
                    onPressed: () => controller.clearOdometro(),
                    tooltip: 'Limpar',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: ThemeManager().isDark.value
                ? Colors.grey.shade900
                : Colors.grey.shade50,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          initialValue: controller.odometro.value > 0
              ? controller.odometro.value
                  .toStringAsFixed(1)
                  .replaceAll('.', ',')
              : '',
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

  Widget _buildDataField(BuildContext context) {
    return Obx(() {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: ShadcnStyle.borderColor.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(8),
          color: ThemeManager().isDark.value
              ? Colors.grey.shade900
              : Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Data e Hora',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.pickDate(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              size: 18,
                              color: ShadcnStyle.mutedTextColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.formatDate(controller.data.value),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ThemeManager().isDark.value
                                    ? Colors.white
                                    : ShadcnStyle.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.pickTime(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: ShadcnStyle.mutedTextColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.formatTime(controller.data.value),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ThemeManager().isDark.value
                                    ? Colors.white
                                    : ShadcnStyle.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}