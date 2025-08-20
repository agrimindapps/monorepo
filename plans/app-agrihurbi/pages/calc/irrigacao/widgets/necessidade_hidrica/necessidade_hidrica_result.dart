// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../controllers/necessidade_hidrica_controller.dart';
import '../shared/result_card.dart';

class NecessidadeHidricaResultWidget extends StatelessWidget {
  final NecessidadeHidricaController controller;
  final Animation<double> animation;
  final VoidCallback onShare;

  NecessidadeHidricaResultWidget({
    super.key,
    required this.controller,
    required this.animation,
    required this.onShare,
  });

  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo dos dados informados:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                label:
                    'ETo: ${_numberFormat.format(controller.model.evapotranspiracao)} mm/dia',
                icon: FontAwesome.droplet_solid,
              ),
              InfoChip(
                label:
                    'Kc: ${_numberFormat.format(controller.model.coeficienteCultura)}',
                icon: FontAwesome.plant_wilt_solid,
              ),
              InfoChip(
                label:
                    'Área: ${_numberFormat.format(controller.model.areaPlantada)} ha',
                icon: FontAwesome.ruler_combined_solid,
              ),
              InfoChip(
                label:
                    'Eficiência: ${_numberFormat.format(controller.model.eficienciaIrrigacao)}%',
                icon: FontAwesome.gauge_high_solid,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Resultados do cálculo:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ResultBox(
                title: 'Necessidade Bruta',
                value:
                    '${_numberFormat.format(controller.model.necessidadeBruta)} mm/dia',
                icon: FontAwesome.droplet_solid,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultBox(
                title: 'Volume Total Diário',
                value:
                    '${_numberFormat.format(controller.model.volumeTotalDiario)} m³/dia',
                icon: FontAwesome.water_solid,
                color: Colors.teal.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecomendacoes() {
    String mensagem;
    IconData icon;
    Color color;

    final necessidade = controller.model.necessidadeBruta;
    if (necessidade > 10) {
      mensagem =
          'A necessidade hídrica é alta. Considere estratégias de conservação de água e verifique a eficiência do sistema de irrigação.';
      icon = FontAwesome.triangle_exclamation_solid;
      color = Colors.orange.shade700;
    } else if (necessidade > 5) {
      mensagem =
          'A necessidade hídrica está em nível moderado. Monitore as condições climáticas e ajuste a irrigação conforme necessário.';
      icon = FontAwesome.info_solid;
      color = Colors.blue.shade700;
    } else {
      mensagem =
          'A necessidade hídrica está em nível adequado. Continue monitorando as condições da cultura e do clima.';
      icon = FontAwesome.check_solid;
      color = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              const Text(
                'Recomendações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(mensagem),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: controller.selectedCultura != null
          ? 'Resultados para ${controller.selectedCultura}'
          : 'Resultados',
      onShare: onShare,
      animation: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          _buildResultadosSection(),
          const SizedBox(height: 16),
          _buildRecomendacoes(),
        ],
      ),
    );
  }
}
