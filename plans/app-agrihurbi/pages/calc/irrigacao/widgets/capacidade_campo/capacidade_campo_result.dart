// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../controllers/capacidade_campo_controller.dart';
import '../shared/result_card.dart';

class CapacidadeCampoResultWidget extends StatelessWidget {
  final CapacidadeCampoController controller;
  final Animation<double> animation;
  final VoidCallback onShare;

  CapacidadeCampoResultWidget({
    super.key,
    required this.controller,
    required this.animation,
    required this.onShare,
  });

  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');
  final _percentFormat = NumberFormat('#,##0.0', 'pt_BR');

  Color _getStatusColor() {
    final eficiencia = controller.model.eficienciaArmazenamento;
    if (eficiencia > 75) {
      return Colors.green.shade700;
    } else if (eficiencia > 50) {
      return Colors.green.shade500;
    } else if (eficiencia > 25) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade700;
    }
  }

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
                    'CC: ${_numberFormat.format(controller.model.capacidadeCampo)}%',
                icon: FontAwesome.droplet_solid,
              ),
              InfoChip(
                label:
                    'PMP: ${_numberFormat.format(controller.model.pontoMurcha)}%',
                icon: FontAwesome.plant_wilt_solid,
              ),
              InfoChip(
                label:
                    'Densidade: ${_numberFormat.format(controller.model.densidadeSolo)} g/cm³',
                icon: FontAwesome.weight_hanging_solid,
              ),
              InfoChip(
                label:
                    'Prof.: ${_numberFormat.format(controller.model.profundidadeRaiz)} cm',
                icon: FontAwesome.ruler_vertical_solid,
              ),
              InfoChip(
                label:
                    'Área: ${_numberFormat.format(controller.model.areaIrrigada)} ha',
                icon: FontAwesome.ruler_combined_solid,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUmidadeSection() {
    if (!controller.camposAdicionais) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ResultBox(
                title: 'Umidade Gravimétrica',
                value:
                    '${_numberFormat.format(controller.model.umidadeGravimetrica)}%',
                icon: FontAwesome.droplet_solid,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultBox(
                title: 'Umidade Volumétrica',
                value:
                    '${_numberFormat.format(controller.model.umidadeVolumetrica)}%',
                icon: FontAwesome.percent_solid,
                color: Colors.purple.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAguaDisponivelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Disponibilidade de Água:',
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
                title: 'Água Disponível Total',
                value:
                    '${_numberFormat.format(controller.model.aguaDisponivel)} mm',
                icon: FontAwesome.droplet_solid,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResultBox(
                title: 'Água Facilmente Disponível',
                value:
                    '${_numberFormat.format(controller.model.aguaFacilmenteDisponivel)} mm',
                icon: FontAwesome.droplet_slash_solid,
                color: Colors.cyan.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ResultBox(
          title: 'Volume Total de Água Disponível',
          value: '${_numberFormat.format(controller.model.volumeTotalAgua)} m³',
          icon: FontAwesome.water_solid,
          color: Colors.indigo.shade700,
        ),
      ],
    );
  }

  Widget _buildRecomendacoes() {
    final statusColor = _getStatusColor();
    String mensagem;
    IconData icon;

    if (controller.camposAdicionais) {
      final eficiencia = controller.model.eficienciaArmazenamento;
      if (eficiencia > 75) {
        mensagem =
            'O solo está com excelente nível de água disponível. Não é necessário irrigar neste momento.';
        icon = FontAwesome.thumbs_up_solid;
      } else if (eficiencia > 50) {
        mensagem =
            'O solo ainda possui boa disponibilidade de água para as plantas. Monitorar nos próximos dias.';
        icon = FontAwesome.check_solid;
      } else if (eficiencia > 25) {
        mensagem =
            'A disponibilidade de água está baixa. Considere irrigar em breve para evitar déficit hídrico.';
        icon = FontAwesome.triangle_exclamation_solid;
      } else {
        mensagem =
            'Nível crítico de água disponível! É necessária irrigação imediata para evitar estresse hídrico severo.';
        icon = FontAwesome.circle_exclamation_solid;
      }
    } else {
      mensagem =
          'Com base nos parâmetros do solo, recomenda-se monitorar a umidade regularmente e programar a irrigação quando a água disponível estiver abaixo de 50% da capacidade total.';
      icon = FontAwesome.lightbulb_solid;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: statusColor),
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
      title: 'Resultados para ${controller.tipoSolo}',
      onShare: onShare,
      animation: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          _buildUmidadeSection(),
          _buildAguaDisponivelSection(),
          const SizedBox(height: 16),
          _buildRecomendacoes(),
        ],
      ),
    );
  }
}
