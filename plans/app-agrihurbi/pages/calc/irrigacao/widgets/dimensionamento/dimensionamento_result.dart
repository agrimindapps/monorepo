// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../controllers/dimensionamento_controller.dart';
import '../shared/result_card.dart';

class DimensionamentoResultWidget extends StatelessWidget {
  final DimensionamentoController controller;
  final Animation<double> animation;
  final VoidCallback onShare;

  DimensionamentoResultWidget({
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
                    'Vazão: ${_numberFormat.format(controller.model.vazaoRequerida)} m³/h/ha',
                icon: FontAwesome.water_solid,
              ),
              InfoChip(
                label:
                    'Área: ${_numberFormat.format(controller.model.areaIrrigada)} ha',
                icon: FontAwesome.ruler_combined_solid,
              ),
              InfoChip(
                label:
                    'Espaçamento: ${_numberFormat.format(controller.model.espacamentoAspersores)} m',
                icon: FontAwesome.ruler_horizontal_solid,
              ),
              InfoChip(
                label:
                    'Pressão: ${_numberFormat.format(controller.model.pressaoOperacao)} mca',
                icon: FontAwesome.gauge_high_solid,
              ),
              InfoChip(
                label:
                    'Tempo: ${_numberFormat.format(controller.model.tempoDisponivel)} h',
                icon: FontAwesome.clock_solid,
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
          'Resultados do dimensionamento:',
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
                title: 'Vazão Total do Sistema',
                value:
                    '${_numberFormat.format(controller.model.vazaoTotal)} m³/h',
                icon: FontAwesome.water_solid,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultBox(
                title: 'Número de Aspersores',
                value: controller.model.numeroAspersoresFormatado,
                icon: FontAwesome.shower_solid,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ResultBox(
                title: 'Vazão por Aspersor',
                value:
                    '${_numberFormat.format(controller.model.vazaoPorAspersor)} m³/h',
                icon: FontAwesome.droplet_solid,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultBox(
                title: 'Tempo de Irrigação',
                value:
                    '${_numberFormat.format(controller.model.tempoIrrigacaoNecessario)} h',
                icon: FontAwesome.clock_solid,
                color: Colors.orange.shade700,
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

    final tempoDisponivel = controller.model.tempoDisponivel;
    final tempoNecessario = controller.model.tempoIrrigacaoNecessario;

    if (tempoNecessario > tempoDisponivel * 1.2) {
      mensagem =
          'O tempo necessário para irrigação excede significativamente o tempo disponível. Considere ajustar o espaçamento entre aspersores ou utilizar aspersores com maior vazão.';
      icon = FontAwesome.triangle_exclamation_solid;
      color = Colors.orange.shade700;
    } else if (tempoNecessario > tempoDisponivel) {
      mensagem =
          'O tempo necessário para irrigação está ligeiramente acima do tempo disponível. Recomenda-se uma pequena otimização do sistema.';
      icon = FontAwesome.info_solid;
      color = Colors.blue.shade700;
    } else {
      mensagem =
          'O dimensionamento está adequado, com tempo de irrigação dentro do limite disponível. Mantenha a manutenção regular do sistema.';
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
      title: 'Resultados do Dimensionamento',
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
