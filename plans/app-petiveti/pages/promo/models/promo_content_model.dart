// Flutter imports:
import 'package:flutter/material.dart';

enum PromoSectionType {
  hero('hero', 'Hero'),
  features('features', 'Recursos'),
  screenshots('screenshots', 'Screenshots'),
  testimonials('testimonials', 'Depoimentos'),
  download('download', 'Download'),
  faq('faq', 'FAQ'),
  footer('footer', 'Rodapé');

  const PromoSectionType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum PromoFeatureCategory {
  petProfiles('pet_profiles', 'Perfis de Pets'),
  health('health', 'Saúde'),
  medication('medication', 'Medicamentos'),
  tracking('tracking', 'Controle'),
  appointments('appointments', 'Consultas'),
  reminders('reminders', 'Lembretes');

  const PromoFeatureCategory(this.id, this.displayName);
  final String id;
  final String displayName;
}

class PromoFeature {
  final String id;
  final IconData icon;
  final Color? color;
  final String title;
  final String description;
  final bool isHighlight;
  final PromoFeatureCategory category;

  const PromoFeature({
    required this.id,
    required this.icon,
    this.color,
    required this.title,
    required this.description,
    this.isHighlight = false,
    this.category = PromoFeatureCategory.petProfiles,
  });

  PromoFeature copyWith({
    String? id,
    IconData? icon,
    Color? color,
    String? title,
    String? description,
    bool? isHighlight,
    PromoFeatureCategory? category,
  }) {
    return PromoFeature(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      title: title ?? this.title,
      description: description ?? this.description,
      isHighlight: isHighlight ?? this.isHighlight,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isHighlight': isHighlight,
    };
  }

  static PromoFeature fromJson(Map<String, dynamic> json) {
    return PromoFeature(
      id: json['id'] ?? '',
      icon: Icons.help_outline, // Default icon
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isHighlight: json['isHighlight'] ?? false,
    );
  }

  @override
  String toString() {
    return 'PromoFeature(id: $id, title: $title)';
  }
}

class PromoTestimonial {
  final String id;
  final String quote;
  final String author;
  final String role;
  final String? imageUrl;
  final double rating;

  const PromoTestimonial({
    required this.id,
    required this.quote,
    required this.author,
    required this.role,
    this.imageUrl,
    this.rating = 5.0,
  });

