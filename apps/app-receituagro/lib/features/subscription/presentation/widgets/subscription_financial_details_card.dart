import 'package:flutter/material.dart';

import '../../../../core/theme/receituagro_colors.dart';

/// Card com detalhes financeiros da assinatura
///
/// Exibe:
/// - Valor do plano (mensal/anual)
/// - Próxima cobrança (data + valor)
/// - Método de pagamento (com opção "Alterar")
///
/// Design: Card branco com ícones e dividers para organização
class SubscriptionFinancialDetailsCard extends StatelessWidget {
  const SubscriptionFinancialDetailsCard({
    required this.productId,
    required this.expirationDate,
    this.onChangePaymentMethod,
    super.key,
  });

  final String productId;
  final DateTime expirationDate;
  final VoidCallback? onChangePaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: ReceitaAgroColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Detalhes do Plano',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Valor do plano
            _buildDetailRow(
              context,
              'Valor',
              _getPlanPrice(productId),
              Icons.monetization_on,
            ),

            const Divider(height: 24),

            // Próxima cobrança
            _buildDetailRow(
              context,
              'Próxima cobrança',
              '${_formatDate(expirationDate)} - ${_getPlanPrice(productId)}',
              Icons.event_repeat,
            ),

            const Divider(height: 24),

            // Método de pagamento
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    context,
                    'Método de pagamento',
                    _getPaymentMethod(),
                    Icons.credit_card,
                  ),
                ),
                if (onChangePaymentMethod != null)
                  TextButton(
                    onPressed: onChangePaymentMethod,
                    child: const Text('Alterar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Linha de detalhe com ícone
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mapear productId para preço
  String _getPlanPrice(String productId) {
    final productLower = productId.toLowerCase();

    if (productLower.contains('mensal')) {
      return 'R\$ 19,90/mês';
    } else if (productLower.contains('semestral')) {
      return 'R\$ 99,90/semestre';
    } else if (productLower.contains('anual')) {
      return 'R\$ 179,90/ano';
    }

    return 'Consultar valor';
  }

  /// Obter método de pagamento (placeholder)
  String _getPaymentMethod() {
    // TODO: Integrar com RevenueCat para obter método real
    return 'Google Play';
  }

  /// Formatar data
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
