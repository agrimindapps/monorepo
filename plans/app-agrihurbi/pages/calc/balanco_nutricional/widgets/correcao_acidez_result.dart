// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../constants.dart';
import '../controllers/correcao_acidez_controller.dart';

class CorrecaoAcidezResult extends StatelessWidget {
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  CorrecaoAcidezResult({super.key});

  Widget _buildResultItem(
      String title, String value, IconData icon, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacoes() {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.amber.withOpacity(0.3) : Colors.amber.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  BalancoNutricionalIcons.tipsAndUpdatesOutlined,
                  color: isDark
                      ? BalancoNutricionalColors.amber
                      : BalancoNutricionalColors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  BalancoNutricionalStrings.recomendacoesTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecomendacaoItem(
              BalancoNutricionalStrings.recomendacao1,
              BalancoNutricionalIcons.gridOnOutlined,
              isDark
                  ? BalancoNutricionalColors.green
                  : BalancoNutricionalColors.green,
            ),
            _buildRecomendacaoItem(
              BalancoNutricionalStrings.recomendacao2,
              BalancoNutricionalIcons.agricultureOutlined,
              isDark
                  ? BalancoNutricionalColors.blue
                  : BalancoNutricionalColors.blue,
            ),
            _buildRecomendacaoItem(
              BalancoNutricionalStrings.recomendacao3,
              BalancoNutricionalIcons.calendarTodayOutlined,
              isDark
                  ? BalancoNutricionalColors.purple
                  : BalancoNutricionalColors.purple,
            ),
            _buildRecomendacaoItem(
              BalancoNutricionalStrings.recomendacao4,
              BalancoNutricionalIcons.layersOutlined,
              isDark
                  ? BalancoNutricionalColors.orange
                  : BalancoNutricionalColors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacaoItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final controller = Get.find<CorrecaoAcidezController>();

    return GetBuilder<CorrecaoAcidezController>(
      builder: (_) {
        return AnimatedOpacity(
          opacity: controller.calculado ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: controller.calculado,
            child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      BalancoNutricionalStrings.resultTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => SharePlus.instance.share(ShareParams(text: controller.compartilhar())),
                      icon: const Icon(BalancoNutricionalIcons.shareOutlined,
                          size: 18),
                      label: const Text(BalancoNutricionalStrings.shareButton),
                      style: ShadcnStyle.textButtonStyle,
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildResultItem(
                          BalancoNutricionalStrings.resultNecessidadeCalcario,
                          '${_numberFormat.format(controller.model.necessidadeCalcario)} ${BalancoNutricionalStrings.unitTHa}',
                          BalancoNutricionalIcons.scaleOutlined,
                          isDark
                              ? BalancoNutricionalColors.green
                              : BalancoNutricionalColors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultItem(
                          BalancoNutricionalStrings.resultQuantidadeTotal,
                          '${_numberFormat.format(controller.model.quantidadeTotal)} ${BalancoNutricionalStrings.unitT}',
                          BalancoNutricionalIcons.inventory2Outlined,
                          isDark
                              ? BalancoNutricionalColors.blue
                              : BalancoNutricionalColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRecomendacoes(),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
