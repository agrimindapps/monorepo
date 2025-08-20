// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../models/tempo_irrigacao_model.dart';
import '../shared/result_card.dart';

class TempoIrrigacaoResult extends StatelessWidget {
  final TempoIrrigacaoModel model;
  final bool isVisible;
  final VoidCallback onShare;

  const TempoIrrigacaoResult({
    super.key,
    required this.model,
    required this.isVisible,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return ResultCard(
      title: 'Resultados',
      onShare: onShare,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tempo de Irrigação:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tempo de irrigação em horas e minutos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesome.clock_solid,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${model.tempoIrrigacaoFormatado} horas (${model.tempoIrrigacaoMinutosFormatado} minutos)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta é a duração necessária de irrigação para aplicar a lâmina d\'água requerida com a eficiência especificada.',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detalhes dos cálculos
          const Text(
            'Detalhes:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                'Área por emissor: ${model.areaPorEmissorFormatada} m²',
                FontAwesome.ruler_combined_solid,
              ),
              _buildInfoChip(
                'Volume por emissor: ${model.volumePorEmissorFormatado} L',
                FontAwesome.droplet_solid,
              ),
              _buildInfoChip(
                'Volume/ha: ${model.volumeTotalPorHectareFormatado} m³',
                FontAwesome.chart_simple_solid,
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildTipCard(context),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    String tipText;
    IconData tipIcon;
    Color tipColor;

    // Tempo em minutos para avaliar recomendações
    double tempoMin = model.tempoIrrigacaoMinutos;

    if (tempoMin > 180) {
      tipText =
          'O tempo de irrigação é longo. Considere dividir em mais de um turno para melhor eficiência.';
      tipIcon = FontAwesome.triangle_exclamation_solid;
      tipColor = Colors.orange;
    } else if (tempoMin < 10) {
      tipText =
          'O tempo de irrigação é muito curto. Verifique os parâmetros informados.';
      tipIcon = FontAwesome.circle_exclamation_solid;
      tipColor = Colors.red;
    } else if (model.eficienciaIrrigacao < 70) {
      tipText =
          'A eficiência do sistema está baixa. Considere melhorias no sistema ou manutenção.';
      tipIcon = FontAwesome.triangle_exclamation_solid;
      tipColor = Colors.orange;
    } else {
      tipText =
          'Irrigue preferencialmente nas primeiras horas da manhã ou final da tarde para reduzir perdas por evaporação.';
      tipIcon = FontAwesome.lightbulb_solid;
      tipColor = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(tipIcon, size: 18, color: tipColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tipText,
              style: TextStyle(color: tipColor),
            ),
          ),
        ],
      ),
    );
  }
}
