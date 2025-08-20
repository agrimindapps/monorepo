// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../controllers/meditacao_controller.dart';

class MeditacaoStatsWidget extends StatelessWidget {
  final MeditacaoController controller;

  const MeditacaoStatsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: const EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          children: [
            const _StatsTitle(),
            const SizedBox(height: MeditacaoConstants.paddingPadrao),
            _StatsRow(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _StatsTitle extends StatelessWidget {
  const _StatsTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Seu Progresso',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final MeditacaoController controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.stats.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatisticItem(
            label: 'Total de Minutos',
            value: stats.totalMinutos.toString(),
          ),
          _StatisticItem(
            label: 'Sequência',
            value: '${stats.sequenciaAtual} dias',
          ),
          _StatisticItem(
            label: 'Sessões',
            value: stats.totalSessoes.toString(),
          ),
        ],
      );
    });
  }
}

class _StatisticItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatisticItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: MeditacaoConstants.paddingPequeno),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