  PromoTestimonial copyWith({
    String? id,
    String? quote,
    String? author,
    String? role,
    String? imageUrl,
    double? rating,
  }) {
    return PromoTestimonial(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'role': role,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  static PromoTestimonial fromJson(Map<String, dynamic> json) {
    return PromoTestimonial(
      id: json['id'] ?? '',
      quote: json['quote'] ?? '',
      author: json['author'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'],
      rating: (json['rating'] ?? 5.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'PromoTestimonial(id: $id, author: $author)';
  }
}

enum FAQCategory {
  general,
  features,
  technical,
  billing,
  contact,
}

class PromoFAQItem {
  final String id;
  final String question;
  final String answer;
  final FAQCategory category;
  final bool isExpanded;
  final int order;

  const PromoFAQItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category = FAQCategory.general,
    this.isExpanded = false,
    this.order = 0,
  });

  PromoFAQItem copyWith({
    String? id,
    String? question,
    String? answer,
    FAQCategory? category,
    bool? isExpanded,
    int? order,
  }) {
    return PromoFAQItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      isExpanded: isExpanded ?? this.isExpanded,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.name,
      'isExpanded': isExpanded,
      'order': order,
    };
  }

  static PromoFAQItem fromJson(Map<String, dynamic> json) {
    return PromoFAQItem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: FAQCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FAQCategory.general,
      ),
      isExpanded: json['isExpanded'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PromoFAQItem(id: $id, question: $question)';
  }
}

class PromoScreenshot {
  final String id;
  final String url;
  final String title;
  final String? description;
  final int order;

  const PromoScreenshot({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.order = 0,
  });

  PromoScreenshot copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    int? order,
  }) {
    return PromoScreenshot(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  static PromoScreenshot fromJson(Map<String, dynamic> json) {
    return PromoScreenshot(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      order: json['order'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PromoScreenshot(id: $id, title: $title)';
  }
}

class PromoHeroContent {
  final String title;
  final String subtitle;
  final String description;
  final String? badgeText;
  final String? ctaText;
  final String? imageUrl;
  final List<String> keyPoints;

  const PromoHeroContent({
    required this.title,
    required this.subtitle,
    required this.description,
    this.badgeText,
    this.ctaText,
    this.imageUrl,
    this.keyPoints = const [],
  });

  PromoHeroContent copyWith({
    String? title,
    String? subtitle,
    String? description,
    String? badgeText,
    String? ctaText,
    String? imageUrl,
    List<String>? keyPoints,
  }) {
    return PromoHeroContent(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      badgeText: badgeText ?? this.badgeText,
      ctaText: ctaText ?? this.ctaText,
      imageUrl: imageUrl ?? this.imageUrl,
      keyPoints: keyPoints ?? this.keyPoints,
    );
  }

  bool get hasBadge => badgeText != null && badgeText!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasKeyPoints => keyPoints.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'badgeText': badgeText,
      'ctaText': ctaText,
      'imageUrl': imageUrl,
      'keyPoints': keyPoints,
    };
  }

  static PromoHeroContent fromJson(Map<String, dynamic> json) {
    return PromoHeroContent(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      badgeText: json['badgeText'],
      ctaText: json['ctaText'],
      imageUrl: json['imageUrl'],
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
    );
  }

  @override
  String toString() {
    return 'PromoHeroContent(title: $title)';
  }
}

class PromoContentRepository {
  static PromoHeroContent getHeroContent() {
    return const PromoHeroContent(
      title: 'PetiVeti',
      subtitle: 'Cuidados completos para seu melhor amigo',
      description: 'O aplicativo mais completo para tutores que se preocupam com a saúde e bem-estar de seus pets. Acompanhe vacinas, medicamentos, peso, consultas e muito mais.',
      badgeText: 'EM BREVE',
      ctaText: 'Quero ser notificado',
      imageUrl: 'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png',
    );
  }

  static List<PromoFeature> getFeatures() {
    return [
      const PromoFeature(
        id: 'pet_profiles',
        icon: Icons.pets,
        color: Color(0xFF6A1B9A), // Purple 700
        title: 'Perfis de Pet',
        description: 'Crie perfis detalhados para todos os seus animais de estimação com raça, idade, peso e muito mais.',
      ),
      const PromoFeature(
        id: 'vaccines',
        icon: Icons.local_hospital,
        color: Color(0xFFD32F2F), // Red 600
        title: 'Vacinas',
        description: 'Acompanhe o calendário de vacinação e receba notificações para nunca perder uma data importante.',
      ),
      const PromoFeature(
        id: 'medications',
        icon: Icons.medication,
        color: Color(0xFF388E3C), // Green 700
        title: 'Medicamentos',
        description: 'Gerencie os medicamentos, doses e horários para garantir tratamentos eficazes.',
      ),
      const PromoFeature(
        id: 'weight_control',
        icon: Icons.monitor_weight,
        color: Color(0xFFFF8F00), // Orange 700
        title: 'Controle de Peso',
        description: 'Acompanhe a evolução do peso do seu animal com gráficos intuitivos.',
      ),
      const PromoFeature(
        id: 'appointments',
        icon: Icons.event_note,
        color: Color(0xFF1976D2), // Blue 600
        title: 'Histórico de Consultas',
        description: 'Mantenha um registro completo de todas as consultas veterinárias, diagnósticos e recomendações.',
      ),
      const PromoFeature(
        id: 'reminders',
        icon: Icons.alarm,
        color: Color(0xFF00796B), // Teal 700
        title: 'Lembretes',
        description: 'Configure alertas personalizados para consultas, medicamentos e outros cuidados importantes.',
      ),
    ];
  }

  static List<PromoTestimonial> getTestimonials() {
    return [
      const PromoTestimonial(
        id: 'testimonial_1',
        quote: 'O PetiVeti me ajudou a manter todas as vacinas da minha cachorra em dia. As notificações são perfeitas!',
        author: 'Ana Silva',
        role: 'Tutora de Golden Retriever',
        imageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
        rating: 5.0,
      ),
      const PromoTestimonial(
        id: 'testimonial_2',
        quote: 'Como tutor de vários gatos, o aplicativo facilitou muito o controle de medicamentos e consultas de cada um.',
        author: 'Carlos Mendes',
        role: 'Tutor de 4 gatos',
        imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
        rating: 5.0,
      ),
      const PromoTestimonial(
        id: 'testimonial_3',
        quote: 'Os gráficos de peso ajudaram a monitorar a dieta do meu pet. O aplicativo é completo e muito fácil de usar.',
        author: 'Marina Costa',
        role: 'Tutora de Bulldog',
        imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
        rating: 5.0,
      ),
    ];
  }

  static List<PromoFAQItem> getFAQItems() {
    return [
      const PromoFAQItem(
        id: 'faq_1',
        question: 'O aplicativo é gratuito?',
        answer: 'Sim, o PetiVeti possui uma versão gratuita com recursos essenciais. Também oferecemos uma versão premium com funcionalidades avançadas.',
        category: FAQCategory.billing,
        order: 1,
      ),
      const PromoFAQItem(
        id: 'faq_2',
        question: 'Posso cadastrar mais de um animal?',
        answer: 'Sim! Você pode cadastrar todos os seus pets no aplicativo e gerenciar as informações de cada um separadamente.',
        category: FAQCategory.features,
        order: 2,
      ),
      const PromoFAQItem(
        id: 'faq_3',
        question: 'Os dados ficam salvos se eu trocar de celular?',
        answer: 'Sim, utilizamos tecnologia de sincronização em nuvem para garantir que seus dados estejam seguros e acessíveis em qualquer dispositivo.',
        category: FAQCategory.technical,
        order: 3,
      ),
      const PromoFAQItem(
        id: 'faq_4',
        question: 'O app funciona offline?',
        answer: 'Sim, você pode usar a maioria das funcionalidades offline. Os dados serão sincronizados quando você reconectar à internet.',
        category: FAQCategory.technical,
        order: 4,
      ),
      const PromoFAQItem(
        id: 'faq_5',
        question: 'Como funciona o sistema de notificações?',
        answer: 'O PetiVeti envia lembretes personalizáveis para vacinas, medicamentos, consultas e outros eventos importantes relacionados ao seu pet.',
        category: FAQCategory.features,
        order: 5,
      ),
    ];
  }

  static List<PromoScreenshot> getScreenshots() {
    return [
      const PromoScreenshot(
        id: 'screenshot_1',
        url: 'https://via.placeholder.com/300x600/6A1B9A/FFFFFF?text=Dashboard',
        title: 'Dashboard',
        description: 'Visão geral dos seus pets',
        order: 1,
      ),
      const PromoScreenshot(
        id: 'screenshot_2',
        url: 'https://via.placeholder.com/300x600/6A1B9A/FFFFFF?text=Vacinas',
        title: 'Vacinas',
        description: 'Controle de vacinação',
        order: 2,
      ),
      const PromoScreenshot(
        id: 'screenshot_3',
        url: 'https://via.placeholder.com/300x600/6A1B9A/FFFFFF?text=Medicamentos',
        title: 'Medicamentos',
        description: 'Gerenciamento de medicamentos',
        order: 3,
      ),
      const PromoScreenshot(
        id: 'screenshot_4',
        url: 'https://via.placeholder.com/300x600/6A1B9A/FFFFFF?text=PerfildoPet',
        title: 'Perfil do Pet',
        description: 'Informações completas do pet',
        order: 4,
      ),
      const PromoScreenshot(
        id: 'screenshot_5',
        url: 'https://via.placeholder.com/300x600/6A1B9A/FFFFFF?text=Consultas',
        title: 'Consultas',
        description: 'Histórico de consultas',
        order: 5,
      ),
    ];
  }

  static PromoFeature? getFeatureById(String id) {
    try {
      return getFeatures().firstWhere((feature) => feature.id == id);
    } catch (e) {
      return null;
    }
  }

  static PromoTestimonial? getTestimonialById(String id) {
    try {
      return getTestimonials().firstWhere((testimonial) => testimonial.id == id);
    } catch (e) {
      return null;
    }
  }

  static PromoFAQItem? getFAQItemById(String id) {
    try {
      return getFAQItems().firstWhere((faq) => faq.id == id);
    } catch (e) {
      return null;
    }
  }

  static PromoScreenshot? getScreenshotById(String id) {
    try {
      return getScreenshots().firstWhere((screenshot) => screenshot.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<PromoFeature> getFeaturesHighlighted() {
    return getFeatures().where((feature) => feature.isHighlight).toList();
  }

  static List<PromoFAQItem> getFAQItemsSorted() {
    final items = getFAQItems();
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  static List<PromoScreenshot> getScreenshotsSorted() {
    final screenshots = getScreenshots();
    screenshots.sort((a, b) => a.order.compareTo(b.order));
    return screenshots;
  }

  static Map<String, dynamic> getContentStatistics() {
    return {
      'totalFeatures': getFeatures().length,
      'totalTestimonials': getTestimonials().length,
      'totalFAQItems': getFAQItems().length,
      'totalScreenshots': getScreenshots().length,
      'highlightedFeatures': getFeaturesHighlighted().length,
      'averageRating': getTestimonials()
          .map((t) => t.rating)
          .reduce((a, b) => a + b) / getTestimonials().length,
    };
  }
}

// Main content classes for PromoController
class PromoContent {
  final HeroContent heroContent;
  final FeaturesContent featuresContent;
  final ScreenshotsContent screenshotsContent;
  final TestimonialsContent testimonialsContent;
  final DownloadContent downloadContent;
  final FAQContent faqContent;
  final FooterContent footerContent;

  const PromoContent({
    required this.heroContent,
    required this.featuresContent,
    required this.screenshotsContent,
    required this.testimonialsContent,
    required this.downloadContent,
    required this.faqContent,
    required this.footerContent,
  });
}

class HeroContent {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final List<String> highlights;

  const HeroContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.highlights,
  });
}

class FeaturesContent {
  final String title;
  final String subtitle;
  final List<PromoFeature> features;

  const FeaturesContent({
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class ScreenshotsContent {
  final String title;
  final String subtitle;
  final List<PromoScreenshot> screenshots;

  const ScreenshotsContent({
    required this.title,
    required this.subtitle,
    required this.screenshots,
  });
}

class TestimonialsContent {
  final String title;
  final String subtitle;
  final List<PromoTestimonial> testimonials;

  const TestimonialsContent({
    required this.title,
    required this.subtitle,
    required this.testimonials,
  });
}

class DownloadContent {
  final String prelaunchTitle;
  final String prelaunchSubtitle;
  final String launchedTitle;
  final String launchedSubtitle;
  final List<String> highlights;
  final List<String> storeFeatures;

  const DownloadContent({
    required this.prelaunchTitle,
    required this.prelaunchSubtitle,
    required this.launchedTitle,
    required this.launchedSubtitle,
    required this.highlights,
    required this.storeFeatures,
  });
}

class FAQContent {
  final String title;
  final String subtitle;
  final List<PromoFAQItem> faqs;

  const FAQContent({
    required this.title,
    required this.subtitle,
    required this.faqs,
  });
}

class FooterContent {
  final String appName;
  final String tagline;
  final String description;
  final String appVersion;
  final String copyright;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final List<String> quickLinks;
  final List<String> socialLinks;
  final List<String> legalLinks;

  const FooterContent({
    required this.appName,
    required this.tagline,
    required this.description,
    required this.appVersion,
    required this.copyright,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.quickLinks,
    required this.socialLinks,
    required this.legalLinks,
  });
}
