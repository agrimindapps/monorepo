import 'package:flutter/material.dart';

/// Service responsible for providing promo page content
/// Follows SRP by handling only content data

class PromoContentService {
  /// Get features list for carousel
  List<PromoFeature> getFeaturesList() {
    return [
      PromoFeature(
        icon: Icons.local_gas_station,
        title: 'Controle de Abastecimento',
        description:
            'Registre cada abastecimento e acompanhe o consumo do seu veículo com precisão.',
      ),
      PromoFeature(
        icon: Icons.build,
        title: 'Manutenções',
        description:
            'Mantenha um histórico completo das manutenções preventivas e corretivas.',
      ),
      PromoFeature(
        icon: Icons.analytics,
        title: 'Relatórios Detalhados',
        description:
            'Visualize gráficos e estatísticas sobre gastos, consumo e performance.',
      ),
      PromoFeature(
        icon: Icons.notifications,
        title: 'Lembretes Inteligentes',
        description:
            'Receba notificações para manutenções programadas e revisões importantes.',
      ),
      PromoFeature(
        icon: Icons.monetization_on,
        title: 'Controle de Gastos',
        description:
            'Acompanhe seus gastos com combustível e manutenção mês a mês.',
      ),
      PromoFeature(
        icon: Icons.cloud_sync,
        title: 'Sincronização em Nuvem',
        description:
            'Seus dados seguros e acessíveis em todos os seus dispositivos.',
      ),
    ];
  }

  /// Get testimonials
  List<Testimonial> getTestimonials() {
    return [
      Testimonial(
        name: 'João Silva',
        role: 'Motorista de Aplicativo',
        comment:
            'O GasOMeter transformou a forma como gerencio meu veículo. Economizei muito com o controle preciso!',
        rating: 5,
        avatarColor: Colors.blue,
      ),
      Testimonial(
        name: 'Maria Santos',
        role: 'Gestora de Frota',
        comment:
            'Perfeito para gerenciar nossa frota. Relatórios detalhados e fácil de usar.',
        rating: 5,
        avatarColor: Colors.purple,
      ),
      Testimonial(
        name: 'Carlos Oliveira',
        role: 'Proprietário',
        comment:
            'Nunca mais esqueci de fazer revisão. Os lembretes são muito úteis!',
        rating: 5,
        avatarColor: Colors.green,
      ),
    ];
  }

  /// Get FAQ items
  List<FaqItem> getFaqItems() {
    return [
      FaqItem(
        question: 'O GasOMeter é gratuito?',
        answer:
            'Sim! O GasOMeter oferece uma versão gratuita completa. Também temos um plano Premium com recursos avançados.',
      ),
      FaqItem(
        question: 'Meus dados ficam seguros?',
        answer:
            'Absolutamente! Utilizamos criptografia de ponta a ponta e seus dados são armazenados com segurança no Firebase.',
      ),
      FaqItem(
        question: 'Posso usar em vários dispositivos?',
        answer:
            'Sim! Com a sincronização em nuvem, você pode acessar seus dados de qualquer dispositivo.',
      ),
      FaqItem(
        question: 'Como funciona o controle de manutenções?',
        answer:
            'Você registra cada manutenção e o app te avisa quando é hora de fazer revisões com base na quilometragem ou tempo.',
      ),
      FaqItem(
        question: 'Posso exportar meus dados?',
        answer:
            'Sim! Você pode exportar todos os seus dados em formato CSV para análise em planilhas.',
      ),
    ];
  }

  /// Get statistics
  PromoStatistics getStatistics() {
    return PromoStatistics(
      activeUsers: '10.000+',
      vehiclesRegistered: '15.000+',
      fuelingsTracked: '500.000+',
      averageRating: 4.8,
    );
  }

  /// Get how it works steps
  List<HowItWorksStep> getHowItWorksSteps() {
    return [
      HowItWorksStep(
        step: 1,
        title: 'Crie sua Conta',
        description: 'Cadastre-se gratuitamente em menos de 1 minuto.',
        icon: Icons.person_add,
      ),
      HowItWorksStep(
        step: 2,
        title: 'Adicione seu Veículo',
        description: 'Informe os dados básicos do seu carro, moto ou caminhão.',
        icon: Icons.directions_car,
      ),
      HowItWorksStep(
        step: 3,
        title: 'Registre Abastecimentos',
        description: 'Anote cada vez que abastecer e veja o consumo médio.',
        icon: Icons.local_gas_station,
      ),
      HowItWorksStep(
        step: 4,
        title: 'Acompanhe Relatórios',
        description: 'Visualize gráficos e estatísticas sobre seu veículo.',
        icon: Icons.analytics,
      ),
    ];
  }

  /// Get app download links
  AppDownloadLinks getDownloadLinks() {
    return AppDownloadLinks(
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.agrimind.gasometer',
      appStoreUrl: 'https://apps.apple.com/app/gasometer/id123456789',
      webAppUrl: 'https://gasometer.app',
    );
  }

  /// Get contact information
  ContactInfo getContactInfo() {
    return ContactInfo(
      email: 'contato@gasometer.app',
      supportEmail: 'suporte@gasometer.app',
      phone: '+55 11 1234-5678',
      address: 'São Paulo, SP - Brasil',
    );
  }

  /// Get social media links
  SocialMediaLinks getSocialMediaLinks() {
    return SocialMediaLinks(
      facebook: 'https://facebook.com/gasometer',
      instagram: 'https://instagram.com/gasometer',
      twitter: 'https://twitter.com/gasometer',
      linkedin: 'https://linkedin.com/company/gasometer',
    );
  }

  /// Get legal links
  LegalLinks getLegalLinks() {
    return LegalLinks(
      privacyPolicyUrl: '/privacy-policy',
      termsConditionsUrl: '/terms-conditions',
      accountDeletionUrl: '/account-deletion',
    );
  }
}

// Models

class PromoFeature {
  final IconData icon;
  final String title;
  final String description;

  PromoFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class Testimonial {
  final String name;
  final String role;
  final String comment;
  final int rating;
  final Color avatarColor;

  Testimonial({
    required this.name,
    required this.role,
    required this.comment,
    required this.rating,
    required this.avatarColor,
  });
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class PromoStatistics {
  final String activeUsers;
  final String vehiclesRegistered;
  final String fuelingsTracked;
  final double averageRating;

  PromoStatistics({
    required this.activeUsers,
    required this.vehiclesRegistered,
    required this.fuelingsTracked,
    required this.averageRating,
  });
}

class HowItWorksStep {
  final int step;
  final String title;
  final String description;
  final IconData icon;

  HowItWorksStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class AppDownloadLinks {
  final String playStoreUrl;
  final String appStoreUrl;
  final String webAppUrl;

  AppDownloadLinks({
    required this.playStoreUrl,
    required this.appStoreUrl,
    required this.webAppUrl,
  });
}

class ContactInfo {
  final String email;
  final String supportEmail;
  final String phone;
  final String address;

  ContactInfo({
    required this.email,
    required this.supportEmail,
    required this.phone,
    required this.address,
  });
}

class SocialMediaLinks {
  final String facebook;
  final String instagram;
  final String twitter;
  final String linkedin;

  SocialMediaLinks({
    required this.facebook,
    required this.instagram,
    required this.twitter,
    required this.linkedin,
  });
}

class LegalLinks {
  final String privacyPolicyUrl;
  final String termsConditionsUrl;
  final String accountDeletionUrl;

  LegalLinks({
    required this.privacyPolicyUrl,
    required this.termsConditionsUrl,
    required this.accountDeletionUrl,
  });
}
