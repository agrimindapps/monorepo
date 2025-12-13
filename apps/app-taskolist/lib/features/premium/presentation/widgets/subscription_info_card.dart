import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Card de informações da assinatura Premium
/// Exibe status da assinatura, tempo restante e datas importantes
class SubscriptionInfoCard extends StatelessWidget {
  final SubscriptionEntity subscription;

  const SubscriptionInfoCard({super.key, required this.subscription});

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

    // Progresso (0.0 - 1.0)
    final progress = !isLifetime && totalDuration > 0
        ? ((totalDuration - daysRemaining) / totalDuration).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorativo
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Nome do plano e status
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
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: AppColors.premium,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getPlanName(subscription.productId),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ATIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Barra de progresso (somente para assinaturas com prazo)
                if (!isLifetime)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDaysRemaining(daysRemaining),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progress * 100).toInt()}% decorrido',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black.withOpacity(0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.premium,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Informações de datas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDateColumn(
                          icon: Icons.calendar_today_rounded,
                          label: 'Início',
                          date: purchaseDate ?? now,
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildDateColumn(
                          icon: isLifetime
                              ? Icons.all_inclusive_rounded
                              : Icons.event_repeat_rounded,
                          label: isLifetime ? 'Validade' : 'Renova em',
                          date: expirationDate,
                        ),
                      ),
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

  Widget _buildDateColumn({
    required IconData icon,
    required String label,
    required DateTime? date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.6),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          date != null ? _formatDate(date) : 'Vitalício ∞',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getPlanName(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('lifetime') || lower.contains('vitalicio')) {
      return 'Vitalício';
    }
    if (lower.contains('anual') || lower.contains('year')) return 'Premium Anual';
    if (lower.contains('semestral') || lower.contains('semester')) {
      return 'Premium Semestral';
    }
    if (lower.contains('mensal') || lower.contains('month')) {
      return 'Premium Mensal';
    }
    return 'Premium';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDaysRemaining(int days) {
    if (days <= 0) return 'Expira hoje';
    if (days == 1) return '1 dia restante';
    if (days < 7) return '$days dias restantes';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return weeks == 1 ? '1 semana restante' : '$weeks semanas restantes';
    }
    final months = (days / 30).floor();
    return months == 1 ? '1 mês restante' : '$months meses restantes';
  }
}
