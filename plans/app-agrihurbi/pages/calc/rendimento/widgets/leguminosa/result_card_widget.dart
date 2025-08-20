// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controllers/leguminosa_controller.dart';
import '../../models/leguminosa_model.dart';

class ResultCardWidget extends StatelessWidget {
  const ResultCardWidget({super.key});

  void _compartilhar(LeguminosaModel model) {
    final numberFormat = NumberFormat('#,###.00#', 'pt_BR');
    final shareText = '''
    Rendimento de Leguminosas

    Valores
    Vagens por Planta: ${numberFormat.format(model.vagensPorPlanta)}
    Sementes por Vagem: ${numberFormat.format(model.sementesPorVagem)}
    Peso de Mil Grãos: ${numberFormat.format(model.pesoMilGraos)} g
    Plantas por m²: ${numberFormat.format(model.plantasM2)}
    
    Resultado
    Rendimento: ${numberFormat.format(model.rendimento)} kg/ha
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  Widget _buildDetalheRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeguminosaController>(
      builder: (controller) {
        if (!controller.calculado) return const SizedBox.shrink();

        final isDark = ThemeManager().isDark.value;
        final model = controller.model;
        final numberFormat = NumberFormat('#,###.00#', 'pt_BR');

        Color getCorClassificacao() {
          switch (model.classificacao) {
            case 'Baixa produtividade':
              return isDark ? Colors.red.shade300 : Colors.red;
            case 'Produtividade média':
              return isDark ? Colors.amber.shade300 : Colors.amber;
            case 'Boa produtividade':
              return isDark ? Colors.green.shade300 : Colors.green.shade600;
            default:
              return isDark ? Colors.green.shade300 : Colors.green;
          }
        }

        IconData getIconeClassificacao() {
          switch (model.classificacao) {
            case 'Baixa produtividade':
              return Icons.trending_down;
            case 'Produtividade média':
              return Icons.trending_flat;
            case 'Boa produtividade':
              return Icons.trending_up;
            default:
              return Icons.stars;
          }
        }

        return AnimatedOpacity(
          opacity: controller.calculado ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
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
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _compartilhar(model),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Compartilhar'),
                        style: ShadcnStyle.primaryButtonStyle,
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: getCorClassificacao()
                        .withValues(alpha: isDark ? 0.15 : 0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: getCorClassificacao().withValues(alpha: 0.3),
                          width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(getIconeClassificacao(),
                                  color: getCorClassificacao(), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rendimento Estimado',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ShadcnStyle.textColor,
                                      ),
                                    ),
                                    Text(
                                      '${numberFormat.format(model.rendimento)} kg/ha',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ShadcnStyle.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${numberFormat.format(model.rendimento / 60)} sacas/ha',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ShadcnStyle.mutedTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            model.classificacao,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getCorClassificacao(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'O rendimento varia conforme a espécie, manejo, condições do solo e clima. Os valores são estimativas baseadas nos componentes de rendimento informados.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: ShadcnStyle.mutedTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black12 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalhes do Cálculo:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: ShadcnStyle.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetalheRow('Sementes por m²',
                                    '${numberFormat.format(model.sementesPorM2)} sementes'),
                                _buildDetalheRow('Peso por m²',
                                    '${numberFormat.format(model.pesoPorM2)} g'),
                                const SizedBox(height: 8),
                                Text(
                                  'Fórmula: Rendimento = (Sementes/m² × Peso Mil Grãos) ÷ 1000 × 10000',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ShadcnStyle.mutedTextColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
