// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/manutencoes_cadastro_form_controller.dart';
import '../models/manutencoes_constants.dart';

class ConfiguracoesSectionWidget extends StatelessWidget {
  final ManutencoesCadastroFormController controller;

  const ConfiguracoesSectionWidget({
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
            ManutencaoConstants.sectionTitles['configuracoes']!,
            ManutencaoConstants.sectionIcons['configuracoes']!,
          ),
          const SizedBox(height: 16),
          _buildProximaRevisaoField(context),
          const SizedBox(height: 12),
          _buildConcluidaField(),
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

  Widget _buildProximaRevisaoField(BuildContext context) {
    return Obx(() => InkWell(
          onTap: () => controller.pickProximaRevisao(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeManager().isDark.value
                  ? Colors.grey.shade900
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ShadcnStyle.borderColor.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ManutencaoConstants.fieldLabels['proximaRevisao']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: ShadcnStyle.mutedTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatProximaRevisao(
                          controller.proximaRevisao.value,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: controller.proximaRevisao.value != null
                              ? (ThemeManager().isDark.value
                                  ? Colors.white
                                  : ShadcnStyle.textColor)
                              : ShadcnStyle.mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.proximaRevisao.value != null)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    onPressed: () => controller.clearProximaRevisao(),
                    tooltip: 'Limpar data',
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: ShadcnStyle.mutedTextColor,
                  ),
              ],
            ),
          ),
        ));
  }

  Widget _buildConcluidaField() {
    return Obx(() {
      final isCompleted = controller.concluida.value;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : Icons.pending_actions,
                size: 20,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ManutencaoConstants.fieldLabels['concluida']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeManager().isDark.value
                          ? Colors.white
                          : ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted
                        ? 'Manutenção já foi realizada'
                        : 'Manutenção ainda pendente',
                    style: TextStyle(
                      fontSize: 12,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.1,
              child: Switch(
                value: isCompleted,
                onChanged: (value) => controller.setConcluida(value),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.orange,
                inactiveTrackColor: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    });
  }
}