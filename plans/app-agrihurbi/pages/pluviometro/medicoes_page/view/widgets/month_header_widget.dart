// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/medicoes_models.dart';
import '../../animations/transition_animations.dart';
import '../../model/medicoes_page_model.dart';
import '../../theme/medicoes_theme.dart';

class MonthHeaderWidget extends StatelessWidget {
  final DateTime date;
  final List<Medicoes> medicoes;
  final MonthStatistics statistics;

  const MonthHeaderWidget({
    super.key,
    required this.date,
    required this.medicoes,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return TransitionAnimations.animatedEntry(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: MedicoesTheme.maxContentWidth,
        ),
        padding: MedicoesTheme.getAdaptivePadding(context),
        decoration: MedicoesTheme.statisticCardDecoration,
        child: MedicoesTheme.isMobile(context)
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  /// Layout responsivo para dispositivos móveis - Issue #21
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEstatisticaItem(
                'Total',
                '${statistics.total.toStringAsFixed(1)} mm',
                Icons.water_drop,
                MedicoesTheme.getStatisticIconColor('total'),
              ),
            ),
            const SizedBox(width: MedicoesTheme.space2),
            Expanded(
              child: _buildEstatisticaItem(
                'Média/Dia',
                '${statistics.media.toStringAsFixed(1)} mm',
                Icons.water,
                MedicoesTheme.getStatisticIconColor('média'),
              ),
            ),
          ],
        ),
        const SizedBox(height: MedicoesTheme.space3),
        _buildEstatisticaItem(
          'Máximo',
          '${statistics.maximo.toStringAsFixed(1)} mm',
          Icons.arrow_upward,
          MedicoesTheme.getStatisticIconColor('máximo'),
        ),
      ],
    );
  }

  /// Layout para dispositivos desktop/tablet
  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildEstatisticaItem(
            'Total',
            '${statistics.total.toStringAsFixed(1)} mm',
            Icons.water_drop,
            MedicoesTheme.getStatisticIconColor('total'),
          ),
        ),
        Expanded(
          child: _buildEstatisticaItem(
            'Média/Dia',
            '${statistics.media.toStringAsFixed(1)} mm',
            Icons.water,
            MedicoesTheme.getStatisticIconColor('média'),
          ),
        ),
        Expanded(
          child: _buildEstatisticaItem(
            'Máximo',
            '${statistics.maximo.toStringAsFixed(1)} mm',
            Icons.arrow_upward,
            MedicoesTheme.getStatisticIconColor('máximo'),
          ),
        ),
      ],
    );
  }

  Widget _buildEstatisticaItem(
      String label, String valor, IconData icon, Color cor) {
    return TransitionAnimations.dataChangeTransition(
      dataKey: '${label}_$valor',
      child: Column(
        children: [
          TransitionAnimations.scaleTransition(
            animation: const AlwaysStoppedAnimation(1.0),
            child: Container(
              padding: const EdgeInsets.all(MedicoesTheme.space3),
              decoration: MedicoesTheme.iconContainerDecoration.copyWith(
                color: cor.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                color: cor,
                size: MedicoesTheme.iconLarge,
              ),
            ),
          ),
          const SizedBox(height: MedicoesTheme.space2),
          Text(
            valor,
            style: MedicoesTheme.statisticValue,
          ),
          Text(
            label,
            style: MedicoesTheme.statisticLabel,
          ),
        ],
      ),
    );
  }
}
