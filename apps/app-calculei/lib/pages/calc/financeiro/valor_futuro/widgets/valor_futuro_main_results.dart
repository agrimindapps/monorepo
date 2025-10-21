// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/widgets/models/valor_futuro_model.dart';

class ValorFuturoMainResults extends StatelessWidget {
  final ValorFuturoModel modelo;

  const ValorFuturoMainResults({
    super.key,
    required this.modelo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    final IconData mainIcon;
    final Color mainColor;
    final String mainLabel;
    final String mainValue;

    // Determina a cor com base no lucro
    if (modelo.lucro > modelo.valorInicial) {
      mainIcon = Icons.trending_up;
      mainColor = Colors.green;
    } else if (modelo.lucro > modelo.valorInicial * 0.5) {
      mainIcon = Icons.trending_up;
      mainColor = Colors.blue;
    } else if (modelo.lucro > 0) {
      mainIcon = Icons.show_chart;
      mainColor = Colors.amber;
    } else {
      mainIcon = Icons.trending_down;
      mainColor = Colors.orange;
    }

    mainLabel = 'Valor Futuro';
    mainValue = numberFormat.format(modelo.valorFuturo);

    final iconColor = isDark ? _getLighterColor(mainColor) : mainColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: mainColor.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: mainColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(mainIcon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mainLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: ShadcnStyle.mutedTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mainValue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lucro: ${numberFormat.format(modelo.lucro)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLighterColor(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor
        .withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0))
        .toColor();
  }
}
