// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../theme/medicoes_theme.dart';

class CarouselMonthSelector extends StatelessWidget {
  final List<DateTime> months;
  final int currentIndex;
  final Function(int) onMonthTap;

  const CarouselMonthSelector({
    super.key,
    required this.months,
    required this.currentIndex,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MedicoesTheme.space2,
        horizontal: MedicoesTheme.getAdaptiveSpacing(context),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: MedicoesTheme.maxContentWidth,
        ),
        padding: EdgeInsets.all(MedicoesTheme.getAdaptiveSpacing(context)),
        decoration: MedicoesTheme.cardDecoration,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MedicoesTheme.isMobile(context) ? 45 : 55,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: months.length,
            cacheExtent: 500, // Performance optimization
            addRepaintBoundaries: true, // Issue #20
            physics: const BouncingScrollPhysics(), // Better UX
            itemBuilder: (context, index) => _buildMonthChip(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthChip(BuildContext context, int index) {
    final isSelected = currentIndex == index;

    return RepaintBoundary(
      // Issue #20 - Isolate repaints
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MedicoesTheme.space1),
        child: InkWell(
          onTap: () => onMonthTap(index),
          borderRadius: MedicoesTheme.radiusFull,
          child: AnimatedContainer(
            duration: MedicoesTheme.animationFast,
            constraints: BoxConstraints(
              minWidth: MedicoesTheme.isMobile(context) ? 60 : 80,
            ), // Issue #21 - Responsive sizing
            padding: EdgeInsets.symmetric(
              horizontal: MedicoesTheme.isMobile(context)
                  ? MedicoesTheme.space3
                  : MedicoesTheme.space4,
              vertical: MedicoesTheme.space2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? MedicoesTheme.primaryColor
                  : MedicoesTheme.surfaceColor,
              borderRadius: MedicoesTheme.radiusFull,
              border: Border.all(
                color: isSelected
                    ? MedicoesTheme.primaryColor
                    : MedicoesTheme.borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                DateFormat('MMM yy', 'pt_BR')
                    .format(months[index])
                    .capitalize(),
                style: isSelected
                    ? MedicoesTheme.labelMedium.copyWith(
                        color: MedicoesTheme.backgroundColor,
                        fontWeight: FontWeight.w600,
                      )
                    : MedicoesTheme.labelMedium.copyWith(
                        color: MedicoesTheme.textColor,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
