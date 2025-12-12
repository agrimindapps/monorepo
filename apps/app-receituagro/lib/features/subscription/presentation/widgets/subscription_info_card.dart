import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Card de informações da assinatura para a tela de configurações
///
/// Exibe:
/// - Nome do plano
/// - Status (Ativo)
/// - Data de início e fim
/// - Tempo restante
/// - Barra de progresso visual
class SubscriptionInfoCard extends StatelessWidget {
  final SubscriptionEntity subscription;
  final bool showDetailsButton;
  final VoidCallback? onDetailsPressed;

  const SubscriptionInfoCard({
    super.key,
    required this.subscription,
    this.showDetailsButton = false,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final expirationDate = subscription.expirationDate;
    final purchaseDate = subscription.purchaseDate;
    final isLifetime = expirationDate == null;

    // Cálculos de tempo
    final now = DateTime.now();
    final totalDuration = isLifetime
        ? 0
        : expirationDate.difference(purchaseDate ?? now).inDays;
    final daysRemaining =
        isLifetime ? 0 : expirationDate.difference(now).inDays;

    // Evita divisão por zero e garante range 0.0 - 1.0
    final progress = !isLifetime && totalDuration > 0
        ? ((totalDuration - daysRemaining) / totalDuration).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20), // Dark Green
            Color(0xFF2E7D32), // Green
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Optional - Circles)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Plan Name & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEU PLANO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPlanName(subscription.productId),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF69F0AE),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ATIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Bar
                if (!isLifetime)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDaysRemaining(daysRemaining),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}% usado',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF69F0AE),
                          ), // Light Green Accent
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Dates Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateColumn('Início', purchaseDate ?? now),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildDateColumn(
                        isLifetime ? 'Validade' : 'Renova em',
                        expirationDate,
                      ),
                    ],
                  ),
                ),

                // Details Button (opcional)
                if (showDetailsButton) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onDetailsPressed,
                      icon: const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Ver detalhes da assinatura',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? _formatDate(date) : 'Vitalício',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPlanName(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('anual')) return 'Plano Anual';
    if (lower.contains('semestral')) return 'Plano Semestral';
    if (lower.contains('mensal')) return 'Plano Mensal';
    return 'Premium';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDaysRemaining(int days) {
    if (days <= 0) return 'Expira hoje';
    if (days == 1) return '1 dia restante';
    return '$days dias restantes';
  }
}
