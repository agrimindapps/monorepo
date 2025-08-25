// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/despesas_cadastro_form_controller.dart';
import '../models/despesas_constants.dart';

class DespesaDescricaoSectionWidget extends StatelessWidget {
  final DespesaCadastroFormController controller;

  const DespesaDescricaoSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            DespesaConstants.sectionTitles['descricao']!,
            DespesaConstants.sectionIcons['descricao']!,
          ),
          const SizedBox(height: 16),
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
            color: Colors.purple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.purple,
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
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
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
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.descricao.value.length}/255',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: controller.descricao.value,
                      decoration: InputDecoration(
                        hintText: 'Descreva a despesa (opcional)',
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
                    if (controller.descricao.value.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.purple.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () => controller.clearDescricao(),
                            tooltip: 'Limpar descrição',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}