// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class EscalaCard extends StatefulWidget {
  const EscalaCard({super.key});

  @override
  State<EscalaCard> createState() => _EscalaCardState();
}

class _EscalaCardState extends State<EscalaCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten_outlined,
                  color: isDark ? Colors.purple.shade300 : Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Escala Visual de Condição Corporal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScaleVisual(isDark),
            const SizedBox(height: 16),
            _buildLegendSection(isDark),
            const SizedBox(height: 16),
            _buildDetailedInfo(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleVisual(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Escala ECC (1-9)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(9, (index) {
              final ecc = index + 1;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hoveredIndex = _hoveredIndex == ecc ? null : ecc;
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = ecc),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _getColorForECC(ecc, isDark),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _hoveredIndex == ecc
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: _hoveredIndex == ecc
                            ? [
                                BoxShadow(
                                  color: _getColorForECC(ecc, isDark)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          ecc.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _hoveredIndex == ecc ? 16 : 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_hoveredIndex != null) ...[
            const SizedBox(height: 12),
            _buildEccDescription(_hoveredIndex!, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildEccDescription(int ecc, bool isDark) {
    String description = _getDescriptionForECC(ecc);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getColorForECC(ecc, isDark).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getColorForECC(ecc, isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: _getColorForECC(ecc, isDark),
              ),
              const SizedBox(width: 8),
              Text(
                'ECC $ecc: ${_getClassificationForECC(ecc)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getColorForECC(ecc, isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSection(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('1-3', 'Abaixo do peso', Colors.orange, isDark),
        _buildLegendItem('4-5', 'Peso ideal', Colors.green, isDark),
        _buildLegendItem('6-9', 'Acima do peso', Colors.red, isDark),
      ],
    );
  }

  Widget _buildLegendItem(
      String range, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.8) : color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                range,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? color.withValues(alpha: 0.9) : color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: ShadcnStyle.mutedTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withValues(alpha: 0.2)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 16,
                color: isDark ? Colors.blue.shade300 : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas para Avaliação:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Observe o animal de cima e de lado\n'
            '• Palpe suavemente as costelas e coluna\n'
            '• Avalie a cintura quando visto de cima\n'
            '• Considere a curvatura abdominal de lado\n'
            '• Toque na região sobre os ossos do quadril',
            style: TextStyle(
              fontSize: 12,
              color: ShadcnStyle.textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForECC(int ecc, bool isDark) {
    if (ecc <= 3) {
      return isDark ? Colors.orange.shade600 : Colors.orange.shade700;
    } else if (ecc <= 5) {
      return isDark ? Colors.green.shade600 : Colors.green.shade700;
    } else {
      return isDark ? Colors.red.shade600 : Colors.red.shade700;
    }
  }

  String _getClassificationForECC(int ecc) {
    switch (ecc) {
      case 1:
        return 'Caquético';
      case 2:
        return 'Muito magro';
      case 3:
        return 'Magro';
      case 4:
        return 'Abaixo do ideal';
      case 5:
        return 'Peso ideal';
      case 6:
        return 'Sobrepeso leve';
      case 7:
        return 'Sobrepeso';
      case 8:
        return 'Obeso';
      case 9:
        return 'Obesidade mórbida';
      default:
        return '';
    }
  }

  String _getDescriptionForECC(int ecc) {
    switch (ecc) {
      case 1:
        return 'Costelas, vértebras e ossos pélvicos evidentes à distância. Sem gordura corporal perceptível.';
      case 2:
        return 'Costelas facilmente visíveis. Cintura acentuada vista de cima. Curvatura abdominal pronunciada.';
      case 3:
        return 'Costelas facilmente palpáveis. Cintura óbvia vista de cima. Curvatura abdominal evidente.';
      case 4:
        return 'Costelas facilmente palpáveis com mínima cobertura de gordura. Cintura observada de cima.';
      case 5:
        return 'Costelas palpáveis sem excesso de gordura. Cintura observada. Abdômen retraído.';
      case 6:
        return 'Costelas palpáveis com leve excesso de gordura. Cintura visível mas não acentuada.';
      case 7:
        return 'Costelas palpáveis com dificuldade. Depósitos de gordura sobre lombar. Cintura pouco visível.';
      case 8:
        return 'Costelas não palpáveis sob cobertura espessa de gordura. Cintura ausente.';
      case 9:
        return 'Depósitos maciços de gordura. Cintura e curvatura abdominal ausentes. Distensão óbvia.';
      default:
        return '';
    }
  }
}
