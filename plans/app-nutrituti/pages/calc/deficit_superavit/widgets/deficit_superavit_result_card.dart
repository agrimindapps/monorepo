// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class DeficitSuperavitResultCard extends StatelessWidget {
  final bool perderPeso;
  final double deficitSuperavitDiario;
  final double deficitSuperavitSemanal;
  final double metaCaloricaDiaria;
  final VoidCallback onCompartilhar;

  const DeficitSuperavitResultCard({
    super.key,
    required this.perderPeso,
    required this.deficitSuperavitDiario,
    required this.deficitSuperavitSemanal,
    required this.metaCaloricaDiaria,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final tipoCalculo = perderPeso ? 'Déficit' : 'Superávit';

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share_rounded,
                      color: isDark ? Colors.blue.shade300 : Colors.blue),
                  onPressed: onCompartilhar,
                  tooltip: 'Compartilhar resultado',
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 24),
          _buildResultItem(
            isDark: isDark,
            label: '$tipoCalculo Diário Necessário:',
            value: '${deficitSuperavitDiario.toStringAsFixed(0)} kcal/dia',
            color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
            fontSize: 20,
          ),
          _buildResultItem(
            isDark: isDark,
            label: '$tipoCalculo Semanal:',
            value: '${deficitSuperavitSemanal.toStringAsFixed(0)} kcal/semana',
            color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
            fontSize: 20,
          ),
          _buildResultItem(
            isDark: isDark,
            label: 'Meta Calórica Diária:',
            value: '${metaCaloricaDiaria.toStringAsFixed(0)} kcal/dia',
            color: isDark ? Colors.green.shade300 : Colors.green.shade700,
            fontSize: 24,
          ),
          if (perderPeso && metaCaloricaDiaria <= 1200)
            _buildWarningSection(isDark),
          _buildGuidanceSection(isDark),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
    required double fontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: ShadcnStyle.textColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'A meta calórica foi ajustada para o mínimo seguro de 1200 kcal/dia. Isso pode aumentar o tempo necessário para atingir sua meta de peso.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como atingir sua meta:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            perderPeso
                ? '1. Reduza o consumo de alimentos calóricos como doces, frituras e bebidas açucaradas.\n'
                    '2. Aumente o consumo de vegetais, que são ricos em nutrientes e baixos em calorias.\n'
                    '3. Beba bastante água, especialmente antes das refeições.\n'
                    '4. Pratique exercícios físicos regularmente para aumentar o gasto calórico.\n'
                    '5. Mantenha um registro do que come para ajudar a controlar a ingestão calórica.'
                : '1. Aumente o consumo de alimentos nutritivos e calóricos como abacate, nozes e azeite.\n'
                    '2. Consuma proteínas de alta qualidade para auxiliar no ganho de massa muscular.\n'
                    '3. Realize refeições mais frequentes ao longo do dia.\n'
                    '4. Pratique exercícios de resistência para estimular o ganho muscular.\n'
                    '5. Considere shakes proteicos para atingir suas metas calóricas e proteicas.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: ShadcnStyle.textColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
