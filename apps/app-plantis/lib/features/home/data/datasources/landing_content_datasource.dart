import '../models/landing_content_model.dart';

/// DataSource for Landing Page content
///
/// Currently provides static content, but designed to support
/// future Firebase Remote Config integration for A/B testing
class LandingContentDataSource {
  /// Get landing page content
  ///
  /// Returns [LandingContentModel] with hero, features, and CTA content
  /// Currently configured for "Coming Soon" state
  LandingContentModel getLandingContent() {
    return LandingContentModel(
      hero: HeroContentModel(
        title: 'Bem-vindo ao Plantis',
        subtitle:
            'Gerencie suas plantas de forma inteligente com tecnologia e sustentabilidade',
        ctaText: 'Entrar',
        ctaSemanticLabel: 'Botão para entrar no aplicativo',
        ctaTooltip: 'Fazer login no Plantis',
        comingSoonLabel: 'Em Breve',
      ),
      features: [
        FeatureItemModel(
          title: 'Biblioteca de Plantas',
          description: 'Acesse informações sobre milhares de espécies',
          icon: '🌿',
        ),
        FeatureItemModel(
          title: 'Gestão de Cultivos',
          description: 'Acompanhe o desenvolvimento das suas plantas',
          icon: '📊',
        ),
        FeatureItemModel(
          title: 'Alertas Inteligentes',
          description: 'Receba notificações de rega e cuidados',
          icon: '🔔',
        ),
        FeatureItemModel(
          title: 'Comunidade',
          description: 'Compartilhe experiências com outros cultivadores',
          icon: '👥',
        ),
        FeatureItemModel(
          title: 'Agenda de Atividades',
          description: 'Organize todas as tarefas do seu cultivo',
          icon: '📅',
        ),
        FeatureItemModel(
          title: 'Análise de Solo',
          description: 'Registre e monitore a qualidade do solo',
          icon: '🌱',
        ),
      ],
      cta: CTAContentModel(
        title: 'Comece agora',
        description: 'Junte-se a milhares de cultivadores',
        buttonText: 'Criar conta grátis',
      ),
      comingSoon: true,
      launchDate: DateTime(2026, 1, 1), // Lançamento: 01 de Janeiro de 2026
    );
  }

  /// Get landing content from remote config (Future implementation)
  ///
  /// This method is prepared for A/B testing scenarios where
  /// content variants can be loaded from Firebase Remote Config
  Future<LandingContentModel> getLandingContentRemote() async {
    // TODO: Implement Firebase Remote Config integration
    // This will enable A/B testing of different landing page variants
    return getLandingContent();
  }
}
