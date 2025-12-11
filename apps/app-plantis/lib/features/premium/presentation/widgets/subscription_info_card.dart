import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/plantis_colors.dart';

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

  const SubscriptionInfoCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final expirationDate = subscription.expirationDate;
    final purchaseDate = subscription.purchaseDate;

    if (expirationDate == null) return const SizedBox.shrink();

    // Cálculos de tempo
    final now = DateTime.now();
    final totalDuration = expirationDate.difference(purchaseDate ?? now).inDays;
    final daysRemaining = expirationDate.difference(now).inDays;

    // Evita divisão por zero e garante range 0.0 - 1.0
    final progress = totalDuration > 0
        ? ((totalDuration - daysRemaining) / totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primaryDark, // Dark Green
            PlantisColors.primary, // Green
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withValues(alpha: 0.3),
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
                            color: PlantisColors.secondaryLight,
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
                          PlantisColors.secondaryLight,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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
                      _buildDateColumn('Renova em', expirationDate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime date) {
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
          _formatDate(date),
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
    if (lower.contains('anual') || lower.contains('year')) return 'Plano Anual';
    if (lower.contains('semestral') || lower.contains('semester'))
      return 'Plano Semestral';
    if (lower.contains('mensal') || lower.contains('month'))
      return 'Plano Mensal';
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
