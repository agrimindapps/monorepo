// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../models/cultura_rotacao.dart';

class CulturaSliderWidget extends StatelessWidget {
  final CulturaRotacao cultura;
  final Function(double) onChanged;

  const CulturaSliderWidget({
    super.key,
    required this.cultura,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cultura.cor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cultura.cor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                cultura.icon,
                color: cultura.cor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cultura.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ),
              Text(
                '${cultura.percentualArea.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cultura.cor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: cultura.cor,
              inactiveTrackColor: cultura.cor.withValues(alpha: 0.2),
              thumbColor: cultura.cor,
              overlayColor: cultura.cor.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: cultura.percentualArea,
              min: 0,
              max: 100,
              divisions: 200,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
