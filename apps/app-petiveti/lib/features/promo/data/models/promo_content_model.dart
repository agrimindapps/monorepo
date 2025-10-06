import '../../domain/entities/promo_content.dart';

class PromoContentModel extends PromoContent {
  const PromoContentModel({
    required super.appName,
    required super.appVersion,
    required super.appDescription,
    required super.appTagline,
    required super.features,
    required super.testimonials,
    required super.faqs,
    required super.screenshots,
    required super.launchInfo,
    required super.contactInfo,
  });

  factory PromoContentModel.fromJson(Map<String, dynamic> json) {
    return PromoContentModel(
      appName: (json['app_name'] as String?) ?? '',
      appVersion: (json['app_version'] as String?) ?? '',
      appDescription: (json['app_description'] as String?) ?? '',
      appTagline: (json['app_tagline'] as String?) ?? '',
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => FeatureModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      testimonials: (json['testimonials'] as List<dynamic>?)
          ?.map((e) => TestimonialModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      faqs: (json['faqs'] as List<dynamic>?)
          ?.map((e) => FAQModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      screenshots: (json['screenshots'] as List<dynamic>?)
          ?.map((e) => AppScreenshotModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      launchInfo: LaunchInfoModel.fromJson((json['launch_info'] as Map<String, dynamic>?) ?? {}),
      contactInfo: ContactInfoModel.fromJson((json['contact_info'] as Map<String, dynamic>?) ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'app_description': appDescription,
      'app_tagline': appTagline,
      'features': features.map((e) => (e as FeatureModel).toJson()).toList(),
      'testimonials': testimonials.map((e) => (e as TestimonialModel).toJson()).toList(),
      'faqs': faqs.map((e) => (e as FAQModel).toJson()).toList(),
      'screenshots': screenshots.map((e) => (e as AppScreenshotModel).toJson()).toList(),
      'launch_info': (launchInfo as LaunchInfoModel).toJson(),
      'contact_info': (contactInfo as ContactInfoModel).toJson(),
    };
  }

  /// Creates a mock promo content for development
  factory PromoContentModel.mock() {
    return PromoContentModel(
      appName: 'PetiVeti',
      appVersion: '1.0.0',
      appDescription: 'O app completo para cuidar do seu melhor amigo. Agende consultas, acompanhe a saúde e mantenha seu pet sempre feliz.',
      appTagline: 'Cuidado completo para seu melhor amigo',
      features: [
        FeatureModel.mock('1', 'Agenda Veterinária', 'Agende consultas com veterinários próximos', 'medical_services'),
        FeatureModel.mock('2', 'Perfil do Pet', 'Mantenha todas as informações do seu pet organizadas', 'pets'),
        FeatureModel.mock('3', 'Lembretes', 'Nunca mais esqueça vacinas e medicamentos', 'schedule'),
        FeatureModel.mock('4', 'Histórico de Saúde', 'Acompanhe o histórico médico completo', 'favorite'),
      ],
      testimonials: [
        TestimonialModel.mock('1', 'O PetiVeti mudou a forma como cuido do meu dog. Super prático!', 'Maria Silva', 'São Paulo, SP', 5),
        TestimonialModel.mock('2', 'Nunca mais esqueci das vacinas do meu gato. Recomendo!', 'João Santos', 'Rio de Janeiro, RJ', 5),
      ],
      faqs: [
        FAQModel.mock('1', 'Como funciona o agendamento?', 'Você pode agendar consultas diretamente pelo app, escolhendo veterinários próximos à sua localização.'),
        FAQModel.mock('2', 'O app é gratuito?', 'Sim! O PetiVeti oferece funcionalidades básicas gratuitas, com planos premium para recursos avançados.'),
        FAQModel.mock('3', 'Posso cadastrar mais de um pet?', 'Claro! Você pode cadastrar quantos pets quiser no mesmo perfil.'),
      ],
      screenshots: [
        AppScreenshotModel.mock('1', 'Tela Principal', 'Visualize rapidamente a saúde dos seus pets', 'screenshot1.png'),
        AppScreenshotModel.mock('2', 'Perfil do Pet', 'Mantenha todas as informações organizadas', 'screenshot2.png'),
        AppScreenshotModel.mock('3', 'Agendamentos', 'Agende consultas facilmente', 'screenshot3.png'),
      ],
      launchInfo: LaunchInfoModel.mock(),
      contactInfo: ContactInfoModel.mock(),
    );
  }

}

class FeatureModel extends Feature {
  const FeatureModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconName,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      iconName: (json['icon_name'] as String?) ?? 'pets',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
    };
  }

  factory FeatureModel.mock(String id, String title, String description, String iconName) {
    return FeatureModel(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
    );
  }
}

class TestimonialModel extends Testimonial {
  const TestimonialModel({
    required super.id,
    required super.text,
    required super.authorName,
    required super.authorLocation,
    required super.rating,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      authorName: (json['author_name'] as String?) ?? '',
      authorLocation: (json['author_location'] as String?) ?? '',
      rating: (json['rating'] as int?) ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author_name': authorName,
      'author_location': authorLocation,
      'rating': rating,
    };
  }

  factory TestimonialModel.mock(String id, String text, String authorName, String authorLocation, int rating) {
    return TestimonialModel(
      id: id,
      text: text,
      authorName: authorName,
      authorLocation: authorLocation,
      rating: rating,
    );
  }
}

class FAQModel extends FAQ {
  const FAQModel({
    required super.id,
    required super.question,
    required super.answer,
    super.isExpanded = false,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: (json['id'] as String?) ?? '',
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      isExpanded: (json['is_expanded'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'is_expanded': isExpanded,
    };
  }

  factory FAQModel.mock(String id, String question, String answer) {
    return FAQModel(
      id: id,
      question: question,
      answer: answer,
      isExpanded: false,
    );
  }

  @override
  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    bool? isExpanded,
  }) {
    return FAQModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class AppScreenshotModel extends AppScreenshot {
  const AppScreenshotModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
  });

  factory AppScreenshotModel.fromJson(Map<String, dynamic> json) {
    return AppScreenshotModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
    };
  }

  factory AppScreenshotModel.mock(String id, String title, String description, String imageUrl) {
    return AppScreenshotModel(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );
  }
}

class LaunchInfoModel extends LaunchInfo {
  const LaunchInfoModel({
    required super.isLaunched,
    super.launchDate,
    super.preRegistrationCount = 0,
    super.betaAccessAvailable = false,
  });

