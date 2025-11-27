import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'premium_feature_card.dart';
import 'premium_feature_model.dart';
import 'premium_strings.dart';

/// Tab bar for switching between feature categories.
class PremiumFeatureTabs extends StatelessWidget {
  const PremiumFeatureTabs({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              GasometerDesignTokens.colorPrimary,
              GasometerDesignTokens.colorPremiumAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: PremiumStrings.tabEssenciais),
          Tab(text: PremiumStrings.tabAvancados),
          Tab(text: PremiumStrings.tabExclusivos),
        ],
      ),
    );
  }
}

/// TabBarView content showing features by category.
class PremiumFeatureTabView extends StatelessWidget {
  const PremiumFeatureTabView({
    super.key,
    required this.tabController,
    required this.isPremium,
  });

  final TabController tabController;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: TabBarView(
        controller: tabController,
        children: [
          _FeatureListView(features: _getEssentialFeatures(isPremium)),
          _FeatureListView(features: _getAdvancedFeatures(isPremium)),
          _FeatureListView(features: _getExclusiveFeatures(isPremium)),
        ],
      ),
    );
  }

  List<PremiumFeature> _getEssentialFeatures(bool isPremium) {
    return [
      PremiumFeature(
        icon: Icons.directions_car,
        title: 'Veículos Ilimitados',
        description: 'Adicione quantos veículos quiser ao seu perfil',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.analytics,
        title: 'Relatórios Avançados',
        description: 'Análises detalhadas de consumo e gastos',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.cloud_sync,
        title: 'Sincronização em Nuvem',
        description: 'Seus dados sempre seguros e sincronizados',
        isEnabled: isPremium,
      ),
    ];
  }

  List<PremiumFeature> _getAdvancedFeatures(bool isPremium) {
    return [
      PremiumFeature(
        icon: Icons.insights,
        title: 'Análises Inteligentes',
        description: 'IA para otimizar seus gastos com combustível',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.notifications_active,
        title: 'Alertas Personalizados',
        description: 'Notificações sobre manutenções e abastecimentos',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.file_download,
        title: 'Exportação de Dados',
        description: 'Exporte relatórios em CSV, PDF e Excel',
        isEnabled: isPremium,
      ),
    ];
  }

  List<PremiumFeature> _getExclusiveFeatures(bool isPremium) {
    return [
      PremiumFeature(
        icon: Icons.support_agent,
        title: 'Suporte Prioritário',
        description: 'Atendimento exclusivo e prioritário 24/7',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.auto_awesome,
        title: 'Recursos Beta',
        description: 'Acesso antecipado a novas funcionalidades',
        isEnabled: isPremium,
      ),
      PremiumFeature(
        icon: Icons.security,
        title: 'Backup Automático',
        description: 'Backup automático de todos os seus dados',
        isEnabled: isPremium,
      ),
    ];
  }
}

class _FeatureListView extends StatelessWidget {
  const _FeatureListView({required this.features});

  final List<PremiumFeature> features;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: features.map((f) => PremiumFeatureCard(feature: f)).toList(),
      ),
    );
  }
}
