// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../providers/meditacao_provider.dart';

class MeditacaoStatsWidget extends ConsumerWidget {
  const MeditacaoStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Card(
      elevation: MeditacaoConstants.elevacaoPadrao,
      child: Padding(
        padding: EdgeInsets.all(MeditacaoConstants.paddingPadrao),
        child: Column(
          children: [
            _StatsTitle(),
            SizedBox(height: MeditacaoConstants.paddingPadrao),
            _StatsRow(),
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

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(
      meditacaoProvider.select((state) => state.stats),
    );

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