  factory LaunchInfoModel.fromJson(Map<String, dynamic> json) {
    return LaunchInfoModel(
      isLaunched: (json['is_launched'] as bool?) ?? false,
      launchDate: json['launch_date'] != null ? DateTime.parse(json['launch_date'] as String) : null,
      preRegistrationCount: (json['pre_registration_count'] as int?) ?? 0,
      betaAccessAvailable: (json['beta_access_available'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_launched': isLaunched,
      'launch_date': launchDate?.toIso8601String(),
      'pre_registration_count': preRegistrationCount,
      'beta_access_available': betaAccessAvailable,
    };
  }

  factory LaunchInfoModel.mock() {
    return LaunchInfoModel(
      isLaunched: false,
      launchDate: DateTime.now().add(const Duration(days: 30)),
      preRegistrationCount: 1250,
      betaAccessAvailable: true,
    );
  }
}

class ContactInfoModel extends ContactInfo {
  const ContactInfoModel({
    required super.supportEmail,
    required super.supportPhone,
    required super.websiteUrl,
    required super.appStoreUrl,
    required super.googlePlayUrl,
    required super.facebookUrl,
    required super.instagramUrl,
    required super.twitterUrl,
    required super.privacyPolicyUrl,
    required super.termsOfServiceUrl,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      supportEmail: (json['support_email'] as String?) ?? '',
      supportPhone: (json['support_phone'] as String?) ?? '',
      websiteUrl: (json['website_url'] as String?) ?? '',
      appStoreUrl: (json['app_store_url'] as String?) ?? '',
      googlePlayUrl: (json['google_play_url'] as String?) ?? '',
      facebookUrl: (json['facebook_url'] as String?) ?? '',
      instagramUrl: (json['instagram_url'] as String?) ?? '',
      twitterUrl: (json['twitter_url'] as String?) ?? '',
      privacyPolicyUrl: (json['privacy_policy_url'] as String?) ?? '',
      termsOfServiceUrl: (json['terms_of_service_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'support_email': supportEmail,
      'support_phone': supportPhone,
      'website_url': websiteUrl,
      'app_store_url': appStoreUrl,
      'google_play_url': googlePlayUrl,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
      'twitter_url': twitterUrl,
      'privacy_policy_url': privacyPolicyUrl,
      'terms_of_service_url': termsOfServiceUrl,
    };
  }

  factory ContactInfoModel.mock() {
    return const ContactInfoModel(
      supportEmail: 'suporte@petiveti.com',
      supportPhone: '+55 11 99999-9999',
      websiteUrl: 'https://www.petiveti.com',
      appStoreUrl: 'https://apps.apple.com/app/petiveti',
      googlePlayUrl: 'https://play.google.com/store/apps/details?id=com.petiveti.app',
      facebookUrl: 'https://facebook.com/petiveti',
      instagramUrl: 'https://instagram.com/petiveti',
      twitterUrl: 'https://twitter.com/petiveti',
      privacyPolicyUrl: 'https://www.petiveti.com/privacy',
      termsOfServiceUrl: 'https://www.petiveti.com/terms',
    );
  }
}
