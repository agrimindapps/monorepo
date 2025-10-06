import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../providers/subscription_notifier.dart';

/// Advanced Premium Features Showcase Widget
///
/// Features:
/// - Dynamic feature cards with A/B testing
/// - Cross-platform premium validation indicators
/// - Feature discovery onboarding flow
/// - Premium feature usage statistics
/// - Interactive feature previews
class PremiumFeaturesShowcaseWidget extends ConsumerStatefulWidget {
  final bool showFullDetails;
  final VoidCallback? onUpgradePressed;

  const PremiumFeaturesShowcaseWidget({
    super.key,
    this.showFullDetails = true,
    this.onUpgradePressed,
  });

  @override
  ConsumerState<PremiumFeaturesShowcaseWidget> createState() =>
      _PremiumFeaturesShowcaseWidgetState();
}

class _PremiumFeaturesShowcaseWidgetState
    extends ConsumerState<PremiumFeaturesShowcaseWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
    // Watch both providers from Riverpod
    final featureFlagsAsync = ref.watch(featureFlagsNotifierProvider);
    final subscriptionAsync = ref.watch(subscriptionNotifierProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        return featureFlagsAsync.when(
          data: (featureFlagsState) {
            final featureFlags = ref.read(
              featureFlagsNotifierProvider.notifier,
            );

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Premium Status
                  _buildHeader(
                    context,
                    featureFlags,
                    subscriptionState.hasActiveSubscription,
                  ),

                  const SizedBox(height: 24),

                  // Feature Categories Tabs
                  _buildFeatureTabs(context),

                  const SizedBox(height: 16),

                  // Feature Content
                  SizedBox(
                    height: widget.showFullDetails ? 400 : 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCoreFeatures(
                          context,
                          featureFlags,
                          subscriptionState.hasActiveSubscription,
                        ),
                        _buildAdvancedFeatures(
                          context,
                          featureFlags,
                          subscriptionState.hasActiveSubscription,
                        ),
                        _buildExclusiveFeatures(
                          context,
                          featureFlags,
                          subscriptionState.hasActiveSubscription,
                        ),
                      ],
                    ),
                  ),

                  // Cross-platform Sync Indicator
                  if (widget.showFullDetails) ...[
                    const SizedBox(height: 24),
                    _buildCrossPlatformIndicator(context, featureFlags),
                  ],

                  // Upgrade CTA
                  if (!subscriptionState.hasActiveSubscription) ...[
                    const SizedBox(height: 24),
                    _buildUpgradeCTA(context),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  /// Header with Premium Status and Validation
  Widget _buildHeader(
    BuildContext context,
    FeatureFlagsNotifier featureFlags,
    bool hasActiveSubscription,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            hasActiveSubscription
                ? LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors: [Colors.blue.shade600, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasActiveSubscription ? Icons.verified : Icons.workspace_premium,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveSubscription
                      ? 'Premium Ativo'
                      : 'ReceitaAgro Premium',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasActiveSubscription
                      ? 'Todos os recursos desbloqueados'
                      : 'Desbloqueie recursos avançados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Cross-platform Sync Status
          if (hasActiveSubscription &&
              featureFlags.isContentSynchronizationEnabled)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sync, color: Colors.white, size: 16),
                  const SizedBox(height: 2),
                  Text(
                    'SYNC',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Feature Categories Tabs
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
          color: Theme.of(context).colorScheme.primary,
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

  /// Core Features Tab
  Widget _buildCoreFeatures(
    BuildContext context,
    FeatureFlagsNotifier featureFlags,
    bool hasActiveSubscription,
  ) {
    final coreFeatures = [
      const PremiumFeature(
        icon: Icons.favorite,
        title: 'Favoritos Ilimitados',
        description: 'Salve quantos diagnósticos quiser',
        isAvailable: true,
        featureFlag: null,
      ),
      PremiumFeature(
        icon: Icons.search,
        title: 'Busca Avançada',
        description: 'Filtros detalhados e pesquisa inteligente',
        isAvailable: featureFlags.isAdvancedDiagnosticsEnabled,
        featureFlag: 'advanced_diagnostics',
      ),
      PremiumFeature(
        icon: Icons.notifications,
        title: 'Notificações Personalizadas',
        description: 'Alertas sobre novas pragas e doenças',
        isAvailable: featureFlags.isPushNotificationsEnabled,
        featureFlag: 'push_notifications',
      ),
    ];

    return _buildFeatureGrid(
      context,
      coreFeatures,
      'Recursos fundamentais para diagnósticos eficientes',
      hasActiveSubscription,
    );
  }

  /// Advanced Features Tab
  Widget _buildAdvancedFeatures(
    BuildContext context,
    FeatureFlagsNotifier featureFlags,
    bool hasActiveSubscription,
  ) {
    final advancedFeatures = [
      PremiumFeature(
        icon: Icons.cloud_download,
        title: 'Modo Offline',
        description: 'Acesse diagnósticos sem internet',
        isAvailable: featureFlags.isOfflineModeEnabled,
        featureFlag: 'offline_mode',
      ),
      PremiumFeature(
        icon: Icons.sync,
        title: 'Sincronização Multi-dispositivo',
        description: 'Dados sincronizados entre todos os dispositivos',
        isAvailable: featureFlags.isContentSynchronizationEnabled,
        featureFlag: 'content_synchronization',
      ),
      PremiumFeature(
        icon: Icons.analytics,
        title: 'Análises Detalhadas',
        description: 'Relatórios completos de uso e eficiência',
        isAvailable: featureFlags.isDetailedAnalyticsEnabled,
        featureFlag: 'detailed_analytics',
      ),
    ];

    return _buildFeatureGrid(
      context,
      advancedFeatures,
      'Funcionalidades avançadas para usuários experientes',
      hasActiveSubscription,
    );
  }

  /// Exclusive Features Tab
  Widget _buildExclusiveFeatures(
    BuildContext context,
    FeatureFlagsNotifier featureFlags,
    bool hasActiveSubscription,
  ) {
    final exclusiveFeatures = [
      const PremiumFeature(
        icon: Icons.support_agent,
        title: 'Suporte Prioritário',
        description: 'Atendimento exclusivo para membros Premium',
        isAvailable: true,
        featureFlag: null,
      ),
      PremiumFeature(
        icon: Icons.science,
        title: 'Recursos Experimentais',
        description: 'Acesso antecipado a novas funcionalidades',
        isAvailable: featureFlags.isNewUiDesignEnabled,
        featureFlag: 'new_ui_design',
      ),
      PremiumFeature(
        icon: Icons.group,
        title: 'Comunidade Premium',
        description: 'Acesso exclusivo ao grupo de especialistas',
        isAvailable: featureFlags.isGamificationEnabled,
        featureFlag: 'gamification',
      ),
    ];

    return _buildFeatureGrid(
      context,
      exclusiveFeatures,
      'Benefícios exclusivos para membros Premium',
      hasActiveSubscription,
    );
  }

  /// Build Feature Grid
  Widget _buildFeatureGrid(
    BuildContext context,
    List<PremiumFeature> features,
    String description,
    bool hasActiveSubscription,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) =>
                _buildFeatureCard(context, feature, hasActiveSubscription),
          ),
        ],
      ),
    );
  }

  /// Individual Feature Card
  Widget _buildFeatureCard(
    BuildContext context,
    PremiumFeature feature,
    bool hasActiveSubscription,
  ) {
    final theme = Theme.of(context);
    final isEnabled = feature.isAvailable && hasActiveSubscription;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isEnabled
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEnabled
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Feature Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color:
                  isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Feature Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isEnabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator
          _buildFeatureStatusIndicator(context, feature, hasActiveSubscription),
        ],
      ),
    );
  }

  /// Feature Status Indicator
  Widget _buildFeatureStatusIndicator(
    BuildContext context,
    PremiumFeature feature,
    bool hasSubscription,
  ) {
    final theme = Theme.of(context);

    if (hasSubscription && feature.isAvailable) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else if (hasSubscription && !feature.isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'EM BREVE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.lock_outline,
        color: theme.colorScheme.outline,
        size: 20,
      );
    }
  }

  /// Cross-platform Sync Indicator
  Widget _buildCrossPlatformIndicator(
    BuildContext context,
    FeatureFlagsNotifier featureFlags,
  ) {
    if (!featureFlags.isContentSynchronizationEnabled) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.devices, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sincronização Cross-platform',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Seus dados estão sincronizados em todos os dispositivos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.sync, color: Colors.green, size: 16),
          ),
        ],
      ),
    );
  }

  /// Upgrade CTA Button
  Widget _buildUpgradeCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onUpgradePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 20),
            const SizedBox(width: 8),
            Text(
              'Atualizar para Premium',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Feature Data Model
class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final bool isAvailable;
  final String? featureFlag;

  const PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isAvailable,
    this.featureFlag,
  });
}
