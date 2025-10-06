import 'package:core/core.dart' show Equatable;

/// Entidade que representa o conteúdo promocional do app
class PromoContent extends Equatable {
  final String appName;
  final String appVersion;
  final String appDescription;
  final String appTagline;
  final List<Feature> features;
  final List<Testimonial> testimonials;
  final List<FAQ> faqs;
  final List<AppScreenshot> screenshots;
  final LaunchInfo launchInfo;
  final ContactInfo contactInfo;

  const PromoContent({
    required this.appName,
    required this.appVersion,
    required this.appDescription,
    required this.appTagline,
    required this.features,
    required this.testimonials,
    required this.faqs,
    required this.screenshots,
    required this.launchInfo,
    required this.contactInfo,
  });

  @override
  List<Object?> get props => [
    appName,
    appVersion,
    appDescription,
    appTagline,
    features,
    testimonials,
    faqs,
    screenshots,
    launchInfo,
    contactInfo,
  ];
}

/// Entidade que representa uma funcionalidade do app
class Feature extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconName;

  const Feature({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, title, description, iconName];
}

/// Entidade que representa um depoimento
class Testimonial extends Equatable {
  final String id;
  final String text;
  final String authorName;
  final String authorLocation;
  final int rating;

  const Testimonial({
    required this.id,
    required this.text,
    required this.authorName,
    required this.authorLocation,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, text, authorName, authorLocation, rating];
}

/// Entidade que representa uma pergunta frequente
class FAQ extends Equatable {
  final String id;
  final String question;
  final String answer;
  final bool isExpanded;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });

  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    bool? isExpanded,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => [id, question, answer, isExpanded];
}

/// Entidade que representa uma screenshot do app
class AppScreenshot extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  const AppScreenshot({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl];
}

/// Entidade que representa informações de lançamento
class LaunchInfo extends Equatable {
  final bool isLaunched;
  final DateTime? launchDate;
  final int preRegistrationCount;
  final bool betaAccessAvailable;

  const LaunchInfo({
    required this.isLaunched,
    this.launchDate,
    this.preRegistrationCount = 0,
    this.betaAccessAvailable = false,
  });

  @override
  List<Object?> get props => [
    isLaunched,
    launchDate,
    preRegistrationCount,
    betaAccessAvailable,
  ];
}

/// Entidade que representa informações de contato
class ContactInfo extends Equatable {
  final String supportEmail;
  final String supportPhone;
  final String websiteUrl;
  final String appStoreUrl;
  final String googlePlayUrl;
  final String facebookUrl;
  final String instagramUrl;
  final String twitterUrl;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;

  const ContactInfo({
    required this.supportEmail,
    required this.supportPhone,
    required this.websiteUrl,
    required this.appStoreUrl,
    required this.googlePlayUrl,
    required this.facebookUrl,
    required this.instagramUrl,
    required this.twitterUrl,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
  });

  @override
  List<Object?> get props => [
    supportEmail,
    supportPhone,
    websiteUrl,
    appStoreUrl,
    googlePlayUrl,
    facebookUrl,
    instagramUrl,
    twitterUrl,
    privacyPolicyUrl,
    termsOfServiceUrl,
  ];
}
