import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/premium_notifier.dart';

class PremiumStatusCard extends core.ConsumerWidget {
  const PremiumStatusCard({super.key});

  @override
  Widget build(BuildContext context, core.WidgetRef ref) {
    final premiumAsync = ref.watch(premiumProvider);

    return premiumAsync.when(
      data: (state) {
        final isPremium = state.isPremium;
        final status = state.subscriptionStatus;
        final expirationDate = state.expirationDate;
        final source = state.premiumSource;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isPremium ? AppColors.premiumGradient : null,
            color: isPremium ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isPremium ? null : Border.all(
              color: AppColors.grey300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPremium ? Icons.star : Icons.star_border,
                    color: isPremium ? Colors.white : AppColors.grey500,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'GasOMeter Premium' : 'GasOMeter Gratuito',
                          style: isPremium 
                            ? AppTextStyles.premiumTitle.copyWith(color: Colors.white)
                            : AppTextStyles.titleLarge,
                        ),
                        Text(
                          status,
                          style: isPremium 
                            ? AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8))
                            : AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ATIVO',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              
              if (isPremium && expirationDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatExpirationText(expirationDate),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (source.isNotEmpty && source != 'subscription') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPremium 
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatSourceText(source),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isPremium 
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.info,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error', style: const TextStyle(color: AppColors.error)),
      ),
    );
  }

  String _formatExpirationText(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now);

    if (difference.isNegative) {
      return 'Expirado';
    }

    if (difference.inDays > 0) {
      return 'Expira em ${difference.inDays} dia${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'Expira em ${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else {
      return 'Expira em breve';
    }
  }

  String _formatSourceText(String source) {
    switch (source) {
      case 'local_license':
        return 'LICENÇA DE DESENVOLVIMENTO';
      case 'trial':
        return 'PERÍODO DE TESTE';
      default:
        return source.toUpperCase();
    }
  }
}
