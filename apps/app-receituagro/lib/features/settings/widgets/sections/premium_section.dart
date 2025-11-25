import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscription/presentation/pages/subscription_page.dart';
import '../../../subscription/presentation/providers/subscription_notifier.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_notifier.dart';

/// Premium subscription management section
/// Shows different content based on premium status
class PremiumSection extends ConsumerWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return settingsState.when(
      data: (state) {
        if (state.isPremiumUser) {
          return _buildActivePremiumCard(context);
        } else {
          return _buildPremiumSubscriptionCard(context);
        }
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Erro: $error'),
      ),
    );
  }

  Widget _buildActivePremiumCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: SettingsDesignTokens.sectionMargin,
      elevation: 8,
      shadowColor: Colors.green.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.green.shade100,
              Colors.teal.shade50,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600,
                          Colors.teal.shade700,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Premium Ativo',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade600,
                                    Colors.green.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'ATIVO',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Consumer(
                          builder: (context, ref, child) {
                            final subscriptionAsync = ref.watch(subscriptionManagementProvider);

                            return subscriptionAsync.when(
                              data: (subscriptionState) {
                                final subscription = subscriptionState.currentSubscription;

                                if (subscription?.expirationDate != null) {
                                  final daysRemaining = subscription!.daysRemaining ?? 0;
                                  final expirationDate = subscription.expirationDate!;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_available,
                                            size: 14,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDaysRemaining(daysRemaining),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.update,
                                            size: 14,
                                            color: Colors.green.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Renovação: ${_formatDate(expirationDate)}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }

                                return Text(
                                  'Todos os recursos premium desbloqueados',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                              loading: () => Text(
                                'Carregando informações...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                              ),
                              error: (_, __) => Text(
                                'Todos os recursos premium desbloqueados',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefícios Ativos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(
                      context,
                      Icons.auto_awesome,
                      'Diagnósticos avançados ilimitados',
                      Colors.green.shade600,
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(
                      context,
                      Icons.cloud_sync,
                      'Sincronização em nuvem',
                      Colors.green.shade600,
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(
                      context,
                      Icons.support_agent,
                      'Suporte prioritário 24/7',
                      Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.settings, size: 20),
                  label: Text(
                    'Gerenciar Assinatura',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.green.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSubscriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: SettingsDesignTokens.sectionMargin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B4332),  // Deep forest green
                  Color(0xFF2D5016),  // Rich agricultural green
                ],
              ),
              borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
              border: Border.all(
                color: const Color(0xFF40916C).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),  // App brand green
                        Color(0xFF388E3C),  // Medium green
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF66BB6A),  // Medium green
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ReceituAgro Premium',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF66BB6A),  // Medium green
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Desbloqueie recursos avançados',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF66BB6A),  // Medium green
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build benefit item widget
  Widget _buildBenefitItem(BuildContext context, IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              icon,
              size: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Formatar dias restantes
  String _formatDaysRemaining(int days) {
    if (days < 0) {
      return 'Expirado';
    } else if (days == 0) {
      return 'Expira hoje';
    } else if (days == 1) {
      return '1 dia restante';
    } else if (days < 30) {
      return '$days dias restantes';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} restantes';
    } else {
      final years = (days / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} restantes';
    }
  }

  /// Formatar data
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
