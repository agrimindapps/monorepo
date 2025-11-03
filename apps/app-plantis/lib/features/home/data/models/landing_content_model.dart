import '../../domain/entities/landing_content.dart';

/// Model for LandingContent
class LandingContentModel {
  final HeroContentModel hero;
  final List<FeatureItemModel> features;
  final CTAContentModel cta;
  final bool comingSoon;
  final DateTime? launchDate;

  const LandingContentModel({
    required this.hero,
    required this.features,
    required this.cta,
    this.comingSoon = false,
    this.launchDate,
  });

  /// Convert to domain entity
  LandingContent toEntity() {
    return LandingContent(
      hero: hero.toEntity(),
      features: features.map((f) => f.toEntity()).toList(),
      cta: cta.toEntity(),
      comingSoon: comingSoon,
      launchDate: launchDate,
    );
  }

  /// Create from JSON
  factory LandingContentModel.fromJson(Map<String, dynamic> json) {
    return LandingContentModel(
      hero: HeroContentModel.fromJson(json['hero'] as Map<String, dynamic>),
      features: (json['features'] as List)
          .map((e) => FeatureItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cta: CTAContentModel.fromJson(json['cta'] as Map<String, dynamic>),
      comingSoon: json['comingSoon'] as bool? ?? false,
      launchDate: json['launchDate'] != null
          ? DateTime.parse(json['launchDate'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'hero': hero.toJson(),
      'features': features.map((f) => f.toJson()).toList(),
      'cta': cta.toJson(),
      'comingSoon': comingSoon,
      'launchDate': launchDate?.toIso8601String(),
    };
  }
}

/// Model for HeroContent
class HeroContentModel {
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaSemanticLabel;
  final String ctaTooltip;
  final String? comingSoonLabel;

  const HeroContentModel({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaSemanticLabel,
    required this.ctaTooltip,
    this.comingSoonLabel,
  });

  HeroContent toEntity() {
    return HeroContent(
      title: title,
      subtitle: subtitle,
      ctaText: ctaText,
      ctaSemanticLabel: ctaSemanticLabel,
      ctaTooltip: ctaTooltip,
      comingSoonLabel: comingSoonLabel,
    );
  }

  factory HeroContentModel.fromJson(Map<String, dynamic> json) {
    return HeroContentModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      ctaText: json['ctaText'] as String,
      ctaSemanticLabel: json['ctaSemanticLabel'] as String,
      ctaTooltip: json['ctaTooltip'] as String,
      comingSoonLabel: json['comingSoonLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'ctaText': ctaText,
      'ctaSemanticLabel': ctaSemanticLabel,
      'ctaTooltip': ctaTooltip,
      'comingSoonLabel': comingSoonLabel,
    };
  }
}

/// Model for FeatureItem
class FeatureItemModel {
  final String title;
  final String description;
  final String icon;

  const FeatureItemModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  FeatureItem toEntity() {
    return FeatureItem(title: title, description: description, icon: icon);
  }

  factory FeatureItemModel.fromJson(Map<String, dynamic> json) {
    return FeatureItemModel(
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'icon': icon};
  }
}

/// Model for CTAContent
class CTAContentModel {
  final String title;
  final String description;
  final String buttonText;

  const CTAContentModel({
    required this.title,
    required this.description,
    required this.buttonText,
  });

  CTAContent toEntity() {
    return CTAContent(
      title: title,
      description: description,
      buttonText: buttonText,
    );
  }

  factory CTAContentModel.fromJson(Map<String, dynamic> json) {
    return CTAContentModel(
      title: json['title'] as String,
      description: json['description'] as String,
      buttonText: json['buttonText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'buttonText': buttonText,
    };
  }
}
