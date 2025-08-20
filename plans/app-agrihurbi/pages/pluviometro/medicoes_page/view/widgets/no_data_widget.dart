// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../theme/medicoes_theme.dart';
import '../../utils/string_extensions.dart';

class NoDataWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isMonthView;

  const NoDataWidget({
    super.key,
    required this.onTap,
    this.isMonthView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMonthView) {
      return Container(
        padding: MedicoesTheme.getAdaptivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: MedicoesTheme.isMobile(context)
                  ? MedicoesTheme.iconXL + 8
                  : MedicoesTheme.iconXL + 16,
              color: MedicoesTheme.mutedTextColor,
            ),
            const SizedBox(height: MedicoesTheme.space4),
            Text(
              'Nenhuma medição registrada',
              style: MedicoesTheme.isMobile(context)
                  ? MedicoesTheme.headingSmall.copyWith(
                      color: MedicoesTheme.mutedTextColor,
                    )
                  : MedicoesTheme.headingMedium.copyWith(
                      color: MedicoesTheme.mutedTextColor,
                    ),
            ),
            const SizedBox(height: MedicoesTheme.space2),
            Text(
              'Toque no botão + para adicionar uma nova medição',
              style: MedicoesTheme.bodyMedium.copyWith(
                color: MedicoesTheme.mutedTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MedicoesTheme.space2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(MedicoesTheme.space2),
            decoration: MedicoesTheme.cardDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MedicoesTheme.space4,
                    vertical: MedicoesTheme.space2,
                  ),
                  decoration: BoxDecoration(
                    color: MedicoesTheme.primaryColor,
                    borderRadius: MedicoesTheme.radiusFull,
                  ),
                  child: Text(
                    DateFormat('MMM yy', 'pt_BR').format(now).capitalize(),
                    style: MedicoesTheme.labelMedium.copyWith(
                      color: MedicoesTheme.backgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: MedicoesTheme.space2),
          // Responsive container that adapts to screen size
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MedicoesTheme.maxContentWidth,
                minHeight: 200, // Altura mínima fixa mais conservadora
                maxHeight: 400, // Altura máxima fixa mais conservadora
              ),
              child: Center(
                child: Container(
                  padding: MedicoesTheme.getAdaptivePadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: MedicoesTheme.isMobile(context)
                            ? MedicoesTheme.iconXL + 16
                            : MedicoesTheme.iconXL + 24,
                        color:
                            MedicoesTheme.mutedTextColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: MedicoesTheme.space4),
                      Text(
                        'Nenhuma medição registrada',
                        style: MedicoesTheme.isMobile(context)
                            ? MedicoesTheme.headingSmall.copyWith(
                                color: MedicoesTheme.mutedTextColor,
                              )
                            : MedicoesTheme.headingMedium.copyWith(
                                color: MedicoesTheme.mutedTextColor,
                              ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
