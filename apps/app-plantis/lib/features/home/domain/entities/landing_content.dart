import 'package:equatable/equatable.dart';

/// Entity representing landing page content
/// Can be used for A/B testing or dynamic content in the future
class LandingContent extends Equatable {
  /// Hero section content
  final HeroContent hero;

  /// Features to highlight
  final List<FeatureItem> features;

  /// Call to action content
  final CTAContent cta;

  const LandingContent({
    required this.hero,
    required this.features,
    required this.cta,
  });

  /// Default landing content
  factory LandingContent.defaultContent() {
    return LandingContent(
      hero: HeroContent.defaultHero(),
      features: FeatureItem.defaultFeatures(),
      cta: CTAContent.defaultCTA(),
    );
  }

  @override
  List<Object?> get props => [hero, features, cta];
}

/// Hero section content
class HeroContent extends Equatable {
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaSemanticLabel;
  final String ctaTooltip;

  const HeroContent({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaSemanticLabel,
    required this.ctaTooltip,
  });

  factory HeroContent.defaultHero() {
    return const HeroContent(
      title: 'Cuide das suas plantas\ncom amor e tecnologia',
      subtitle: 'Seu jardim inteligente na palma da mão',
      ctaText: 'Começar Agora',
      ctaSemanticLabel: 'Botão para começar a usar o Plantis',
      ctaTooltip: 'Toque para criar sua conta ou fazer login',
    );
  }

  @override
  List<Object?> get props => [
    title,
    subtitle,
    ctaText,
    ctaSemanticLabel,
    ctaTooltip,
  ];
}

/// Feature item for landing page
class FeatureItem extends Equatable {
  final String title;
  final String description;
  final String icon;

  const FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  static List<FeatureItem> defaultFeatures() {
    return const [
      FeatureItem(
        title: 'Lembretes Inteligentes',
        description: 'Nunca mais esqueça de regar suas plantas',
        icon: 'notifications',
      ),
      FeatureItem(
        title: 'Catálogo Completo',
        description: 'Milhares de espécies catalogadas',
        icon: 'local_florist',
      ),
      FeatureItem(
        title: 'Dicas Personalizadas',
        description: 'Cuidados específicos para cada planta',
        icon: 'lightbulb',
      ),
    ];
  }

  @override
  List<Object?> get props => [title, description, icon];
}

/// Call to action content
class CTAContent extends Equatable {
  final String title;
  final String description;
  final String buttonText;

  const CTAContent({
    required this.title,
    required this.description,
    required this.buttonText,
  });

  factory CTAContent.defaultCTA() {
    return const CTAContent(
      title: 'Pronto para começar?',
      description:
          'Junte-se a milhares de pessoas que já cuidam melhor de suas plantas',
      buttonText: 'Criar Conta Grátis',
    );
  }

  @override
  List<Object?> get props => [title, description, buttonText];
}
