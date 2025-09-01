import 'package:flutter/foundation.dart';

/// Centralized configuration for app-wide URLs and external links
/// Provides environment-specific configurations and link validation
class AppConfig {
  AppConfig._();

  // Environment detection
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  
  /// Legal and Policy URLs
  static const String _privacyPolicyUrl = 'https://plantis.app/privacy';
  static const String _termsOfServiceUrl = 'https://plantis.app/terms';
  static const String _cookiePolicyUrl = 'https://plantis.app/cookies';
  
  /// Support and Contact URLs
  static const String _supportEmailUrl = 'mailto:suporte@plantis.app';
  static const String _contactFormUrl = 'https://plantis.app/contact';
  static const String _helpCenterUrl = 'https://help.plantis.app';
  
  /// Social Media URLs
  static const String _instagramUrl = 'https://instagram.com/plantisapp';
  static const String _twitterUrl = 'https://twitter.com/plantisapp';
  static const String _facebookUrl = 'https://facebook.com/plantisapp';
  
  /// Store URLs
  static const String _appStoreUrl = 'https://apps.apple.com/app/plantis/id123456789';
  static const String _googlePlayUrl = 'https://play.google.com/store/apps/details?id=com.plantis.app';
  static const String _webAppUrl = 'https://app.plantis.app';
  
  /// Premium and Subscription Management URLs
  static const String _manageSubscriptionAppleUrl = 'https://apps.apple.com/account/subscriptions';
  static const String _manageSubscriptionGoogleUrl = 'https://play.google.com/store/account/subscriptions';
  static const String _subscriptionHelpUrl = 'https://help.plantis.app/subscription';
  
  /// Development URLs (for testing)
  static const String _devPrivacyPolicyUrl = 'https://dev.plantis.app/privacy';
  static const String _devTermsOfServiceUrl = 'https://dev.plantis.app/terms';
  static const String _devSupportEmailUrl = 'mailto:dev-support@plantis.app';
  
  /// Getters for Legal URLs
  static String get privacyPolicyUrl => isProduction ? _privacyPolicyUrl : _devPrivacyPolicyUrl;
  static String get termsOfServiceUrl => isProduction ? _termsOfServiceUrl : _devTermsOfServiceUrl;
  static String get cookiePolicyUrl => _cookiePolicyUrl;
  
  /// Getters for Support URLs
  static String get supportEmailUrl => isProduction ? _supportEmailUrl : _devSupportEmailUrl;
  static String get contactFormUrl => _contactFormUrl;
  static String get helpCenterUrl => _helpCenterUrl;
  
  /// Getters for Social Media URLs
  static String get instagramUrl => _instagramUrl;
  static String get twitterUrl => _twitterUrl;
  static String get facebookUrl => _facebookUrl;
  
  /// Getters for Store URLs
  static String get appStoreUrl => _appStoreUrl;
  static String get googlePlayUrl => _googlePlayUrl;
  static String get webAppUrl => _webAppUrl;
  
  /// Getters for Subscription Management URLs
  static String get manageSubscriptionAppleUrl => _manageSubscriptionAppleUrl;
  static String get manageSubscriptionGoogleUrl => _manageSubscriptionGoogleUrl;
  static String get subscriptionHelpUrl => _subscriptionHelpUrl;
  
  /// Premium Configuration
  static const Map<String, dynamic> premiumConfig = {
    'features': [
      {
        'id': 'unlimited_plants',
        'title': 'Plantas Ilimitadas',
        'description': 'Adicione quantas plantas quiser ao seu jardim',
        'icon': 'all_inclusive',
        'enabled': true,
      },
      {
        'id': 'advanced_reminders',
        'title': 'Lembretes Avançados',
        'description': 'Configure lembretes personalizados para cada planta',
        'icon': 'notifications_active',
        'enabled': true,
      },
      {
        'id': 'detailed_analytics',
        'title': 'Análises Detalhadas',
        'description': 'Acompanhe o crescimento e saúde das suas plantas',
        'icon': 'analytics',
        'enabled': true,
      },
      {
        'id': 'cloud_backup',
        'title': 'Backup na Nuvem',
        'description': 'Seus dados sempre seguros e sincronizados',
        'icon': 'cloud_sync',
        'enabled': true,
      },
      {
        'id': 'plant_identification',
        'title': 'Identificação de Plantas',
        'description': 'Use a câmera para identificar espécies',
        'icon': 'photo_camera',
        'enabled': false, // Feature coming soon
      },
      {
        'id': 'disease_diagnosis',
        'title': 'Diagnóstico de Doenças',
        'description': 'Identifique e trate problemas rapidamente',
        'icon': 'medical_services',
        'enabled': false, // Feature coming soon
      },
      {
        'id': 'custom_themes',
        'title': 'Temas Personalizados',
        'description': 'Personalize a aparência do aplicativo',
        'icon': 'palette',
        'enabled': true,
      },
      {
        'id': 'data_export',
        'title': 'Exportar Dados',
        'description': 'Exporte informações das suas plantas',
        'icon': 'download',
        'enabled': true,
      },
    ],
    'plans': [
      {
        'id': 'monthly',
        'name': 'Mensal',
        'popular': false,
        'discount': null,
      },
      {
        'id': 'annual',
        'name': 'Anual',
        'popular': true,
        'discount': 'Economize 20%',
      },
    ],
  };
  
  /// FAQ Configuration
  static const List<Map<String, String>> faqItems = [
    {
      'question': 'Posso cancelar a qualquer momento?',
      'answer': 'Sim! Você pode cancelar sua assinatura a qualquer momento nas configurações da App Store ou Google Play.',
    },
    {
      'question': 'O que acontece quando cancelo?',
      'answer': 'Você continuará tendo acesso ao Premium até o fim do período pago. Após isso, voltará ao plano gratuito.',
    },
    {
      'question': 'Posso trocar de plano?',
      'answer': 'Sim, você pode mudar entre mensal e anual a qualquer momento. O valor será ajustado proporcionalmente.',
    },
    {
      'question': 'Funciona em múltiplos dispositivos?',
      'answer': 'Sim! Sua assinatura funciona em todos os dispositivos conectados à mesma conta.',
    },
    {
      'question': 'Como posso obter suporte?',
      'answer': 'Entre em contato através do aplicativo (Menu > Configurações > Suporte) ou envie um email para suporte@plantis.app.',
    },
  ];
  
  /// URL Validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https') || uri.isScheme('mailto'));
    } catch (e) {
      return false;
    }
  }
  
  /// Check if URL is external (not within the app domain)
  static bool isExternalUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return !uri.host.contains('plantis.app') && uri.hasScheme;
    } catch (e) {
      return true; // Assume external if parsing fails
    }
  }
  
  /// Get environment-specific configuration
  static Map<String, String> get environmentUrls => {
    'privacy_policy': privacyPolicyUrl,
    'terms_of_service': termsOfServiceUrl,
    'support_email': supportEmailUrl,
    'contact_form': contactFormUrl,
    'help_center': helpCenterUrl,
  };
  
  /// App Metadata
  static const String appName = 'Plantis';
  static const String appDescription = 'Aplicativo para cuidado de plantas domésticas';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Plantis Team';
  static const String copyrightText = '© 2024 Plantis Team. Todos os direitos reservados.';
}