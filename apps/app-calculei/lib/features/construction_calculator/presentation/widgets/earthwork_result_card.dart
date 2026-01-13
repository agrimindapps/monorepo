import 'package:flutter/material.dart';

import '../../../../../shared/widgets/adaptive_spec_card.dart';
import '../../../../../shared/widgets/share_button.dart';
import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/earthwork_calculation.dart';

/// Result card widget for earthwork calculation - Dark theme
class EarthworkResultCard extends StatelessWidget {
  final EarthworkCalculation calculation;

  const EarthworkResultCard({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.construction;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive colors
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final infoBgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100;
    final infoBorderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300;

    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resultado',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShareButton(
                  text: _formatShareText(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Volume highlight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Volume Total',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.totalVolume.toStringAsFixed(2)} m³',
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Volume ${_getVolumeLabel()}: ${calculation.compactedVolume.toStringAsFixed(2)} m³',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Logística',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Logistics Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AdaptiveSpecCard(
                  icon: Icons.local_shipping,
                  label: 'Caminhões',
                  value: '${calculation.truckLoads}',
                  unit: 'viagens (8m³)',
                  color: SemanticColors.specOrange(context),
                  width: 170,
                ),
                AdaptiveSpecCard(
                  icon: Icons.access_time,
                  label: 'Tempo Estimado',
                  value: calculation.estimatedHours.toStringAsFixed(1),
                  unit: 'horas',
                  color: SemanticColors.specBlue(context),
                  width: 170,
                ),
                AdaptiveSpecCard(
                  icon: Icons.terrain,
                  label: 'Tipo de Solo',
                  value: calculation.soilType,
                  unit: '',
                  color: SemanticColors.specTeal(context),
                  width: 170,
                ),
                AdaptiveSpecCard(
                  icon: Icons.construction,
                  label: 'Operação',
                  value: calculation.operationType,
                  unit: '',
                  color: SemanticColors.specPurple(context),
                  width: 170,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Technical Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: infoBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: infoBorderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: labelColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Informações Técnicas',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _TechnicalDetail(
                    label: 'Fator de ${_isExcavation() ? 'Expansão' : 'Compactação'}',
                    value: _isExcavation()
                        ? calculation.expansionFactor.toStringAsFixed(2)
                        : calculation.compactionFactor.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 6),
                  _TechnicalDetail(
                    label: 'Dimensões',
                    value: '${calculation.length.toStringAsFixed(2)}m × ${calculation.width.toStringAsFixed(2)}m × ${calculation.depth.toStringAsFixed(2)}m',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isExcavation() {
    return calculation.operationType == 'Escavação';
  }

  String _getVolumeLabel() {
    switch (calculation.operationType) {
      case 'Escavação':
        return 'Expandido';
      case 'Aterro':
        return 'Compactado';
      case 'Corte e Aterro':
        return 'Ajustado';
      default:
        return 'Ajustado';
    }
  }

  String _formatShareText() {
    return '''
📊 CÁLCULO DE TERRAPLENAGEM

🏗️ Operação: ${calculation.operationType}
🌍 Tipo de Solo: ${calculation.soilType}

📐 Dimensões:
• Comprimento: ${calculation.length.toStringAsFixed(2)} m
• Largura: ${calculation.width.toStringAsFixed(2)} m
• Profundidade: ${calculation.depth.toStringAsFixed(2)} m

📦 Volumes:
• Volume Total: ${calculation.totalVolume.toStringAsFixed(2)} m³
• Volume ${_getVolumeLabel()}: ${calculation.compactedVolume.toStringAsFixed(2)} m³

🚛 Logística:
• Caminhões: ${calculation.truckLoads} viagens (8m³)
• Tempo Estimado: ${calculation.estimatedHours.toStringAsFixed(1)} horas

⚙️ Fatores:
• ${_isExcavation() ? 'Expansão' : 'Compactação'}: ${_isExcavation() ? calculation.expansionFactor.toStringAsFixed(2) : calculation.compactionFactor.toStringAsFixed(2)}

Calculado por App Calculei
''';
  }
}

/// Technical detail row
class _TechnicalDetail extends StatelessWidget {
  final String label;
  final String value;

  const _TechnicalDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final valueColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;

    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
