// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../models/medicoes_models.dart';
import '../../animations/transition_animations.dart';
import '../../controller/medicoes_page_controller.dart';
import '../../theme/medicoes_theme.dart';

class DailyListWidget extends StatelessWidget {
  final DateTime month;
  final List<Medicoes> medicoes;
  final Function(Medicoes?) onMedicaoTap;
  final MedicoesPageController controller;

  const DailyListWidget({
    super.key,
    required this.month,
    required this.medicoes,
    required this.onMedicaoTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: daysInMonth,
      cacheExtent: 1000.0, // Improve performance by caching more items
      addRepaintBoundaries: true, // Isolate rebuilds
      itemBuilder: (context, index) => _DailyItemWidget(
        key: ValueKey('${month.year}_${month.month}_$index'), // Stable keys
        month: month,
        index: index,
        medicoes: medicoes,
        onMedicaoTap: onMedicaoTap,
        controller: controller,
      ),
    );
  }
}

/// Optimized daily item widget to avoid rebuilds - Issue #20
class _DailyItemWidget extends StatelessWidget {
  final DateTime month;
  final int index;
  final List<Medicoes> medicoes;
  final Function(Medicoes?) onMedicaoTap;
  final MedicoesPageController controller;

  const _DailyItemWidget({
    super.key,
    required this.month,
    required this.index,
    required this.medicoes,
    required this.onMedicaoTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime(month.year, month.month, index + 1);
    final medicao = controller.findMeasurementForDate(medicoes, currentDate);
    final bool hasMedicao = medicao.quantidade > 0;
    final weekDay = controller.formatWeekDay(currentDate);
    final rainIntensityColor =
        MedicoesTheme.getRainIntensityColor(medicao.quantidade.toDouble());

    return RepaintBoundary(
      // Isolate this widget's repaints
      child: TransitionAnimations.listItemAnimation(
        index: index,
        child: TransitionAnimations.cardMicroInteraction(
          onTap: () => onMedicaoTap(medicao),
          isSelected: hasMedicao,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: MedicoesTheme.space1),
            child: Container(
              decoration: MedicoesTheme.dailyItemDecoration,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: MedicoesTheme.space3,
                  vertical: MedicoesTheme.space1,
                ),
                leading: _DayCircle(
                  day: index + 1,
                  color: rainIntensityColor,
                ),
                title: Text(
                  weekDay,
                  style: hasMedicao
                      ? MedicoesTheme.bodyMedium
                      : MedicoesTheme.bodyMedium.copyWith(
                          color: MedicoesTheme.mutedTextColor,
                        ),
                ),
                trailing: _MeasurementChip(
                  value: medicao.quantidade,
                  color: rainIntensityColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized day circle widget with const constructor
class _DayCircle extends StatelessWidget {
  final int day;
  final Color color;

  const _DayCircle({
    required this.day,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: MedicoesTheme.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Optimized measurement chip widget with const constructor
class _MeasurementChip extends StatelessWidget {
  final double value;
  final Color color;

  const _MeasurementChip({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MedicoesTheme.space2,
        vertical: MedicoesTheme.space1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: MedicoesTheme.radiusSmall,
      ),
      child: Text(
        '${value.toStringAsFixed(1)} mm',
        style: MedicoesTheme.measurementValue.copyWith(
          color: color,
        ),
      ),
    );
  }
}
