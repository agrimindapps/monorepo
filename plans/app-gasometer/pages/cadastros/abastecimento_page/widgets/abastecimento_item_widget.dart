// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/23_abastecimento_model.dart';
import '../../abastecimento_cadastro/widgets/abastecimento_cadastro.dart';
import '../constants/abastecimento_strings.dart';
import '../controller/abastecimento_page_controller.dart';

class AbastecimentoItemWidget extends GetView<AbastecimentoPageController> {
  final AbastecimentoCar abastecimento;

  const AbastecimentoItemWidget({super.key, required this.abastecimento});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
    final dayOfMonth = controller.formatDay(date);
    final weekday = controller.formatWeekday(date);

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () async {
          final created =
              await showAbastecimentoCadastroDialog(context, abastecimento);
          if (created == true) {
            controller.carregarAbastecimentos();
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      color: ShadcnStyle.mutedTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayOfMonth,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: ShadcnStyle.borderColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          icon: Icons.local_gas_station,
                          value:
                              '${abastecimento.litros.toStringAsFixed(1)}${AbastecimentoStrings.litersUnit}',
                          label: AbastecimentoStrings.litersLabel,
                        ),
                        _buildInfoItem(
                          icon: Icons.attach_money,
                          value:
                              'R\$ ${abastecimento.precoPorLitro.toStringAsFixed(2)}',
                          label: AbastecimentoStrings.valuePerLiterLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem(
                          icon: Icons.speed,
                          value:
                              '${abastecimento.odometro.toStringAsFixed(0)} km',
                          label: AbastecimentoStrings.odometerLabel,
                        ),
                        _buildInfoItem(
                          icon: Icons.receipt_long,
                          value:
                              'R\$ ${abastecimento.valorTotal.toStringAsFixed(2)}',
                          label: AbastecimentoStrings.totalLabel,
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    bool isHighlighted = false,
  }) {
    return SizedBox(
      width: 110,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? ShadcnStyle.textColor.withValues(alpha: 0.1)
                  : ShadcnStyle.borderColor.withValues(alpha: 0.3),
              borderRadius: ShadcnStyle.borderRadius,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isHighlighted
                  ? ShadcnStyle.textColor
                  : ShadcnStyle.mutedTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isHighlighted
                        ? ShadcnStyle.textColor
                        : ShadcnStyle.mutedTextColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ShadcnStyle.mutedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
