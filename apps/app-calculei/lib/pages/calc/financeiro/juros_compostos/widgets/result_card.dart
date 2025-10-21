// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';

class ResultCard extends StatelessWidget {
  final double montanteFinal;
  final double totalInvestido;
  final double totalJuros;
  final double rendimentoTotal;

  const ResultCard({
    super.key,
    required this.montanteFinal,
    required this.totalInvestido,
    required this.totalJuros,
    required this.rendimentoTotal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final percentFormat = NumberFormat.decimalPercentPattern(
      locale: 'pt_BR',
      decimalDigits: 2,
    );

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resultado do Investimento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: () {
                      // TODO: Implementar compartilhamento
                    },
                    tooltip: 'Compartilhar resultados',
                  ),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              _buildResultItem(
                context,
                'Montante Final',
                currencyFormat.format(montanteFinal),
                Icons.account_balance_wallet_outlined,
                isDark ? Colors.green.shade300 : Colors.green,
                isDark,
              ),
              _buildResultItem(
                context,
                'Total Investido',
                currencyFormat.format(totalInvestido),
                Icons.savings_outlined,
                isDark ? Colors.blue.shade300 : Colors.blue,
                isDark,
              ),
              _buildResultItem(
                context,
                'Total em Juros',
                currencyFormat.format(totalJuros),
                Icons.trending_up,
                isDark ? Colors.orange.shade300 : Colors.orange,
                isDark,
              ),
              _buildResultItem(
                context,
                'Rendimento Total',
                percentFormat.format(rendimentoTotal / 100),
                Icons.percent_outlined,
                isDark ? Colors.purple.shade300 : Colors.purple,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(bool isDark) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color:
          isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.shade700.withValues(alpha: 0.3)
              : Colors.blue.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'O investimento em renda fixa pode ser uma boa opção para seu perfil. Considere diversificar sua carteira e consultar um especialista para orientações específicas.',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
