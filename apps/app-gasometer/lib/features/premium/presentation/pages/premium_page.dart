import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../providers/premium_notifier.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumNotifierProvider);
    final bool isPremiumValue = premiumAsync.when(
      data: (premiumState) => premiumState.isPremium,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isPremiumValue),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatusCard(context, isPremiumValue),
                      const SizedBox(height: 24),
                      _buildFeatureTabs(context),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 450,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEssentialFeatures(context, isPremiumValue),
                            _buildAdvancedFeatures(context, isPremiumValue),
                            _buildExclusiveFeatures(context, isPremiumValue),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isPremiumValue) _buildPricingSection(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isPremium) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: GasometerDesignTokens.colorHeaderBackground,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'GasOMeter Premium',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GasometerDesignTokens.colorHeaderBackground,
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
                GasometerDesignTokens.colorPrimary,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/patterns/premium_pattern.png'),
                        repeat: ImageRepeat.repeat,
                        onError: (exception, stackTrace) {},
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 40),
                  child: Icon(
                    isPremium ? Icons.verified : Icons.workspace_premium,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isPremium) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? [
                  GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1),
                  GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
                ]
              : [
                  GasometerDesignTokens.colorPrimary.withValues(alpha: 0.1),
                  GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3)
              : GasometerDesignTokens.colorPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? GasometerDesignTokens.colorPremiumAccent : GasometerDesignTokens.colorPrimary)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPremium
                  ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2)
                  : GasometerDesignTokens.colorPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.verified : Icons.workspace_premium,
              color: isPremium ? GasometerDesignTokens.colorPremiumAccent : GasometerDesignTokens.colorPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Ativo' : 'Desbloqueie o Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium
                      ? 'Todos os recursos premium desbloqueados'
                      : 'Acesse recursos avançados e análises detalhadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GasometerDesignTokens.colorPremiumAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ATIVO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
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
          Tab(text: 'Essenciais'),
          Tab(text: 'Avançados'),
          Tab(text: 'Exclusivos'),
        ],
      ),
    );
  }

  Widget _buildEssentialFeatures(BuildContext context, bool isPremium) {
    final features = [
      _PremiumFeature(
        icon: Icons.directions_car,
        title: 'Veículos Ilimitados',
        description: 'Adicione quantos veículos quiser ao seu perfil',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.analytics,
        title: 'Relatórios Avançados',
        description: 'Análises detalhadas de consumo e gastos',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.cloud_sync,
        title: 'Sincronização em Nuvem',
        description: 'Seus dados sempre seguros e sincronizados',
        isEnabled: isPremium,
      ),
    ];

    return _buildFeatureList(context, features);
  }

  Widget _buildAdvancedFeatures(BuildContext context, bool isPremium) {
    final features = [
      _PremiumFeature(
        icon: Icons.insights,
        title: 'Análises Inteligentes',
        description: 'IA para otimizar seus gastos com combustível',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.notifications_active,
        title: 'Alertas Personalizados',
        description: 'Notificações sobre manutenções e abastecimentos',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.file_download,
        title: 'Exportação de Dados',
        description: 'Exporte relatórios em CSV, PDF e Excel',
        isEnabled: isPremium,
      ),
    ];

    return _buildFeatureList(context, features);
  }

  Widget _buildExclusiveFeatures(BuildContext context, bool isPremium) {
    final features = [
      _PremiumFeature(
        icon: Icons.support_agent,
        title: 'Suporte Prioritário',
        description: 'Atendimento exclusivo e prioritário 24/7',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.auto_awesome,
        title: 'Recursos Beta',
        description: 'Acesso antecipado a novas funcionalidades',
        isEnabled: isPremium,
      ),
      _PremiumFeature(
        icon: Icons.security,
        title: 'Backup Automático',
        description: 'Backup automático de todos os seus dados',
        isEnabled: isPremium,
      ),
    ];

    return _buildFeatureList(context, features);
  }

  Widget _buildFeatureList(BuildContext context, List<_PremiumFeature> features) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: features.map((feature) => _buildFeatureCard(context, feature)).toList(),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feature.isEnabled
            ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.isEnabled
              ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: feature.isEnabled
                  ? GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: feature.isEnabled
                  ? GasometerDesignTokens.colorPremiumAccent
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: feature.isEnabled
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            feature.isEnabled ? Icons.check_circle : Icons.lock_outline,
            color: feature.isEnabled ? Colors.green : Theme.of(context).colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha seu Plano',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildPricingCard(
          context,
          title: 'Premium Mensal',
          price: 'R\$ 9,90',
          period: '/mês',
          features: [
            'Todos os recursos premium',
            'Suporte prioritário',
            'Sincronização em nuvem',
            'Relatórios avançados',
          ],
          isPopular: false,
        ),
        const SizedBox(height: 12),
        _buildPricingCard(
          context,
          title: 'Premium Anual',
          price: 'R\$ 79,90',
          period: '/ano',
          originalPrice: 'R\$ 118,80',
          discount: '32% OFF',
          features: [
            'Todos os recursos premium',
            'Suporte prioritário',
            'Sincronização em nuvem',
            'Relatórios avançados',
            '2 meses grátis',
          ],
          isPopular: true,
        ),
      ],
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    String? discount,
    required List<String> features,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.1),
                  GasometerDesignTokens.colorPrimary.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isPopular ? null : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? GasometerDesignTokens.colorPremiumAccent
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GasometerDesignTokens.colorPremiumAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'MAIS POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isPopular) const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isPopular
                      ? GasometerDesignTokens.colorPremiumAccent
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (discount != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (originalPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              'De $originalPrice',
              style: TextStyle(
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isPopular ? GasometerDesignTokens.colorPremiumAccent : Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de compra em desenvolvimento'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? GasometerDesignTokens.colorPremiumAccent
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isPopular ? 6 : 2,
              ),
              child: const Text(
                'Assinar Agora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature {

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isEnabled,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool isEnabled;
}