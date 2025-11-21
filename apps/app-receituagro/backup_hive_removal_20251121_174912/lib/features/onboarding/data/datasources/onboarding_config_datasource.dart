import '../models/models.dart';

/// Static configuration data source for onboarding
/// Provides hardcoded onboarding steps and feature tooltips
/// This data is embedded in the app (not fetched from network)
class OnboardingConfigDataSource {
  /// Get all onboarding steps configuration
  List<OnboardingStepModel> getSteps() {
    return [
      const OnboardingStepModel(
        id: 'welcome',
        title: 'Bem-vindo ao ReceitauAgro!',
        description:
            'Seu assistente completo para diagnóstico e controle de pragas e doenças agrícolas.',
        imageAsset: 'assets/images/onboarding_welcome.png',
        config: {
          'show_logo': true,
          'background_color': '#4CAF50',
        },
      ),
      const OnboardingStepModel(
        id: 'explore_database',
        title: 'Explore o Banco de Pragas',
        description:
            'Acesse informações detalhadas sobre pragas, doenças e culturas.',
        imageAsset: 'assets/images/onboarding_database.png',
        config: {
          'highlight_search': true,
          'show_categories': true,
        },
      ),
      const OnboardingStepModel(
        id: 'diagnostic_tool',
        title: 'Use a Ferramenta de Diagnóstico',
        description:
            'Identifique problemas em suas culturas usando nossos filtros inteligentes.',
        imageAsset: 'assets/images/onboarding_diagnostic.png',
        config: {
          'demo_filters': ['cultura', 'sintoma', 'parte_afetada'],
        },
      ),
      const OnboardingStepModel(
        id: 'favorites',
        title: 'Salve seus Favoritos',
        description:
            'Marque pragas e diagnósticos importantes para acesso rápido.',
        imageAsset: 'assets/images/onboarding_favorites.png',
        config: {
          'show_favorite_button': true,
        },
      ),
      const OnboardingStepModel(
        id: 'premium_features',
        title: 'Recursos Premium',
        description:
            'Desbloqueie funcionalidades avançadas com a assinatura Premium.',
        imageAsset: 'assets/images/onboarding_premium.png',
        config: {
          'highlight_premium': ['export', 'advanced_search', 'comments'],
        },
        isRequired: false,
      ),
      const OnboardingStepModel(
        id: 'notifications',
        title: 'Mantenha-se Atualizado',
        description:
            'Receba notificações sobre novas pragas e atualizações importantes.',
        imageAsset: 'assets/images/onboarding_notifications.png',
        config: {
          'request_permission': true,
        },
        isRequired: false,
      ),
      const OnboardingStepModel(
        id: 'profile_setup',
        title: 'Configure seu Perfil',
        description:
            'Personalize sua experiência definindo suas culturas principais.',
        imageAsset: 'assets/images/onboarding_profile.png',
        config: {
          'suggest_cultures': ['soja', 'milho', 'algodão', 'café'],
        },
        isRequired: false,
      ),
    ];
  }

  /// Get all feature discovery tooltips
  List<FeatureTooltipModel> getTooltips() {
    return [
      const FeatureTooltipModel(
        id: 'search_filters',
        title: 'Busca Avançada',
        description: 'Use os filtros para encontrar exatamente o que precisa',
        targetWidget: 'search_filters_button',
        priority: 1,
        triggers: ['first_search'],
        config: {
          'position': 'bottom',
          'delay_ms': 2000,
        },
      ),
      const FeatureTooltipModel(
        id: 'export_function',
        title: 'Exportar Relatórios',
        description:
            'Gere relatórios PDF dos seus diagnósticos (Premium)',
        targetWidget: 'export_button',
        priority: 2,
        triggers: ['diagnostic_completed'],
        config: {
          'premium_only': true,
          'position': 'top',
        },
      ),
      const FeatureTooltipModel(
        id: 'comment_system',
        title: 'Sistema de Comentários',
        description:
            'Compartilhe experiências com outros usuários (Premium)',
        targetWidget: 'comments_tab',
        priority: 3,
        triggers: ['viewing_plague_details'],
        config: {
          'premium_only': true,
          'position': 'left',
        },
      ),
      const FeatureTooltipModel(
        id: 'sync_devices',
        title: 'Sincronização',
        description:
            'Seus dados são sincronizados entre todos os dispositivos',
        targetWidget: 'sync_status_icon',
        priority: 2,
        triggers: ['second_session'],
        config: {
          'position': 'bottom',
          'show_sync_animation': true,
        },
      ),
      const FeatureTooltipModel(
        id: 'offline_access',
        title: 'Acesso Offline',
        description:
            'Consulte dados mesmo sem conexão com a internet',
        targetWidget: 'offline_indicator',
        priority: 3,
        triggers: ['network_disconnected'],
        config: {
          'position': 'top',
          'timeout_ms': 5000,
        },
      ),
    ];
  }
}
