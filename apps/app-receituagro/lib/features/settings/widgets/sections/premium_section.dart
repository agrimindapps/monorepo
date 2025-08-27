import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../subscription/subscription_page.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

/// Premium subscription management section
/// Shows different content based on premium status
class PremiumSection extends StatelessWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Premium',
          icon: SettingsDesignTokens.premiumIcon,
          showIcon: true,
        ),
        Consumer<SettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isPremiumUser) {
              return _buildActivePremiumCard(context);
            } else {
              return _buildPremiumSubscriptionCard(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActivePremiumCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SettingsCard(
      showBorder: true,
      borderColor: Colors.green.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone premium e status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Ativo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recursos exclusivos desbloqueados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'ATIVO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Lista de benefícios ativos
          _buildBenefitItem(
            Icons.cloud_sync,
            'Sincronização na Nuvem',
            'Dados seguros em todos os dispositivos',
            theme,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.analytics,
            'Relatórios Avançados',
            'Análises detalhadas de pragas',
            theme,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.block,
            'Sem Anúncios',
            'Experiência premium sem interrupções',
            theme,
          ),
          
          const SizedBox(height: 20),
          
          // Botão para gerenciar
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text(
                'Gerenciar Assinatura',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSubscriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SettingsCard(
      child: Column(
        children: [
          // Header com ícone premium
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade400,
                  Colors.orange.shade600,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'ReceitaAgro Premium',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Desbloqueie recursos avançados e tenha a melhor experiência',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Lista de benefícios
          _buildBenefitItem(
            Icons.cloud_sync,
            'Sincronização na Nuvem',
            'Dados seguros e acessíveis em qualquer dispositivo',
            theme,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.analytics,
            'Relatórios Avançados',
            'Análises detalhadas de pragas e defensivos',
            theme,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.notifications_active,
            'Alertas Inteligentes',
            'Notificações personalizadas e lembretes',
            theme,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.block,
            'Sem Anúncios',
            'Experiência premium sem interrupções',
            theme,
          ),

          const SizedBox(height: 24),

          // Botão de assinatura
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.star, size: 20),
              label: const Text(
                'Assinar Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon, 
            color: theme.colorScheme.primary, 
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}